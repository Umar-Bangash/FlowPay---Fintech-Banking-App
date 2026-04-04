import 'dart:async';

import 'package:flowpay/features/account/domain/entities/account.dart';
import 'package:flowpay/features/account/domain/repo/account_repo.dart';
import 'package:flowpay/features/account/presentation/cubit/account_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountCubit extends Cubit<AccountStates> {
  final AccountRepo accountRepo;
  StreamSubscription? _accountSubscription;
  AccountCubit(this.accountRepo) : super(AccountInitial());

  // real-time account update ...
  void listenToAccounts(String userId) {
    emit(AccountLoading());
    _accountSubscription?.cancel();
    _accountSubscription = accountRepo.accountsStream(userId).listen((
      accounts,
    ) {
      emit(AccountLoaded(accounts));
    }, onError: (e) => emit(AccountError(e.toString())));
  }

  @override
  Future<void> close() {
    _accountSubscription?.cancel();
    return super.close();
  }

  // fetch all accounts method
  Future<void> loadAccounts(String userId) async {
    try {
      emit(AccountLoading());
      final accounts = await accountRepo.getAccounts(userId);
      emit(AccountLoaded(accounts));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  // create account method
  Future<void> createAccount(Account account) async {
    try {
      emit(AccountLoading());
      await accountRepo.createAccount(account);
      emit(AccountSuccess('Account Created Successfully'));
      await loadAccounts(account.userId);
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  // update account balance method
  Future<void> updateBalance(
    String accountId,
    userId,
    double newBalance,
  ) async {
    try {
      emit(AccountLoading());
      await accountRepo.updateBlaance(accountId, newBalance);
      emit(AccountSuccess('Balance Updated'));
      loadAccounts(userId);
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  // delete account method
  Future<void> deleteAccount(String accountId, userId) async {
    try {
      emit(AccountLoading());
      await accountRepo.deleteAccount(accountId);
      emit(AccountSuccess('Account Deleted'));
      loadAccounts(userId);
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  // fetch single account
  Future<void> getAccountById(String accountId) async {
    try {
      emit(AccountLoading());
      final account = await accountRepo.getAccountById(accountId);
      emit(AccountSuccess('Account Loaded'));
      emit(AccountLoaded([account]));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  // search for user by their name
  Future<void> searchAccounts(String query) async {
    emit(AccountLoading());
    try {
      final results = await accountRepo.searchAccountsByName(query);
      emit(AccountLoaded(results));
    } catch (e) {
      emit(AccountError("Failed to search accounts: $e"));
    }
  }

  void deductBalance(double amount) {
    if (state is AccountLoaded) {
      final current = state as AccountLoaded;
      final updatedAccount = current.accounts.first.copyWith(
        balance: current.accounts.first.balance - amount,
      );

      emit(AccountLoaded([updatedAccount]));
    }
  }
}
