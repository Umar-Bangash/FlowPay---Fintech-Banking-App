import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String? id;
  final String senderId;
  final String senderEmail;
  final String senderName;
  final String receiverId;
  final String type; // "text" | "image" | "request"
  final String? message;
  final String? imageUrl;

  // Request fields
  final double? requestAmount;
  final String? requestPurpose;
  final DateTime? returnTime;
  final String? requestStatus; // "pending" | "accepted" | "rejected"

  final DateTime timestamp;

  // Read receipts
  // delivered = true the instant the message lands in Firestore
  // seenAt    = set when the receiver opens the chat (markMessagesAsSeen)
  final bool delivered;
  final DateTime? seenAt;

  // Edit flag — shown as "edited" label under the message text
  final bool? edited;

  MessageModel({
    this.id,
    required this.senderId,
    required this.senderEmail,
    required this.senderName,
    required this.receiverId,
    required this.type,
    this.message,
    this.imageUrl,
    this.requestAmount,
    this.requestPurpose,
    this.returnTime,
    this.requestStatus,
    required this.timestamp,
    this.delivered = false,
    this.seenAt,
    this.edited,
  });

  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'senderEmail': senderEmail,
    'senderName': senderName,
    'receiverId': receiverId,
    'type': type,
    'message': message,
    'imageUrl': imageUrl,
    'requestAmount': requestAmount,
    'requestPurpose': requestPurpose,
    'returnTime': returnTime != null ? Timestamp.fromDate(returnTime!) : null,
    'requestStatus': requestStatus,
    'timestamp': Timestamp.fromDate(timestamp),
    'delivered': delivered,
    'seenAt': seenAt != null ? Timestamp.fromDate(seenAt!) : null,
    'edited': edited ?? false,
  };

  factory MessageModel.fromJson(Map<String, dynamic> json, String docId) =>
      MessageModel(
        id: docId,
        senderId: json['senderId'] ?? '',
        senderEmail: json['senderEmail'] ?? '',
        senderName: json['senderName'] ?? '',
        receiverId: json['receiverId'] ?? '',
        type: json['type'] ?? 'text',
        message: json['message'],
        imageUrl: json['imageUrl'],
        requestAmount: (json['requestAmount'] as num?)?.toDouble(),
        requestPurpose: json['requestPurpose'],
        returnTime:
            json['returnTime'] != null
                ? (json['returnTime'] as Timestamp).toDate()
                : null,
        requestStatus: json['requestStatus'],
        timestamp: (json['timestamp'] as Timestamp).toDate(),
        delivered: json['delivered'] ?? false,
        seenAt:
            json['seenAt'] != null
                ? (json['seenAt'] as Timestamp).toDate()
                : null,
        edited: json['edited'] ?? false,
      );

  MessageModel copyWith({
    String? requestStatus,
    bool? delivered,
    DateTime? seenAt,
    bool? edited,
    String? message,
  }) => MessageModel(
    id: id,
    senderId: senderId,
    senderEmail: senderEmail,
    senderName: senderName,
    receiverId: receiverId,
    type: type,
    message: message ?? this.message,
    imageUrl: imageUrl,
    requestAmount: requestAmount,
    requestPurpose: requestPurpose,
    returnTime: returnTime,
    requestStatus: requestStatus ?? this.requestStatus,
    timestamp: timestamp,
    delivered: delivered ?? this.delivered,
    seenAt: seenAt ?? this.seenAt,
    edited: edited ?? this.edited,
  );
}
