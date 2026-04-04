import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/auth/domain/entities/app_user.dart';
import 'package:flowpay/features/account/domain/entities/account.dart';
import 'package:flowpay/features/transaction/domain/entities/transaction.dart';
import 'package:flowpay/features/transaction/domain/repo/transaction_repo.dart';
import 'package:flowpay/features/transaction/data/services/transaction_service.dart';
import 'package:flowpay/features/transaction/presentation/cubit/transaction_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionCubit extends Cubit<TransactionStates> {
  final TransactionRepo transactionRepo;
  final TransactionService transactionService;
  StreamSubscription? _trxSub;

  TransactionCubit(this.transactionRepo, this.transactionService)
    : super(TransactionInitial());

  AppUser? searchedReceiver;

  // real time listener for transaction
  void listenToTransactions(String accountId) {
    _trxSub?.cancel();
    _trxSub = FirebaseFirestore.instance
        .collection('transactions')
        .where('accountId', isEqualTo: accountId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen((snapshot) {
          final transactions =
              snapshot.docs.map((doc) {
                return TransactionModel.fromJson(doc.data(), accountId);
              }).toList();
          emit(TransactionLoaded(transactions));
        });
  }

  // Create Transaction Method
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      emit(TransactionLoading());
      await transactionRepo.createTransaction(transaction);
      emit(TransactionSuccess('Transaction done Successfully'));
      emit(TransactionLoaded([transaction]));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  // get all transactions for account
  Future<void> getTransactions(String accountId) async {
    try {
      emit(TransactionLoading());
      final transactions = await transactionRepo.getTransactions(accountId);
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  // Money transfer from one account to another
  Future<void> transferMoney(
    String senderAccountId,
    reciverAccountId,
    double amount,
  ) async {
    try {
      emit(TransactionLoading());
      await transactionService.transferMoney(
        senderUid: senderAccountId,
        receiverUid: reciverAccountId,
        amount: amount,
      );
      emit(TransactionSuccess('Transfer Successful'));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> deleteTransaction(String transactionId, String accountId) async {
    try {
      emit(TransactionLoading());
      await transactionRepo.deleteTransaction(transactionId);
      emit(TransactionSuccess('Transaction Deleted Successfully'));
      final transactions = await transactionRepo.getTransactions(accountId);
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  // ✅ FIXED: get user by id — now fetches account from separate collection
  Future<AppUser?> getReceiverById(String uid) async {
    try {
      // ✅ Step 1: Fetch user document
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        debugPrint("getReceiverById: No user found for uid=$uid");
        return null;
      }

      // ✅ Step 2: Build AppUser from user doc (account will be null here)
      final appUser = AppUser.fromJson(userDoc.data()!);

      // ✅ Step 3: Fetch account from separate 'accounts' collection
      // Account document has a 'userId' field matching the uid
      final accountSnapshot =
          await FirebaseFirestore.instance
              .collection('accounts')
              .where('userId', isEqualTo: uid)
              .limit(1)
              .get();

      if (accountSnapshot.docs.isNotEmpty) {
        final accountData = accountSnapshot.docs.first.data();
        debugPrint("getReceiverById: Found account -> $accountData");

        // ✅ Step 4: Attach account to appUser
        appUser.account = Account.fromJson(accountData);
      } else {
        debugPrint("getReceiverById: No account found for uid=$uid");
      }

      debugPrint(
        "getReceiverById: Returning user=${appUser.name}, phone=${appUser.account?.phone}",
      );

      return appUser;
    } catch (e) {
      debugPrint("TransactionCubit -> getReceiverById Error: $e");
      return null;
    }
  }

  // get receiver by account number
  Stream<AppUser?> searchReceiverStream(String accountNumber) {
    return transactionRepo.getReceiverByAccount(accountNumber);
  }

  @override
  Future<void> close() {
    _trxSub?.cancel();
    return super.close();
  }
}
