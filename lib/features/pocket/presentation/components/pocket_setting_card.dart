import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class PocketSettingCard extends StatelessWidget {
  final String pocketImage;
  final String pocketName;
  final double saveAmount;
  final double targetAmount;
  const PocketSettingCard({
    super.key,
    required this.pocketImage,
    required this.pocketName,
    required this.saveAmount,
    required this.targetAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: context.hPx(198),
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Color(0xffFFFFFF),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 15,
                spreadRadius: 6,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Padding(
            padding: context.padSymmetricPx(horizontal: 25, vertical: 25),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: context.hPx(42),
                      width: context.wPx(42),
                      decoration: BoxDecoration(
                        color: Color(0xff007AFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Image.asset(
                          pocketImage,
                          color: Color(0xffFFFFFF),
                          height: context.hPx(24),
                          width: context.wPx(24),
                        ),
                      ),
                    ),
                    context.spaceWPx(12),
                    Text(
                      pocketName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                context.spaceHPx(25),
                Row(
                  children: [
                    Text(
                      'Rs $saveAmount',
                      style: TextStyle(fontSize: 31, color: Color(0xff737373)),
                    ),
                    Text(
                      ' / $targetAmount',
                      style: TextStyle(fontSize: 12, color: Color(0xff737373)),
                    ),
                  ],
                ),
                context.spaceHPx(15),
                Image.asset('assets/pocket/greybar.png'),
              ],
            ),
          ),
        ),
        Positioned(
          right: -25,
          child: Image.asset(
            'assets/pocket/sidecircle.png',
            height: context.hPx(119.29),
            width: context.wPx(135.49),
          ),
        ),
      ],
    );
  }
}
