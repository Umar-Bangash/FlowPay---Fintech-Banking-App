import 'package:dotted_border/dotted_border.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

import '../features/pocket/presentation/pages/pocket_category_page.dart';

class AddPocketBox extends StatelessWidget {
  final bool isHavePocket;
  final int? totalPockets;
  final double? saveAmount;
  final VoidCallback? onTap;

  const AddPocketBox({
    super.key,
    this.isHavePocket = false,
    this.totalPockets,
    this.onTap,
    this.saveAmount,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        color: const Color(0xff737373),
        strokeWidth: 1.5,
        dashPattern: const [6, 3],
        radius: const Radius.circular(21),
      ),
      child: Container(
        padding: context.padSymmetricPx(vertical: 20, horizontal: 20),
        width: context.wPx(390),
        child: Column(
          children: [
            isHavePocket
                ? SizedBox(
                  width: double.maxFinite,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Saved"),
                        Text(
                          "Rs ${saveAmount.toString()}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        context.spaceHPx(10),
                        TextButton(
                          onPressed: onTap,
                          child: Text(
                            "${totalPockets.toString()} active pockets",
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : Column(
                  children: [
                    Image.asset(
                      'assets/home/pocket.png',
                      height: context.hPx(42),
                      width: context.wPx(42),
                    ),
                    context.spaceHPx(20),
                    const Text(
                      'Create your First Pocket',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    context.spaceHPx(8),
                    const Text(
                      'Start saving for vacation, gadget, \nemergency, or any dream goal',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),

                    context.spaceHPx(25),
                  ],
                ),
            context.spaceHPx(25),

            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PocketCategory()),
                );
              },
              child: Container(
                height: context.hPx(56),
                width: context.wPx(276),
                decoration: BoxDecoration(
                  color: const Color(0xff007AFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/home/plus.png',
                        height: context.hPx(24),
                        width: context.wPx(24),
                      ),
                      context.spaceWPx(20),
                      const Text(
                        'Add Pocket',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xffFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
