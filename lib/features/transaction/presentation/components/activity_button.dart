import 'package:flutter/material.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class ActivityButton extends StatelessWidget {
  final String imagePath;
  final Color buttonColor;
  final String buttonName;
  final Color textColor;
  final VoidCallback onTap;

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
    AppResponsive.init(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
      child: Container(
        height: AppResponsive.h(52),
        width: double.infinity, // ← was context.wPx(169), now fluid
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xff007AFF)),
          borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
          color: buttonColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: AppResponsive.sp(20),
              width: AppResponsive.sp(20),
            ),
            SizedBox(width: AppResponsive.w(8)),
            Flexible(
              child: Text(
                buttonName,
                style: TextStyle(
                  fontSize: AppResponsive.fs(13),
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
