import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../notification/data/services/local_notification_service.dart';
import '../../../notification/domain/entities/notification.dart';
import '../../../notification/domain/repo/notification_repo.dart';
import '../../domain/chat_repo.dart';
import '../../domain/message_entity.dart';
import 'chat_states.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo repo;
  final NotificationRepo notificationRepo;

  StreamSubscription? _messagesSubscription;

  ChatCubit(this.repo, this.notificationRepo) : super(ChatInitial());

  // ───────────────────────── LOAD MESSAGES ─────────────────────────
  void loadMessages(String otherUserId) {
    emit(ChatLoading());
    _messagesSubscription?.cancel();
    _messagesSubscription = repo
        .getMessages(otherUserId)
        .listen(
          (messages) => emit(ChatLoaded(messages)),
          onError: (e) => emit(ChatError(e.toString())),
        );
  }

  // ───────────────────────── SEND TEXT MESSAGE ─────────────────────────
  Future<void> sendTextMessage(String receiverId, String text) async {
    final user = FirebaseAuth.instance.currentUser!;
    final message = MessageModel(
      senderId: user.uid,
      senderEmail: user.email ?? '',
      senderName: user.displayName ?? 'Unknown',
      receiverId: receiverId,
      type: "text",
      message: text,
      timestamp: DateTime.now(),
    );
    await repo.sendMessage(message);
  }

  // ───────────────────────── SEND IMAGE MESSAGE ─────────────────────────
  Future<void> sendImageMessage(String receiverId, File file) async {
    final user = FirebaseAuth.instance.currentUser!;
    final imageUrl = await repo.uploadChatImage(file);
    final message = MessageModel(
      senderId: user.uid,
      senderEmail: user.email ?? '',
      senderName: user.displayName ?? 'Unknown',
      receiverId: receiverId,
      type: "image",
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
    );
    await repo.sendMessage(message);
  }

  // ───────────────────────── SEND REQUEST MONEY MESSAGE ─────────────────────────
  Future<void> sendRequestMessage({
    required String receiverId,
    required double amount,
    required String purpose,
    required DateTime returnTime,
    required String note,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final senderName = userDoc.data()?['name'] ?? 'Unknown';

    final message = MessageModel(
      senderId: user.uid,
      senderEmail: user.email ?? '',
      senderName: senderName,
      receiverId: receiverId,
      type: "request",
      requestAmount: amount,
      requestPurpose: purpose,
      returnTime: returnTime,
      requestStatus: "pending",
      message: note,
      timestamp: DateTime.now(),
    );

    await repo.sendMessage(message);

    // Firestore notification
    final notification = Notifications(
      notificationId:
          FirebaseFirestore.instance.collection('notifications').doc().id,
      userId: receiverId,
      title: "Money Request",
      message: "$senderName requested Rs $amount",
      dateTime: DateTime.now(),
      type: "request_sent",
      isRead: false,
    );

    await notificationRepo.createNotification(notification);

    // Local banner
    LocalNotificationService.instance().showNotification(
      notification.title,
      notification.message,
      null,
    );
  }

  // ───────────────────────── UPDATE REQUEST STATUS ─────────────────────────
  Future<void> updateRequestStatus({
    required String otherUserId,
    required String messageId,
    required String status,
    required int amount,
  }) async {
    await repo.updateMessageFields(otherUserId, messageId, {
      'requestStatus': status,
    });

    if (status == "accepted" || status == "rejected") {
      final notification = Notifications(
        notificationId:
            FirebaseFirestore.instance.collection('notifications').doc().id,
        userId: otherUserId,
        title: status == "accepted" ? "Request Accepted" : "Request Rejected",
        message: "Your request of Rs $amount was $status",
        dateTime: DateTime.now(),
        type: status == "accepted" ? "request_accepted" : "request_rejected",
        isRead: false,
      );

      await notificationRepo.createNotification(notification);

      // Local banner
      LocalNotificationService.instance().showNotification(
        notification.title,
        notification.message,
        null,
      );
    }
  }

  // ───────────────────────── DELETE MESSAGE ─────────────────────────
  Future<void> deleteMessage({
    required String receiverId,
    required String messageId,
  }) async {
    await repo.deleteMessage(receiverId, messageId);
  }

  // ───────────────────────── CLEANUP ─────────────────────────
  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
