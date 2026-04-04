import 'package:flutter/material.dart';

/// Fully responsive pixel-based helper

extension ResponsivePx on BuildContext {
  // Current device dimensions
  double get _screenWidth => MediaQuery.of(this).size.width;
  double get _screenHeight => MediaQuery.of(this).size.height;

  // Width based scaling
  double wPx(double value) => _screenWidth * (value / _screenWidth);

  // Height based scaling
  double hPx(double value) => _screenHeight * (value / _screenHeight);

  // Font scaling
  double textPx(double value) => _screenWidth * (value / _screenWidth);

  // Padding helpers
  EdgeInsets padAllPx(double value) => EdgeInsets.all(wPx(value));

  EdgeInsets padSymmetricPx({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(
        horizontal: wPx(horizontal),
        vertical: hPx(vertical),
      );

  // Spacing helpers
  SizedBox spaceHPx(double value) => SizedBox(height: hPx(value));
  SizedBox spaceWPx(double value) => SizedBox(width: wPx(value));
}
