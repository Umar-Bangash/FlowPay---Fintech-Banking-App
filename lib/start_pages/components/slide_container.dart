import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class SlideContainer extends StatelessWidget {
  final String imagePath;
  final double imgHeight;
  final double imgWidth;
  final String title;
  final String subTitle;
  const SlideContainer({
    super.key,
    required this.imagePath,
    required this.imgHeight,
    required this.imgWidth,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.wPx(350),
      child: Column(
        children: [
          Image.asset(imagePath, height: imgHeight, width: imgWidth),
          context.spaceHPx(context.hPx(50)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.textPx(32),
              fontWeight: FontWeight.bold,
            ),
          ),
          context.spaceHPx(context.hPx(8)),
          Text(
            subTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.textPx(16),
              color: Color(0xff737373),
            ),
          ),
        ],
      ),
    );
  }
}
