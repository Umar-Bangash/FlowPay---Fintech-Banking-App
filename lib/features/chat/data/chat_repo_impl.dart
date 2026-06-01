import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/chat_repo.dart';
import '../domain/message_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TICK LOGIC (WhatsApp-accurate)
//
//  delivered=false, seenAt=null  → single grey tick
//    • Message written to Firestore but receiver is offline / hasn't loaded yet
//
//  delivered=true,  seenAt=null  → double grey tick
//    • Receiver's device stream fired (markMessagesAsDelivered ran)
//
//  delivered=true,  seenAt≠null  → double white tick
//    • Receiver opened the chat (markMessagesAsSeen ran)
//
// WHO calls what:
//   sendMessage()              → sets delivered=false  (sender's device)
//   markMessagesAsDelivered()  → sets delivered=true   (receiver's device, on stream load)
//   markMessagesAsSeen()       → sets seenAt           (receiver's device, on chat open)
// ─────────────────────────────────────────────────────────────────────────────

class ChatRepoImpl implements ChatRepo {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final SupabaseClient supabase = Supabase.instance.client;

  final Map<String, _RoomCache> _roomCache = {};

  ChatRepoImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : firestore = firestore ?? FirebaseFirestore.instance,
      auth = auth ?? FirebaseAuth.instance;

  String get _uid => auth.currentUser!.uid;

  String _roomId(String otherUserId) {
    final ids = [_uid, otherUserId]..sort();
    return ids.join('_');
  }

  DocumentReference _roomDoc(String otherUserId) =>
      firestore.collection('chat_room').doc(_roomId(otherUserId));

  CollectionReference _messagesCol(String otherUserId) =>
      _roomDoc(otherUserId).collection('messages');

  // ── GET MESSAGES ─────────────────────────────────────────────────────────────
  @override
  Stream<List<MessageModel>> getMessages(String otherUserId) {
    return _messagesCol(otherUserId)
        .orderBy('timestamp')
        .snapshots()
        .map(
          (s) =>
              s.docs
                  .map(
                    (d) => MessageModel.fromJson(
                      d.data() as Map<String, dynamic>,
                      d.id,
                    ),
                  )
                  .toList(),
        );
  }

  // ── SEND MESSAGE ─────────────────────────────────────────────────────────────
  // Always writes delivered=false.
  // The receiver's markMessagesAsDelivered() flips it to true when they load.
  @override
  Future<void> sendMessage(MessageModel message) async {
    final json = message.toJson();
    json['delivered'] = false; // ← single tick until receiver loads
    await _messagesCol(message.receiverId).add(json);
  }

  // ── DELETE MESSAGE ────────────────────────────────────────────────────────────
  @override
  Future<void> deleteMessage(String receiverId, String messageId) async {
    await _messagesCol(receiverId).doc(messageId).delete();
  }

  // ── UPDATE FIELDS ─────────────────────────────────────────────────────────────
  @override
  Future<void> updateMessageFields(
    String receiverId,
    String messageId,
    Map<String, dynamic> data,
  ) async {
    await _messagesCol(receiverId).doc(messageId).update(data);
  }

  // ── MARK AS DELIVERED ─────────────────────────────────────────────────────────
  // Called on the RECEIVER'S device when their getMessages() stream fires.
  // Finds all messages sent TO _uid with delivered=false and batch-flips them.
  // This is the moment the SENDER's single tick becomes a double grey tick.
  @override
  Future<void> markMessagesAsDelivered(String otherUserId) async {
    try {
      final snap =
          await _messagesCol(otherUserId)
              .where('receiverId', isEqualTo: _uid)
              .where('delivered', isEqualTo: false)
              .get();

      if (snap.docs.isEmpty) return;

      final batch = firestore.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'delivered': true});
      }
      await batch.commit();
    } catch (_) {
      // Never crash the stream
    }
  }

  // ── MARK AS SEEN ──────────────────────────────────────────────────────────────
  // Called on the RECEIVER'S device when they open the chat.
  // Sets seenAt — triggers double grey → double white on sender's side.
  // Also ensures delivered=true (covers the edge case where delivery and open happen together).
  @override
  Future<void> markMessagesAsSeen(String otherUserId) async {
    try {
      final snap =
          await _messagesCol(
            otherUserId,
          ).where('senderId', isEqualTo: otherUserId).get();

      final unseen =
          snap.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['seenAt'] == null && data['receiverId'] == _uid;
          }).toList();

      if (unseen.isEmpty) return;

      final batch = firestore.batch();
      final now = Timestamp.fromDate(DateTime.now());
      for (final doc in unseen) {
        batch.update(doc.reference, {
          'seenAt': now,
          'delivered': true, // edge case: seen before delivered fired
        });
      }
      await batch.commit();
    } catch (_) {}
  }

  // ── GET CHAT ROOMS ────────────────────────────────────────────────────────────
  @override
  Stream<List<ChatRoomSummary>> getChatRooms() {
    return firestore
        .collection('chat_room')
        .where('participants', arrayContains: _uid)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .map((snap) {
          final summaries = <ChatRoomSummary>[];
          for (final doc in snap.docs) {
            final d = doc.data();
            final participants = List<String>.from(
              d['participants'] as List? ?? [],
            );
            final otherUserId = participants.firstWhere(
              (id) => id != _uid,
              orElse: () => '',
            );
            if (otherUserId.isEmpty) continue;
            summaries.add(
              ChatRoomSummary(
                otherUserId: otherUserId,
                lastMessage: d['lastMessage'] as String? ?? '',
                lastTimestamp:
                    (d['lastTimestamp'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
                lastMessageType: d['lastMessageType'] as String? ?? 'text',
              ),
            );
          }
          return summaries;
        });
  }

  // ── UPDATE ROOM SUMMARY ───────────────────────────────────────────────────────
  Future<void> updateRoomSummary({
    required String otherUserId,
    required String lastMessage,
    required String lastMessageType,
  }) async {
    final roomId = _roomId(otherUserId);
    final cache = _roomCache[roomId];
    if (cache != null &&
        cache.lastMessage == lastMessage &&
        cache.lastMessageType == lastMessageType) {
      return;
    }
    final now = Timestamp.fromDate(DateTime.now());
    await firestore.collection('chat_room').doc(roomId).set({
      'participants': [_uid, otherUserId],
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType,
      'lastTimestamp': now,
    }, SetOptions(merge: true));
    _roomCache[roomId] = _RoomCache(
      lastMessage: lastMessage,
      lastMessageType: lastMessageType,
    );
  }

  // ── IMAGE UPLOAD ──────────────────────────────────────────────────────────────
  @override
  Future<String> uploadChatImage(File file) async {
    final fileName = 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await supabase.storage
        .from('chat_images')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));
    return supabase.storage.from('chat_images').getPublicUrl(fileName);
  }

  String get currentUserId => _uid;
}

class _RoomCache {
  final String lastMessage;
  final String lastMessageType;
  const _RoomCache({required this.lastMessage, required this.lastMessageType});
}
