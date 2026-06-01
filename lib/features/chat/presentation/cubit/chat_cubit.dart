import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../../notification/data/services/fcm_service.dart';
import '../../../notification/data/services/local_notification_service.dart';
import '../../../notification/domain/entities/notification.dart';
import '../../../notification/domain/repo/notification_repo.dart';
import '../../data/chat_repo_impl.dart';
import '../../domain/chat_repo.dart';
import '../../domain/message_entity.dart';
import 'chat_states.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo repo;
  final NotificationRepo notificationRepo;

  StreamSubscription? _messagesSubscription;
  String? _activeChatUserId;
  String? _lastKnownLatestId;

  final Map<String, int> _pendingCount = {};
  Timer? _notifDebounce;

  ChatCubit(this.repo, this.notificationRepo) : super(ChatInitial());

  // ─────────────────────────────────────────────────────────────────
  // PRESENCE
  // ─────────────────────────────────────────────────────────────────
  Future<void> setOnlineStatus(bool isOnline) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<bool> watchOnlineStatus(String otherUserId) => FirebaseFirestore
      .instance
      .collection('users')
      .doc(otherUserId)
      .snapshots()
      .map((s) => s.data()?['isOnline'] == true);

  // ─────────────────────────────────────────────────────────────────
  // ACTIVE CHAT
  // ─────────────────────────────────────────────────────────────────
  void setActiveChat(String otherUserId) {
    _activeChatUserId = otherUserId;
    _pendingCount.remove(otherUserId);
    _notifDebounce?.cancel();
  }

  void clearActiveChat() {
    _activeChatUserId = null;
    _lastKnownLatestId = null;
  }

  // ─────────────────────────────────────────────────────────────────
  // LOAD MESSAGES
  //
  // Every time the stream fires on the RECEIVER's device:
  //   1. markMessagesAsDelivered() → flips delivered false→true
  //      This is what upgrades the SENDER's single tick to double grey.
  //   2. If chat is open: markMessagesAsSeen() → sets seenAt
  //      This upgrades double grey to double white on sender's side.
  // ─────────────────────────────────────────────────────────────────
  void loadMessages(String otherUserId) {
    emit(ChatLoading());
    _messagesSubscription?.cancel();
    _lastKnownLatestId = null;

    _messagesSubscription = repo.getMessages(otherUserId).listen((messages) {
      emit(ChatLoaded(messages));

      final uid = FirebaseAuth.instance.currentUser?.uid;

      // Step 1: Mark incoming messages as delivered (single → double grey)
      // Always runs when stream fires — receiver's device has the messages now
      repo.markMessagesAsDelivered(otherUserId);

      // Step 2: If chat is open, also mark as seen (double grey → double white)
      if (_activeChatUserId == otherUserId && messages.isNotEmpty) {
        repo.markMessagesAsSeen(otherUserId);
      }

      // Detect new incoming message for local notification
      if (messages.isNotEmpty) {
        final latest = messages.last;
        final isNew =
            latest.id != null &&
            latest.id != _lastKnownLatestId &&
            latest.senderId == otherUserId &&
            latest.receiverId == uid;

        if (isNew) {
          _lastKnownLatestId = latest.id;
          if (_activeChatUserId != otherUserId) {
            _queueNotification(
              senderId: otherUserId,
              senderName: latest.senderName,
              preview:
                  latest.type == 'image'
                      ? '📷 Photo'
                      : latest.type == 'request'
                      ? '💸 Money request'
                      : latest.message ?? '',
            );
          }
        }
      }
    }, onError: (e) => emit(ChatError(e.toString())));

    // Run both immediately on open (for any pre-existing undelivered/unseen msgs)
    repo.markMessagesAsDelivered(otherUserId);
    repo.markMessagesAsSeen(otherUserId);
  }

  // ─────────────────────────────────────────────────────────────────
  // NOTIFICATION QUEUE (debounced 1.5s)
  // ─────────────────────────────────────────────────────────────────
  void _queueNotification({
    required String senderId,
    required String senderName,
    required String preview,
  }) {
    _pendingCount[senderId] = (_pendingCount[senderId] ?? 0) + 1;
    _notifDebounce?.cancel();
    _notifDebounce = Timer(const Duration(milliseconds: 1500), () {
      final count = _pendingCount.remove(senderId) ?? 1;
      LocalNotificationService.instance().showNotification(
        senderName,
        count == 1 ? preview : '$count new messages',
        null,
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // FCM PUSH
  // ─────────────────────────────────────────────────────────────────
  Future<void> _fcmPush({
    required String token,
    required String title,
    required String body,
    required String type,
  }) async {
    if (token.isEmpty) return;
    try {
      final accessToken = await getAccessToken();
      const projectId = 'flowpay-856f7';
      final res = await http.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {'title': title, 'body': body},
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'type': type,
            },
          },
        }),
      );
      if (res.statusCode != 200) print('FCM push failed: ${res.body}');
    } catch (_) {}
  }

  Future<Map<String, dynamic>> _receiverInfo(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return doc.data() ?? {};
    } catch (_) {
      return {};
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // SEND TEXT
  // ─────────────────────────────────────────────────────────────────
  Future<void> sendTextMessage(String receiverId, String text) async {
    final user = FirebaseAuth.instance.currentUser!;

    await repo.sendMessage(
      MessageModel(
        senderId: user.uid,
        senderEmail: user.email ?? '',
        senderName: user.displayName ?? 'Unknown',
        receiverId: receiverId,
        type: 'text',
        message: text,
        timestamp: DateTime.now(),
        delivered: false, // ← single tick until receiver loads
      ),
    );
    await _updateRoom(receiverId, text, 'text');

    _notifyReceiverIfOffline(
      receiverId: receiverId,
      senderName: user.displayName ?? 'Someone',
      title: user.displayName ?? 'New message',
      body: text,
      type: 'chat',
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // SEND IMAGE
  // ─────────────────────────────────────────────────────────────────
  Future<void> sendImageMessage(String receiverId, File file) async {
    final user = FirebaseAuth.instance.currentUser!;
    final imageUrl = await repo.uploadChatImage(file);

    await repo.sendMessage(
      MessageModel(
        senderId: user.uid,
        senderEmail: user.email ?? '',
        senderName: user.displayName ?? 'Unknown',
        receiverId: receiverId,
        type: 'image',
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
        delivered: false,
      ),
    );
    await _updateRoom(receiverId, '📷 Photo', 'image');

    _notifyReceiverIfOffline(
      receiverId: receiverId,
      senderName: user.displayName ?? 'Someone',
      title: user.displayName ?? 'New message',
      body: '📷 Sent you a photo',
      type: 'chat',
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // NOTIFY RECEIVER IF OFFLINE (fire-and-forget)
  // ─────────────────────────────────────────────────────────────────
  Future<void> _notifyReceiverIfOffline({
    required String receiverId,
    required String senderName,
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      final info = await _receiverInfo(receiverId);
      final isOnline = info['isOnline'] == true;
      final token = (info['fcmToken'] as String?) ?? '';
      if (!isOnline && token.isNotEmpty) {
        await _fcmPush(token: token, title: title, body: body, type: type);
      }
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────────
  // EDIT MESSAGE
  // ─────────────────────────────────────────────────────────────────
  Future<void> editMessage({
    required String receiverId,
    required String messageId,
    required String newText,
  }) async {
    await repo.updateMessageFields(receiverId, messageId, {
      'message': newText,
      'edited': true,
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // DELETE MESSAGE
  // ─────────────────────────────────────────────────────────────────
  Future<void> deleteMessage({
    required String receiverId,
    required String messageId,
  }) async {
    await repo.deleteMessage(receiverId, messageId);
  }

  // ─────────────────────────────────────────────────────────────────
  // SEND REQUEST MONEY
  // ─────────────────────────────────────────────────────────────────
  Future<void> sendRequestMessage({
    required String receiverId,
    required double amount,
    required String purpose,
    required DateTime returnTime,
    required String note,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;

    final senderDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final senderName = senderDoc.data()?['name'] ?? 'Unknown';

    await repo.sendMessage(
      MessageModel(
        senderId: user.uid,
        senderEmail: user.email ?? '',
        senderName: senderName,
        receiverId: receiverId,
        type: 'request',
        requestAmount: amount,
        requestPurpose: purpose,
        returnTime: returnTime,
        requestStatus: 'pending',
        message: note,
        timestamp: DateTime.now(),
        delivered: false,
      ),
    );
    await _updateRoom(receiverId, '💸 Rs $amount request', 'request');

    await LocalNotificationService.instance().showNotification(
      'Request Sent',
      'You requested Rs $amount',
      null,
    );

    await notificationRepo.createNotification(
      Notifications(
        notificationId:
            FirebaseFirestore.instance.collection('notifications').doc().id,
        userId: receiverId,
        title: 'Money Request',
        message: '$senderName requested Rs $amount from you',
        dateTime: DateTime.now(),
        type: 'request_sent',
        isRead: false,
      ),
    );

    _notifyReceiverIfOffline(
      receiverId: receiverId,
      senderName: senderName,
      title: 'Money Request',
      body: '$senderName requested Rs $amount from you',
      type: 'payment',
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // UPDATE REQUEST STATUS
  // ─────────────────────────────────────────────────────────────────
  Future<void> updateRequestStatus({
    required String otherUserId,
    required String messageId,
    required String status,
    required int amount,
  }) async {
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    await repo.updateMessageFields(otherUserId, messageId, {
      'requestStatus': status,
    });

    if (status != 'accepted' && status != 'rejected') return;

    final isAccepted = status == 'accepted';
    final myInfo = await _receiverInfo(myUid);
    final myName = myInfo['name'] ?? 'User';

    final requesterInfo = await _receiverInfo(otherUserId);
    final requesterName = requesterInfo['name'] ?? 'User';
    final requesterToken = (requesterInfo['fcmToken'] as String?) ?? '';
    final requesterOnline = requesterInfo['isOnline'] == true;

    await LocalNotificationService.instance().showNotification(
      'Request ${isAccepted ? 'Accepted' : 'Rejected'}',
      'You ${isAccepted ? 'accepted' : 'rejected'} '
          '$requesterName\'s request of Rs $amount',
      null,
    );

    await notificationRepo.createNotification(
      Notifications(
        notificationId:
            FirebaseFirestore.instance.collection('notifications').doc().id,
        userId: otherUserId,
        title: 'Request ${isAccepted ? 'Accepted' : 'Rejected'}',
        message:
            '$myName ${isAccepted ? 'accepted' : 'rejected'} '
            'your request of Rs $amount',
        dateTime: DateTime.now(),
        type: isAccepted ? 'request_accepted' : 'request_rejected',
        isRead: false,
      ),
    );

    if (!requesterOnline && requesterToken.isNotEmpty) {
      await _fcmPush(
        token: requesterToken,
        title: 'Request ${isAccepted ? 'Accepted' : 'Rejected'}',
        body:
            '$myName ${isAccepted ? 'accepted' : 'rejected'} '
            'your request of Rs $amount',
        type: 'payment',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // HELPER
  // ─────────────────────────────────────────────────────────────────
  Future<void> _updateRoom(
    String receiverId,
    String lastMessage,
    String type,
  ) async {
    if (repo is ChatRepoImpl) {
      await (repo as ChatRepoImpl).updateRoomSummary(
        otherUserId: receiverId,
        lastMessage: lastMessage,
        lastMessageType: type,
      );
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _notifDebounce?.cancel();
    return super.close();
  }
}
