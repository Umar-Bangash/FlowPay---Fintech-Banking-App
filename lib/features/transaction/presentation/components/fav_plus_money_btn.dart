import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class FavPlusMoneyBtn extends StatelessWidget {
  final Widget buttoncontent;
  final void Function() onTap;
  const FavPlusMoneyBtn({
    super.key,
    required this.buttoncontent,
    required this.onTap,
  });

  /// In-Complete

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Image.asset(
            'assets/transfer/favbutton.png',
            height: context.hPx(56),
            width: context.wPx(55),
          ),
          context.spaceWPx(8),
          Container(
            height: context.hPx(56),
            width: context.wPx(316),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Color(0xff007AFF),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buttoncontent,
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Image.asset(
                    'assets/transfer/send.png',
                    height: context.hPx(24),
                    width: context.wPx(24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
