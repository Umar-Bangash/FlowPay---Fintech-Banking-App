import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/auth/domain/entities/app_user.dart';
import 'package:flowpay/features/notification/data/repo/notification_repo_impl.dart';
import 'package:flowpay/features/notification/data/services/fcm_sender.dart';
import 'package:flowpay/features/notification/domain/entities/notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/entities/qr_access_request.dart';
import '../domain/entities/qr_access_token.dart';
import '../domain/entities/qr_transaction.dart';
import '../domain/repo/qr_repo.dart';

class QrRepoImpl implements QrRepo {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  QrRepoImpl({required this.firestore, required this.auth});

  @override
  Future<AppUser?> getReceiverById(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return AppUser.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch receiver: $e');
    }
  }

  @override
  Future<void> payViaQr(QrTransaction transaction) async {
    try {
      final senderRef = firestore.collection('users').doc(transaction.senderId);
      final receiverRef = firestore
          .collection('users')
          .doc(transaction.receiverId);
      final trxRef = firestore.collection('qr_transactions').doc();

      await firestore.runTransaction((trx) async {
        final senderSnap = await trx.get(senderRef);
        final receiverSnap = await trx.get(receiverRef);

        double senderBalance =
            (senderSnap.data()!['balance'] as num).toDouble();
        double receiverBalance =
            (receiverSnap.data()!['balance'] as num).toDouble();

        if (senderBalance < transaction.amount) {
          throw Exception('Insufficient balance');
        }

        trx.update(senderRef, {'balance': senderBalance - transaction.amount});
        trx.update(receiverRef, {
          'balance': receiverBalance + transaction.amount,
        });
        trx.set(trxRef, transaction.toJson());
      });
    } catch (e) {
      throw Exception('QR Payment failed: $e');
    }
  }

  @override
  Future<QrTransaction?> getTransaction(String transactionId) async {
    try {
      final doc =
          await firestore
              .collection('qr_transactions')
              .doc(transactionId)
              .get();
      if (!doc.exists) return null;
      return QrTransaction.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get transaction: $e');
    }
  }

  // ─────────────────────────────────────────────
  // SEND ACCESS REQUEST
  // Runs on B's device after scanning
  // Must notify A (owner) — via FCM only
  // FCM delivers to A's device
  // A's FirebaseMessagingService shows local notification
  // ─────────────────────────────────────────────
  @override
  Future<QrAccessRequest> sendAccessRequest({
    required String requesterId,
    required String requesterName,
    required String ownerId,
  }) async {
    try {
      debugPrint('sendAccessRequest ownerId=$ownerId requesterId=$requesterId');

      final ownerDoc = await firestore.collection('users').doc(ownerId).get();

      debugPrint('ownerDoc.exists=${ownerDoc.exists}');

      if (!ownerDoc.exists) {
        throw Exception('Owner not found');
      }

      final ownerEmail = ownerDoc.data()?['email'] as String? ?? '';
      final ownerName = ownerDoc.data()?['name'] as String? ?? 'Account Owner';

      final requestRef = firestore.collection('qr_access_requests').doc();
      final requestId = requestRef.id;

      final request = QrAccessRequest(
        requestId: requestId,
        requesterId: requesterId,
        ownerId: ownerId,
        ownerEmail: ownerEmail,
        ownerName: ownerName,
        requesterName: requesterName,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await requestRef.set(request.toJson());

      // ── In-app notification stored for owner (A) ──
      final ownerNotifRef = firestore.collection('notifications').doc();
      await NotificationRepoImpl().createNotification(
        Notifications(
          notificationId: ownerNotifRef.id,
          userId: ownerId, // ← stored for A
          title: 'Account Access Request',
          message:
              '$requesterName wants to access your account. Tap to Accept or Reject.',
          dateTime: DateTime.now(),
          type: 'qr_access_request',
          isRead: false,
          data: {'requestId': requestId, 'requesterName': requesterName},
        ),
      );

      // ── FCM push to A's device ──
      // When A's device receives this:
      // → if foreground: FirebaseMessagingService._handleMessage()
      //   calls LocalNotificationService on A's device ✅
      // → if background/terminated: iOS/Android shows it natively ✅
      await FcmSender.sendToUser(
        uid: ownerId, // ← sends to A
        title: 'Account Access Request',
        body:
            '$requesterName wants to access your account. Open FlowPay to Accept or Reject.',
        data: {
          'type': 'qr_access_request',
          'requestId': requestId,
          'screen': '/notifications',
        },
      );

      // ── NO LocalNotificationService call here ──
      // This code runs on B's device
      // B should NOT see "someone wants to access your account"

      return request;
    } catch (e) {
      throw Exception('Failed to send access request: $e');
    }
  }

  // ─────────────────────────────────────────────
  // RESPOND TO ACCESS REQUEST
  // Runs on A's device after Accept/Reject
  // Must notify B (requester) — via FCM only
  // FCM delivers to B's device
  // B's FirebaseMessagingService shows local notification
  // ─────────────────────────────────────────────
  @override
  Future<void> respondToAccessRequest({
    required String requestId,
    required String status,
  }) async {
    try {
      final updateData = <String, dynamic>{'status': status};

      // ── If accepting — write temp credentials ──
      if (status == 'accepted') {
        final storedPassword = await _secureStorage.read(key: 'password');
        final storedEmail = await _secureStorage.read(key: 'email');

        debugPrint(
          'Owner stored email=$storedEmail hasPassword=${storedPassword != null}',
        );

        if (storedPassword != null && storedPassword.isNotEmpty) {
          updateData['tempPassword'] = storedPassword;
          updateData['tempEmail'] = storedEmail ?? '';
          updateData['tempExpiresAt'] = Timestamp.fromDate(
            DateTime.now().add(const Duration(minutes: 2)),
          );
        }
      }

      await firestore
          .collection('qr_access_requests')
          .doc(requestId)
          .update(updateData);

      final doc =
          await firestore.collection('qr_access_requests').doc(requestId).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final requesterId = data['requesterId'] as String;
      final ownerId = data['ownerId'] as String;

      final ownerDoc = await firestore.collection('users').doc(ownerId).get();
      final ownerName =
          ownerDoc.data()?['name'] as String? ?? 'The account owner';

      final isAccepted = status == 'accepted';

      // ── In-app notification stored for B (requester) ──
      final notifRef = firestore.collection('notifications').doc();
      await NotificationRepoImpl().createNotification(
        Notifications(
          notificationId: notifRef.id,
          userId: requesterId, // ← stored for B
          title: isAccepted ? 'Access Granted' : 'Access Denied',
          message:
              isAccepted
                  ? '$ownerName approved your access request.'
                  : '$ownerName declined your access request.',
          dateTime: DateTime.now(),
          type: isAccepted ? 'qr_access_accepted' : 'qr_access_rejected',
          isRead: false,
          data: {'requestId': requestId},
        ),
      );

      // ── FCM push to B's device ──
      // When B's device receives this:
      // → if foreground: FirebaseMessagingService._handleMessage()
      //   calls LocalNotificationService on B's device ✅
      // → if background/terminated: iOS/Android shows it natively ✅
      await FcmSender.sendToUser(
        uid: requesterId, // ← sends to B
        title: isAccepted ? 'Access Granted' : 'Access Denied',
        body:
            isAccepted
                ? '$ownerName approved your access request.'
                : '$ownerName declined your access request.',
        data: {
          'type': isAccepted ? 'qr_access_accepted' : 'qr_access_rejected',
          'requestId': requestId,
        },
      );

      // ── NO LocalNotificationService call here ──
      // This code runs on A's device
      // A should NOT see "Access Granted/Denied" on their own phone
      // No owner confirmation notification either — removed as requested
    } catch (e) {
      throw Exception('Failed to respond to access request: $e');
    }
  }

  @override
  Stream<QrAccessRequest?> watchAccessRequest(String requestId) {
    return firestore
        .collection('qr_access_requests')
        .doc(requestId)
        .snapshots()
        .map((snap) {
          if (!snap.exists) return null;
          return QrAccessRequest.fromJson(snap.data()!);
        });
  }

  @override
  Future<QrAccessToken> generateAccessToken(String ownerUid) async {
    try {
      final tokenRef = firestore.collection('qr_access_tokens').doc();
      final token = QrAccessToken(
        tokenId: tokenRef.id,
        ownerUid: ownerUid,
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        used: false,
      );
      await tokenRef.set(token.toJson());
      return token;
    } catch (e) {
      throw Exception('Failed to generate access token: $e');
    }
  }

  @override
  Future<QrAccessToken?> validateAndConsumeToken(String tokenId) async {
    try {
      final tokenRef = firestore.collection('qr_access_tokens').doc(tokenId);
      QrAccessToken? result;

      await firestore.runTransaction((trx) async {
        final snap = await trx.get(tokenRef);
        if (!snap.exists) {
          result = null;
          return;
        }
        final token = QrAccessToken.fromJson(snap.data()!);
        if (!token.isValid) {
          result = null;
          return;
        }
        trx.update(tokenRef, {'used': true});
        result = token;
      });

      return result;
    } catch (e) {
      throw Exception('Failed to validate token: $e');
    }
  }
}
