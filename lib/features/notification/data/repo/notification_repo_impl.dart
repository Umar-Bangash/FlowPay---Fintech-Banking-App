import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/notification/domain/entities/notification.dart';
import 'package:flowpay/features/notification/domain/repo/notification_repo.dart';
import 'package:flutter/foundation.dart';

class NotificationRepoImpl extends NotificationRepo {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<void> createNotification(Notifications notification) async {
    try {
      await _firebaseFirestore
          .collection('notifications')
          .doc(notification.notificationId)
          .set(notification.toJson());
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firebaseFirestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete notification $e');
    }
  }

  @override
  Future<List<Notifications>> getNotification(String userId) async {
    try {
      final snapshot =
          await _firebaseFirestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .orderBy('dateTime', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => Notifications.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Failed to load notifications $e');
    }
  }

  // Corrected markAsRead
  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firebaseFirestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Fixed markAllAsRead (was reversed before)
  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot =
          await _firebaseFirestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      final batch = _firebaseFirestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all as read $e');
    }
  }

  @override
  Stream<List<Notifications>> streamNotifications(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Notifications.fromJson(doc.data()))
                  .toList(),
        );
  }
}
