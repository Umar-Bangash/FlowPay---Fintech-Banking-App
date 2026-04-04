/*

 Account States: outline all the possible states of Account.

 */

import 'package:flowpay/features/account/domain/entities/account.dart';

abstract class AccountStates {}

// initial
class AccountInitial extends AccountStates {}

// loading
class AccountLoading extends AccountStates {}

// loaded
class AccountLoaded extends AccountStates {
  final List<Account> accounts;

  AccountLoaded(this.accounts);
}

// success
class AccountSuccess extends AccountStates {
  final String meessage;

  AccountSuccess(this.meessage);
}

// error
class AccountError extends AccountStates {
  final String message;

  AccountError(this.message);
}
