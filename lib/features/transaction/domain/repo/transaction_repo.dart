/*

 Transaction Respository: Outline the functionality of Transaction.

 */

import 'package:flowpay/features/auth/domain/entities/app_user.dart';
import 'package:flowpay/features/transaction/domain/entities/transaction.dart';

abstract class TransactionRepo {
  Future<void> createTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> getTransactions(String accountID);
  Future<void> deleteTransaction(String transactionId);
  Stream<AppUser?> getReceiverByAccount(String accountNumber);
  Stream<List<TransactionModel>> streamTransactions(String accountId);
}
