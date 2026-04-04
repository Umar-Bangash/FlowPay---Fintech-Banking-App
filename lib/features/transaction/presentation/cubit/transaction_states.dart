/*

 Transaction States: outline all the possible states of transaction

 */

import 'package:flowpay/features/transaction/domain/entities/transaction.dart';

abstract class TransactionStates {}

// initial
class TransactionInitial extends TransactionStates {}

// loading
class TransactionLoading extends TransactionStates {}

// loaded
class TransactionLoaded extends TransactionStates {
  final List<TransactionModel> transactions;

  TransactionLoaded(this.transactions);
}

// success
class TransactionSuccess extends TransactionStates {
  final String message;

  TransactionSuccess(this.message);
}

// error
class TransactionError extends TransactionStates {
  final String message;

  TransactionError(this.message);
}
