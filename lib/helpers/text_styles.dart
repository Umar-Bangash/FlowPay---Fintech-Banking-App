import 'package:flutter/material.dart';

Widget boldBigText(String text) {
  return Text(
    text,
    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  );
}

Widget mediumText(String text) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  );
}

Widget mediumGreyText(String text) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color(0xff737373),
    ),
  );
}
