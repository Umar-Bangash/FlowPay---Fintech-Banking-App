import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class BiometricCircle extends StatelessWidget {
  final String biometricImagePath;
  final String biometricName;
  final void Function() onTap;
  const BiometricCircle({
    super.key,
    required this.biometricImagePath,
    required this.biometricName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: context.padAllPx(20),
        height: context.hPx(116),
        width: context.wPx(117),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xffF3F7FD),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              biometricImagePath,
              height: context.hPx(30.86),
              width: context.wPx(30.86),
              color: Color(0xff007AFF),
            ),
            context.spaceHPx(12),
            Text(
              biometricName,
              style: TextStyle(
                fontSize: 10.29,
                color: Color(0xff007AFF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
