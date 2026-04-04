import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final double width; // total width of switch
  final double height; // total height of switch
  final double thumbSize; // size of the circular thumb
  final double padding; // inner horizontal padding
  final bool value;
  final VoidCallback onTap;

  final Color activeColor;
  final Color inactiveColor;
  final Color activeThumbColor;
  final Color inactiveThumbColor;

  const CustomSwitch({
    super.key,
    required this.width,
    required this.height,
    required this.thumbSize,
    this.padding = 3,
    required this.value,
    required this.onTap,
    this.activeColor = const Color(0xFFE5EEFF),
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.activeThumbColor = const Color(0xFF3A7AFE),
    this.inactiveThumbColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height),
          color: value ? activeColor : inactiveColor,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: thumbSize,
            height: thumbSize,
            decoration: BoxDecoration(
              color: value ? activeThumbColor : inactiveThumbColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
