import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return Container(
      padding: context.padSymmetricPx(horizontal: 10),
      width: context.wPx(342),
      height: context.hPx(110),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffDEE0E5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              height: context.hPx(32),
              width: context.wPx(32),
            ),
          ],
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff2F394E),
                ),
              ),
              CupertinoSwitch(value: switchValue, onChanged: onChange),
            ],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xff737373),
          ),
        ),
      ),
    );
  }
}
