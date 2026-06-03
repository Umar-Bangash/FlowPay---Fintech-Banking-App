import 'package:flowpay/features/auth/presentation/components/my_textfield.dart';
import 'package:flowpay/features/auth/presentation/pages/account_cred_page.dart';
import 'package:flowpay/features/auth/presentation/pages/dob_page.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowpay/features/auth/presentation/cubit/pwd_strength_cubit.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  final DateTime? dob;
  const RegisterPage({required this.onTap, super.key, this.dob});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String _formatDOB(DateTime dob) => DateFormat('dd MMM yyyy').format(dob);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _idCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Color _strengthColor(double s) {
    if (s <= 0.25) return Colors.red;
    if (s <= 0.50) return Colors.orange;
    if (s <= 0.75) return Colors.blue;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return BlocProvider(
      create: (_) => PasswordStrengthCubit(),
      child: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is FaceSetupRequired) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AccountCredPage()),
            );
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: Colors.white,
            body: AppAnimatedPage(
              direction: SlideDirection.right,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.w(25),
                    vertical: AppResponsive.h(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppResponsive.h(20)),

                      // Header
                      AppAnimatedItem(
                        index: 0,
                        direction: SlideDirection.left,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tell Us About You',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(15),
                                color: const Color(0xff737373),
                              ),
                            ),
                            SizedBox(height: AppResponsive.h(6)),
                            Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(24),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(22)),

                      // Name
                      AppAnimatedItem(
                        index: 1,
                        direction: SlideDirection.right,
                        child: _FieldLabel(label: 'Name'),
                      ),
                      AppAnimatedItem(
                        index: 1,
                        direction: SlideDirection.right,
                        child: MyTextField(
                          controller: _nameCtrl,
                          hintText: 'Enter your legal name',
                          obscureText: false,
                        ),
                      ),

                      // Email
                      AppAnimatedItem(
                        index: 2,
                        direction: SlideDirection.left,
                        child: _FieldLabel(label: 'Email'),
                      ),
                      AppAnimatedItem(
                        index: 2,
                        direction: SlideDirection.left,
                        child: MyTextField(
                          controller: _emailCtrl,
                          hintText: 'Enter your email',
                          obscureText: false,
                        ),
                      ),

                      // DOB
                      AppAnimatedItem(
                        index: 3,
                        direction: SlideDirection.right,
                        child: _FieldLabel(label: 'Date of Birth'),
                      ),
                      AppAnimatedItem(
                        index: 3,
                        direction: SlideDirection.right,
                        child: MyTextField(
                          onTap: () async {
                            final picked = await Navigator.push<DateTime>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DateOfBirthPicker(),
                              ),
                            );
                            if (picked != null) {
                              _dobCtrl.text = _formatDOB(picked);
                            }
                          },
                          readOnly: true,
                          controller: _dobCtrl,
                          hintText:
                              _dobCtrl.text.isNotEmpty
                                  ? _dobCtrl.text
                                  : 'Set your date of birth',
                          obscureText: false,
                          suffixIcon: Image.asset(
                            'assets/images/calender.png',
                            height: 56,
                            width: 85,
                          ),
                        ),
                      ),

                      // National ID
                      AppAnimatedItem(
                        index: 4,
                        direction: SlideDirection.left,
                        child: _FieldLabel(label: 'National ID'),
                      ),
                      AppAnimatedItem(
                        index: 4,
                        direction: SlideDirection.left,
                        child: MyTextField(
                          controller: _idCtrl,
                          hintText: 'Enter your verified national ID',
                          obscureText: false,
                        ),
                      ),

                      // Password
                      AppAnimatedItem(
                        index: 5,
                        direction: SlideDirection.right,
                        child: _FieldLabel(label: 'Password'),
                      ),

                      AppAnimatedItem(
                        index: 5,
                        direction: SlideDirection.right,
                        child: BlocBuilder<
                          PasswordStrengthCubit,
                          PasswordStrengthState
                        >(
                          builder:
                              (context, ss) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyTextField(
                                    controller: _passwordCtrl,
                                    hintText: 'Enter your password',
                                    obscureText: true,
                                    onChange:
                                        (v) => context
                                            .read<PasswordStrengthCubit>()
                                            .checkPassword(v),
                                  ),
                                  if (ss.strength > 0) ...[
                                    SizedBox(height: AppResponsive.h(4)),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppResponsive.w(4),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: ss.strength,
                                              minHeight: AppResponsive.h(5),
                                              backgroundColor: Colors.grey[200],
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    _strengthColor(ss.strength),
                                                  ),
                                            ),
                                          ),
                                          SizedBox(height: AppResponsive.h(4)),
                                          Text(
                                            ss.feedbackText,
                                            style: TextStyle(
                                              fontSize: AppResponsive.fs(11),
                                              fontWeight: FontWeight.w500,
                                              color: _strengthColor(
                                                ss.strength,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: AppResponsive.h(8)),
                                  ],
                                ],
                              ),
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(28)),

                      //  Sign Up button
                      AppAnimatedItem(
                        index: 6,
                        direction: SlideDirection.bottom,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MainButton(
                              buttonName:
                                  isLoading ? 'Signing up...' : 'Sign Up',
                              onTap: () {
                                if (isLoading) return;
                                if (_nameCtrl.text.trim().isEmpty ||
                                    _emailCtrl.text.trim().isEmpty ||
                                    _passwordCtrl.text.trim().isEmpty ||
                                    _dobCtrl.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please fill all fields'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                context.read<AuthCubit>().register(
                                  _nameCtrl.text.trim(),
                                  _emailCtrl.text.trim(),
                                  _passwordCtrl.text.trim(),
                                  _dobCtrl.text,
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(22)),

                      // Login link
                      AppAnimatedItem(
                        index: 7,
                        direction: SlideDirection.bottom,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(13),
                                color: const Color(0xff737373),
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Login',
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

                      SizedBox(height: AppResponsive.h(24)),
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

//  Small reusable field label
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize: AppResponsive.fs(15),
      fontWeight: FontWeight.w500,
    ),
  );
}
