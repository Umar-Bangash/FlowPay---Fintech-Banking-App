import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/chat_repo.dart';
import '../domain/message_entity.dart';

class ChatRepoImpl implements ChatRepo {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final SupabaseClient supabase = Supabase.instance.client;

  ChatRepoImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : firestore = firestore ?? FirebaseFirestore.instance,
      auth = auth ?? FirebaseAuth.instance;

  // ───────────────────────── CHAT ROOM ID ─────────────────────────

  String _chatRoomId(String otherUserId) {
    final ids = [auth.currentUser!.uid, otherUserId]..sort();
    return ids.join('_');
  }

  // ───────────────────────── GET MESSAGES ─────────────────────────

  @override
  Stream<List<MessageModel>> getMessages(String otherUserId) {
    return firestore
        .collection('chat_room')
        .doc(_chatRoomId(otherUserId))
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => MessageModel.fromJson(doc.data(), doc.id))
                  .toList(),
        );
  }

  // ───────────────────────── SEND MESSAGE ─────────────────────────

  @override
  Future<void> sendMessage(MessageModel message) async {
    await firestore
        .collection('chat_room')
        .doc(_chatRoomId(message.receiverId))
        .collection('messages')
        .add(message.toJson());
  }

  // ───────────────────────── DELETE MESSAGE ─────────────────────────

  @override
  Future<void> deleteMessage(String receiverId, String messageId) async {
    await firestore
        .collection('chat_room')
        .doc(_chatRoomId(receiverId))
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  // ───────────────────────── UPDATE MESSAGE FIELDS ─────────────────────────

  @override
  Future<void> updateMessageFields(
    String receiverId,
    String messageId,
    Map<String, dynamic> data,
  ) async {
    await firestore
        .collection('chat_room')
        .doc(_chatRoomId(receiverId))
        .collection('messages')
        .doc(messageId)
        .update(data);
  }

  // ───────────────────────── IMAGE UPLOAD ─────────────────────────

  @override
  Future<String> uploadChatImage(File file) async {
    final fileName = 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from('chat_images')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

    return supabase.storage.from('chat_images').getPublicUrl(fileName);
  }

  String get currentUserId => auth.currentUser!.uid;
}

// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../domain/chat_repo.dart';
// import '../domain/message_entity.dart';

// class ChatRepoImpl implements ChatRepo {
//   final FirebaseFirestore firestore;
//   final FirebaseAuth auth;
//   final SupabaseClient supabase = Supabase.instance.client;

//   // Default constructor with default Firebase instances
//   ChatRepoImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
//     : firestore = firestore ?? FirebaseFirestore.instance,
//       auth = auth ?? FirebaseAuth.instance;

//   String _chatRoomId(String otherUserId) {
//     final ids = [auth.currentUser!.uid, otherUserId]..sort();
//     return ids.join('_');
//   }

//   @override
//   Stream<List<MessageModel>> getMessages(String otherUserId) {
//     return firestore
//         .collection('chat_room')
//         .doc(_chatRoomId(otherUserId))
//         .collection('messages')
//         .orderBy('timestamp')
//         .snapshots()
//         .map(
//           (snapshot) =>
//               snapshot.docs
//                   .map((doc) => MessageModel.fromJson(doc.data()))
//                   .toList(),
//         );
//   }

//   @override
//   Future<void> sendMessage(MessageModel message) async {
//     await firestore
//         .collection('chat_room')
//         .doc(_chatRoomId(message.receiverId))
//         .collection('messages')
//         .add(message.toJson());
//   }

//   @override
//   Future<void> deleteMessage(String receiverId, String messageId) async {
//     await firestore
//         .collection('chat_room')
//         .doc(_chatRoomId(receiverId))
//         .collection('messages')
//         .doc(messageId)
//         .delete();
//   }

//   @override
//   Future<void> updateMessage(
//     String receiverId,
//     String messageId,
//     String newMessage,
//   ) async {
//     await firestore
//         .collection('chat_room')
//         .doc(_chatRoomId(receiverId))
//         .collection('messages')
//         .doc(messageId)
//         .update({'message': newMessage});
//   }

//   @override
//   Future<String> uploadChatImage(File file) async {
//     final fileName = 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg';

//     await supabase.storage
//         .from('chat_images')
//         .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

//     return supabase.storage.from('chat_images').getPublicUrl(fileName);
//   }

//   // Optional helper to get current user ID easily
//   String get currentUserId => auth.currentUser!.uid;
// }
