import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/notification/domain/entities/notification.dart';
import 'package:flowpay/features/notification/domain/repo/notification_repo.dart';
import 'package:flowpay/features/notification/data/services/fcm_service.dart';
import 'package:flowpay/features/notification/data/services/local_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestMoneyNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationRepo notificationRepo;

  RequestMoneyNotificationService(this.notificationRepo);

  // HELPERS
  Future<bool> _isNotificationEnabled(String uid, String type) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return true;
      final data = doc.data()!;
      switch (type) {
        case 'payment':
          return data['paymentNotifEnabled'] ?? true;
        case 'chat':
          return data['chatNotifEnabled'] ?? true;
        default:
          return true;
      }
    } catch (_) {
      return true;
    }
  }

  Future<Map<String, String>> _getUserInfo(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      return {
        'name': data?['name'] ?? 'User',
        'fcmToken': data?['fcmToken'] ?? '',
      };
    } catch (_) {
      return {'name': 'User', 'fcmToken': ''};
    }
  }

  Future<void> _sendPushMessage({
    required String token,
    required String title,
    required String body,
    required String type,
  }) async {
    if (token.isEmpty) return;
    try {
      final accessToken = await getAccessToken();
      const projectId = 'flowpay-856f7';
      final response = await http.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {'title': title, 'body': body},
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'type': type,
            },
          },
        }),
      );
      if (response.statusCode == 200) {
        debugPrint('Push sent: $title');
      } else {
        debugPrint('FCM failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Push error: $e');
    }
  }

  Future<void> _saveToFirestore({
    required String userId,
    required String title,
    required String message,
    required String idSuffix,
  }) async {
    await notificationRepo.createNotification(
      Notifications(
        notificationId: '${DateTime.now().millisecondsSinceEpoch}_$idSuffix',
        userId: userId,
        title: title,
        message: message,
        dateTime: DateTime.now(),
        type: 'payment',
        isRead: false,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 1. REQUEST SENT
  //    Called by: requester's device
  //    Requester → local popup + Firestore + FCM to self (background safety)
  //    Receiver  → Firestore + FCM push (NO local — wrong device)
  // ─────────────────────────────────────────────
  Future<void> notifyRequestSent({
    required String requesterId,
    required String receiverId,
    required double amount,
  }) async {
    final requesterInfo = await _getUserInfo(requesterId);
    final receiverInfo = await _getUserInfo(receiverId);
    final requesterName = requesterInfo['name']!;
    final receiverName = receiverInfo['name']!;
    final requesterToken = requesterInfo['fcmToken']!;
    final receiverToken = receiverInfo['fcmToken']!;

    final requesterEnabled = await _isNotificationEnabled(
      requesterId,
      'payment',
    );
    final receiverEnabled = await _isNotificationEnabled(receiverId, 'payment');

    // ── Requester: "You requested Rs X from ReceiverName" ──
    if (requesterEnabled) {
      const title = 'Request Sent';
      final body =
          'You requested Rs: ${amount.toStringAsFixed(2)} from $receiverName';

      await _saveToFirestore(
        userId: requesterId,
        title: title,
        message: body,
        idSuffix: 'req_sent_requester',
      );

      // Local popup fires on requester's own device
      await LocalNotificationService.instance().showNotification(
        title,
        body,
        null,
      );

      if (requesterToken.isNotEmpty) {
        await _sendPushMessage(
          token: requesterToken,
          title: title,
          body: body,
          type: 'payment',
        );
      }
    }

    // ── Receiver: "RequesterName is requesting Rs X from you" ──
    if (receiverEnabled) {
      const title = 'Money Requested';
      final body =
          '$requesterName is requesting Rs: ${amount.toStringAsFixed(2)} from you';

      await _saveToFirestore(
        userId: receiverId,
        title: title,
        message: body,
        idSuffix: 'req_sent_receiver',
      );

      // NO LocalNotificationService here — would show on requester's screen
      if (receiverToken.isNotEmpty) {
        await _sendPushMessage(
          token: receiverToken,
          title: title,
          body: body,
          type: 'payment',
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  // 2. REQUEST ACCEPTED
  //    Called by: receiver's device (they tapped Accept)
  //    Receiver  → local popup + Firestore
  //    Requester → Firestore + FCM push (NO local — wrong device)
  // ─────────────────────────────────────────────
  Future<void> notifyRequestAccepted({
    required String requesterId,
    required String receiverId,
    required double amount,
  }) async {
    final requesterInfo = await _getUserInfo(requesterId);
    final receiverInfo = await _getUserInfo(receiverId);
    final requesterName = requesterInfo['name']!;
    final receiverName = receiverInfo['name']!;
    final requesterToken = requesterInfo['fcmToken']!;

    final requesterEnabled = await _isNotificationEnabled(
      requesterId,
      'payment',
    );
    final receiverEnabled = await _isNotificationEnabled(receiverId, 'payment');

    // ── Receiver (code is running here): "You accepted RequesterName's request" ──
    if (receiverEnabled) {
      const title = 'Request Accepted';
      final body =
          'You accepted $requesterName\'s request for Rs: ${amount.toStringAsFixed(2)}';

      await _saveToFirestore(
        userId: receiverId,
        title: title,
        message: body,
        idSuffix: 'req_accepted_receiver',
      );

      // Local popup fires on receiver's device (they are using the app now)
      await LocalNotificationService.instance().showNotification(
        title,
        body,
        null,
      );
    }

    // ── Requester: "ReceiverName accepted your request" ──
    if (requesterEnabled) {
      const title = 'Request Accepted';
      final body =
          '$receiverName accepted your request for Rs: ${amount.toStringAsFixed(2)}';

      await _saveToFirestore(
        userId: requesterId,
        title: title,
        message: body,
        idSuffix: 'req_accepted_requester',
      );

      // NO local here — receiver's device is running this code
      if (requesterToken.isNotEmpty) {
        await _sendPushMessage(
          token: requesterToken,
          title: title,
          body: body,
          type: 'payment',
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  // 3. REQUEST DECLINED
  //    Called by: receiver's device (they tapped Decline)
  //    Receiver  → local popup + Firestore
  //    Requester → Firestore + FCM push (NO local — wrong device)
  // ─────────────────────────────────────────────
  Future<void> notifyRequestDeclined({
    required String requesterId,
    required String receiverId,
    required double amount,
  }) async {
    final requesterInfo = await _getUserInfo(requesterId);
    final receiverInfo = await _getUserInfo(receiverId);
    final requesterName = requesterInfo['name']!;
    final receiverName = receiverInfo['name']!;
    final requesterToken = requesterInfo['fcmToken']!;

    final requesterEnabled = await _isNotificationEnabled(
      requesterId,
      'payment',
    );
    final receiverEnabled = await _isNotificationEnabled(receiverId, 'payment');

    // ── Receiver: "You declined RequesterName's request" ──
    if (receiverEnabled) {
      const title = 'Request Declined';
      final body =
          'You declined $requesterName\'s request for Rs: ${amount.toStringAsFixed(2)}';

      await _saveToFirestore(
        userId: receiverId,
        title: title,
        message: body,
        idSuffix: 'req_declined_receiver',
      );

      await LocalNotificationService.instance().showNotification(
        title,
        body,
        null,
      );
    }

    // ── Requester: "ReceiverName declined your request" ──
    if (requesterEnabled) {
      const title = 'Request Declined';
      final body =
          '$receiverName declined your request for Rs: ${amount.toStringAsFixed(2)}';

      await _saveToFirestore(
        userId: requesterId,
        title: title,
        message: body,
        idSuffix: 'req_declined_requester',
      );

      if (requesterToken.isNotEmpty) {
        await _sendPushMessage(
          token: requesterToken,
          title: title,
          body: body,
          type: 'payment',
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  // 4. REQUEST PAID
  //    Called by: payer's device (they tapped Pay)
  //    Payer     → local popup + Firestore
  //    Requester → Firestore + FCM push (NO local — wrong device)
  // ─────────────────────────────────────────────
  Future<void> notifyRequestPaid({
    required String requesterId,
    required String payerId,
    required double amount,
  }) async {
    final requesterInfo = await _getUserInfo(requesterId);
    final payerInfo = await _getUserInfo(payerId);
    final requesterName = requesterInfo['name']!;
    final payerName = payerInfo['name']!;
    final requesterToken = requesterInfo['fcmToken']!;

    final requesterEnabled = await _isNotificationEnabled(
      requesterId,
      'payment',
    );
    final payerEnabled = await _isNotificationEnabled(payerId, 'payment');

    // ── Payer (code is running here): "You paid RequesterName's request" ──
    if (payerEnabled) {
      const title = 'Payment Sent';
      final body =
          'You paid Rs: ${amount.toStringAsFixed(2)} to $requesterName';

      await _saveToFirestore(
        userId: payerId,
        title: title,
        message: body,
        idSuffix: 'req_paid_payer',
      );

      await LocalNotificationService.instance().showNotification(
        title,
        body,
        null,
      );
    }

    // ── Requester: "PayerName paid your request" ──
    if (requesterEnabled) {
      const title = 'Request Paid';
      final body =
          '$payerName paid your request of Rs: ${amount.toStringAsFixed(2)}';

      await _saveToFirestore(
        userId: requesterId,
        title: title,
        message: body,
        idSuffix: 'req_paid_requester',
      );

      if (requesterToken.isNotEmpty) {
        await _sendPushMessage(
          token: requesterToken,
          title: title,
          body: body,
          type: 'payment',
        );
      }
    }
  }
}
