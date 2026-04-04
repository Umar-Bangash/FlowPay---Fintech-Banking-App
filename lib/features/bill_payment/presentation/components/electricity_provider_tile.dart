import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class ElectricTile extends StatelessWidget {
  final String imagePath;
  final String providerName;
  final String provideFor;
  const ElectricTile({
    super.key,
    required this.imagePath,
    required this.providerName,
    required this.provideFor,
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
          title: Text(
            providerName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xff0F172A),
            ),
          ),
          subtitle: Text(
            provideFor,
            style: TextStyle(fontSize: 12, color: Color(0xff64748B)),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: Color(0xffCBD5E1),
          ),
        ),
      ),
    );
  }
}
