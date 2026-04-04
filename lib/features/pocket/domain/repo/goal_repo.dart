/*

Goal Repository: Outline the functionalites of goal

*/

import 'package:flowpay/features/pocket/domain/entities/goal.dart';

abstract class GoalRepo {
  // create goal
  Future<void> createGoal(Goal goal);

  // get goal
  Future<List<Goal>> getGoals(String userId);

  // update goal
  Future<void> updateGoal(Goal goal);

  // delete goal
  Future<void> deleteGoal(String goalID);

  // add money to goal
  Future<void> addMoneyToGoal({
    required String accountId,
    required String goalId,
    required double amount,
  });

  // withdraw money from goal
  Future<void> withdrawFromGoal({
    required String accountId,
    required String goalId,
    required double amount,
  });

  // get goal transactions
  Stream<List<Map<String, dynamic>>> getGoalTransactionsStream(String goalId);
  // delete goal transactions
  Future<void> deleteGoalTransaction(String goalId, String transactionId);
}
