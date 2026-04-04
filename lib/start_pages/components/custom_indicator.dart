import 'package:flutter/material.dart';

class CustomIndicator extends StatelessWidget {
  final int currentIndex;
  final int itemCount;

  const CustomIndicator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            color:
                currentIndex == index
                    ? const Color(0xFF21496A) // selected
                    : const Color(0xFFE5E5E5), // unselected
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
