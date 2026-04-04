import 'package:flowpay/features/auth/presentation/components/biometric_tile.dart';
import 'package:flowpay/features/auth/presentation/cubit/biometric_cubit.dart';
import 'package:flowpay/features/auth/presentation/pages/biometrics/face_lock/face_id_setup_page.dart';
import 'package:flowpay/helpers/text_styles.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flowpay/navigations/navigation_page.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'fingerprint/fingerprint_setupt_page.dart';

class BiometricsPage extends StatelessWidget {
  const BiometricsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final biometricCubit = context.read<BiometricCubit>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xffFFFFFF),
        body: SizedBox(
          width: double.maxFinite,
          child: Padding(
            padding: context.padSymmetricPx(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/privacy_icon.png',
                  width: context.wPx(202),
                  height: context.hPx(174),
                ),
                context.spaceHPx(40),
                boldBigText('Secure Your Account'),
                context.spaceHPx(15),
                mediumGreyText('Enable additional security features'),
                context.spaceHPx(25),

                // Face ID Toggle
                BlocBuilder<BiometricCubit, BiometricState>(
                  builder: (context, state) {
                    return BiometricTile(
                      imagePath: 'assets/images/face.png',
                      title: 'Face ID',
                      subtitle:
                          'Use facial recognition to unlock \nyour account securely',
                      switchValue: state.faceIdEnabled,
                      onChange: biometricCubit.toggleFaceId,
                    );
                  },
                ),

                context.spaceHPx(15),

                // Fingerprint Toggle
                BlocBuilder<BiometricCubit, BiometricState>(
                  builder: (context, state) {
                    return BiometricTile(
                      imagePath: 'assets/images/fingerprint.png',
                      title: 'Fingerprint',
                      subtitle:
                          'Access your account quickly and \nsafely using your fingerprint',
                      switchValue: state.fingerprintEnabled,
                      onChange: biometricCubit.toggleFingerprint,
                    );
                  },
                ),

                context.spaceHPx(35),

                // Continue Button — smart routing based on toggles
                BlocBuilder<BiometricCubit, BiometricState>(
                  builder: (context, state) {
                    return MainButton(
                      buttonName: 'Continue',
                      onTap: () {
                        if (state.faceIdEnabled && state.fingerprintEnabled) {
                          // Both selected — do face first then fingerprint
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FaceIdSetupPage(),
                            ),
                          );
                        } else if (state.faceIdEnabled) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FaceIdSetupPage(),
                            ),
                          );
                        } else if (state.fingerprintEnabled) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FingerprintSetuptPage(),
                            ),
                          );
                        } else {
                          _goToHome(context);
                        }
                      },
                    );
                  },
                ),

                context.spaceHPx(40),

                // Skip → go home without any biometric setup
                InkWell(
                  onTap: () => _goToHome(context),
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff737373),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Navigate to home — clears entire back stack
  // so user can't go back to biometrics page
  // ─────────────────────────────────────────────
  void _goToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const NavigationPage()),
      (route) => false, // removes all previous routes
    );
  }
}
