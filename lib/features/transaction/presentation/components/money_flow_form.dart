import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class MoneyFlowForm extends StatelessWidget {
  const MoneyFlowForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.hPx(87.02),
      width: context.wPx(242.45),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/transfer/wallet.png',
                height: context.hPx(57.42),
                width: context.hPx(57.42),
              ),
              Image.asset(
                'assets/transfer/flowpaycircle.png',
                height: context.hPx(76.56),
                width: context.hPx(76.56),
              ),

              Image.asset(
                'assets/transfer/share.png',
                height: context.hPx(57.42),
                width: context.hPx(57.42),
              ),
            ],
          ),
          Positioned(
            left: 35,
            child: Image.asset(
              'assets/transfer/from.png',
              height: context.hPx(8.79),
              width: context.wPx(52.49),
            ),
          ),
          Positioned(
            bottom: 15,
            right: 45,
            child: Image.asset(
              'assets/transfer/to.png',
              height: context.hPx(8.79),
              width: context.wPx(52.49),
            ),
          ),
        ],
      ),
    );
  }
}
