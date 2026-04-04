import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class CardDetail extends StatelessWidget {
  final Widget image;
  final Color imageCardColor;
  final Color titleColor;
  final String name;
  final Widget subTitle;

  const CardDetail({
    super.key,
    required this.image,
    required this.imageCardColor,
    required this.name,
    required this.titleColor,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.padSymmetricPx(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: context.hPx(60),
            width: context.wPx(60),
            decoration: BoxDecoration(
              color: imageCardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(child: image),
          ),
          context.spaceHPx(14),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          context.spaceHPx(6),
          subTitle,
        ],
      ),
    );
  }
}
