import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/pocket/domain/entities/goal.dart';
import 'package:flowpay/features/pocket/domain/repo/goal_repo.dart';
import 'package:flowpay/features/notification/data/services/local_notification_service.dart';
import 'package:flutter/foundation.dart';

class GoalRepoImpl implements GoalRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference goalsCollection = _firestore.collection(
    'goals',
  );

  late final CollectionReference accountsCollection = _firestore.collection(
    'accounts',
  );

  late final CollectionReference notificationsCollection = _firestore
      .collection('notifications');

  // create goal
  @override
  Future<void> createGoal(Goal goal) async {
    try {
      final docRef = await goalsCollection.add(goal.toJson());
      await docRef.update({'goalId': docRef.id});
    } catch (e) {
      throw Exception('Failed to create goal: $e');
    }
  }

  // delete goal
  @override
  Future<void> deleteGoal(String goalID) async {
    try {
      await goalsCollection.doc(goalID).delete();
    } catch (e) {
      throw Exception('Failed to delete goal');
    }
  }

  // fetch goal
  @override
  Future<List<Goal>> getGoals(String userId) async {
    try {
      final snapshot =
          await goalsCollection.where('userId', isEqualTo: userId).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Goal.fromJson(data).copyWith(goalId: doc.id);
      }).toList();
    } catch (e, st) {
      debugPrint('Error fetching goals: $e');
      debugPrint('$st');
      throw Exception('Failed to fetch goals');
    }
  }

  // update goal
  @override
  Future<void> updateGoal(Goal goal) async {
    try {
      await goalsCollection.doc(goal.goalId).update({
        'goalName': goal.goalName,
        'targetAmount': goal.targetAmount,
        'savedAmount': goal.savedAmount,
        'deadline': goal.deadline,
      });
    } catch (e) {
      throw Exception('Failed to update goal');
    }
  }

  // add money to goal
  @override
  Future<void> addMoneyToGoal({
    required String accountId,
    required String goalId,
    required double amount,
  }) async {
    final batch = _firestore.batch();
    final transactionId = DateTime.now().millisecondsSinceEpoch.toString();

    final accountRef = accountsCollection.doc(accountId);
    final goalRef = goalsCollection.doc(goalId);

    final accountSnap = await accountRef.get();
    final goalSnap = await goalRef.get();

    if (!accountSnap.exists) throw Exception("Account not found");
    if (!goalSnap.exists) throw Exception("Goal not found");

    final accountData = accountSnap.data() as Map<String, dynamic>;
    final goalData = goalSnap.data() as Map<String, dynamic>;

    final userId = accountData['userId'];
    final accountBalance = (accountData['balance'] as num).toDouble();
    final savedAmount = (goalData['savedAmount'] as num).toDouble();
    final goalName = goalData['goalName'];

    if (accountBalance < amount) {
      throw Exception("Insufficient balance");
    }

    // Update balances
    batch.update(accountRef, {'balance': accountBalance - amount});
    batch.update(goalRef, {'savedAmount': savedAmount + amount});

    // Store transaction
    final txnRef = _firestore
        .collection('goal_transactions')
        .doc(transactionId);

    batch.set(txnRef, {
      'transactionId': transactionId,
      'accountId': accountId,
      'goalId': goalId,
      'amount': amount,
      'type': 'goal_saving',
      'description': 'Money added to goal $goalName',
      'dateTime': DateTime.now().toIso8601String(),
    });

    await batch.commit();

    // Firestore notification
    await storeNotification(
      userId: userId,
      message: 'You saved Rs.${amount.toStringAsFixed(0)} toward $goalName',
    );
  }

  // withdraw money from goal
  @override
  Future<void> withdrawFromGoal({
    required String accountId,
    required String goalId,
    required double amount,
  }) async {
    final batch = _firestore.batch();
    final transactionId = DateTime.now().millisecondsSinceEpoch.toString();

    final accountRef = accountsCollection.doc(accountId);
    final goalRef = goalsCollection.doc(goalId);

    final accountSnap = await accountRef.get();
    final goalSnap = await goalRef.get();

    if (!accountSnap.exists) throw Exception("Account not found");
    if (!goalSnap.exists) throw Exception("Goal not found");

    final accountData = accountSnap.data() as Map<String, dynamic>;
    final goalData = goalSnap.data() as Map<String, dynamic>;

    final userId = accountData['userId'];
    final accountBalance = (accountData['balance'] as num).toDouble();
    final savedAmount = (goalData['savedAmount'] as num).toDouble();
    final goalName = goalData['goalName'];

    if (savedAmount < amount) {
      throw Exception("Not enough saved amount");
    }

    // Update balances
    batch.update(accountRef, {'balance': accountBalance + amount});
    batch.update(goalRef, {'savedAmount': savedAmount - amount});

    // Store transaction
    final txnRef = _firestore
        .collection('goal_transactions')
        .doc(transactionId);

    batch.set(txnRef, {
      'transactionId': transactionId,
      'accountId': accountId,
      'goalId': goalId,
      'amount': amount,
      'type': 'goal_withdraw',
      'description': 'Money withdrawn from goal $goalName',
      'dateTime': DateTime.now().toIso8601String(),
    });

    await batch.commit();

    // Firestore notification
    await storeNotification(
      userId: userId,
      message: 'You withdrew Rs.${amount.toStringAsFixed(0)} from $goalName',
    );
  }

  // private notification method
  Future<void> storeNotification({
    required String userId,
    required String message,
  }) async {
    final notificationId = '${DateTime.now().millisecondsSinceEpoch}_goal';

    await notificationsCollection.doc(notificationId).set({
      'notificationId': notificationId,
      'userId': userId,
      'title': 'Goal Updated',
      'message': message,
      'dateTime': DateTime.now(),
      'type': 'goal',
      'read': false,
    });

    LocalNotificationService.instance().showNotification(
      "Goal Updated",
      message,
      null,
    );
  }

  @override
  Stream<List<Map<String, dynamic>>> getGoalTransactionsStream(String goalId) {
    return _firestore
        .collection('goal_transactions')
        .where('goalId', isEqualTo: goalId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => d.data()).toList());
  }

  // delete goal-transaction
  Future<void> deleteGoalTransaction(
    String goalId,
    String transactionId,
  ) async {
    await FirebaseFirestore.instance
        .collection('goal_transactions')
        .doc(transactionId)
        .delete();
  }
}

    // (Optional) Push notification if token available
    //   final userSnap = await firestore.collection('users').doc(userId).get();
    //   final userToken = userSnap.data()?['fcmToken'] ?? "";
    //   if (userToken.isNotEmpty) {
    //     try {
    //       final accessToken = await getAccessToken();
    //       await http.post(
    //         Uri.parse(
    //           "https://fcm.googleapis.com/v1/projects/flowpay-856f7/messages:send",
    //         ),
    //         headers: {
    //           "Content-Type": "application/json",
    //           "Authorization": "Bearer $accessToken",
    //         },
    //         body: jsonEncode({
    //           "message": {
    //             "token": userToken,
    //             "notification": {
    //               "title": "Goal Updated 🎯",
    //               "body":
    //                   "You saved Rs.${amount.toStringAsFixed(0)} toward $goalName",
    //             },
    //           },
    //         }),
    //       );
    //     } catch (e) {
    //       debugPrint("FCM Error: $e");
    //     }
    //   }
  

