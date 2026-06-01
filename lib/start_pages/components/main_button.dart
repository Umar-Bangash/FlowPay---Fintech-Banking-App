import 'package:flutter/material.dart';
import '../../helpers/ui_responsive_helper.dart';

class MainButton extends StatelessWidget {
  final String buttonName;
  final void Function() onTap;

  const MainButton({required this.buttonName, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.maxFinite,
          height: AppResponsive.h(54),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
            color: const Color(0xff007AFF),
          ),
          child: Center(
            child: Text(
              buttonName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppResponsive.fs(16),
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
