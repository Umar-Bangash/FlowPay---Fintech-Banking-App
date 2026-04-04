import 'package:flowpay/features/notification/domain/entities/notification.dart';

abstract class NotificationRepo {
  // create a new notification
  Future<void> createNotification(Notifications notification);
  // get all notification for login user
  Future<List<Notifications>> getNotification(String userId);
  // delete notification
  Future<void> deleteNotification(String notificationId);
  // mark single notification as read
  Future<void> markAsRead(String notificaionId);
  // mark all notification as read for login user
  Future<void> markAllAsRead(String userId);
  // get notification in UI as happens
  Stream<List<Notifications>> streamNotifications(String userId);
}
