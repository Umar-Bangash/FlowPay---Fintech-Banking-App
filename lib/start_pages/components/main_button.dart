import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  final String buttonName;
  final void Function() onTap;
  const MainButton({required this.buttonName, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: context.padSymmetricPx(horizontal: 40, vertical: 14),
        height: context.hPx(56),
        width: context.wPx(342),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Color(0xff007AFF),
        ),
        child: Center(
          child: Text(
            buttonName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xffFFFFFF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
