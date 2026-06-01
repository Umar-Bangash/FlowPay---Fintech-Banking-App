import 'dart:math' as math;
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowpay/navigations/navigation_page.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../helpers/app_animation.dart';
import '../../../../../../helpers/ui_responsive_helper.dart';

enum FingerprintLockMode { register, login, transaction }

class FingerprintLockPage extends StatefulWidget {
  final FingerprintLockMode mode;
  final VoidCallback? onVerified;
  const FingerprintLockPage({
    super.key,
    this.mode = FingerprintLockMode.register,
    this.onVerified,
  });
  @override
  State<FingerprintLockPage> createState() => _FingerprintLockPageState();
}

class _FingerprintLockPageState extends State<FingerprintLockPage>
    with TickerProviderStateMixin {
  double _fill = 0.0;
  bool _scanning = false;
  bool _success = false;
  bool _failed = false;
  String _status = '';

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _successCtrl;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _successScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut));

    WidgetsBinding.instance.addPostFrameCallback((_) => _scan());
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    if (_scanning) return;
    setState(() {
      _scanning = true;
      _failed = false;
      _success = false;
      _fill = 0.0;
      _status = '';
    });
    try {
      final repo = context.read<AuthCubit>().biometricAuthRepo;
      final ok = await repo.authenticateWithFingerprint();
      if (!mounted) return;
      if (ok) {
        _pulseCtrl.stop();
        await _animateFill(1.0, 700);
        if (!mounted) return;
        setState(() => _success = true);
        _successCtrl.forward();
        await _handleSuccess();
      } else {
        _fail('Fingerprint not recognized. Try again.');
      }
    } catch (_) {
      _fail('Something went wrong. Try again.');
    }
  }

  Future<void> _handleSuccess() async {
    final cubit = context.read<AuthCubit>();
    switch (widget.mode) {
      case FingerprintLockMode.register:
        final uid = cubit.currentUser?.uid;
        if (uid != null) await cubit.markFingerprintEnabled(uid);
        await Future.delayed(const Duration(milliseconds: 900));
        if (mounted)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const NavigationPage()),
            (r) => false,
          );
        break;
      case FingerprintLockMode.login:
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) await cubit.loginWithFingerprint();
        break;
      case FingerprintLockMode.transaction:
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) widget.onVerified?.call();
        break;
    }
  }

  Future<void> _animateFill(double to, int ms) async {
    final start = _fill;
    const steps = 60;
    final stepMs = ms ~/ steps;
    final diff = to - start;
    for (int i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepMs));
      if (!mounted) return;
      setState(() => _fill = start + diff * i / steps);
    }
  }

  void _fail(String msg) {
    if (!mounted) return;
    _pulseCtrl.stop();
    setState(() {
      _scanning = false;
      _failed = true;
      _fill = 0.0;
      _status = msg;
    });
  }

  void _retry() {
    setState(() {
      _failed = false;
      _success = false;
      _scanning = false;
      _fill = 0.0;
      _status = '';
    });
    _successCtrl.reset();
    _pulseCtrl.repeat(reverse: true);
    _scan();
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return BlocListener<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is Authenticated &&
            widget.mode == FingerprintLockMode.login) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const NavigationPage()),
            (r) => false,
          );
        }
        if (state is AuthError) _fail(state.message);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Colors.black,
            ),
          ),
        ),
        body: AppAnimatedPage(
          direction: SlideDirection.bottom,
          child: SafeArea(
            child: SizedBox.expand(
              child: Column(
                children: [
                  SizedBox(height: AppResponsive.h(10)),

                  // ── Title ──────────────────────────────────────────────
                  AppAnimatedItem(
                    index: 0,
                    direction: SlideDirection.left,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _success
                            ? 'Success'
                            : _failed
                            ? 'Try Again'
                            : 'Place your Finger',
                        key: ValueKey(
                          _success
                              ? 's'
                              : _failed
                              ? 'f'
                              : 'i',
                        ),
                        style: TextStyle(
                          fontSize: AppResponsive.fs(22),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(10)),

                  // ── Subtitle ───────────────────────────────────────────
                  AppAnimatedItem(
                    index: 1,
                    direction: SlideDirection.right,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _success
                            ? 'You will use this to log in and\nauthorize payments'
                            : _failed
                            ? 'Fingerprint not recognized.\nPlease try again.'
                            : 'Place your finger firmly on your phone\'s\nfingerprint sensor to register it',
                        key: ValueKey(
                          _success
                              ? 's'
                              : _failed
                              ? 'f'
                              : 'i',
                        ),
                        style: TextStyle(
                          fontSize: AppResponsive.fs(13),
                          color: const Color(0xff737373),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(50)),

                  // ── Fingerprint graphic — responsive size ──────────────
                  AppAnimatedItem(
                    index: 2,
                    direction: SlideDirection.bottom,
                    child: ScaleTransition(
                      scale:
                          _success
                              ? _successScale
                              : (_scanning && !_failed)
                              ? _pulseAnim
                              : const AlwaysStoppedAnimation(1.0),
                      child: SizedBox(
                        // Size based on screen — never too big on tablet, never tiny on SE
                        width: AppResponsive.w(180).clamp(140.0, 220.0),
                        height: AppResponsive.w(180).clamp(140.0, 220.0),
                        child: CustomPaint(
                          painter: _FingerprintPainter(
                            fillProgress: _fill,
                            isFailed: _failed,
                            isSuccess: _success,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(28)),

                  // ── Status text ────────────────────────────────────────
                  AnimatedOpacity(
                    opacity: _status.isNotEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _status.isNotEmpty ? _status : ' ',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(13),
                        color: _failed ? Colors.redAccent : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Spacer(),

                  // ── Button ─────────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppResponsive.w(25),
                    ),
                    child:
                        _success
                            ? MainButton(
                              buttonName: 'Continue',
                              onTap:
                                  () => Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const NavigationPage(),
                                    ),
                                    (r) => false,
                                  ),
                            )
                            : _failed
                            ? MainButton(buttonName: 'Try Again', onTap: _retry)
                            : Opacity(
                              opacity: 0.45,
                              child: MainButton(
                                buttonName: 'Continue',
                                onTap: () {},
                              ),
                            ),
                  ),

                  SizedBox(height: AppResponsive.h(36)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Fingerprint CustomPainter (unchanged logic)
// ─────────────────────────────────────────────
class _FingerprintPainter extends CustomPainter {
  final double fillProgress;
  final bool isFailed;
  final bool isSuccess;
  static const _grey = Color(0xffDDDDDD);
  static const _blue = Color(0xff3B6FE8);

  _FingerprintPainter({
    required this.fillProgress,
    required this.isFailed,
    required this.isSuccess,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final active = isFailed ? Colors.redAccent : _blue;
    const total = 9;

    for (int i = 0; i < total; i++) {
      final t = i / (total - 1);
      final radius = size.width * 0.10 + size.width * 0.38 * t;
      final sweepD = 160.0 + t * 60.0;
      final sweepR = sweepD * math.pi / 180;
      final startR = (-90.0 - sweepD / 2 + i * 2.0) * math.pi / 180;
      final sw = 2.8 + t * 1.2;
      final thr = i / total;
      final prog = ((fillProgress - thr) * total).clamp(0.0, 1.0);
      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
      final base =
          Paint()
            ..color = _grey
            ..style = PaintingStyle.stroke
            ..strokeWidth = sw
            ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startR, sweepR, false, base);
      if (prog > 0) {
        canvas.drawArc(
          rect,
          startR,
          sweepR * prog,
          false,
          Paint()
            ..color = active
            ..style = PaintingStyle.stroke
            ..strokeWidth = sw
            ..strokeCap = StrokeCap.round,
        );
      }
    }
    canvas.drawCircle(
      Offset(cx, cy),
      4.0,
      Paint()
        ..color = fillProgress > 0 ? active : _grey
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_FingerprintPainter o) =>
      o.fillProgress != fillProgress ||
      o.isFailed != isFailed ||
      o.isSuccess != isSuccess;
}
