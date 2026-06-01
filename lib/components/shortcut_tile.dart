import 'package:flutter/material.dart';
import '../helpers/ui_responsive_helper.dart';

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
    AppResponsive.init(context);
    return LayoutBuilder(
      builder: (context, c) {
        final iconSz = (c.maxWidth * 0.32).clamp(18.0, 32.0);
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xffE8EDFF),
            borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppResponsive.w(6),
            vertical: AppResponsive.h(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(imagePath, height: iconSz, width: iconSz),
              SizedBox(height: AppResponsive.h(5)),
              Text(
                buttonName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppResponsive.fs(11),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

final List<ShortCutTile> listOfShortCuts = [
  const ShortCutTile(
    imagePath: 'assets/home/paybill.png',
    buttonName: 'Pay Bill',
  ),
  const ShortCutTile(imagePath: 'assets/home/recent.png', buttonName: 'Recent'),
  const ShortCutTile(
    imagePath: 'assets/home/request.png',
    buttonName: 'Request',
  ),
  const ShortCutTile(
    imagePath: 'assets/home/quicktransfer.png',
    buttonName: 'Quick\nTransfer',
  ),
];
