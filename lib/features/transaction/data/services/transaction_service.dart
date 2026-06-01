import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/notification/domain/entities/notification.dart';
import 'package:flowpay/features/notification/domain/repo/notification_repo.dart';
import 'package:flowpay/features/notification/data/services/fcm_service.dart';
import 'package:flowpay/features/notification/data/services/local_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationRepo notificationRepo;

  TransactionService(this.notificationRepo);

  // ─────────────────────────────────────────────
  // CHECK notification flag before firing
  // ─────────────────────────────────────────────
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
        case 'system':
          return data['systemNotifEnabled'] ?? false;
        default:
          return true;
      }
    } catch (e) {
      return true;
    }
  }

  // ─────────────────────────────────────────────
  // PUSH notification helper (FCM — goes to a specific device token)
  // This is the ONLY way to reach the receiver's device.
  // Never call LocalNotificationService for the receiver — that runs
  // on whoever is executing the code (i.e. the sender's phone).
  // ─────────────────────────────────────────────
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

      final message = {
        'message': {
          'token': token,
          'notification': {'title': title, 'body': body},
          'data': {'click_action': 'FLUTTER_NOTIFICATION_CLICK', 'type': type},
        },
      };

      final response = await http.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        debugPrint('Push sent: $title - $body');
      } else {
        debugPrint('FCM push failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending push: $e');
    }
  }

  // ─────────────────────────────────────────────
  // MAIN TRANSFER
  // ─────────────────────────────────────────────
  Future<void> transferMoney({
    required String senderUid,
    required String receiverUid,
    required double amount,
  }) async {
    final batch = _firestore.batch();

    // ── Get sender account ──
    final senderQuery =
        await _firestore
            .collection('accounts')
            .where('userId', isEqualTo: senderUid)
            .limit(1)
            .get();
    if (senderQuery.docs.isEmpty) throw Exception('Sender account not found');
    final senderSnap = senderQuery.docs.first;
    final senderRef = senderSnap.reference;
    final senderData = senderSnap.data();

    // ── Get receiver account ──
    final receiverQuery =
        await _firestore
            .collection('accounts')
            .where('userId', isEqualTo: receiverUid)
            .limit(1)
            .get();
    if (receiverQuery.docs.isEmpty) {
      throw Exception('Receiver account not found');
    }
    final receiverSnap = receiverQuery.docs.first;
    final receiverRef = receiverSnap.reference;
    final receiverData = receiverSnap.data();

    // ── Get user info + FCM tokens ──
    final senderUserSnap =
        await _firestore.collection('users').doc(senderUid).get();
    final receiverUserSnap =
        await _firestore.collection('users').doc(receiverUid).get();

    final senderName = senderUserSnap.data()?['name'] ?? 'You';
    final receiverName = receiverUserSnap.data()?['name'] ?? 'Receiver';
    final senderToken = senderUserSnap.data()?['fcmToken'] ?? '';
    final receiverToken = receiverUserSnap.data()?['fcmToken'] ?? '';

    // ── Check balance ──
    final senderBalance = (senderData['balance'] as num).toDouble();
    if (senderBalance < amount) throw Exception('Insufficient balance');

    // ── Update balances ──
    batch.update(senderRef, {'balance': senderBalance - amount});
    batch.update(receiverRef, {
      'balance': (receiverData['balance'] as num).toDouble() + amount,
    });

    // ── Create transaction docs ──
    final transactionId = _firestore.collection('transactions').doc().id;

    batch.set(
      _firestore.collection('transactions').doc('${transactionId}_sender'),
      {
        'transactionId': transactionId,
        'accountId': senderSnap.id,
        'userId': senderUid,
        'receiverId': receiverUid,
        'type': 'debit',
        'amount': amount,
        'dateTime': DateTime.now().toIso8601String(),
        'description': receiverName,
      },
    );

    batch.set(
      _firestore.collection('transactions').doc('${transactionId}_receiver'),
      {
        'transactionId': transactionId,
        'accountId': receiverSnap.id,
        'userId': receiverUid,
        'receiverId': senderUid,
        'type': 'credit',
        'amount': amount,
        'dateTime': DateTime.now().toIso8601String(),
        'description': senderName,
      },
    );

    await batch.commit();

    // ─────────────────────────────────────────────
    // NOTIFICATIONS
    //
    // KEY RULE:
    //   LocalNotificationService  → runs on the CURRENT device (sender's phone only)
    //   FCM _sendPushMessage       → delivered to a SPECIFIC device by token
    //
    //   Sender  → Firestore record + local popup + FCM to sender token
    //   Receiver → Firestore record + FCM to receiver token (NO local here)
    // ─────────────────────────────────────────────
    final senderNotifEnabled = await _isNotificationEnabled(
      senderUid,
      'payment',
    );
    final receiverNotifEnabled = await _isNotificationEnabled(
      receiverUid,
      'payment',
    );

    // ── SENDER notifications (all run on sender's device — correct) ──
    if (senderNotifEnabled) {
      const senderTitle = 'Money Sent';
      final senderBody =
          'You sent Rs: ${amount.toStringAsFixed(2)} to $receiverName';

      // 1. Firestore in-app record for sender
      await notificationRepo.createNotification(
        Notifications(
          notificationId: '${DateTime.now().millisecondsSinceEpoch}_sender',
          userId: senderUid,
          title: senderTitle,
          message: senderBody,
          dateTime: DateTime.now(),
          type: 'payment',
          isRead: false,
        ),
      );

      // 2. Local popup — shows on THIS device (sender's phone)
      await LocalNotificationService.instance().showNotification(
        senderTitle,
        senderBody,
        null,
      );

      // 3. FCM push to sender's own token (handles background/terminated state)
      if (senderToken.isNotEmpty) {
        await _sendPushMessage(
          token: senderToken,
          title: senderTitle,
          body: senderBody,
          type: 'payment',
        );
      }
    } else {
      debugPrint('Sender payment notification blocked by user preference');
    }

    if (receiverNotifEnabled) {
      const receiverTitle = 'Money Received';
      final receiverBody =
          'You got Rs: ${amount.toStringAsFixed(2)} from $senderName';

      // 1. Firestore in-app record for receiver
      await notificationRepo.createNotification(
        Notifications(
          notificationId: '${DateTime.now().millisecondsSinceEpoch}_receiver',
          userId: receiverUid,
          title: receiverTitle,
          message: receiverBody,
          dateTime: DateTime.now(),
          type: 'payment',
          isRead: false,
        ),
      );

      // 2. FCM push to receiver's device token
      //    NO LocalNotificationService call here — that would fire on the sender's phone
      if (receiverToken.isNotEmpty) {
        await _sendPushMessage(
          token: receiverToken,
          title: receiverTitle,
          body: receiverBody,
          type: 'payment',
        );
      }
    } else {
      debugPrint('Receiver payment notification blocked by user preference');
    }

    debugPrint('Transaction completed successfully!');
  }
}
