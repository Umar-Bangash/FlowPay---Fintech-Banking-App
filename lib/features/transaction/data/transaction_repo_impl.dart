import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/auth/domain/entities/app_user.dart';
import 'package:flowpay/features/transaction/domain/entities/transaction.dart';
import '../../account/domain/entities/account.dart';
import '../domain/repo/transaction_repo.dart';

class TransactionRepoImpl implements TransactionRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // Create Transaction Method
  @override
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      await firebaseFirestore
          .collection('transactions')
          .doc(transaction.transactionId)
          .set(transaction.toJson());
    } catch (e) {
      throw Exception('Transaction Failed: $e');
    }
  }

  // Fetch Transaction Method (for sender or receiver)
  @override
  Future<List<TransactionModel>> getTransactions(String accountId) async {
    try {
      // Fetch transactions where the given accountId is either sender or receiver
      final snapshot =
          await firebaseFirestore
              .collection('transactions')
              .where('accountId', isEqualTo: accountId)
              .orderBy('dateTime', descending: true)
              .get();

      // Map docs to TransactionModel
      return snapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await firebaseFirestore
          .collection('transactions')
          .doc(transactionId)
          .delete();
    } catch (e) {
      throw Exception('Falied to delete transaction $e');
    }
  }

  @override
  Stream<AppUser?> getReceiverByAccount(String phone) {
    return FirebaseFirestore.instance
        .collection('accounts')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .snapshots()
        .asyncMap((accountSnapshot) async {
          if (accountSnapshot.docs.isEmpty) {
            return null;
          }

          final accountData = accountSnapshot.docs.first.data();
          final userId = accountData['userId'];

          final userDoc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get();

          if (!userDoc.exists) {
            return null;
          }

          final userData = userDoc.data()!;

          final user = AppUser.fromJson(userData);

          // attach account
          user.account = Account.fromJson(accountData);

          // attach profile image
          user.profileImageUrl = userData['profileImageUrl'];

          return user;
        });
  }

  @override
  Stream<List<TransactionModel>> streamTransactions(String accountId) {
    return FirebaseFirestore.instance
        .collection('transactions')
        .where('phone', isEqualTo: accountId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => TransactionModel.fromJson(doc.data(), accountId),
                  )
                  .toList(),
        );
  }
}
