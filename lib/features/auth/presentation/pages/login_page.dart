import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/auth/presentation/components/my_textfield.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowpay/features/auth/presentation/pages/forgot_pwd_req_page.dart';
import 'package:flowpay/features/auth/presentation/pages/register_page.dart';
import 'package:flowpay/features/qr/presentation/cubit/qr_cubit.dart';
import 'package:flowpay/features/qr/presentation/cubit/qr_states.dart';
import 'package:flowpay/features/qr/presentation/pages/access_qr_dialog.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../components/auth_bottom_sheet.dart';

enum _QrStatus { none, pending, accepted, rejected }

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _faceEnabled = false;
  bool _fingerprintEnabled = false;
  String? _storedUid;

  _QrStatus _qrStatus = _QrStatus.none;
  String _statusMessage = '';

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _pulseCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    try {
      final uid = await _storage.read(key: 'uid');
      if (uid == null || uid.isEmpty) return;
      _storedUid = uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists || !mounted) return;
      final data = doc.data()!;
      setState(() {
        _faceEnabled = data['faceEnabled'] ?? false;
        _fingerprintEnabled = data['fingerprintEnabled'] ?? false;
      });
    } catch (_) {}
  }

  void _setStatus(_QrStatus s, {String message = ''}) {
    if (!mounted) return;
    setState(() {
      _qrStatus = s;
      _statusMessage = message;
    });
    if (s != _QrStatus.none) _slideCtrl.forward(from: 0);
    if (s == _QrStatus.pending) {
      _pulseCtrl.repeat(reverse: true);
    } else {
      _pulseCtrl.stop();
    }
  }

  void _showMyQrDialog(BuildContext ctx) {
    ctx.read<QRCubit>().resetToInitial();
    showDialog(context: ctx, builder: (_) => const AccessQrDialog());
  }

  void _showScanQrDialog(BuildContext ctx) {
    ctx.read<QRCubit>().resetToInitial();
    _nameCtrl.clear();
    _setStatus(_QrStatus.none);
    bool scanned = false, nameSubmitted = false;
    String submittedName = '';

    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder:
          (dCtx) => StatefulBuilder(
            builder: (sbCtx, setDS) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
                ),
                backgroundColor: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(AppResponsive.w(20)),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: AppResponsive.h(420),
                      minHeight: AppResponsive.h(300),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              !nameSubmitted
                                  ? 'Enter your name'
                                  : 'Scan Account QR',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(17),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(dCtx).pop(),
                            ),
                          ],
                        ),
                        SizedBox(height: AppResponsive.h(8)),
                        Expanded(
                          child:
                              !nameSubmitted
                                  ? _buildNameView(
                                    onSubmit:
                                        (name) => setDS(() {
                                          submittedName = name;
                                          nameSubmitted = true;
                                        }),
                                  )
                                  : ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppResponsive.radiusMd,
                                    ),
                                    child: MobileScanner(
                                      onDetect: (capture) async {
                                        if (scanned) return;
                                        final raw =
                                            capture.barcodes.first.rawValue
                                                ?.trim();
                                        if (raw == null || raw.isEmpty) return;
                                        scanned = true;

                                        String ownerId;
                                        if (raw.startsWith(
                                          'flowpay_access::',
                                        )) {
                                          final parts = raw.split('::');
                                          if (parts.length < 3 ||
                                              parts[2].isEmpty) {
                                            scanned = false;
                                            if (ctx.mounted) {
                                              ScaffoldMessenger.of(
                                                ctx,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Invalid QR. Ask the owner to generate a new one.',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                            return;
                                          }
                                          ownerId = parts[2];
                                        } else {
                                          ownerId = raw;
                                        }

                                        if (dCtx.mounted) {
                                          Navigator.of(dCtx).pop();
                                        }
                                        _setStatus(
                                          _QrStatus.pending,
                                          message:
                                              'Waiting for account owner to approve...',
                                        );

                                        String requesterId =
                                            'anon_${DateTime.now().millisecondsSinceEpoch}';
                                        try {
                                          final existing =
                                              FirebaseAuth.instance.currentUser;
                                          requesterId =
                                              existing != null
                                                  ? existing.uid
                                                  : (await FirebaseAuth.instance
                                                          .signInAnonymously())
                                                      .user!
                                                      .uid;
                                        } catch (_) {}

                                        if (!ctx.mounted) return;
                                        ctx
                                            .read<QRCubit>()
                                            .requestAccountAccess(
                                              requesterId: requesterId,
                                              requesterName: submittedName,
                                              ownerId: ownerId,
                                            );
                                      },
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildNameView({required Function(String) onSubmit}) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: AppResponsive.h(10)),
          Icon(
            Icons.person_outline,
            size: AppResponsive.sp(44),
            color: const Color(0xff007AFF),
          ),
          SizedBox(height: AppResponsive.h(14)),
          Text(
            'What\'s your name?',
            style: TextStyle(
              fontSize: AppResponsive.fs(14),
              color: const Color(0xff737373),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppResponsive.h(4)),
          Text(
            'This will be shown to the account owner.',
            style: TextStyle(
              fontSize: AppResponsive.fs(11),
              color: const Color(0xffA3A3A3),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppResponsive.h(16)),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: const TextStyle(color: Color(0xffA3A3A3)),
              filled: true,
              fillColor: const Color(0xffF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppResponsive.w(16),
                vertical: AppResponsive.h(13),
              ),
            ),
          ),
          SizedBox(height: AppResponsive.h(16)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff007AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
                ),
                padding: EdgeInsets.symmetric(vertical: AppResponsive.h(13)),
              ),
              onPressed: () {
                final name = _nameCtrl.text.trim();
                if (name.isEmpty) return;
                onSubmit(name);
              },
              child: Text(
                'Continue to Scanner',
                style: TextStyle(
                  fontSize: AppResponsive.fs(14),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _biometricBtn({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    final size = AppResponsive.sp(56);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              color:
                  isEnabled ? const Color(0xffEEF4FF) : const Color(0xffF5F5F5),
              borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
              border: Border.all(
                color:
                    isEnabled
                        ? const Color(0xff007AFF).withOpacity(0.3)
                        : const Color(0xffDEE0E5),
              ),
            ),
            child: Icon(
              icon,
              size: AppResponsive.sp(26),
              color:
                  isEnabled ? const Color(0xff007AFF) : const Color(0xffC0C0C0),
            ),
          ),
          SizedBox(height: AppResponsive.h(6)),
          Text(
            label,
            style: TextStyle(
              fontSize: AppResponsive.fs(12),
              fontWeight: FontWeight.w500,
              color:
                  isEnabled ? const Color(0xff737373) : const Color(0xffC0C0C0),
            ),
          ),
          if (!isEnabled)
            Text(
              'Not set up',
              style: TextStyle(
                fontSize: AppResponsive.fs(10),
                color: const Color(0xffC0C0C0),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusWidget() {
    if (_qrStatus == _QrStatus.none) return const SizedBox.shrink();

    Color bgColor, borderColor, iconColor;
    IconData icon;
    String title;

    switch (_qrStatus) {
      case _QrStatus.pending:
        bgColor = const Color(0xffFFF8E1);
        borderColor = const Color(0xffFFA000);
        iconColor = const Color(0xffFFA000);
        icon = Icons.hourglass_top_rounded;
        title = 'Waiting for approval...';
        break;
      case _QrStatus.accepted:
        bgColor = const Color(0xffE8F5E9);
        borderColor = const Color(0xff34C759);
        iconColor = const Color(0xff34C759);
        icon = Icons.check_circle_outline_rounded;
        title = 'Access Approved!';
        break;
      case _QrStatus.rejected:
        bgColor = const Color(0xffFFEBEE);
        borderColor = const Color(0xffFF3B30);
        iconColor = const Color(0xffFF3B30);
        icon = Icons.cancel_outlined;
        title = 'Access Denied';
        break;
      default:
        return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnim,
      child: Container(
        margin: EdgeInsets.only(bottom: AppResponsive.h(18)),
        padding: EdgeInsets.all(AppResponsive.w(14)),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
          border: Border.all(color: borderColor.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            _qrStatus == _QrStatus.pending
                ? ScaleTransition(
                  scale: _pulseAnim,
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: AppResponsive.sp(30),
                  ),
                )
                : Icon(icon, color: iconColor, size: AppResponsive.sp(30)),
            SizedBox(width: AppResponsive.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppResponsive.fs(14),
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                  if (_statusMessage.isNotEmpty) ...[
                    SizedBox(height: AppResponsive.h(2)),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: AppResponsive.fs(11),
                        color: iconColor.withOpacity(0.75),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_qrStatus != _QrStatus.pending)
              GestureDetector(
                onTap: () => _setStatus(_QrStatus.none),
                child: Icon(
                  Icons.close,
                  size: AppResponsive.sp(16),
                  color: iconColor.withOpacity(0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final authCubit = context.read<AuthCubit>();

    return BlocListener<QRCubit, QRStates>(
      listener: (context, qrState) async {
        if (qrState is QRAccessGranted) {
          if (qrState.tempPassword?.isNotEmpty ?? false) {
            _setStatus(
              _QrStatus.accepted,
              message: '${qrState.ownerName} approved! Logging you in...',
            );
            await Future.delayed(const Duration(milliseconds: 600));
            if (!mounted) return;
            authCubit.login(qrState.ownerEmail, qrState.tempPassword!);
          } else {
            _setStatus(
              _QrStatus.rejected,
              message: 'Could not authenticate automatically.',
            );
          }
        } else if (qrState is QRAccessDenied) {
          _setStatus(
            _QrStatus.rejected,
            message:
                qrState.ownerName.isNotEmpty
                    ? '${qrState.ownerName} declined your request.'
                    : 'The account owner declined your request.',
          );
        } else if (qrState is QRError) {
          _setStatus(_QrStatus.none);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(qrState.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is AuthError) {
            if (_qrStatus == _QrStatus.accepted) {
              _setStatus(
                _QrStatus.rejected,
                message: 'Login failed: ${state.message}',
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.qr_code,
                    color: const Color(0xff007AFF),
                    size: AppResponsive.sp(22),
                  ),
                  tooltip: 'Show my access QR',
                  onPressed: () => _showMyQrDialog(context),
                ),
                IconButton(
                  icon: Icon(
                    Icons.qr_code_scanner,
                    color: const Color(0xff007AFF),
                    size: AppResponsive.sp(22),
                  ),
                  tooltip: 'Scan access QR',
                  onPressed: () => _showScanQrDialog(context),
                ),
                SizedBox(width: AppResponsive.w(4)),
              ],
            ),
            body: AppAnimatedPage(
              direction: SlideDirection.bottom,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.w(25),
                    vertical: AppResponsive.h(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // QR status banner
                      _buildStatusWidget(),

                      // ── Header ───────────────────────────────────────
                      AppAnimatedItem(
                        index: 0,
                        direction: SlideDirection.left,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back 👋',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(15),
                                color: const Color(0xff737373),
                              ),
                            ),
                            SizedBox(height: AppResponsive.h(6)),
                            Text(
                              'Log in to continue',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(24),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(28)),

                      // ── Email ─────────────────────────────────────────
                      AppAnimatedItem(
                        index: 1,
                        direction: SlideDirection.right,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(15),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            MyTextField(
                              controller: _emailCtrl,
                              hintText: 'Enter your email',
                              obscureText: false,
                            ),
                          ],
                        ),
                      ),

                      // ── Password ──────────────────────────────────────
                      AppAnimatedItem(
                        index: 2,
                        direction: SlideDirection.left,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(15),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            MyTextField(
                              controller: _passwordCtrl,
                              hintText: 'Enter your password',
                              obscureText: true,
                            ),
                          ],
                        ),
                      ),

                      // ── Forgot password ───────────────────────────────
                      AppAnimatedItem(
                        index: 3,
                        direction: SlideDirection.right,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ForgotPwdReqPage(),
                                  ),
                                ),
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(13),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff007AFF),
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xff007AFF),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(18)),

                      // ── Login button ──────────────────────────────────
                      AppAnimatedItem(
                        index: 4,
                        direction: SlideDirection.bottom,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: MainButton(
                                buttonName:
                                    isLoading ? 'Logging in...' : 'Login',
                                onTap:
                                    isLoading
                                        ? () {}
                                        : () => authCubit.login(
                                          _emailCtrl.text.trim(),
                                          _passwordCtrl.text.trim(),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(20)),

                      // ── Divider ───────────────────────────────────────
                      AppAnimatedItem(
                        index: 5,
                        direction: SlideDirection.bottom,
                        child: Row(
                          children: [
                            const Expanded(
                              child: Divider(color: Color(0xffE0E0E0)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppResponsive.w(10),
                              ),
                              child: Text(
                                'or login with',
                                style: TextStyle(
                                  fontSize: AppResponsive.fs(12),
                                  color: const Color(0xffA3A3A3),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: Color(0xffE0E0E0)),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(20)),

                      // ── Biometric buttons ─────────────────────────────
                      AppAnimatedItem(
                        index: 6,
                        direction: SlideDirection.bottom,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //  Face ID — ALWAYS show, grey if not enabled
                            _biometricBtn(
                              context: context,
                              icon: Icons.face_retouching_natural,
                              label: 'Face ID',
                              isEnabled: _faceEnabled,
                              onTap: () async {
                                if (_storedUid == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please login with email & password first.',
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                await showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                  isScrollControlled: true,
                                  isDismissible: true,
                                  builder:
                                      (_) => AuthBottomSheet(
                                        uid: _storedUid!,
                                        onVerified: () async {
                                          final email = await _storage.read(
                                            key: 'email',
                                          );
                                          final password = await _storage.read(
                                            key: 'password',
                                          );
                                          if (email != null &&
                                              password != null) {
                                            if (context.mounted) {
                                              context.read<AuthCubit>().login(
                                                email,
                                                password,
                                              );
                                            }
                                          } else {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'No credentials found. Login with email & password first.',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        onSkip: () {},
                                      ),
                                );
                              },
                            ),

                            SizedBox(width: AppResponsive.w(24)),

                            // ✅ Fingerprint — ALWAYS show, grey if not enabled
                            _biometricBtn(
                              context: context,
                              icon: Icons.fingerprint,
                              label: 'Fingerprint',
                              isEnabled: _fingerprintEnabled,
                              onTap: () async {
                                if (_storedUid == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please login with email & password first.',
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                await showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                  isScrollControlled: true,
                                  isDismissible: true,
                                  builder:
                                      (_) => AuthBottomSheet(
                                        uid: _storedUid!,
                                        onVerified: () async {
                                          final email = await _storage.read(
                                            key: 'email',
                                          );
                                          final password = await _storage.read(
                                            key: 'password',
                                          );
                                          if (email != null &&
                                              password != null) {
                                            if (context.mounted) {
                                              context.read<AuthCubit>().login(
                                                email,
                                                password,
                                              );
                                            }
                                          } else {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'No credentials found.',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        onSkip: () {},
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(26)),

                      // ── Sign up link ──────────────────────────────────
                      AppAnimatedItem(
                        index: 7,
                        direction: SlideDirection.bottom,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account ',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(13),
                                color: const Color(0xff737373),
                              ),
                            ),
                            InkWell(
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => RegisterPage(onTap: () {}),
                                    ),
                                  ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: AppResponsive.fs(13),
                                  color: const Color(0xff007AFF),
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                  decorationColor: const Color(0xff007AFF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(20)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
