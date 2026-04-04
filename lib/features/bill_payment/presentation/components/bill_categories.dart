import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class BillCategories extends StatelessWidget {
  final String imagePath;
  final String billName;
  const BillCategories({
    super.key,
    required this.imagePath,
    required this.billName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: context.hPx(64),
          width: context.wPx(64),
          decoration: BoxDecoration(
            color: Color(0xffEFF6FF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Image.asset(
              imagePath,
              height: context.hPx(36),
              width: context.wPx(30),
            ),
          ),
        ),
        context.spaceHPx(8),
        Text(
          billName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xff475569),
          ),
        ),
      ],
    );
  }
}

List<BillCategories> lisofBillCategories = [
  BillCategories(
    imagePath: 'assets/bill/electricity.png',
    billName: 'Electricity',
  ),
  BillCategories(imagePath: 'assets/bill/gas.png', billName: 'Gas'),
  BillCategories(imagePath: 'assets/bill/water.png', billName: 'Water'),
  BillCategories(imagePath: 'assets/bill/internet.png', billName: 'Internet'),
  BillCategories(imagePath: 'assets/bill/education.png', billName: 'Education'),
  BillCategories(imagePath: 'assets/bill/telephone.png', billName: 'Telephone'),
  BillCategories(imagePath: 'assets/bill/insurance.png', billName: 'Insurance'),
  BillCategories(
    imagePath: 'assets/bill/governoment.png',
    billName: 'Government',
  ),
  BillCategories(imagePath: 'assets/bill/more.png', billName: 'More'),
];
