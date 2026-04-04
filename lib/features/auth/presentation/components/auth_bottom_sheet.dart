import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBottomSheet extends StatefulWidget {
  final String uid;
  final VoidCallback onVerified;

  const AuthBottomSheet({
    super.key,
    required this.uid,
    required this.onVerified,
  });

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet>
    with TickerProviderStateMixin {
  // ── View state ──
  String _view = 'select';

  // ── Biometric flags from Firestore ──
  bool _faceEnabled = false;
  bool _fingerprintEnabled = false;
  bool _flagsLoaded = false;

  // ── Face state ──
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  double _faceProgress = 0.0;
  String _faceStatusText = 'Hold your face still';
  bool _faceScanning = false;

  // ── Fingerprint state ──
  double _fingerprintFill = 0.0;
  bool _fingerprintFailed = false;
  bool _fingerprintSuccess = false;

  // ── Shared ──
  String _statusText = '';

  // ── Scan line animation ──
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Load biometric flags on open
    _loadBiometricFlags();
  }

  // ═══════════════════════════════════════════
  // LOAD FLAGS FROM FIRESTORE
  // ═══════════════════════════════════════════
  Future<void> _loadBiometricFlags() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .get();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _faceEnabled = data['faceEnabled'] ?? false;
          _fingerprintEnabled = data['fingerprintEnabled'] ?? false;
          _flagsLoaded = true;
        });
      } else {
        setState(() => _flagsLoaded = true);
      }
    } catch (e) {
      debugPrint('_loadBiometricFlags error: $e');
      if (mounted) setState(() => _flagsLoaded = true);
    }
  }

  // ═══════════════════════════════════════════
  // FACE METHODS
  // ═══════════════════════════════════════════

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
        _startFaceScan();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _faceStatusText = 'Camera error. Try again.');
      }
    }
  }

  void _startFaceScan() {
    if (_faceScanning) return;
    _faceScanning = true;

    setState(() {
      _faceProgress = 0.0;
      _isProcessing = false;
      _faceStatusText = 'Hold your face still';
    });

    int tick = 0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 60));
      if (!mounted || _view != 'face') return false;

      tick++;
      final p = (tick * 0.60) / 100;

      if (mounted) {
        if (p >= 0.3 && p < 0.6) {
          setState(() => _faceStatusText = 'Recognizing your face...');
        } else if (p >= 0.6 && p < 1.0) {
          setState(() => _faceStatusText = 'Almost done...');
        }
      }

      if (p >= 1.0) {
        if (mounted) setState(() => _faceProgress = 1.0);
        await _captureAndVerifyFace();
        return false;
      }

      if (mounted) setState(() => _faceProgress = p);
      return true;
    });
  }

  Future<void> _captureAndVerifyFace() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing)
      return;

    setState(() {
      _isProcessing = true;
      _faceStatusText = 'Verifying identity...';
    });

    try {
      final XFile image = await _cameraController!.takePicture();
      final imageBytes = await image.readAsBytes();

      final faceRepo = context.read<AuthCubit>().faceAuthRepo;
      final isMatch = await faceRepo.verifyFace(
        uid: widget.uid,
        imageBytes: imageBytes,
      );

      if (!mounted) return;

      if (isMatch) {
        setState(() => _view = 'success');
        await Future.delayed(const Duration(milliseconds: 900));
        if (mounted) widget.onVerified();
      } else {
        setState(() {
          _view = 'failed';
          _statusText = 'Face not recognized. Try again.';
          _faceScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _view = 'failed';
          _statusText = 'Something went wrong. Try again.';
          _faceScanning = false;
        });
      }
    }
  }

  void _resetFace() {
    _cameraController?.dispose();
    _cameraController = null;
    setState(() {
      _isCameraReady = false;
      _faceScanning = false;
      _faceProgress = 0.0;
      _isProcessing = false;
      _faceStatusText = 'Hold your face still';
    });
  }

  // ═══════════════════════════════════════════
  // FINGERPRINT METHODS
  // ═══════════════════════════════════════════

  Future<void> _startFingerprintAuth() async {
    setState(() {
      _view = 'fingerprint';
      _fingerprintFill = 0.0;
      _fingerprintFailed = false;
      _fingerprintSuccess = false;
      _statusText = '';
    });

    _animateFingerprintFill(to: 0.85, durationMs: 1500);

    try {
      final biometricRepo = context.read<AuthCubit>().biometricAuthRepo;
      final success = await biometricRepo.authenticateWithFingerprint();

      if (!mounted) return;

      if (success) {
        await _animateFingerprintFill(to: 1.0, durationMs: 300);
        setState(() => _fingerprintSuccess = true);
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) widget.onVerified();
      } else {
        setState(() {
          _fingerprintFailed = true;
          _statusText = 'Fingerprint not recognized. Try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fingerprintFailed = true;
          _statusText = 'Fingerprint error. Try again.';
        });
      }
    }
  }

  Future<void> _animateFingerprintFill({
    required double to,
    required int durationMs,
  }) async {
    final start = _fingerprintFill;
    const steps = 60;
    final stepDuration = durationMs ~/ steps;
    final diff = to - start;

    for (int i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      if (!mounted || _view != 'fingerprint') return;
      setState(() => _fingerprintFill = start + (diff * i / steps));
    }
  }

  // ═══════════════════════════════════════════
  // RETRY
  // ═══════════════════════════════════════════

  void _retry() {
    setState(() {
      _view = 'select';
      _statusText = '';
      _faceScanning = false;
      _faceProgress = 0.0;
      _fingerprintFill = 0.0;
      _fingerprintFailed = false;
      _fingerprintSuccess = false;
    });
    _resetFace();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        child: _buildView(),
      ),
    );
  }

  Widget _buildView() {
    switch (_view) {
      case 'select':
        return _buildSelectView();
      case 'face':
        return _buildFaceView();
      case 'fingerprint':
        return _buildFingerprintView();
      case 'success':
        return _buildResultView(success: true);
      case 'failed':
        return _buildResultView(success: false);
      default:
        return _buildSelectView();
    }
  }

  // ═══════════════════════════════════════════
  // VIEW 1 — SELECT
  // ═══════════════════════════════════════════

  Widget _buildSelectView() {
    // Show loader while flags loading
    if (!_flagsLoaded) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dragHandle(),
          const SizedBox(height: 40),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 40),
        ],
      );
    }

    // Neither enabled
    final neitherEnabled = !_faceEnabled && !_fingerprintEnabled;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dragHandle(),
        const SizedBox(height: 16),

        // Close
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: Colors.black87, size: 22),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Authorize Payment',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          neitherEnabled
              ? 'No biometric method enabled.\nEnable Face ID or Fingerprint\nfrom Profile → Account & Privacy Settings.'
              : 'Authenticate with your fingerprint / Face ID\nto authorize this transfer.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: neitherEnabled ? Colors.redAccent : const Color(0xff737373),
            height: 1.5,
          ),
        ),

        const SizedBox(height: 35),

        // ── Auth circles — only show enabled ones ──
        if (!neitherEnabled)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Face ID — only if faceEnabled
              if (_faceEnabled)
                _authCircle(
                  icon: Icons.face_retouching_natural,
                  label: 'Face ID',
                  available: true,
                  onTap: () {
                    setState(() => _view = 'face');
                    _initCamera();
                  },
                ),

              // spacing only if both enabled
              if (_faceEnabled && _fingerprintEnabled)
                const SizedBox(width: 40),

              // Fingerprint — only if fingerprintEnabled
              if (_fingerprintEnabled)
                _authCircle(
                  icon: Icons.fingerprint,
                  label: 'Fingerprint',
                  available: true,
                  onTap: () => _startFingerprintAuth(),
                ),
            ],
          ),

        // ── Neither enabled icon ──
        if (neitherEnabled)
          const Icon(Icons.lock_outline, size: 60, color: Color(0xffDDDDDD)),

        const SizedBox(height: 40),

        // ── Verify button ──
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            // disabled if neither enabled
            onPressed:
                neitherEnabled
                    ? null
                    : _faceEnabled
                    ? () {
                      setState(() => _view = 'face');
                      _initCamera();
                    }
                    : () => _startFingerprintAuth(),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  neitherEnabled ? Colors.grey[300] : const Color(0xff3B6FE8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              neitherEnabled
                  ? 'No biometric enabled'
                  : 'Verify through biometric',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: neitherEnabled ? Colors.grey : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // VIEW 2 — FACE CAMERA
  // ═══════════════════════════════════════════

  Widget _buildFaceView() {
    final borderColor =
        _faceProgress < 0.5
            ? Colors.blueAccent
            : _faceProgress < 1.0
            ? Colors.lightBlueAccent
            : Colors.greenAccent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dragHandle(),
        const SizedBox(height: 14),

        Row(
          children: [
            GestureDetector(
              onTap: () {
                _resetFace();
                setState(() => _view = 'select');
              },
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Face Verification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 16),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 260,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_isCameraReady && _cameraController != null)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cameraController!.value.previewSize!.height,
                      height: _cameraController!.value.previewSize!.width,
                      child: CameraPreview(_cameraController!),
                    ),
                  )
                else
                  Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),

                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.25),
                        Colors.transparent,
                        Colors.black.withOpacity(0.35),
                      ],
                    ),
                  ),
                ),

                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: CustomPaint(
                      painter: _BracketsPainter(color: borderColor),
                    ),
                  ),
                ),

                if (_isCameraReady)
                  AnimatedBuilder(
                    animation: _scanController,
                    builder: (context, _) {
                      return Positioned(
                        top: _scanController.value * 250,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.blueAccent.withOpacity(0.9),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _faceStatusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            const Text(
              'Scanning',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _faceProgress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _faceProgress < 1.0 ? Colors.blueAccent : Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(_faceProgress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // VIEW 3 — FINGERPRINT
  // ═══════════════════════════════════════════

  Widget _buildFingerprintView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        _dragHandle(),
        const SizedBox(height: 16),

        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _view = 'select';
                  _fingerprintFill = 0.0;
                  _fingerprintFailed = false;
                  _fingerprintSuccess = false;
                });
              },
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Fingerprint Verification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Text(
          _fingerprintSuccess
              ? 'Verified!'
              : _fingerprintFailed
              ? 'Try Again'
              : 'Place your Finger',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color:
                _fingerprintSuccess
                    ? Colors.green
                    : _fingerprintFailed
                    ? Colors.redAccent
                    : Colors.black,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          _fingerprintSuccess
              ? 'Identity confirmed!'
              : _fingerprintFailed
              ? _statusText
              : 'Place your finger on the\nsensor to authorize payment',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xff737373),
            height: 1.5,
          ),
        ),

        const SizedBox(height: 30),

        SizedBox(
          width: 160,
          height: 160,
          child: CustomPaint(
            painter: _FingerprintPainter(
              fillProgress: _fingerprintFill,
              isFailed: _fingerprintFailed,
              isSuccess: _fingerprintSuccess,
            ),
          ),
        ),

        const SizedBox(height: 30),

        if (_fingerprintFailed)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _startFingerprintAuth(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3B6FE8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // VIEW 4 — RESULT
  // ═══════════════════════════════════════════

  Widget _buildResultView({required bool success}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dragHandle(),
        const SizedBox(height: 30),

        Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                success
                    ? Colors.green.withOpacity(0.12)
                    : Colors.red.withOpacity(0.12),
          ),
          child: Icon(
            success ? Icons.check_circle_outline : Icons.highlight_off,
            color: success ? Colors.green : Colors.redAccent,
            size: 55,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          success ? 'Identity Verified!' : 'Verification Failed',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: success ? Colors.green : Colors.redAccent,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          success ? 'Processing your transaction...' : _statusText,
          style: const TextStyle(fontSize: 14, color: Color(0xff737373)),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 30),

        if (!success)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _retry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3B6FE8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════

  Widget _dragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _authCircle({
    required IconData icon,
    required String label,
    required bool available,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xffF0F2F5),
            ),
            child: Icon(
              icon,
              size: 36,
              color:
                  available
                      ? const Color(0xff3B6FE8)
                      : const Color(0xff3B6FE8).withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color:
                  available
                      ? const Color(0xff3B6FE8)
                      : const Color(0xff3B6FE8).withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// CORNER BRACKETS PAINTER
// ═══════════════════════════════════════════

class _BracketsPainter extends CustomPainter {
  final Color color;
  _BracketsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    const len = 24.0;

    canvas.drawLine(const Offset(0, 0), const Offset(len, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, len), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - len),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - len, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BracketsPainter old) => old.color != color;
}

// ═══════════════════════════════════════════
// FINGERPRINT PAINTER
// ═══════════════════════════════════════════

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

    const rings = 8;
    for (int i = 0; i < rings; i++) {
      final radius = (size.width / 2) * ((i + 1) / rings);
      final ringProgress = ((fillProgress * rings) - (rings - 1 - i)).clamp(
        0.0,
        1.0,
      );

      final greyPaint =
          Paint()
            ..color = const Color(0xffDDDDDD)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.0
            ..strokeCap = StrokeCap.round;

      final activePaint =
          Paint()
            ..color = activeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.0
            ..strokeCap = StrokeCap.round;

      const startAngle = -2.8;
      const sweepAngle = 5.6;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        greyPaint,
      );

      if (ringProgress > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle * ringProgress,
          false,
          activePaint,
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
