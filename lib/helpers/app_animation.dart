import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
///  AppAnimations  –  Premium Page & Widget Animation Utility
///  Slide-in animations from left/right/bottom + fade for every screen.
///  Use AppAnimatedPage as your screen wrapper — zero boilerplate per screen.
/// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────
//  ENUMS
// ─────────────────────────────────────────────────────────────

enum SlideDirection { left, right, bottom, top }

// ─────────────────────────────────────────────────────────────
//  1.  AppAnimatedPage
//      Wrap your entire screen Scaffold with this.
//      Children animate in staggered from the direction you choose.
// ─────────────────────────────────────────────────────────────

class AppAnimatedPage extends StatefulWidget {
  final Widget child;

  /// Overall entry animation direction for the whole page.
  final SlideDirection direction;

  /// Duration of a single item's animation.
  final Duration duration;

  /// Delay before the page starts animating (good for route transitions).
  final Duration initialDelay;

  const AppAnimatedPage({
    super.key,
    required this.child,
    this.direction = SlideDirection.bottom,
    this.duration = const Duration(milliseconds: 500),
    this.initialDelay = const Duration(milliseconds: 80),
  });

  @override
  State<AppAnimatedPage> createState() => _AppAnimatedPageState();
}

class _AppAnimatedPageState extends State<AppAnimatedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);

    _slide = Tween<Offset>(
      begin: _offsetFor(widget.direction),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));

    Future.delayed(widget.initialDelay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  2.  AppAnimatedItem
//      Wrap individual widgets (cards, rows, form fields, buttons)
//      with this for staggered entry animations.
//
//      index  → controls stagger delay (0, 1, 2, 3 …)
//      direction → left / right / bottom / top
// ─────────────────────────────────────────────────────────────

class AppAnimatedItem extends StatefulWidget {
  final Widget child;
  final int index;
  final SlideDirection direction;
  final Duration duration;
  final Duration baseDelay;

  const AppAnimatedItem({
    super.key,
    required this.child,
    this.index = 0,
    this.direction = SlideDirection.bottom,
    this.duration = const Duration(milliseconds: 450),
    this.baseDelay = const Duration(milliseconds: 80),
  });

  @override
  State<AppAnimatedItem> createState() => _AppAnimatedItemState();
}

class _AppAnimatedItemState extends State<AppAnimatedItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);

    _slide = Tween<Offset>(
      begin: _offsetFor(widget.direction),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));

    // Stagger: each index adds baseDelay
    final stagger = widget.baseDelay * widget.index;
    Future.delayed(stagger, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  3.  AppAnimatedList
//      Pass a list of widgets — each one staggers in
//      automatically. alternateDirections = true makes
//      odd items come from left, even from right (premium look).
// ─────────────────────────────────────────────────────────────

class AppAnimatedList extends StatelessWidget {
  final List<Widget> children;
  final bool alternateDirections;
  final SlideDirection defaultDirection;
  final Duration baseDelay;
  final Duration itemDuration;
  final double spacing;

  const AppAnimatedList({
    super.key,
    required this.children,
    this.alternateDirections = false,
    this.defaultDirection = SlideDirection.bottom,
    this.baseDelay = const Duration(milliseconds: 80),
    this.itemDuration = const Duration(milliseconds: 450),
    this.spacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(children.length, (i) {
        final dir =
            alternateDirections
                ? (i.isEven ? SlideDirection.left : SlideDirection.right)
                : defaultDirection;

        return Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: AppAnimatedItem(
            index: i,
            direction: dir,
            duration: itemDuration,
            baseDelay: baseDelay,
            child: children[i],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  4.  AppFadeIn
//      Simple fade-in only (for images, icons, backgrounds).
// ─────────────────────────────────────────────────────────────

class AppFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const AppFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<AppFadeIn> createState() => _AppFadeInState();
}

class _AppFadeInState extends State<AppFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _fade, child: widget.child);
}

// ─────────────────────────────────────────────────────────────
//  5.  AppScaleIn
//      Scale + fade in (great for QR codes, modals, icons).
// ─────────────────────────────────────────────────────────────

class AppScaleIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double beginScale;

  const AppScaleIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.beginScale = 0.85,
  });

  @override
  State<AppScaleIn> createState() => _AppScaleInState();
}

class _AppScaleInState extends State<AppScaleIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: ScaleTransition(scale: _scale, child: widget.child),
  );
}

// ─────────────────────────────────────────────────────────────
//  INTERNAL HELPER
// ─────────────────────────────────────────────────────────────

Offset _offsetFor(SlideDirection dir) {
  switch (dir) {
    case SlideDirection.left:
      return const Offset(-0.25, 0);
    case SlideDirection.right:
      return const Offset(0.25, 0);
    case SlideDirection.top:
      return const Offset(0, -0.25);
    case SlideDirection.bottom:
      return const Offset(0, 0.20);
  }
}


// ─────────────────────────────────────────────────────────────────────────────
//  USAGE GUIDE
// ─────────────────────────────────────────────────────────────────────────────
//
//  ── Wrap the whole screen (Scaffold) ──────────────────────────────────────
//
//    @override
//    Widget build(BuildContext context) {
//      AppResponsive.init(context);
//      return AppAnimatedPage(                    // ← wraps Scaffold
//        direction: SlideDirection.bottom,
//        child: Scaffold(
//          body: ...,
//        ),
//      );
//    }
//
//  ── Stagger individual cards / rows ───────────────────────────────────────
//
//    Column(children: [
//      AppAnimatedItem(index: 0, direction: SlideDirection.left,  child: balanceCard),
//      AppAnimatedItem(index: 1, direction: SlideDirection.right, child: quickActions),
//      AppAnimatedItem(index: 2, direction: SlideDirection.bottom,child: transactionList),
//    ])
//
//  ── Auto-staggered list (alternates left ↔ right) ─────────────────────────
//
//    AppAnimatedList(
//      alternateDirections: true,
//      spacing: AppResponsive.sm,
//      children: transactionWidgets,   // any list of widgets
//    )
//
//  ── Fade in a background image or icon ────────────────────────────────────
//
//    AppFadeIn(
//      delay: Duration(milliseconds: 200),
//      child: Image.asset('assets/logo.png'),
//    )
//
//  ── Scale in a QR code or modal card ──────────────────────────────────────
//
//    AppScaleIn(
//      delay: Duration(milliseconds: 150),
//      child: qrWidget,
//    )
//
//  ── Recommended delay presets ─────────────────────────────────────────────
//
//    Header / hero card    → index: 0  (appears first)
//    Balance / amount      → index: 1
//    Action buttons row    → index: 2
//    Section title         → index: 3
//    Transaction list      → index: 4  (each item inside also staggers)
//    Bottom button / FAB   → index: 5  (appears last)
//
// ─────────────────────────────────────────────────────────────────────────────