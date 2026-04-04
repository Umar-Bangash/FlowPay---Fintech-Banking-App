// features/auth/presentation/pages/biometrics/face_lock/face_lock_page.dart

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowpay/navigations/navigation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  bool _captured = false;

  // ── Real-time progress simulation ──
  double _progress = 0.0;
  String _statusText = 'Hold your face';
  Timer? _progressTimer;
  late AnimationController _scanLineController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Scan line animation
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initCamera();
  }

  // ─────────────────────────────────────────────
  // CAMERA INIT
  // ─────────────────────────────────────────────
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() => _isCameraReady = true);
        // Auto start scanning after camera is ready
        _startAutoCapture();
      }
    } catch (e) {
      if (mounted) setState(() => _statusText = 'Camera error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // AUTO CAPTURE — starts progress then captures
  // ─────────────────────────────────────────────
  void _startAutoCapture() {
    if (_isProcessing || _captured) return;

    setState(() {
      _progress = 0.0;
      _statusText = 'Hold your face';
    });

    // Simulate real scanning progress over 3 seconds
    // then auto capture at 100%
    int tick = 0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      tick++;
      final newProgress = (tick * 0.60) / 100; // reaches 1.0 in ~100 ticks = 3s

      if (newProgress >= 0.3 && newProgress < 0.6) {
        setState(() => _statusText = 'Recognizing your face...');
      } else if (newProgress >= 0.6 && newProgress < 1.0) {
        setState(() => _statusText = 'Almost done...');
      }

      if (newProgress >= 1.0) {
        timer.cancel();
        setState(() {
          _progress = 1.0;
          _statusText = 'Face captured!';
        });
        // Auto capture at 100%
        _captureAndProcess();
      } else {
        setState(() => _progress = newProgress);
      }
    });
  }

  // ─────────────────────────────────────────────
  // CAPTURE + SEND TO CUBIT
  // ─────────────────────────────────────────────
  Future<void> _captureAndProcess() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing ||
        _captured)
      return;

    setState(() {
      _isProcessing = true;
      _captured = true;
    });

    try {
      final XFile image = await _cameraController!.takePicture();
      final cubit = context.read<AuthCubit>();

      switch (widget.mode) {
        case FaceLockMode.register:
          await cubit.registerFaceEmbedding(image);
          break;
        case FaceLockMode.login:
          if (widget.uid == null) {
            _resetState('User ID missing. Login with password first.');
            return;
          }
          await cubit.loginWithFace(uid: widget.uid!, capturedImage: image);
          break;
        case FaceLockMode.transaction:
          if (widget.uid == null) {
            _resetState('User ID missing.');
            return;
          }
          await cubit.verifyFaceForTransaction(
            uid: widget.uid!,
            capturedImage: image,
          );
          break;
      }
    } catch (e) {
      _resetState('Something went wrong. Try again.');
    }
  }

  void _resetState(String message) {
    if (mounted) {
      setState(() {
        _statusText = message;
        _isProcessing = false;
        _captured = false;
        _progress = 0.0;
      });
      // Restart auto capture after short delay
      Future.delayed(const Duration(seconds: 2), _startAutoCapture);
    }
  }

  // ─────────────────────────────────────────────
  // STATE LISTENER
  // ─────────────────────────────────────────────
  void _handleStateChanges(BuildContext context, AuthStates state) {
    if (state is FaceRegistrationSuccess) {
      setState(() => _statusText = 'Face registered successfully!');
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const NavigationPage()),
            (route) => false,
          );
        }
      });
    }

    if (state is FaceRegistrationError) {
      _resetState(state.message);
    }

    if (state is FaceVerificationSuccess) {
      setState(() => _statusText = 'Identity verified!');
      if (widget.mode == FaceLockMode.transaction) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context, true);
        });
      }
    }

    if (state is FaceVerificationFailed) {
      _resetState('Face not recognized. Scanning again...');
    }

    if (state is FaceVerificationError) {
      _resetState(state.message);
    }
  }

  String get _pageTitle {
    switch (widget.mode) {
      case FaceLockMode.register:
        return 'Face Recognition';
      case FaceLockMode.login:
        return 'Face Login';
      case FaceLockMode.transaction:
        return 'Verify Identity';
    }
  }

  // Border color based on progress
  Color get _borderColor {
    if (_progress < 0.5) return Colors.blueAccent;
    if (_progress < 1.0) return Colors.lightBlueAccent;
    return Colors.greenAccent;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null) return;
    if (state == AppLifecycleState.inactive) {
      _progressTimer?.cancel();
      _cameraController!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _scanLineController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: _handleStateChanges,
      builder: (context, state) {
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
              // ── 1. Full screen camera ──
              if (_isCameraReady && _cameraController != null)
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cameraController!.value.previewSize!.height,
                      height: _cameraController!.value.previewSize!.width,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                )
              else
                Container(color: Colors.black),

              // ── 2. Dark vignette overlay on sides ──
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

              // ── 3. Top + bottom dark overlay ──
              Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.15,
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
                    height: MediaQuery.of(context).size.height * 0.30,
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

              // ── 4. All UI on top ──
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 15),

                    // Top bar
                    _buildTopBar(context),

                    const SizedBox(height: 8),

                    Text(
                      'Please into the camera and hold still',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),

                    const Spacer(),

                    // ── Scan border frame ──
                    _buildScanFrame(isSuccess),

                    const Spacer(),

                    // ── Status pill ──
                    _buildStatusPill(isApiLoading),

                    const SizedBox(height: 20),

                    // ── Circular progress ──
                    _buildCircularProgress(isSuccess, isApiLoading),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // TOP BAR
  // ─────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 34,
              width: 34,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 14,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Text(
            _pageTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SCAN FRAME — corner brackets like your design
  // ─────────────────────────────────────────────
  Widget _buildScanFrame(bool isSuccess) {
    final color = isSuccess ? Colors.greenAccent : _borderColor;
    final size = MediaQuery.of(context).size;
    final frameW = size.width * 0.72;
    final frameH = size.height * 0.42;

    return SizedBox(
      width: frameW,
      height: frameH,
      child: Stack(
        children: [
          // Animated scan line
          if (!isSuccess)
            AnimatedBuilder(
              animation: _scanLineController,
              builder: (context, _) {
                return Positioned(
                  top: _scanLineController.value * (frameH - 2),
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
                );
              },
            ),

          // Corner brackets
          ..._buildCornerBrackets(frameW, frameH, color),

          // Success icon in center
          if (isSuccess)
            Center(
              child: Icon(
                Icons.check_circle_outline,
                color: Colors.greenAccent,
                size: 70,
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerBrackets(double w, double h, Color color) {
    const len = 28.0;
    const thick = 3.0;

    return [
      // Top-left
      Positioned(
        top: 0,
        left: 0,
        child: _bracket(len, thick, color, top: true, left: true),
      ),
      // Top-right
      Positioned(
        top: 0,
        right: 0,
        child: _bracket(len, thick, color, top: true, left: false),
      ),
      // Bottom-left
      Positioned(
        bottom: 0,
        left: 0,
        child: _bracket(len, thick, color, top: false, left: true),
      ),
      // Bottom-right
      Positioned(
        bottom: 0,
        right: 0,
        child: _bracket(len, thick, color, top: false, left: false),
      ),
    ];
  }

  Widget _bracket(
    double len,
    double thick,
    Color color, {
    required bool top,
    required bool left,
  }) {
    return SizedBox(
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
  }

  // ─────────────────────────────────────────────
  // STATUS PILL
  // ─────────────────────────────────────────────
  Widget _buildStatusPill(bool isApiLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isApiLoading) ...[
            const SizedBox(
              height: 12,
              width: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            isApiLoading ? 'Processing...' : _statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CIRCULAR PROGRESS — exactly like your design
  // ─────────────────────────────────────────────
  Widget _buildCircularProgress(bool isSuccess, bool isApiLoading) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.15),
          ),
        ),
        // Progress ring
        SizedBox(
          width: 75,
          height: 75,
          child: CircularProgressIndicator(
            value: isApiLoading ? null : _progress,
            strokeWidth: 5,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(
              isSuccess ? Colors.greenAccent : Colors.blueAccent,
            ),
          ),
        ),
        // Percentage text
        Text(
          isApiLoading
              ? '...'
              : isSuccess
              ? '✓'
              : '${(_progress * 100).toInt()}%',
          style: TextStyle(
            color: isSuccess ? Colors.greenAccent : Colors.white,
            fontSize: isSuccess ? 22 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// CUSTOM PAINTER — corner brackets
// ─────────────────────────────────────────────
class _BracketPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool top;
  final bool left;

  _BracketPainter({
    required this.color,
    required this.thickness,
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = thickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final double len = size.width;
    final double x = left ? 0 : size.width;
    final double y = top ? 0 : size.height;
    final double dx = left ? len : -len;
    final double dy = top ? len : -len;

    // Horizontal line
    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    // Vertical line
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_BracketPainter old) =>
      old.color != color || old.thickness != thickness;
}
