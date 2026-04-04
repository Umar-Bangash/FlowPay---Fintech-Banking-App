import 'package:cloud_firestore/cloud_firestore.dart';

class Notifications {
  final String notificationId;
  final String userId;
  final String title;
  final String message;
  final DateTime dateTime;
  final String type;
  final bool isRead;

  Notifications({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.type,
    this.isRead = false,
  });

  Notifications copyWith({bool? isRead}) {
    return Notifications(
      notificationId: notificationId,
      userId: userId,
      title: title,
      message: message,
      dateTime: dateTime,
      type: type,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'message': message,
      'dateTime': Timestamp.fromDate(dateTime),
      'type': type,
      'isRead': isRead,
    };
  }

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      notificationId: json['notificationId'],
      userId: json['userId'],
      title: json['title'],
      message: json['message'],
      dateTime:
          (json['dateTime'] as dynamic) is Timestamp
              ? (json['dateTime'] as Timestamp).toDate()
              : DateTime.parse(json['dateTime']),
      type: json['type'],
      isRead: json['isRead'] ?? false,
    );
  }
}
