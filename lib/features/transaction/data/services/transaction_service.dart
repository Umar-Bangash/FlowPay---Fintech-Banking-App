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
  // PUSH notification helper
  // ─────────────────────────────────────────────
  Future<void> _sendPushMessage({
    required String token,
    required String title,
    required String body,
    required String type, // 👈 added type
  }) async {
    if (token.isEmpty) return;
    try {
      final accessToken = await getAccessToken();
      const projectId = 'flowpay-856f7';

      final message = {
        'message': {
          'token': token,
          'notification': {'title': title, 'body': body},
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'type': type, // 👈 pass type so FCM handler can check flag
          },
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
    final transactionId = DateTime.now().millisecondsSinceEpoch.toString();

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
    batch.set(
      _firestore.collection('transactions').doc('${transactionId}_sender'),
      {
        'transactionId': transactionId,
        'accountId': senderSnap.id,
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
        'type': 'credit',
        'amount': amount,
        'dateTime': DateTime.now().toIso8601String(),
        'description': senderName,
      },
    );

    await batch.commit();

    // ─────────────────────────────────────────────
    // NOTIFICATIONS — check flag before firing
    // ─────────────────────────────────────────────
    final senderNotifEnabled = await _isNotificationEnabled(
      senderUid,
      'payment',
    );
    final receiverNotifEnabled = await _isNotificationEnabled(
      receiverUid,
      'payment',
    );

    // ── Firestore notifications (in-app) ──
    if (senderNotifEnabled) {
      await notificationRepo.createNotification(
        Notifications(
          notificationId: '${DateTime.now().millisecondsSinceEpoch}_sender',
          userId: senderUid,
          title: 'Money Sent',
          message: 'You sent Rs: ${amount.toStringAsFixed(2)} to $receiverName',
          dateTime: DateTime.now(),
          type: 'payment', // ✅ fixed from 'transaction'
          isRead: false,
        ),
      );

      // ── Local notification for sender ──
      await LocalNotificationService.instance().showNotification(
        'Money Sent',
        'You sent Rs: ${amount.toStringAsFixed(2)} to $receiverName',
        null,
      );

      // ── Push notification for sender ──
      if (senderToken.isNotEmpty) {
        await _sendPushMessage(
          token: senderToken,
          title: 'Money Sent',
          body: 'You sent Rs: ${amount.toStringAsFixed(2)} to $receiverName',
          type: 'payment', // ✅ type tagged
        );
      }
    } else {
      debugPrint('Sender payment notification blocked by user preference');
    }

    if (receiverNotifEnabled) {
      await notificationRepo.createNotification(
        Notifications(
          notificationId: '${DateTime.now().millisecondsSinceEpoch}_receiver',
          userId: receiverUid,
          title: 'Money Received',
          message: 'You got Rs: ${amount.toStringAsFixed(2)} from $senderName',
          dateTime: DateTime.now(),
          type: 'payment', // ✅ fixed
          isRead: false,
        ),
      );

      // ── Local notification for receiver ──
      await LocalNotificationService.instance().showNotification(
        'Money Received',
        'You got Rs: ${amount.toStringAsFixed(2)} from $senderName',
        null,
      );

      // ── Push notification for receiver ──
      if (receiverToken.isNotEmpty) {
        await _sendPushMessage(
          token: receiverToken,
          title: 'Money Received',
          body: 'You got Rs: ${amount.toStringAsFixed(2)} from $senderName',
          type: 'payment', // ✅ type tagged
        );
      }
    } else {
      debugPrint('Receiver payment notification blocked by user preference');
    }

    debugPrint('Transaction completed successfully!');
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flowpay/features/notification/domain/entities/notification.dart';
// import 'package:flowpay/features/notification/domain/repo/notification_repo.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flowpay/features/notification/data/services/fcm_service.dart';
// import 'package:flowpay/features/notification/data/services/local_notification_service.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class TransactionService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final NotificationRepo notificationRepo;

//   TransactionService(this.notificationRepo);

//   /// Push notification helper
//   Future<void> _sendPushMessage({
//     required String token,
//     required String title,
//     required String body,
//   }) async {
//     if (token.isEmpty) return;

//     try {
//       final accessToken =
//           await getAccessToken(); // Implement your access token logic
//       final projectId = "flowpay-856f7";

//       final message = {
//         "message": {
//           "token": token,
//           "notification": {"title": title, "body": body},
//           "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK"},
//         },
//       };

//       final response = await http.post(
//         Uri.parse(
//           "https://fcm.googleapis.com/v1/projects/$projectId/messages:send",
//         ),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $accessToken",
//         },
//         body: jsonEncode(message),
//       );

//       if (response.statusCode == 200) {
//         debugPrint("Push sent: $title - $body");
//       } else {
//         debugPrint("FCM push failed: ${response.body}");
//       }
//     } catch (e) {
//       debugPrint("Error sending push notification: $e");
//     }
//   }

//   /// Main transfer function
//   Future<void> transferMoney({
//     required String senderUid,
//     required String receiverUid,
//     required double amount,
//   }) async {
//     final batch = _firestore.batch();
//     final transactionId = DateTime.now().millisecondsSinceEpoch.toString();

//     // ----------- Get Sender Account -----------
//     final senderQuery =
//         await _firestore
//             .collection('accounts')
//             .where('userId', isEqualTo: senderUid)
//             .limit(1)
//             .get();

//     if (senderQuery.docs.isEmpty) throw Exception("Sender account not found");

//     final senderSnap = senderQuery.docs.first;
//     final senderRef = senderSnap.reference;
//     final senderData = senderSnap.data();

//     // ----------- Get Receiver Account -----------
//     final receiverQuery =
//         await _firestore
//             .collection('accounts')
//             .where('userId', isEqualTo: receiverUid)
//             .limit(1)
//             .get();

//     if (receiverQuery.docs.isEmpty) {
//       throw Exception("Receiver account not found");
//     }

//     final receiverSnap = receiverQuery.docs.first;
//     final receiverRef = receiverSnap.reference;
//     final receiverData = receiverSnap.data();

//     // ----------- Get User Info + FCM Token -----------
//     final senderUserSnap =
//         await _firestore.collection('users').doc(senderUid).get();
//     final receiverUserSnap =
//         await _firestore.collection('users').doc(receiverUid).get();

//     final senderName = senderUserSnap.data()?['name'] ?? "You";
//     final receiverName = receiverUserSnap.data()?['name'] ?? "Receiver";

//     final senderToken = senderUserSnap.data()?['fcmToken'] ?? "";
//     final receiverToken = receiverUserSnap.data()?['fcmToken'] ?? "";

//     // ----------- Check Sender Balance -----------
//     final senderBalance = (senderData['balance'] as num).toDouble();
//     if (senderBalance < amount) throw Exception("Insufficient balance");

//     // ----------- Update Balances -----------
//     batch.update(senderRef, {'balance': senderBalance - amount});
//     batch.update(receiverRef, {
//       'balance': (receiverData['balance'] as num).toDouble() + amount,
//     });

//     // ----------- Create Transaction Documents -----------
//     final senderTransactionRef = _firestore
//         .collection('transactions')
//         .doc('${transactionId}_sender');
//     final receiverTransactionRef = _firestore
//         .collection('transactions')
//         .doc('${transactionId}_receiver');

//     batch.set(senderTransactionRef, {
//       'transactionId': transactionId,
//       'accountId': senderSnap.id,
//       'type': 'debit',
//       'amount': amount,
//       'dateTime': DateTime.now().toIso8601String(),
//       'description': receiverName,
//     });

//     batch.set(receiverTransactionRef, {
//       'transactionId': transactionId,
//       'accountId': receiverSnap.id,
//       'type': 'credit',
//       'amount': amount,
//       'dateTime': DateTime.now().toIso8601String(),
//       'description': senderName,
//     });

//     // ----------- Commit Batch -----------
//     await batch.commit();

//     // ----------- Create Notifications thorug repo -----------
//     final notificationIdSender =
//         '${DateTime.now().millisecondsSinceEpoch}_sender';
//     final notificationIdReceiver =
//         '${DateTime.now().millisecondsSinceEpoch}_receiver';

//     // sender notification
//     await notificationRepo.createNotification(
//       Notifications(
//         notificationId: notificationIdSender,
//         userId: senderUid,
//         title: 'Money Sent',
//         message: 'You sent Rs: ${amount.toStringAsFixed(2)} to $receiverName',
//         dateTime: DateTime.now(),
//         type: 'transaction',
//         isRead: false,
//       ),
//     );
//     // reciver notification
//     await notificationRepo.createNotification(
//       Notifications(
//         notificationId: notificationIdReceiver,
//         userId: receiverUid,
//         title: 'Money Recived',
//         message: 'You got Rs: ${amount.toStringAsFixed(2)} from $receiverName',
//         dateTime: DateTime.now(),
//         type: 'transaction',
//         isRead: false,
//       ),
//     );

//     // ----------- Local Notifications -----------
//     LocalNotificationService.instance().showNotification(
//       "Money Sent",
//       "You sent Rs: ${amount.toStringAsFixed(2)} to $receiverName",
//       null,
//     );

//     LocalNotificationService.instance().showNotification(
//       "Money Received",
//       "You got Rs: ${amount.toStringAsFixed(2)} from $senderName",
//       null,
//     );

//     // ------------ Push Notifications -----------
//     if (senderToken.isNotEmpty) {
//       await _sendPushMessage(
//         token: senderToken,
//         title: "Money Sent",
//         body: "You sent Rs: ${amount.toStringAsFixed(2)} to $receiverName",
//       );
//     }

//     if (receiverToken.isNotEmpty) {
//       await _sendPushMessage(
//         token: receiverToken,
//         title: "Money Received",
//         body: "You got Rs: ${amount.toStringAsFixed(2)} from $senderName",
//       );
//     }

//     debugPrint("Transaction completed successfully!");
//   }
// }
