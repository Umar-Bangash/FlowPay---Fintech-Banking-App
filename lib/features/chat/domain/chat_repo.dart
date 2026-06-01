import 'dart:io';
import 'message_entity.dart';

class ChatRoomSummary {
  final String otherUserId;
  final String lastMessage;
  final DateTime lastTimestamp;
  final String lastMessageType;

  const ChatRoomSummary({
    required this.otherUserId,
    required this.lastMessage,
    required this.lastTimestamp,
    required this.lastMessageType,
  });
}

abstract class ChatRepo {
  Stream<List<MessageModel>> getMessages(String otherUserId);
  Future<void> sendMessage(MessageModel message);
  Future<void> deleteMessage(String receiverId, String messageId);
  Future<void> updateMessageFields(
    String receiverId,
    String messageId,
    Map<String, dynamic> data,
  );

  // Called by RECEIVER when their stream fires → flips delivered false→true
  // This is what upgrades the SENDER's single tick to double grey tick
  Future<void> markMessagesAsDelivered(String otherUserId);

  // Called by RECEIVER when they open the chat → sets seenAt
  // This upgrades double grey tick to double white tick on sender's side
  Future<void> markMessagesAsSeen(String otherUserId);

  Stream<List<ChatRoomSummary>> getChatRooms();
  Future<String> uploadChatImage(File file);
}
