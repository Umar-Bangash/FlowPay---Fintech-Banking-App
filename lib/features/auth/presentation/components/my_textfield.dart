import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final bool readOnly;
  final String hintText;
  final Widget? lable;
  Widget? suffixIcon;
  void Function(String)? onChange;
  final VoidCallback? onTap;

  MyTextField({
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.lable,
    this.suffixIcon,
    this.onChange,
    super.key,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.padSymmetricPx(vertical: 4),
      child: TextFormField(
        onTap: onTap,
        readOnly: readOnly,
        onChanged: onChange,
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          label: lable,
          // border when unselected
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffE5E5E5)),
            borderRadius: BorderRadius.circular(12),
          ),
          // border when selected
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffE5E5E5)),
            borderRadius: BorderRadius.circular(12),
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Color(0xffA3A3A3)),
        ),
      ),
    );
  }
}
