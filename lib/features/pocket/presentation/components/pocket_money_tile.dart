import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class PocketMoneyTile extends StatelessWidget {
  final Color iconContainerColor;
  final String icon;
  final Color iconColor;
  final String titleText;
  final String date;
  final double amount;
  final Color textColor;
  final Color currenyColor;
  const PocketMoneyTile({
    super.key,
    required this.iconContainerColor,
    required this.icon,
    required this.iconColor,
    required this.titleText,
    required this.date,
    required this.amount,
    required this.textColor,
    required this.currenyColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        height: context.hPx(84),
        decoration: BoxDecoration(
          color: Color(0xffF9FAFB),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ListTile(
          leading: Container(
            height: context.hPx(40),
            width: context.wPx(40),
            decoration: BoxDecoration(
              color: iconContainerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Image.asset(
                icon,
                color: iconColor,
                height: context.hPx(24),
                width: context.wPx(24),
              ),
            ),
          ),
          title: Text(
            titleText,
            style: TextStyle(fontSize: 16, color: Color(0xff101828)),
          ),
          subtitle: Text(
            date,
            style: TextStyle(fontSize: 14, color: Color(0xff6A7282)),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Rs', style: TextStyle(fontSize: 16, color: currenyColor)),
              context.spaceHPx(2),
              Text(
                amount.toString(),
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
