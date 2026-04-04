import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class ShortCutTile extends StatelessWidget {
  final String imagePath;
  final String buttonName;

  const ShortCutTile({
    super.key,
    required this.imagePath,
    required this.buttonName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Container(
        height: context.hPx(98),
        width: context.wPx(99),
        decoration: BoxDecoration(
          color: Color(0xffE8EDFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: context.padSymmetricPx(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset(
                imagePath,
                height: context.hPx(42),
                width: context.wPx(42),
              ),
              Text(
                buttonName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<ShortCutTile> listOfShortCuts = [
  ShortCutTile(imagePath: 'assets/home/paybill.png', buttonName: 'Pay Bill'),
  ShortCutTile(imagePath: 'assets/home/recent.png', buttonName: 'Recent'),
  ShortCutTile(imagePath: 'assets/home/request.png', buttonName: 'Request'),
  ShortCutTile(
    imagePath: 'assets/home/quicktransfer.png',
    buttonName: 'Quick \nTransfer',
  ),
];
