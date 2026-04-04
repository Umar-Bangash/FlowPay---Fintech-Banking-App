import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class NotificationButton extends StatelessWidget {
  final String buttonName;
  final void Function() onClick;
  final bool isSelected;
  final Color btnColor;
  const NotificationButton({
    super.key,
    required this.buttonName,
    required this.onClick,
    required this.isSelected,
    required this.btnColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        height: context.hPx(33),
        decoration: BoxDecoration(
          color: btnColor,
          border: Border.all(
            color: isSelected ? Color(0xffFFFFFF) : Color(0xffA2A2A7),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: context.padSymmetricPx(horizontal: 10, vertical: 4),
          child: Center(
            child: Text(
              buttonName,
              style: TextStyle(
                color: isSelected ? Color(0xff000000) : Color(0xffA2A2A7),
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
