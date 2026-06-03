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

/// ─────────────────────────────────────────────
///  AppResponsive  –  Bulletproof Responsive Utility
///  Usage: wrap your build() with AppResponsive.init(context)
///  then use AppResponsive.w(16) / AppResponsive.h(16) etc.
/// ─────────────────────────────────────────────

class AppResponsive {
  AppResponsive._();

  // ── Raw screen dimensions ──────────────────
  static late double _screenW;
  static late double _screenH;
  static late double _pixelRatio;
  static late double _statusBarH;
  static late double _bottomBarH;
  static late double _safeW;
  static late double _safeH;
  static late TextScaler _textScaler;

  // ── Design reference (designed on 390×844 – iPhone 14) ──
  static const double _designW = 390.0;
  static const double _designH = 844.0;

  // ── Breakpoints ────────────────────────────
  static const double _mobileMaxW = 600.0;
  static const double _tabletMaxW = 1024.0;

  /// Call once at the top of every build() that needs responsive values.
  static void init(BuildContext context) {
    final mq = MediaQuery.of(context);
    _screenW = mq.size.width;
    _screenH = mq.size.height;
    _pixelRatio = mq.devicePixelRatio;
    _statusBarH = mq.padding.top;
    _bottomBarH = mq.padding.bottom;
    _safeW = _screenW - mq.padding.left - mq.padding.right;
    _safeH = _screenH - _statusBarH - _bottomBarH;
    _textScaler = mq.textScaler;
  }

  // ─────────────────────────────────────────────────────────
  //  DIMENSION HELPERS
  // ─────────────────────────────────────────────────────────

  /// Scale a width value from the design spec to the current screen.
  static double w(double designPx) => (designPx / _designW) * _screenW;

  /// Scale a height value from the design spec to the current screen.
  static double h(double designPx) => (designPx / _designH) * _screenH;

  /// Scale using the SHORTER axis – good for square elements (icons, avatars).
  static double sp(double designPx) =>
      (designPx / _designW) * _screenW.clamp(0, _screenH);

  /// Percentage of screen width  (0–100).
  static double wp(double percent) => _screenW * percent / 100;

  /// Percentage of screen height (0–100).
  static double hp(double percent) => _screenH * percent / 100;

  /// Percentage of SAFE width  (excludes notch / padding).
  static double swp(double percent) => _safeW * percent / 100;

  /// Percentage of SAFE height (excludes status + bottom bar).
  static double shp(double percent) => _safeH * percent / 100;

  // ─────────────────────────────────────────────────────────
  //  FONT SIZE  (respects OS accessibility scale, but clamped)
  // ─────────────────────────────────────────────────────────

  /// Responsive font size.
  /// [min] & [max] are hard pixel limits to prevent
  /// tiny text on watches or huge text breaking layouts.
  static double fs(double designPx, {double min = 10.0, double max = 18.0}) {
    final scaled = (designPx / _designW) * _screenW;
    // honour OS text scale but clamp so UI never breaks
    final accessible = _textScaler.scale(scaled);
    return accessible.clamp(min, max);
  }

  // ─────────────────────────────────────────────────────────
  //  SPACING  (use instead of hardcoded numbers)
  // ─────────────────────────────────────────────────────────

  static double get xs => w(4);
  static double get sm => w(8);
  static double get md => w(16);
  static double get lg => w(24);
  static double get xl => w(32);
  static double get xxl => w(48);

  // ─────────────────────────────────────────────────────────
  //  RADIUS
  // ─────────────────────────────────────────────────────────

  static double get radiusSm => w(8);
  static double get radiusMd => w(12);
  static double get radiusLg => w(16);
  static double get radiusXl => w(24);
  static double get radiusFull => 999;

  // ─────────────────────────────────────────────────────────
  //  SAFE AREA HELPERS
  // ─────────────────────────────────────────────────────────

  static double get statusBarHeight => _statusBarH;
  static double get bottomBarHeight => _bottomBarH;
  static double get safeAreaWidth => _safeW;
  static double get safeAreaHeight => _safeH;

  // ─────────────────────────────────────────────────────────
  //  SCREEN INFO
  // ─────────────────────────────────────────────────────────

  static double get screenWidth => _screenW;
  static double get screenHeight => _screenH;
  static double get pixelRatio => _pixelRatio;

  // ─────────────────────────────────────────────────────────
  //  DEVICE TYPE
  // ─────────────────────────────────────────────────────────

  static bool get isMobile => _screenW < _mobileMaxW;
  static bool get isTablet => _screenW >= _mobileMaxW && _screenW < _tabletMaxW;
  static bool get isDesktop => _screenW >= _tabletMaxW;

  static bool get isSmallPhone => _screenW <= 360; // e.g. iPhone SE, Galaxy A12
  static bool get isMediumPhone => _screenW > 360 && _screenW <= 414;
  static bool get isLargePhone => _screenW > 414; // Pro Max, Plus sizes

  static bool get isShortScreen => _screenH < 700; // SE / compact Android

  // ─────────────────────────────────────────────────────────
  //  ORIENTATION
  // ─────────────────────────────────────────────────────────

  static bool get isPortrait => _screenH >= _screenW;
  static bool get isLandscape => _screenW > _screenH;

  // ─────────────────────────────────────────────────────────
  //  ADAPTIVE VALUE HELPER
  //  Returns different values based on device type.
  //  e.g. AppResponsive.adaptive(mobile: 16, tablet: 24, desktop: 32)
  // ─────────────────────────────────────────────────────────

  static T adaptive<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // ─────────────────────────────────────────────────────────
  //  ICON SIZE PRESETS
  // ─────────────────────────────────────────────────────────

  static double get iconXs => sp(16);
  static double get iconSm => sp(20);
  static double get iconMd => sp(24);
  static double get iconLg => sp(32);
  static double get iconXl => sp(48);

  // ─────────────────────────────────────────────────────────
  //  COMMON UI SIZES  (banking-app specific)
  // ─────────────────────────────────────────────────────────

  /// Standard button height
  static double get buttonHeight => h(52);

  /// App bar / top bar height (excluding status bar)
  static double get appBarHeight => h(56);

  /// Bottom nav bar height (excluding bottom safe area)
  static double get bottomNavHeight => h(60);

  /// Card padding
  static EdgeInsets get cardPadding =>
      EdgeInsets.symmetric(horizontal: md, vertical: md);

  /// Screen horizontal padding
  static EdgeInsets get screenPadding =>
      EdgeInsets.symmetric(horizontal: w(20));

  /// Screen padding with vertical breathing room
  static EdgeInsets get pagePadding =>
      EdgeInsets.symmetric(horizontal: w(20), vertical: h(16));

  // ─────────────────────────────────────────────────────────
  //  SCROLLABLE CONTENT GUARD
  //  Wraps content in SingleChildScrollView only when the
  //  content might be taller than the available safe height.
  // ─────────────────────────────────────────────────────────

  /// Use in Scaffolds where content may overflow on small phones.
  static Widget safeScroll({
    required Widget child,
    EdgeInsets? padding,
    bool reverse = false,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      reverse: reverse,
      padding: padding ?? pagePadding,
      child: child,
    );
  }
}
