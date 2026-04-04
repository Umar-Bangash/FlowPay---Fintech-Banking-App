import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class PasswordStrengthState {
  final double strength;
  final String feedbackText;
  final Color feedbackColor;

  const PasswordStrengthState({
    this.strength = 0.0,
    this.feedbackText = '',
    this.feedbackColor = Colors.green,
  });

  PasswordStrengthState copyWith({
    double? strength,
    String? feedbackText,
    Color? feedbackColor,
  }) {
    return PasswordStrengthState(
      strength: strength ?? this.strength,
      feedbackText: feedbackText ?? this.feedbackText,
      feedbackColor: feedbackColor ?? this.feedbackColor,
    );
  }
}

class PasswordStrengthCubit extends Cubit<PasswordStrengthState> {
  PasswordStrengthCubit() : super(const PasswordStrengthState());

  void checkPassword(String value) {
    final password = value.trim();
    double strength = 0.0;
    String feedback = '';
    Color feedbackColor = Colors.green;

    if (password.isEmpty) {
      strength = 0.0;
      feedback = '';
    } else if (password.length < 6) {
      strength = 0.25;
      feedback = 'Weak';
    } else if (password.length < 8) {
      strength = 0.5;
      feedback = 'Good';
    } else if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      strength = 1.0;
      feedback = 'Great! ✅';
    } else {
      strength = 0.75;
      feedback = 'Strong ✅';
    }

    emit(
      state.copyWith(
        strength: strength,
        feedbackText: feedback,
        feedbackColor: feedbackColor,
      ),
    );
  }
}
