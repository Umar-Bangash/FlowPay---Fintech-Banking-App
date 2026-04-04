/*

Goal State: Outline the possibe goal state

*/

import 'package:flowpay/features/pocket/domain/entities/goal.dart';

abstract class GoalState {}

// initial
class GoalInitial extends GoalState {}

// loading
class GoalLoading extends GoalState {}

// success
class GoalSuccess extends GoalState {
  final String message;

  GoalSuccess(this.message);
}

// loaded
class GoalLoaded extends GoalState {
  final List<Goal> goals;
  final int? selectedIconIndex;
  final List<Map<String, dynamic>> transactions;

  GoalLoaded(
    this.goals, {
    this.selectedIconIndex = 0,
    this.transactions = const [],
  });
}

// error
class GoalError extends GoalState {
  final String message;

  GoalError(this.message);
}
