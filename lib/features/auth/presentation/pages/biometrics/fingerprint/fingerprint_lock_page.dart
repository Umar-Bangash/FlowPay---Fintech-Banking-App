import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowpay/helpers/text_styles.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flowpay/navigations/navigation_page.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum FingerprintLockMode { register, login, transaction }

class FingerprintLockPage extends StatefulWidget {
  final FingerprintLockMode mode;
  final VoidCallback? onVerified; // used for transaction mode

  const FingerprintLockPage({
    super.key,
    this.mode = FingerprintLockMode.register,
    this.onVerified,
  });

  @override
  State<FingerprintLockPage> createState() => _FingerprintLockPageState();
}

class _FingerprintLockPageState extends State<FingerprintLockPage>
    with SingleTickerProviderStateMixin {
  // 0.0 → 1.0 fill progress
  double _fillProgress = 0.0;
  bool _isScanning = false;
  bool _isSuccess = false;
  bool _isFailed = false;
  String _statusText = '';

  late AnimationController _successController;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _successScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    // Auto trigger fingerprint scan on page open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startFingerprintScan();
    });
  }

  // ─────────────────────────────────────────────
  // START SCAN — animate fill then trigger biometric
  // ─────────────────────────────────────────────
  Future<void> _startFingerprintScan() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _isFailed = false;
      _fillProgress = 0.0;
      _statusText = '';
    });

    // Animate fill progress 0 → 0.85 while waiting for biometric
    _animateFill(to: 0.85, durationMs: 1500);

    try {
      final biometricRepo = context.read<AuthCubit>().biometricAuthRepo;
      final success = await biometricRepo.authenticateWithFingerprint();

      if (!mounted) return;

      if (success) {
        // Complete the fill to 100%
        await _animateFill(to: 1.0, durationMs: 300);
        setState(() => _isSuccess = true);
        _successController.forward();

        // Handle based on mode
        switch (widget.mode) {
          case FingerprintLockMode.register:
            // Mark fingerprint enabled in Firestore
            await _markFingerprintEnabled();
            break;

          case FingerprintLockMode.login:
            await _loginWithStoredCredentials();
            break;

          case FingerprintLockMode.transaction:
            await Future.delayed(const Duration(milliseconds: 800));
            if (mounted) widget.onVerified?.call();
            break;
        }
      } else {
        _handleFailure('Fingerprint not recognized. Try again.');
      }
    } catch (e) {
      _handleFailure('Fingerprint error. Try again.');
    }
  }

  // ─────────────────────────────────────────────
  // ANIMATE FILL
  // ─────────────────────────────────────────────
  Future<void> _animateFill({
    required double to,
    required int durationMs,
  }) async {
    final start = _fillProgress;
    final steps = 60;
    final stepDuration = durationMs ~/ steps;
    final diff = to - start;

    for (int i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      if (!mounted) return;
      setState(() => _fillProgress = start + (diff * i / steps));
    }
  }

  // ─────────────────────────────────────────────
  // MARK FINGERPRINT ENABLED IN FIRESTORE
  // ─────────────────────────────────────────────
  Future<void> _markFingerprintEnabled() async {
    try {
      final uid = context.read<AuthCubit>().currentUser?.uid;
      if (uid == null) return;

      await context.read<AuthCubit>().markFingerprintEnabled(uid);
    } catch (e) {
      debugPrint('markFingerprintEnabled error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // LOGIN WITH STORED CREDENTIALS
  // ─────────────────────────────────────────────
  Future<void> _loginWithStoredCredentials() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    await context.read<AuthCubit>().loginWithFingerprint();
  }

  // ─────────────────────────────────────────────
  // HANDLE FAILURE
  // ─────────────────────────────────────────────
  void _handleFailure(String message) {
    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _isFailed = true;
      _fillProgress = 0.0;
      _statusText = message;
    });
  }

  // ─────────────────────────────────────────────
  // RETRY
  // ─────────────────────────────────────────────
  void _retry() {
    setState(() {
      _isFailed = false;
      _isSuccess = false;
      _isScanning = false;
      _fillProgress = 0.0;
      _statusText = '';
    });
    _successController.reset();
    _startFingerprintScan();
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is Authenticated) {
          // Login mode — go home
          if (widget.mode == FingerprintLockMode.login) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const NavigationPage()),
              (route) => false,
            );
          }
        }
        if (state is AuthError) {
          _handleFailure(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Title
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child:
                    _isSuccess
                        ? boldBigText('Success')
                        : boldBigText('Place your Finger'),
              ),

              context.spaceHPx(15),

              // Subtitle
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child:
                    _isSuccess
                        ? mediumGreyText(
                          'You will use to do this to log in and\nauthorize payments',
                        )
                        : mediumGreyText(
                          'Place your finger firmly on your phone\'s \nfingerprint sensor to register it with the app',
                        ),
              ),

              context.spaceHPx(80),

              // Animated fingerprint
              ScaleTransition(
                scale:
                    _isSuccess
                        ? _successScale
                        : const AlwaysStoppedAnimation(1.0),
                child: _FingerprintWidget(
                  fillProgress: _fillProgress,
                  isFailed: _isFailed,
                  isSuccess: _isSuccess,
                ),
              ),

              context.spaceHPx(30),

              // Status text
              if (_statusText.isNotEmpty)
                Text(
                  _statusText,
                  style: TextStyle(
                    fontSize: 14,
                    color: _isFailed ? Colors.redAccent : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

              const Spacer(),

              // Continue button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child:
                    _isSuccess
                        ? MainButton(
                          buttonName: 'Continue',
                          onTap: () {
                            if (widget.mode == FingerprintLockMode.register) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NavigationPage(),
                                ),
                                (route) => false,
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        )
                        : _isFailed
                        ? MainButton(buttonName: 'Try Again', onTap: _retry)
                        : MainButton(
                          buttonName: 'Continue',
                          onTap: () {}, // disabled while scanning
                        ),
              ),

              context.spaceHPx(40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FINGERPRINT WIDGET — progressive fill
// ─────────────────────────────────────────────
class _FingerprintWidget extends StatelessWidget {
  final double fillProgress; // 0.0 to 1.0
  final bool isFailed;
  final bool isSuccess;

  const _FingerprintWidget({
    required this.fillProgress,
    required this.isFailed,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: CustomPaint(
        painter: _FingerprintPainter(
          fillProgress: fillProgress,
          isFailed: isFailed,
          isSuccess: isSuccess,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FINGERPRINT PAINTER — draws grey + blue arcs
// ─────────────────────────────────────────────
class _FingerprintPainter extends CustomPainter {
  final double fillProgress;
  final bool isFailed;
  final bool isSuccess;

  _FingerprintPainter({
    required this.fillProgress,
    required this.isFailed,
    required this.isSuccess,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final activeColor =
        isFailed
            ? Colors.redAccent
            : isSuccess
            ? Colors.green
            : const Color(0xff3B6FE8);

    // Draw concentric arcs — 8 rings like fingerprint
    final rings = 8;
    for (int i = 0; i < rings; i++) {
      final radius = (size.width / 2) * ((i + 1) / rings);
      final ringProgress = ((fillProgress * rings) - (rings - 1 - i)).clamp(
        0.0,
        1.0,
      );

      // Grey base ring
      final greyPaint =
          Paint()
            ..color = const Color(0xffDDDDDD)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.5
            ..strokeCap = StrokeCap.round;

      // Blue fill ring
      final bluePaint =
          Paint()
            ..color = activeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.5
            ..strokeCap = StrokeCap.round;

      const startAngle = -2.8; // slightly past left
      const sweepAngle = 5.6; // almost full circle

      // Draw grey background arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        greyPaint,
      );

      // Draw blue fill arc on top
      if (ringProgress > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle * ringProgress,
          false,
          bluePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FingerprintPainter old) =>
      old.fillProgress != fillProgress ||
      old.isFailed != isFailed ||
      old.isSuccess != isSuccess;
}
