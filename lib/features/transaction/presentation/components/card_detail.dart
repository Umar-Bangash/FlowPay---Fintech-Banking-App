import 'package:flutter/material.dart';
import '../../../../helpers/ui_responsive_helper.dart';

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
    AppResponsive.init(context);
    final imgSz = AppResponsive.sp(52).clamp(40.0, 66.0);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.w(14),
        vertical: AppResponsive.h(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: imgSz,
            width: imgSz,
            decoration: BoxDecoration(
              color: imageCardColor,
              borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
            ),
            child: Center(child: image),
          ),
          SizedBox(height: AppResponsive.h(10)),
          Text(
            name,
            style: TextStyle(
              fontSize: AppResponsive.fs(12),
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppResponsive.h(4)),
          subTitle,
        ],
      ),
    );
  }
}
