import 'package:flowpay/features/auth/presentation/components/my_textfield.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class ForgotPwdReqPage extends StatefulWidget {
  const ForgotPwdReqPage({super.key});
  @override
  State<ForgotPwdReqPage> createState() => _ForgotPwdReqPageState();
}

class _ForgotPwdReqPageState extends State<ForgotPwdReqPage> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _showSuccessSheet(BuildContext context, String email) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true, // ← respects keyboard / small screens
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder:
          (_) => SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppResponsive.w(25),
                AppResponsive.h(20),
                AppResponsive.w(25),
                AppResponsive.h(30),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: AppResponsive.w(40),
                    height: AppResponsive.h(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(28)),

                  // Icon
                  Container(
                    height: AppResponsive.sp(72),
                    width: AppResponsive.sp(72),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.12),
                    ),
                    child: Icon(
                      Icons.mark_email_read_outlined,
                      color: Colors.green,
                      size: AppResponsive.sp(36),
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(18)),

                  Text(
                    'Check your email!',
                    style: TextStyle(
                      fontSize: AppResponsive.fs(19),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(10)),

                  Text(
                    'We\'ve sent a password reset link to\n$email',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppResponsive.fs(13),
                      color: const Color(0xff737373),
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(8)),

                  Text(
                    'Please check your inbox and follow\nthe link to reset your password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppResponsive.fs(12),
                      color: const Color(0xffA3A3A3),
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(26)),

                  MainButton(
                    buttonName: 'Back to Login',
                    onTap: () {
                      Navigator.pop(context); // close sheet
                      Navigator.pop(context); // go to login
                    },
                  ),

                  SizedBox(height: AppResponsive.h(14)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive it? ',
                        style: TextStyle(
                          fontSize: AppResponsive.fs(12),
                          color: const Color(0xff737373),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
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
                        child: Text(
                          'Resend',
                          style: TextStyle(
                            fontSize: AppResponsive.fs(12),
                            color: const Color(0xff3B6FE8),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xff3B6FE8),
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
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is PasswordResetEmailSent)
          _showSuccessSheet(context, state.email);
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
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, size: 20),
            ),
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
                child: ConstrainedBox(
                  // Ensures content centres on large screens without overflow on small ones
                  constraints: BoxConstraints(
                    minHeight:
                        AppResponsive.safeAreaHeight - AppResponsive.h(60),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Lock illustration ──────────────────────────────
                      AppAnimatedItem(
                        index: 0,
                        direction: SlideDirection.bottom,
                        child: AppScaleIn(
                          child: Image.asset(
                            'assets/images/lock.png',
                            height: AppResponsive.h(160),
                            width: AppResponsive.h(160),
                          ),
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(36)),

                      // ── Title ──────────────────────────────────────────
                      AppAnimatedItem(
                        index: 1,
                        direction: SlideDirection.left,
                        child: Text(
                          'Forgot your password?',
                          style: TextStyle(
                            fontSize: AppResponsive.fs(22),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(10)),

                      // ── Subtitle ───────────────────────────────────────
                      AppAnimatedItem(
                        index: 2,
                        direction: SlideDirection.right,
                        child: Text(
                          'Enter your registered email and we\'ll\nsend you a password reset link.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppResponsive.fs(13),
                            color: const Color(0xff737373),
                            height: 1.5,
                          ),
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(28)),

                      // ── Email field ────────────────────────────────────
                      AppAnimatedItem(
                        index: 3,
                        direction: SlideDirection.left,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Email',
                            style: TextStyle(
                              fontSize: AppResponsive.fs(15),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      AppAnimatedItem(
                        index: 3,
                        direction: SlideDirection.left,
                        child: MyTextField(
                          controller: _emailCtrl,
                          hintText: 'Enter your email',
                          obscureText: false,
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(28)),

                      // ── Send button ────────────────────────────────────
                      AppAnimatedItem(
                        index: 4,
                        direction: SlideDirection.bottom,
                        child: MainButton(
                          buttonName: isLoading ? 'Sending...' : 'Send Link',
                          onTap:
                              isLoading
                                  ? () {}
                                  : () {
                                    final email = _emailCtrl.text.trim();
                                    if (email.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Please enter your email',
                                          ),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    if (!email.contains('@')) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Please enter a valid email',
                                          ),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    context.read<AuthCubit>().forgetPassword(
                                      email,
                                    );
                                  },
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(28)),

                      // ── Login link ─────────────────────────────────────
                      AppAnimatedItem(
                        index: 5,
                        direction: SlideDirection.bottom,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Remembered your password? ',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(13),
                                color: const Color(0xff737373),
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: AppResponsive.fs(13),
                                  color: const Color(0xff21496A),
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                  decorationColor: const Color(0xff21496A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
