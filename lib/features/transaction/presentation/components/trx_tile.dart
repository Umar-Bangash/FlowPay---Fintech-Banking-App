import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class TrxTile extends StatelessWidget {
  final String imagePath;
  final String name;
  final String datetime;
  final String amount;
  final Color amountColor;

  const TrxTile({
    super.key,
    required this.imagePath,
    required this.name,
    required this.datetime,
    required this.amount,
    required this.amountColor,
    required Function() onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.hPx(105),
      width: double.maxFinite,
      padding: context.padSymmetricPx(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xffFBFCFF),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: Color(0xffDFDFDF)),
      ),
      child: ListTile(
        leading: Container(
          height: context.hPx(50.5),
          width: context.wPx(50.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.57),
            color: Color(0xffDFE5FF),
          ),
          child: Image.asset(
            imagePath,
            height: context.hPx(42),
            width: context.wPx(42),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          datetime,
          style: TextStyle(
            fontSize: 11.57,
            fontWeight: FontWeight.w500,
            color: Color(0xff707070),
          ),
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: amountColor,
          ),
        ),
      ),
    );
  }
}
