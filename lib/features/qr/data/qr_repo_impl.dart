import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/auth/domain/entities/app_user.dart';

import '../domain/qr_repo.dart';
import '../domain/qr_transaction.dart';

class QrRepoImpl implements QrRepo {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  QrRepoImpl({required this.firestore, required this.auth});

  // get reciver after qr scan

  @override
  Future<AppUser?> getReceiverById(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;

      return AppUser.fromJson(data);
    } catch (e) {
      throw Exception("Failed to fetch receiver: $e");
    }
  }

  // process qr payment

  @override
  Future<void> payViaQr(QrTransaction transaction) async {
    try {
      final senderRef = firestore.collection('users').doc(transaction.senderId);

      final receiverRef = firestore
          .collection('users')
          .doc(transaction.receiverId);

      final trxRef = firestore.collection('qr_transactions').doc();

      await firestore.runTransaction((trx) async {
        final senderSnapshot = await trx.get(senderRef);
        final receiverSnapshot = await trx.get(receiverRef);

        final senderData = senderSnapshot.data()!;
        final receiverData = receiverSnapshot.data()!;

        double senderBalance = (senderData['balance'] as num).toDouble();

        double receiverBalance = (receiverData['balance'] as num).toDouble();

        if (senderBalance < transaction.amount) {
          throw Exception("Insufficient balance");
        }

        /// Deduct from sender
        trx.update(senderRef, {'balance': senderBalance - transaction.amount});

        /// Add to receiver
        trx.update(receiverRef, {
          'balance': receiverBalance + transaction.amount,
        });

        /// Save transaction
        trx.set(trxRef, transaction.toJson());
      });
    } catch (e) {
      throw Exception("QR Payment failed: $e");
    }
  }

  // get transaction detatil

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
      throw Exception("Failed to get transaction: $e");
    }
  }
}
