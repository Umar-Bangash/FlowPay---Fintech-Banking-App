import 'package:flowpay/features/auth/presentation/components/my_textfield.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPwdReqPage extends StatefulWidget {
  const ForgotPwdReqPage({super.key});

  @override
  State<ForgotPwdReqPage> createState() => _ForgotPwdReqPageState();
}

class _ForgotPwdReqPageState extends State<ForgotPwdReqPage> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is PasswordResetEmailSent) {
          // Show success bottom sheet
          _showSuccessSheet(context, state.email);
        }

        if (state is PasswordResetError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: const Color(0xffFFFFFF),
          appBar: AppBar(
            backgroundColor: const Color(0xffFFFFFF),
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, size: 20),
            ),
          ),
          body: SizedBox(
            width: double.maxFinite,
            child: Padding(
              padding: context.padSymmetricPx(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Lock image ──
                  Image.asset(
                    'assets/images/lock.png',
                    height: 180,
                    width: 180,
                  ),

                  context.spaceHPx(40),

                  // ── Title ──
                  const Text(
                    'Forgot your password?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                  context.spaceHPx(10),

                  // ── Subtitle ──
                  const Text(
                    'Enter your registered email and we\'ll\nsend you a password reset link.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff737373),
                      height: 1.5,
                    ),
                  ),

                  context.spaceHPx(30),

                  // ── Email field ──
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  MyTextField(
                    controller: emailController,
                    hintText: 'Enter your email',
                    obscureText: false,
                  ),

                  context.spaceHPx(30),

                  // ── Send Link button ──
                  MainButton(
                    buttonName: isLoading ? 'Sending...' : 'Send Link',
                    onTap:
                        isLoading
                            ? () {}
                            : () {
                              final email = emailController.text.trim();
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Please enter your email',
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (!email.contains('@')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Please enter a valid email',
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                                return;
                              }

                              context.read<AuthCubit>().forgetPassword(email);
                            },
                  ),

                  context.spaceHPx(30),

                  // ── Remember password ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Remembered your password? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff737373),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff21496A),
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xff21496A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // SUCCESS BOTTOM SHEET
  // ─────────────────────────────────────────────
  void _showSuccessSheet(BuildContext context, String email) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder:
          (_) => Padding(
            padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 30),

                // Success icon
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.12),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    color: Colors.green,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Check your email!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  'We\'ve sent a password reset link to\n$email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff737373),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Please check your inbox and follow\nthe link to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xffA3A3A3),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                // Back to Login button
                MainButton(
                  buttonName: 'Back to Login',
                  onTap: () {
                    Navigator.pop(context); // close sheet
                    Navigator.pop(context); // go back to login
                  },
                ),

                const SizedBox(height: 16),

                // Resend option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Didn\'t receive it? ',
                      style: TextStyle(fontSize: 13, color: Color(0xff737373)),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context); // close sheet
                        // user can try again with same email
                        context.read<AuthCubit>().forgetPassword(email);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Reset link resent!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Resend',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xff3B6FE8),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xff3B6FE8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
