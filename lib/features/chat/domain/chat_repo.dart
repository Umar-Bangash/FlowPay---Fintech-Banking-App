import 'dart:io';
import 'message_entity.dart';

abstract class ChatRepo {
  Stream<List<MessageModel>> getMessages(String otherUserId);

  Future<void> sendMessage(MessageModel message);

  Future<void> deleteMessage(String receiverId, String messageId);

  Future<void> updateMessageFields(
    String receiverId,
    String messageId,
    Map<String, dynamic> data,
  );

  Future<String> uploadChatImage(File file);
}

// import 'dart:io';
// import 'message_entity.dart';

// abstract class ChatRepo {
//   Stream<List<MessageModel>> getMessages(String otherUserId);
//   Future<void> sendMessage(MessageModel message);
//   Future<void> deleteMessage(String receiverId, String messageId);
//   Future<void> updateMessage(
//     String receiverId,
//     String messageId,
//     String newMessage,
//   );
//   Future<String> uploadChatImage(File file);
// }
