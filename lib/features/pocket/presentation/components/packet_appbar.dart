import 'package:flowpay/helpers/text_styles.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget pocketAppBar(
  BuildContext context,
  String appBarName,
  Widget child,
) {
  return AppBar(
    leading: InkWell(
      onTap: () => Navigator.pop(context),
      child: Icon(Icons.arrow_back_ios, size: 20),
    ),
    centerTitle: true,
    title: mediumText(appBarName),
    actions: [child, context.spaceWPx(15)],
    backgroundColor: Color(0xffFFFFFF),
  );
}
