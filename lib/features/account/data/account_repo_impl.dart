import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/account/domain/entities/account.dart';
import 'package:flowpay/features/account/domain/repo/account_repo.dart';

class AccountRepoImpl implements AccountRepo {
  final CollectionReference accountsCollection = FirebaseFirestore.instance
      .collection('accounts');

  // Create Account
  @override
  Future<void> createAccount(Account account) async {
    try {
      final docRef = accountsCollection.doc();

      await docRef.set({
        'accountId': docRef.id,
        'userId': account.userId,
        'phone': account.phone,
        'balance': account.balance,
      });
    } catch (e) {
      throw Exception('Failed to create account: $e');
    }
  }

  // Get all accounts for a user
  @override
  Future<List<Account>> getAccounts(String userId) async {
    try {
      final snapshot =
          await accountsCollection.where('userId', isEqualTo: userId).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Account.fromJson({...data, 'accountId': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to load accounts: $e');
    }
  }

  // Update account balance
  @override
  Future<void> updateBlaance(String accountId, double newBalance) async {
    try {
      await accountsCollection.doc(accountId).update({'balance': newBalance});
    } catch (e) {
      throw Exception('Failed to update balance: $e');
    }
  }

  // Delete account
  @override
  Future<void> deleteAccount(String accountId) async {
    try {
      await accountsCollection.doc(accountId).delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Get single account by ID
  @override
  Future<Account> getAccountById(String accountId) async {
    try {
      final doc = await accountsCollection.doc(accountId).get();

      if (!doc.exists) {
        throw Exception('Account not found');
      }

      return Account.fromJson({
        ...(doc.data() as Map<String, dynamic>),
        'accountId': doc.id,
      });
    } catch (e) {
      throw Exception('Failed to get account: $e');
    }
  }

  // Search accounts by phone (VALID for your model)
  @override
  Future<List<Account>> searchAccountsByName(String query) async {
    try {
      final snapshot =
          await accountsCollection
              .where('phone', isGreaterThanOrEqualTo: query)
              .where('phone', isLessThanOrEqualTo: '$query\uf8ff')
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Account.fromJson({...data, 'accountId': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to search accounts: $e');
    }
  }

  // real-time update for account
  @override
  Stream<List<Account>> accountsStream(String userId) {
    return accountsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Account.fromJson({...data, 'accountId': doc.id});
              }).toList(),
        );
  }
}
