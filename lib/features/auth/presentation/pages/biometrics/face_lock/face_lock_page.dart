import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowpay/navigations/navigation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../helpers/ui_responsive_helper.dart';

enum FaceLockMode { register, login, transaction }

class FaceLockPage extends StatefulWidget {
  final FaceLockMode mode;
  final String? uid;
  const FaceLockPage({super.key, required this.mode, this.uid});
  @override
  State<FaceLockPage> createState() => _FaceLockPageState();
}

class _FaceLockPageState extends State<FaceLockPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _cam;
  bool _camReady = false;
  bool _processing = false;
  bool _captured = false;

  double _progress = 0.0;
  String _status = 'Hold your face still';
  bool _showRetry = false;
  Timer? _timer;

  late AnimationController _scanCtrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      final front = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      _cam = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _cam!.initialize();
      if (mounted) {
        setState(() => _camReady = true);
        _startCapture();
      }
    } catch (_) {
      if (mounted) setState(() => _status = 'Camera error');
    }
  }

  void _startCapture() {
    if (_processing || _captured) return;
    setState(() {
      _progress = 0.0;
      _status = 'Hold your face still';
      _showRetry = false;
    });
    int tick = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      tick++;
      final p = (tick * 0.60) / 100;
      if (p >= 0.3 && p < 0.6) {
        setState(() => _status = 'Scanning face...');
      } else if (p >= 0.6 && p < 1.0) {
        setState(() => _status = 'Almost done...');
      }
      if (p >= 1.0) {
        t.cancel();
        setState(() {
          _progress = 1.0;
          _status = 'Sending to server...';
        });
        _captureAndProcess();
      } else {
        setState(() => _progress = p);
      }
    });
  }

  Future<void> _captureAndProcess() async {
    if (_cam == null ||
        !_cam!.value.isInitialized ||
        _processing ||
        _captured) {
      return;
    }
    setState(() {
      _processing = true;
      _captured = true;
    });
    try {
      final img = await _cam!.takePicture();
      final cubit = context.read<AuthCubit>();
      switch (widget.mode) {
        case FaceLockMode.register:
          await cubit.registerFaceEmbedding(img);
          break;
        case FaceLockMode.login:
          if (widget.uid == null) {
            _serverError('User ID missing.');
            return;
          }
          await cubit.loginWithFace(uid: widget.uid!, capturedImage: img);
          break;
        case FaceLockMode.transaction:
          if (widget.uid == null) {
            _serverError('User ID missing.');
            return;
          }
          await cubit.verifyFaceForTransaction(
            uid: widget.uid!,
            capturedImage: img,
          );
          break;
      }
    } catch (_) {
      _serverError('Something went wrong');
    }
  }

  void _reset(String msg) {
    if (!mounted) return;
    setState(() {
      _status = msg;
      _processing = false;
      _captured = false;
      _progress = 0.0;
      _showRetry = false;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _startCapture();
    });
  }

  void _serverError(String msg) {
    if (!mounted) return;
    setState(() {
      _status = msg;
      _processing = false;
      _captured = false;
      _progress = 0.0;
      _showRetry = true;
    });
  }

  String _friendly(String raw) {
    if (raw.contains('server') ||
        raw.contains('unavailable') ||
        raw.contains('HF') ||
        raw.contains('500')) {
      return 'Server unavailable';
    }
    if (raw.contains('internet') || raw.contains('connection')) {
      return 'Check your internet';
    }
    if (raw.contains('No face') || raw.contains('detected')) {
      return 'No face detected';
    }
    if (raw.contains('lighting')) return 'Try better lighting';
    if (raw.contains('registered')) return 'No face registered';
    return raw.length > 30 ? '${raw.substring(0, 30)}...' : raw;
  }

  bool _isServerErr(String r) =>
      r.contains('server') ||
      r.contains('unavailable') ||
      r.contains('HF') ||
      r.contains('500') ||
      r.contains('face embedding');

  void _handleState(BuildContext ctx, AuthStates state) {
    if (state is FaceRegistrationSuccess) {
      setState(() {
        _status = 'Face registered!';
        _showRetry = false;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            ctx,
            MaterialPageRoute(builder: (_) => const NavigationPage()),
            (r) => false,
          );
        }
      });
    }
    if (state is FaceRegistrationError) {
      _isServerErr(state.message)
          ? _serverError('Server unavailable')
          : _reset(_friendly(state.message));
    }
    if (state is FaceVerificationSuccess) {
      setState(() {
        _status = 'Identity verified!';
        _showRetry = false;
      });
      if (widget.mode == FaceLockMode.transaction) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(ctx, true);
        });
      }
    }
    if (state is FaceVerificationFailed) _reset('Face not recognized');
    if (state is FaceVerificationError) {
      _isServerErr(state.message)
          ? _serverError('Server unavailable')
          : _reset(_friendly(state.message));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (_cam == null) return;
    if (s == AppLifecycleState.inactive) {
      _timer?.cancel();
      _cam!.dispose();
    } else if (s == AppLifecycleState.resumed)
      _initCamera();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scanCtrl.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _cam?.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.mode) {
      case FaceLockMode.register:
        return 'Face Recognition';
      case FaceLockMode.login:
        return 'Face Login';
      case FaceLockMode.transaction:
        return 'Verify Identity';
    }
  }

  Color get _borderColor {
    if (_progress < 0.5) return Colors.blueAccent;
    if (_progress < 1.0) return Colors.lightBlueAccent;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return BlocConsumer<AuthCubit, AuthStates>(
      listener: _handleState,
      builder: (ctx, state) {
        final isSuccess =
            state is FaceRegistrationSuccess ||
            state is FaceVerificationSuccess;
        final isApiLoading =
            state is FaceRegistrationLoading ||
            state is FaceVerificationLoading;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // ── Camera preview
              if (_camReady && _cam != null)
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cam!.value.previewSize!.height,
                      height: _cam!.value.previewSize!.width,
                      child: CameraPreview(_cam!),
                    ),
                  ),
                )
              else
                Container(color: Colors.black),

              // ── Side vignette
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xCC000000),
                      Colors.transparent,
                      Colors.transparent,
                      Color(0xCC000000),
                    ],
                    stops: [0.0, 0.25, 0.75, 1.0],
                  ),
                ),
              ),

              // ── Top + bottom fade
              Column(
                children: [
                  Container(
                    height: AppResponsive.hp(15),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xDD000000), Colors.transparent],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: AppResponsive.hp(30),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xEE000000), Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),

              // ── UI layer
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: AppResponsive.h(14)),
                    _topBar(ctx),
                    SizedBox(height: AppResponsive.h(8)),
                    Text(
                      'Look into the camera and hold still',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: AppResponsive.fs(12),
                      ),
                    ),
                    const Spacer(),
                    _scanFrame(isSuccess),
                    const Spacer(),
                    _statusPill(isApiLoading),
                    SizedBox(height: AppResponsive.h(14)),
                    if (_showRetry && !isApiLoading) _errorBanner(),
                    SizedBox(height: AppResponsive.h(14)),
                    _circularProgress(isSuccess, isApiLoading),
                    SizedBox(height: AppResponsive.h(36)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _topBar(BuildContext ctx) => Padding(
    padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(20)),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: Container(
            height: AppResponsive.sp(34),
            width: AppResponsive.sp(34),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: AppResponsive.sp(13),
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(width: AppResponsive.w(16)),
        Text(
          _title,
          style: TextStyle(
            color: Colors.white,
            fontSize: AppResponsive.fs(20),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  Widget _scanFrame(bool isSuccess) {
    // Responsive frame — 72% of width, max 400 wide; height proportional
    final fw = (AppResponsive.screenWidth * 0.72).clamp(220.0, 340.0);
    final fh = (AppResponsive.screenHeight * 0.40).clamp(260.0, 420.0);
    final color = isSuccess ? Colors.greenAccent : _borderColor;

    return SizedBox(
      width: fw,
      height: fh,
      child: Stack(
        children: [
          if (!isSuccess)
            AnimatedBuilder(
              animation: _scanCtrl,
              builder:
                  (_, __) => Positioned(
                    top: _scanCtrl.value * (fh - 2),
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.blueAccent.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
            ),
          ..._corners(fw, fh, color),
          if (isSuccess)
            const Center(
              child: Icon(
                Icons.check_circle_outline,
                color: Colors.greenAccent,
                size: 70,
              ),
            ),
          if (_showRetry && !isSuccess)
            Center(
              child: Icon(
                Icons.cloud_off,
                color: Colors.redAccent.withOpacity(0.7),
                size: AppResponsive.sp(44),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _corners(double w, double h, Color c) {
    const l = 28.0;
    const t = 3.0;
    return [
      Positioned(
        top: 0,
        left: 0,
        child: _bracket(l, t, c, top: true, left: true),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: _bracket(l, t, c, top: true, left: false),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: _bracket(l, t, c, top: false, left: true),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: _bracket(l, t, c, top: false, left: false),
      ),
    ];
  }

  Widget _bracket(
    double len,
    double thick,
    Color color, {
    required bool top,
    required bool left,
  }) => SizedBox(
    width: len,
    height: len,
    child: CustomPaint(
      painter: _BracketPainter(
        color: color,
        thickness: thick,
        top: top,
        left: left,
      ),
    ),
  );

  Widget _statusPill(bool apiLoading) => Container(
    constraints: BoxConstraints(maxWidth: AppResponsive.wp(85)),
    padding: EdgeInsets.symmetric(
      horizontal: AppResponsive.w(18),
      vertical: AppResponsive.h(7),
    ),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.55),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: _showRetry ? Colors.redAccent.withOpacity(0.5) : Colors.white24,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (apiLoading) ...[
          SizedBox(
            width: AppResponsive.sp(12),
            height: AppResponsive.sp(12),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(width: AppResponsive.w(8)),
        ] else if (_showRetry) ...[
          Icon(
            Icons.error_outline,
            color: Colors.redAccent,
            size: AppResponsive.sp(13),
          ),
          SizedBox(width: AppResponsive.w(6)),
        ],
        Flexible(
          child: Text(
            apiLoading ? 'Processing...' : _status,
            style: TextStyle(
              color: _showRetry ? Colors.redAccent : Colors.white,
              fontSize: AppResponsive.fs(12),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );

  Widget _errorBanner() => Container(
    margin: EdgeInsets.symmetric(horizontal: AppResponsive.w(24)),
    padding: EdgeInsets.symmetric(
      horizontal: AppResponsive.w(14),
      vertical: AppResponsive.h(12),
    ),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.15),
      borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
      border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.cloud_off,
              color: Colors.redAccent,
              size: AppResponsive.sp(15),
            ),
            SizedBox(width: AppResponsive.w(8)),
            Flexible(
              child: Text(
                'Face server is unavailable.\nAsk your friend to restart the HF Space.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: AppResponsive.fs(11),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppResponsive.h(10)),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _startCapture,
            style: TextButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
              ),
              padding: EdgeInsets.symmetric(vertical: AppResponsive.h(10)),
            ),
            child: Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: AppResponsive.fs(13),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _circularProgress(bool isSuccess, bool apiLoading) {
    final sz = AppResponsive.sp(80).clamp(64.0, 100.0);
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: sz + 10,
          height: sz + 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                _showRetry
                    ? Colors.red.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.15),
          ),
        ),
        SizedBox(
          width: sz,
          height: sz,
          child: CircularProgressIndicator(
            value: apiLoading ? null : _progress,
            strokeWidth: 5,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(
              isSuccess
                  ? Colors.greenAccent
                  : _showRetry
                  ? Colors.redAccent
                  : Colors.blueAccent,
            ),
          ),
        ),
        Text(
          apiLoading
              ? '...'
              : isSuccess
              ? '✓'
              : _showRetry
              ? '!'
              : '${(_progress * 100).toInt()}%',
          style: TextStyle(
            color:
                isSuccess
                    ? Colors.greenAccent
                    : _showRetry
                    ? Colors.redAccent
                    : Colors.white,
            fontSize:
                isSuccess || _showRetry
                    ? AppResponsive.fs(20)
                    : AppResponsive.fs(15),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ─── Bracket painter (unchanged)
class _BracketPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool top, left;
  _BracketPainter({
    required this.color,
    required this.thickness,
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p =
        Paint()
          ..color = color
          ..strokeWidth = thickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    final dx = left ? size.width : -size.width;
    final dy = top ? size.height : -size.height;
    canvas.drawLine(Offset(x, y), Offset(x + dx, y), p);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), p);
  }

  @override
  bool shouldRepaint(_BracketPainter o) =>
      o.color != color || o.thickness != thickness;
}
