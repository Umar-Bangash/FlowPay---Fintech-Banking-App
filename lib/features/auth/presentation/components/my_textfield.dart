import 'package:flutter/material.dart';

import '../../../../helpers/ui_responsive_helper.dart';

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
    AppResponsive.init(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppResponsive.h(4)),
      child: TextFormField(
        onTap: onTap,
        readOnly: readOnly,
        onChanged: onChange,
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(fontSize: AppResponsive.fs(14)),
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          label: lable,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xffE5E5E5)),
            borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff007AFF)),
            borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: const Color(0xffA3A3A3),
            fontSize: AppResponsive.fs(13),
          ),
        ),
      ),
    );
  }
}
