import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String goalId;
  final String userId;
  final String goalName;
  final double targetAmount;
  final double savedAmount;
  final DateTime deadline;
  final String categoryId;
  final bool notifyOnComplete; // ← NEW: persisted to Firestore

  Goal({
    required this.goalId,
    required this.userId,
    required this.goalName,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
    required this.categoryId,
    this.notifyOnComplete = true, // default ON
  });

  Goal copyWith({
    String? goalId,
    String? userId,
    String? goalName,
    double? targetAmount,
    double? savedAmount,
    DateTime? deadline,
    String? categoryId,
    bool? notifyOnComplete,
  }) {
    return Goal(
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      goalName: goalName ?? this.goalName,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      deadline: deadline ?? this.deadline,
      categoryId: categoryId ?? this.categoryId,
      notifyOnComplete: notifyOnComplete ?? this.notifyOnComplete,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goalId': goalId,
      'userId': userId,
      'goalName': goalName,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'deadline': deadline.toIso8601String(),
      'categoryId': categoryId,
      'notifyOnComplete': notifyOnComplete,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    DateTime deadline;
    if (json['deadline'] is Timestamp) {
      deadline = (json['deadline'] as Timestamp).toDate();
    } else if (json['deadline'] is String) {
      deadline = DateTime.parse(json['deadline']);
    } else {
      deadline = DateTime.now();
    }

    return Goal(
      goalId: json['goalId'] ?? '',
      userId: json['userId'] ?? '',
      goalName: json['goalName'] ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0.0,
      deadline: deadline,
      categoryId: json['categoryId'] ?? 'custom',
      // Old docs without this field default to true (notify by default)
      notifyOnComplete: json['notifyOnComplete'] as bool? ?? true,
    );
  }
}
