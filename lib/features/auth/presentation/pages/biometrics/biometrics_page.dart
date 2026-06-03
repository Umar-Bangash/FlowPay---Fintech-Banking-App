import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/auth/presentation/components/biometric_tile.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/pages/biometrics/face_lock/face_id_setup_page.dart';
import 'package:flowpay/features/auth/presentation/pages/biometrics/fingerprint/fingerprint_setupt_page.dart';
import 'package:flowpay/navigations/navigation_page.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../helpers/app_animation.dart';
import '../../../../../helpers/ui_responsive_helper.dart';

class BiometricsPage extends StatefulWidget {
  final bool fromSettings;
  const BiometricsPage({super.key, this.fromSettings = false});
  @override
  State<BiometricsPage> createState() => _BiometricsPageState();
}

class _BiometricsPageState extends State<BiometricsPage> {
  bool _faceEnabled = false;
  bool _fingerprintEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final uid = context.read<AuthCubit>().currentUser?.uid;
      if (uid == null) {
        setState(() => _isLoading = false);
        return;
      }
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (mounted) {
        setState(() {
          _fingerprintEnabled = doc.data()?['fingerprintEnabled'] ?? false;
          _faceEnabled = doc.data()?['faceEnabled'] ?? false;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onContinue() {
    if (_faceEnabled) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FaceIdSetupPage()),
      );
    } else if (_fingerprintEnabled) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FingerprintSetuptPage()),
      );
    } else {
      widget.fromSettings ? Navigator.pop(context) : _goHome();
    }
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const NavigationPage()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return PopScope(
      canPop: widget.fromSettings,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar:
            widget.fromSettings
                ? AppBar(
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
                )
                : null,
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : AppAnimatedPage(
                  direction: SlideDirection.bottom,
                  child: SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppResponsive.w(25),
                        vertical: AppResponsive.h(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: AppResponsive.h(16)),

                          // ── Illustration ─────────────────────────────────
                          AppAnimatedItem(
                            index: 0,
                            direction: SlideDirection.bottom,
                            child: AppScaleIn(
                              child: Image.asset(
                                'assets/images/privacy_icon.png',
                                // Responsive image size — caps on large screens
                                width: AppResponsive.w(180).clamp(120.0, 220.0),
                                height: AppResponsive.h(
                                  155,
                                ).clamp(110.0, 190.0),
                              ),
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(32)),

                          // ── Title ─────────────────────────────────────────
                          AppAnimatedItem(
                            index: 1,
                            direction: SlideDirection.left,
                            child: Text(
                              'Secure Your Account',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(22),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(10)),

                          AppAnimatedItem(
                            index: 2,
                            direction: SlideDirection.right,
                            child: Text(
                              'Enable additional security features',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(13),
                                color: const Color(0xff737373),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(24)),

                          // ── Face ID tile ──────────────────────────────────
                          AppAnimatedItem(
                            index: 3,
                            direction: SlideDirection.left,
                            child: BiometricTile(
                              imagePath: 'assets/images/face.png',
                              title: 'Face ID',
                              subtitle:
                                  'Use facial recognition to unlock \nyour account securely',
                              switchValue: _faceEnabled,
                              onChange: (v) => setState(() => _faceEnabled = v),
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(14)),

                          // ── Fingerprint tile ──────────────────────────────
                          AppAnimatedItem(
                            index: 4,
                            direction: SlideDirection.right,
                            child: BiometricTile(
                              imagePath: 'assets/images/fingerprint.png',
                              title: 'Fingerprint',
                              subtitle:
                                  'Access your account quickly and \nsafely using your fingerprint',
                              switchValue: _fingerprintEnabled,
                              onChange:
                                  (v) =>
                                      setState(() => _fingerprintEnabled = v),
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(32)),

                          // ── Continue ──────────────────────────────────────
                          AppAnimatedItem(
                            index: 5,
                            direction: SlideDirection.bottom,
                            child: MainButton(
                              buttonName: 'Continue',
                              onTap: _onContinue,
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(18)),

                          // ── Skip ──────────────────────────────────────────
                          if (!widget.fromSettings)
                            AppAnimatedItem(
                              index: 6,
                              direction: SlideDirection.bottom,
                              child: InkWell(
                                onTap: _goHome,
                                child: Text(
                                  'Skip for now',
                                  style: TextStyle(
                                    fontSize: AppResponsive.fs(13),
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xff737373),
                                  ),
                                ),
                              ),
                            ),

                          SizedBox(height: AppResponsive.h(20)),
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }
}
