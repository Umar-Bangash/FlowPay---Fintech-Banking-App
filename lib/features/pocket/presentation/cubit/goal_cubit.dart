import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/pocket/domain/entities/goal.dart';
import 'package:flowpay/features/pocket/domain/repo/goal_repo.dart';
import 'package:flowpay/features/pocket/presentation/cubit/goal_states.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GoalCubit extends Cubit<GoalState> {
  final GoalRepo goalRepo;
  GoalCubit(this.goalRepo) : super(GoalInitial());

  // userId
  final userId = FirebaseAuth.instance.currentUser!.uid;

  // fetch goals
  Future<void> fetchGoals(String userId) async {
    try {
      emit(GoalLoading());
      final goals = await goalRepo.getGoals(userId);
      emit(GoalLoaded(goals));
      for (var i in goals) {
        debugPrint("Goals are ${i.goalName}");
      }
    } catch (e) {
      emit(GoalError('Failed to fetch goals'));
    }
  }

  // create goal
  Future<void> createGoal(Goal goal) async {
    try {
      emit(GoalLoading());
      await goalRepo.createGoal(goal);
      emit(GoalSuccess('Goal created successfully'));
      await fetchGoals(userId);
    } catch (e) {
      emit(GoalError('Failed to set goal'));
    }
  }

  // update goal
  Future<void> updateGoal(Goal goal) async {
    try {
      emit(GoalLoading());
      await goalRepo.updateGoal(goal);
      emit(GoalSuccess('Goal updated successfully'));
      await fetchGoals(userId);
    } catch (e) {
      emit(GoalError('Failed to update goal'));
    }
  }

  // delete goal
  Future<void> deleteGoal(String goalId) async {
    try {
      emit(GoalLoading());
      await goalRepo.deleteGoal(goalId);
      emit(GoalSuccess('Goal deleted Successfully'));
      await fetchGoals(userId);
    } catch (e) {
      emit(GoalError('Failed to delete goal'));
    }
  }

  // add money to pocket
  Future<void> addMoneyToPocket({
    required Goal goal,
    required String accountId,
    required double amount,
  }) async {
    emit(GoalLoading());

    try {
      await goalRepo.addMoneyToGoal(
        accountId: accountId,
        goalId: goal.goalId,
        amount: amount,
      );

      await fetchGoals(goal.userId);
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  // withdraw money from pocket
  Future<void> withdrawFromPocket({
    required Goal goal,
    required String accountId,
    required double amount,
  }) async {
    emit(GoalLoading());

    try {
      await goalRepo.withdrawFromGoal(
        accountId: accountId,
        goalId: goal.goalId,
        amount: amount,
      );

      await fetchGoals(goal.userId);
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  // fetch goal transactions
  Stream<List<Map<String, dynamic>>> goalTransactionsStream(String goalId) {
    return goalRepo.getGoalTransactionsStream(goalId);
  }

  // delete goal transactions
  Future<void> deleteGoalTransaction(
    String goalId,
    String transactionId,
  ) async {
    try {
      await goalRepo.deleteGoalTransaction(goalId, transactionId);

      /// refresh transactions instantly
      goalRepo.getGoalTransactionsStream(goalId);
    } catch (e) {
      emit(GoalError("Failed to delete transaction"));
    }
  }

  void selectGoalIcon(int index) {
    if (state is GoalLoaded) {
      final currentGoals = (state as GoalLoaded).goals;
      emit(GoalLoaded(currentGoals, selectedIconIndex: index));
    }
  }
}
