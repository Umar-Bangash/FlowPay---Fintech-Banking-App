import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String? id; // Firestore document ID

  final String senderId;
  final String senderEmail;
  final String senderName;
  final String receiverId;
  final String type; // "text" | "image" | "request"

  final String? message; // for text
  final String? imageUrl; // for image

  // Request fields
  final double? requestAmount;
  final String? requestPurpose;
  final DateTime? returnTime;
  final String? requestStatus; // "pending" | "accepted" | "rejected"

  final DateTime timestamp;

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
  });

  // convert message -> json to store in DB

  Map<String, dynamic> toJson() {
    return {
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
    };
  }

  // convert json -> message to use in app

  factory MessageModel.fromJson(Map<String, dynamic> json, String docId) {
    return MessageModel(
      id: docId,
      senderId: json['senderId'],
      senderEmail: json['senderEmail'],
      senderName: json['senderName'],
      receiverId: json['receiverId'],
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
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';

// class MessageModel {
//   final String senderId;
//   final String senderEmail;
//   final String receiverId;
//   final String message;
//   final String? imageUrl;
//   final DateTime timestamp;

//   MessageModel({
//     required this.senderId,
//     required this.senderEmail,
//     required this.receiverId,
//     required this.message,
//     this.imageUrl,
//     required this.timestamp,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'senderId': senderId,
//       'senderEmail': senderEmail,
//       'receiverId': receiverId,
//       'message': message,
//       'imageUrl': imageUrl,
//       'timestamp': Timestamp.fromDate(timestamp),
//     };
//   }

//   factory MessageModel.fromJson(Map<String, dynamic> json) {
//     return MessageModel(
//       senderId: json['senderId'],
//       senderEmail: json['senderEmail'],
//       receiverId: json['receiverId'],
//       message: json['message'],
//       imageUrl: json['imageUrl'],
//       timestamp: (json['timestamp'] as Timestamp).toDate(),
//     );
//   }
// }
