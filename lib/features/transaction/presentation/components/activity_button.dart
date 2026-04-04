import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class ActivityButton extends StatelessWidget {
  final String imagePath;
  final Color buttonColor;
  final String buttonName;
  final Color textColor;
  final void Function() onTap;
  const ActivityButton({
    super.key,
    required this.imagePath,
    required this.buttonColor,
    required this.buttonName,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: context.hPx(56),
        width: context.wPx(169),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xff007AFF)),
          borderRadius: BorderRadius.circular(16),
          color: buttonColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: context.hPx(24),
              width: context.wPx(24),
            ),
            context.spaceWPx(10),
            Text(
              buttonName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
