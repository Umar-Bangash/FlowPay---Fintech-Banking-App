import 'package:flowpay/helpers/text_styles.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget billAppBar(BuildContext context, String appBarName) {
  return AppBar(
    leading: InkWell(
      onTap: () => Navigator.pop(context),
      child: Icon(Icons.arrow_back_ios),
    ),
    title: mediumText(appBarName),
    backgroundColor: Color(0xffFFFFFF),
  );
}
