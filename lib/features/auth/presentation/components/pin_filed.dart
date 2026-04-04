import 'package:flutter/material.dart';

Widget pinField(String text) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffE5E5E5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ),
    ),
  );
}
