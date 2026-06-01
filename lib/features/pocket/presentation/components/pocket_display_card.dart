import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../helpers/ui_responsive_helper.dart';

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
    AppResponsive.init(context);
    final progress = (percentage / 100).clamp(0.0, 1.0);
    final iconSz = AppResponsive.sp(40).clamp(32.0, 50.0);

    return Padding(
      padding: EdgeInsets.only(bottom: AppResponsive.h(12)),
      child: Container(
        width: double.infinity,
        // No fixed height — content drives size
        padding: EdgeInsets.symmetric(
          horizontal: AppResponsive.w(18),
          vertical: AppResponsive.h(18),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 15,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon + name ─────────────────────────────────────────
            Row(
              children: [
                Container(
                  height: iconSz,
                  width: iconSz,
                  decoration: BoxDecoration(
                    color: const Color(0xff007AFF),
                    borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
                  ),
                  child: Center(
                    child: Image.asset(
                      pocketImage,
                      color: Colors.white,
                      height: iconSz * 0.55,
                      width: iconSz * 0.55,
                    ),
                  ),
                ),
                SizedBox(width: AppResponsive.w(10)),
                Expanded(
                  child: Text(
                    pocketName,
                    style: TextStyle(
                      fontSize: AppResponsive.fs(16),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppResponsive.h(16)),

            Text(
              'You\'ve saved',
              style: TextStyle(
                fontSize: AppResponsive.fs(14),
                color: const Color(0xff737373),
              ),
            ),

            SizedBox(height: AppResponsive.h(6)),

            // ── Amount row — FittedBox prevents overflow for large numbers ──
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    'Rs ${_fmt(saveAmount)}',
                    style: TextStyle(
                      fontSize: AppResponsive.fs(28, max: 34),
                      color: const Color(0xff737373),
                    ),
                  ),
                  Text(
                    ' / ${_fmt(targetAmount)}',
                    style: TextStyle(
                      fontSize: AppResponsive.fs(12),
                      color: const Color(0xff737373),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppResponsive.h(8)),

            // ── Progress bar — LayoutBuilder width ─────────────────────
            LayoutBuilder(
              builder:
                  (context, c) => LinearPercentIndicator(
                    width: c.maxWidth,
                    animation: true,
                    animationDuration: 800,
                    lineHeight: AppResponsive.h(10).clamp(8.0, 14.0),
                    percent: progress,
                    padding: EdgeInsets.zero,
                    barRadius: const Radius.circular(10),
                    backgroundColor: const Color(0xffE6E6E6),
                    progressColor: const Color(0xff007AFF),
                  ),
            ),

            SizedBox(height: AppResponsive.h(6)),

            // ── Bottom row — Flexible text prevents overflow ────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${percentage.toStringAsFixed(1)}% Complete',
                    style: TextStyle(
                      fontSize: AppResponsive.fs(11),
                      color: const Color(0xff737373),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: AppResponsive.w(8)),
                Flexible(
                  child: Text(
                    'Rs ${_fmt(remainAmount)} to go',
                    style: TextStyle(
                      fontSize: AppResponsive.fs(11),
                      color: const Color(0xff737373),
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Format large numbers nicely: 1000000 → "1,000,000"
  String _fmt(double v) {
    if (v >= 1000) {
      // Insert commas
      final parts = v.toStringAsFixed(0).split('');
      final buf = StringBuffer();
      for (int i = 0; i < parts.length; i++) {
        if (i > 0 && (parts.length - i) % 3 == 0) buf.write(',');
        buf.write(parts[i]);
      }
      return buf.toString();
    }
    return v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
  }
}
