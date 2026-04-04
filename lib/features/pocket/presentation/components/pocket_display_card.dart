import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class PocketDisplayCard extends StatelessWidget {
  final String pocketImage;
  final String pocketName;
  final double saveAmount;
  final double targetAmount;
  final double percentage;
  final double remainAmount;

  const PocketDisplayCard({
    super.key,

    required this.pocketImage,
    required this.pocketName,
    required this.saveAmount,
    required this.targetAmount,
    required this.percentage,
    required this.remainAmount,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (percentage / 100).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        height: context.hPx(241),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Color(0xffFFFFFF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 15,
              spreadRadius: 6,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: context.padSymmetricPx(horizontal: 20, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: context.hPx(42),
                    width: context.wPx(42),
                    decoration: BoxDecoration(
                      color: Color(0xff007AFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Image.asset(
                        pocketImage,
                        color: Color(0xffFFFFFF),
                        height: context.hPx(24),
                        width: context.wPx(24),
                      ),
                    ),
                  ),
                  context.spaceWPx(12),
                  Text(
                    pocketName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              context.spaceHPx(20),
              Text(
                'You\'ve saved',
                style: TextStyle(fontSize: 16, color: Color(0xff737373)),
              ),
              context.spaceHPx(10),
              Row(
                children: [
                  Text(
                    'Rs $saveAmount',
                    style: TextStyle(fontSize: 31, color: Color(0xff737373)),
                  ),
                  Text(
                    ' / $targetAmount',
                    style: TextStyle(fontSize: 12, color: Color(0xff737373)),
                  ),
                ],
              ),
              context.spaceHPx(8),

              LinearPercentIndicator(
                width: MediaQuery.of(context).size.width - 100,

                animation: true,
                animationDuration: 800,
                lineHeight: 12.0,
                percent: progress,

                barRadius: const Radius.circular(10),
                backgroundColor: const Color(0xffE6E6E6),
                progressColor: const Color(0xff007AFF),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${percentage.toStringAsFixed(2)}% Complete',
                    style: TextStyle(fontSize: 12, color: Color(0xff737373)),
                  ),
                  Text(
                    'Rs $remainAmount to go',
                    style: TextStyle(fontSize: 12, color: Color(0xff737373)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
