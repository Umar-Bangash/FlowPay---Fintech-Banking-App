import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/pocket/domain/entities/goal.dart';
import 'package:flowpay/features/pocket/domain/repo/goal_repo.dart';
import 'package:flowpay/features/notification/data/services/local_notification_service.dart';
import 'package:flutter/foundation.dart';

class GoalRepoImpl implements GoalRepo {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _goals => _db.collection('goals');
  CollectionReference get _accts => _db.collection('accounts');
  CollectionReference get _notifs => _db.collection('notifications');
  CollectionReference get _goalTxn => _db.collection('goal_transactions');

  @override
  Future<void> createGoal(Goal goal) async {
    try {
      final ref = await _goals.add(goal.toJson());
      await ref.update({'goalId': ref.id});
    } catch (e) {
      throw Exception('Failed to create goal: $e');
    }
  }

  @override
  Future<void> deleteGoal(String goalID) async {
    try {
      await _goals.doc(goalID).delete();
    } catch (e) {
      throw Exception('Failed to delete goal');
    }
  }

  @override
  Future<List<Goal>> getGoals(String userId) async {
    try {
      final snap = await _goals.where('userId', isEqualTo: userId).get();
      return snap.docs
          .map(
            (d) => Goal.fromJson(
              d.data() as Map<String, dynamic>,
            ).copyWith(goalId: d.id),
          )
          .toList();
    } catch (e, st) {
      debugPrint('Error fetching goals: $e\n$st');
      throw Exception('Failed to fetch goals');
    }
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    try {
      await _goals.doc(goal.goalId).update({
        'goalName': goal.goalName,
        'targetAmount': goal.targetAmount,
        'savedAmount': goal.savedAmount,
        'deadline': goal.deadline,
        'categoryId': goal.categoryId,
        'notifyOnComplete': goal.notifyOnComplete,
      });
    } catch (e) {
      throw Exception('Failed to update goal');
    }
  }

  @override
  Future<void> addMoneyToGoal({
    required String accountId,
    required String goalId,
    required double amount,
  }) async {
    final batch = _db.batch();
    final txnId = DateTime.now().millisecondsSinceEpoch.toString();

    final acctRef = _accts.doc(accountId);
    final goalRef = _goals.doc(goalId);

    final acctSnap = await acctRef.get();
    final goalSnap = await goalRef.get();

    if (!acctSnap.exists) throw Exception('Account not found');
    if (!goalSnap.exists) throw Exception('Goal not found');

    final acctData = acctSnap.data() as Map<String, dynamic>;
    final goalData = goalSnap.data() as Map<String, dynamic>;
    final userId = acctData['userId'] as String;
    final balance = (acctData['balance'] as num).toDouble();
    final saved = (goalData['savedAmount'] as num).toDouble();
    final target = (goalData['targetAmount'] as num).toDouble();
    final goalName = goalData['goalName'] as String;
    // Read notification preference — default true for old docs
    final notifyOnComplete = goalData['notifyOnComplete'] as bool? ?? true;

    if (balance < amount) throw Exception('Insufficient balance');

    final newSaved = saved + amount;

    batch.update(acctRef, {'balance': balance - amount});
    batch.update(goalRef, {'savedAmount': newSaved});
    batch.set(_goalTxn.doc(txnId), {
      'transactionId': txnId,
      'accountId': accountId,
      'goalId': goalId,
      'amount': amount,
      'type': 'goal_saving',
      'description': 'Money added to goal $goalName',
      'dateTime': DateTime.now().toIso8601String(),
    });

    await batch.commit();

    // Only notify when goal is hit AND user has notifications enabled
    if (newSaved >= target && notifyOnComplete) {
      await _storeGoalHitNotification(
        userId: userId,
        goalName: goalName,
        amount: target,
      );
    }
  }

  @override
  Future<void> withdrawFromGoal({
    required String accountId,
    required String goalId,
    required double amount,
  }) async {
    final batch = _db.batch();
    final txnId = DateTime.now().millisecondsSinceEpoch.toString();

    final acctRef = _accts.doc(accountId);
    final goalRef = _goals.doc(goalId);

    final acctSnap = await acctRef.get();
    final goalSnap = await goalRef.get();

    if (!acctSnap.exists) throw Exception('Account not found');
    if (!goalSnap.exists) throw Exception('Goal not found');

    final acctData = acctSnap.data() as Map<String, dynamic>;
    final goalData = goalSnap.data() as Map<String, dynamic>;
    final balance = (acctData['balance'] as num).toDouble();
    final saved = (goalData['savedAmount'] as num).toDouble();
    final goalName = goalData['goalName'] as String;

    if (saved < amount) throw Exception('Not enough saved amount');

    batch.update(acctRef, {'balance': balance + amount});
    batch.update(goalRef, {'savedAmount': saved - amount});
    batch.set(_goalTxn.doc(txnId), {
      'transactionId': txnId,
      'accountId': accountId,
      'goalId': goalId,
      'amount': amount,
      'type': 'goal_withdraw',
      'description': 'Money withdrawn from goal $goalName',
      'dateTime': DateTime.now().toIso8601String(),
    });

    await batch.commit();
  }

  // ── Goal hit notification — clean, no emoji icon ──────────────────────────
  Future<void> _storeGoalHitNotification({
    required String userId,
    required String goalName,
    required double amount,
  }) async {
    final id = '${DateTime.now().millisecondsSinceEpoch}_goal_hit';
    final title = 'Savings Goal Reached';
    final message =
        'You have successfully saved Rs.${amount.toStringAsFixed(0)} for "$goalName". Well done!';

    await _notifs.doc(id).set({
      'notificationId': id,
      'userId': userId,
      'title': title,
      'message': message,
      'dateTime': DateTime.now(),
      'type': 'goal_hit',
      'read': false,
    });

    LocalNotificationService.instance().showNotification(title, message, null);
  }

  @override
  Stream<List<Map<String, dynamic>>> getGoalTransactionsStream(String goalId) =>
      _db
          .collection('goal_transactions')
          .where('goalId', isEqualTo: goalId)
          .orderBy('dateTime', descending: true)
          .snapshots()
          .map((s) => s.docs.map((d) => d.data()).toList());

  @override
  Future<void> deleteGoalTransaction(String goalId, String txnId) async {
    await _goalTxn.doc(txnId).delete();
  }
}
