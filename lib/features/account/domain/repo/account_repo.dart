import 'package:flowpay/features/account/domain/entities/account.dart';

abstract class AccountRepo {
  Future<void> createAccount(Account account);
  Future<List<Account>> getAccounts(String userId);
  Future<void> updateBlaance(String accountId, double newBalance);
  Future<void> deleteAccount(String accountId);
  Future<Account> getAccountById(String accountId);
  Future<List<Account>> searchAccountsByName(String query);
  Stream<List<Account>> accountsStream(String userId);
}
