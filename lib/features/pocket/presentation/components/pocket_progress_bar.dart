import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class PocketProgressBar extends StatelessWidget {
  final double savedAmount;
  final double targetAmount;

  const PocketProgressBar({
    super.key,
    required this.savedAmount,
    required this.targetAmount,
  });

  @override
  Widget build(BuildContext context) {
    double progress = 0;

    if (targetAmount > 0) {
      progress = (savedAmount / targetAmount).clamp(0, 1);
    }

    return Container(
      height: context.hPx(12),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xffE5E7EB),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: constraints.maxWidth * progress,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color(0xff007AFF),
            ),
          );
        },
      ),
    );
  }
}
