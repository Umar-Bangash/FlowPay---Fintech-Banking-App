import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class BillTile extends StatelessWidget {
  final String imagePath;
  final String billName;
  final String billID;
  final Color color;
  final Widget useWidget;
  const BillTile({
    super.key,
    required this.imagePath,
    required this.billName,
    required this.billID,
    required this.color,
    required this.useWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Color(0xffF8FAFC)),
        ),
        child: ListTile(
          leading: Container(
            height: context.hPx(48),
            width: context.wPx(48),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: color,
            ),
            child: Padding(
              padding: context.padAllPx(8),
              child: Image.asset(imagePath),
            ),
          ),
          title: Text(
            billName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xff0F172A),
            ),
          ),
          subtitle: Text(
            billID,
            style: TextStyle(fontSize: 12, color: Color(0xff64748B)),
          ),
          trailing: useWidget,
        ),
      ),
    );
  }
}
