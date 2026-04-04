import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/auth/presentation/components/my_textfield.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowpay/features/auth/presentation/pages/biometrics/face_lock/face_lock_page.dart';
import 'package:flowpay/features/auth/presentation/pages/forgot_pwd_req_page.dart';
import 'package:flowpay/features/auth/presentation/pages/register_page.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _faceEnabled = false;
  bool _fingerprintEnabled = false;
  String? _storedUid;
  bool _biometricChecked = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  // ─────────────────────────────────────────────
  // CHECK Firestore for enabled biometrics
  // ─────────────────────────────────────────────
  Future<void> _checkBiometricAvailability() async {
    try {
      final uid = await _secureStorage.read(key: 'uid');
      if (uid == null || uid.isEmpty) {
        setState(() => _biometricChecked = true);
        return;
      }
      _storedUid = uid;

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!doc.exists) {
        setState(() => _biometricChecked = true);
        return;
      }

      final data = doc.data()!;
      setState(() {
        _faceEnabled = data['faceEnabled'] ?? false;
        _fingerprintEnabled = data['fingerprintEnabled'] ?? false;
        _biometricChecked = true;
      });
    } catch (e) {
      setState(() => _biometricChecked = true);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: const Color(0xffFFFFFF),
          body: Padding(
            padding: context.padSymmetricPx(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                const Text(
                  'Welcome back 👋',
                  style: TextStyle(fontSize: 16, color: Color(0xff737373)),
                ),
                context.spaceHPx(8),
                const Text(
                  'Log in to continue',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                context.spaceHPx(30),

                // ── Email ──
                const Text(
                  'Email',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                MyTextField(
                  controller: emailController,
                  hintText: 'Enter your email',
                  obscureText: false,
                ),

                // ── Password ──
                const Text(
                  'Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Enter your password',
                  obscureText: true,
                ),

                // ── Forgot password ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ForgotPwdReqPage()),
                        );
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff007AFF),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xff007AFF),
                        ),
                      ),
                    ),
                  ],
                ),

                context.spaceHPx(20),

                // ── Login button ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MainButton(
                      buttonName: isLoading ? 'Logging in...' : 'Login',
                      onTap:
                          isLoading
                              ? () {}
                              : () {
                                authCubit.login(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                );
                              },
                    ),
                  ],
                ),

                context.spaceHPx(16),

                // ── Biometric section ──
                // Shows only when at least one is enabled
                if (_biometricChecked &&
                    (_faceEnabled || _fingerprintEnabled)) ...[
                  // Replace the biometric section in login_page.dart with this:
                  context.spaceHPx(20),

                  // ── Biometric section — ALWAYS show both ──
                  if (_biometricChecked) ...[
                    Row(
                      children: const [
                        Expanded(child: Divider(color: Color(0xffE0E0E0))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'or login with',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xffA3A3A3),
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xffE0E0E0))),
                      ],
                    ),

                    context.spaceHPx(20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Face ID ──
                        _biometricBtn(
                          context: context,
                          icon: Icons.face_retouching_natural,
                          label: 'Face ID',
                          isEnabled: _faceEnabled,
                          onTap: () async {
                            if (!_faceEnabled) {
                              // Not registered yet — show hint
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Face ID not set up. Enable it from Profile → Account & Privacy Settings.',
                                  ),
                                  backgroundColor: const Color(0xff3B6FE8),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                              return;
                            }
                            if (_storedUid == null) return;
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => FaceLockPage(
                                      mode: FaceLockMode.login,
                                      uid: _storedUid!,
                                    ),
                              ),
                            );
                          },
                        ),

                        context.spaceWPx(24),

                        // ── Fingerprint ──
                        _biometricBtn(
                          context: context,
                          icon: Icons.fingerprint,
                          label: 'Fingerprint',
                          isEnabled: _fingerprintEnabled,
                          onTap: () {
                            if (!_fingerprintEnabled) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Fingerprint not set up. Enable it from Profile → Account & Privacy Settings.',
                                  ),
                                  backgroundColor: const Color(0xff3B6FE8),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                              return;
                            }
                            context.read<AuthCubit>().loginWithFingerprint();
                          },
                        ),
                      ],
                    ),
                  ],

                  context.spaceHPx(26),

                  // ── Sign up ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don\'t have an account ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff737373),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RegisterPage(onTap: () {}),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff007AFF),
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xff007AFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // BIOMETRIC BUTTON — matches your app UI style
  // ─────────────────────────────────────────────
  Widget _biometricBtn({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isEnabled, // 👈 new
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: context.hPx(58),
            width: context.wPx(58),
            decoration: BoxDecoration(
              // Grey when not enabled, blue tint when enabled
              color:
                  isEnabled ? const Color(0xffEEF4FF) : const Color(0xffF5F5F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isEnabled
                        ? const Color(0xff007AFF).withOpacity(0.3)
                        : const Color(0xffDEE0E5),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 28,
              // Blue when enabled, grey when not
              color:
                  isEnabled ? const Color(0xff007AFF) : const Color(0xffC0C0C0),
            ),
          ),
          context.spaceHPx(6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              // Blue when enabled, grey when not
              color:
                  isEnabled ? const Color(0xff737373) : const Color(0xffC0C0C0),
            ),
          ),
          // "Not set up" label under disabled button
          if (!isEnabled)
            Text(
              'Not set up',
              style: const TextStyle(fontSize: 10, color: Color(0xffC0C0C0)),
            ),
        ],
      ),
    );
  }
}
