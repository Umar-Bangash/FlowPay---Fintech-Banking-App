import 'package:flutter/cupertino.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class BiometricTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final bool switchValue;
  final ValueChanged<bool> onChange;

  const BiometricTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.switchValue,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    return Container(
      width: double.infinity, // ← was context.wPx(342), now fluid
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.w(12),
        vertical: AppResponsive.h(14),
      ),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffDEE0E5)),
        borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Image.asset(
            imagePath,
            height: AppResponsive.sp(30),
            width: AppResponsive.sp(30),
          ),
          SizedBox(width: AppResponsive.w(12)),
          // Text block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppResponsive.fs(16),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff2F394E),
                  ),
                ),
                SizedBox(height: AppResponsive.h(5)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppResponsive.fs(12),
                    color: const Color(0xff737373),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Switch — no fixed size, just let it sit
          Padding(
            padding: EdgeInsets.only(top: AppResponsive.h(2)),
            child: CupertinoSwitch(value: switchValue, onChanged: onChange),
          ),
        ],
      ),
    );
  }
}
