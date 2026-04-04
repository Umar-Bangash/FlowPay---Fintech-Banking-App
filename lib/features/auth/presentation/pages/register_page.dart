import 'package:flowpay/features/auth/presentation/components/my_textfield.dart';
import 'package:flowpay/features/auth/presentation/pages/account_cred_page.dart';
import 'package:flowpay/features/auth/presentation/pages/dob_page.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowpay/features/auth/presentation/cubit/pwd_strength_cubit.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  final DateTime? dob;

  const RegisterPage({required this.onTap, super.key, this.dob});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final idController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String formatDOB(DateTime dob) {
    return DateFormat('dd MMM yyyy').format(dob);
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    idController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            body: Padding(
              padding: context.padSymmetricPx(horizontal: 25),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    context.spaceHPx(60),

                    const Text(
                      'Tell Us About You',
                      style: TextStyle(fontSize: 16, color: Color(0xff737373)),
                    ),
                    context.spaceHPx(8),
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    context.spaceHPx(25),

                    // ── Name ──
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    MyTextField(
                      controller: nameController,
                      hintText: 'Enter your legal name',
                      obscureText: false,
                    ),

                    // ── Email ──
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    MyTextField(
                      controller: emailController,
                      hintText: 'Enter your email',
                      obscureText: false,
                    ),

                    // ── Date of Birth ──
                    const Text(
                      'Date of Birth',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    MyTextField(
                      onTap: () async {
                        final selectedDob = await Navigator.push<DateTime>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DateOfBirthPicker(),
                          ),
                        );
                        if (selectedDob != null) {
                          dobController.text = formatDOB(selectedDob);
                        }
                      },
                      readOnly: true,
                      controller: dobController,
                      hintText:
                          dobController.text.isNotEmpty
                              ? dobController.text
                              : 'Set your date of birth',
                      obscureText: false,
                      suffixIcon: Image.asset(
                        'assets/images/calender.png',
                        height: 56,
                        width: 85,
                      ),
                    ),

                    // ── National ID ──
                    const Text(
                      'National ID',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    MyTextField(
                      controller: idController,
                      hintText: 'Enter your verified national ID',
                      obscureText: false,
                    ),

                    // ── Password ──
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Password field with strength listener
                    BlocBuilder<PasswordStrengthCubit, PasswordStrengthState>(
                      builder: (context, strengthState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyTextField(
                              controller: passwordController,
                              hintText: 'Enter your password',
                              obscureText: true,
                              onChange: (value) {
                                context
                                    .read<PasswordStrengthCubit>()
                                    .checkPassword(value);
                              },
                            ),

                            // Strength bar — only shows when typing
                            if (strengthState.strength > 0) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Progress bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: strengthState.strength,
                                        minHeight: 5,
                                        backgroundColor: Colors.grey[200],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              _strengthColor(
                                                strengthState.strength,
                                              ),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // Feedback text
                                    Text(
                                      strengthState.feedbackText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _strengthColor(
                                          strengthState.strength,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        );
                      },
                    ),

                    context.spaceHPx(30),

                    // ── Sign Up button ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MainButton(
                          buttonName: isLoading ? 'Signing up...' : 'Sign Up',
                          onTap: () {
                            if (isLoading) return;

                            // Validation
                            if (nameController.text.trim().isEmpty ||
                                emailController.text.trim().isEmpty ||
                                passwordController.text.trim().isEmpty ||
                                dobController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all fields'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            context.read<AuthCubit>().register(
                              nameController.text.trim(),
                              emailController.text.trim(),
                              passwordController.text.trim(),
                              dobController.text,
                            );
                          },
                        ),
                      ],
                    ),

                    context.spaceHPx(25),

                    // ── Login link ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff737373),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Login',
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

                    context.spaceHPx(30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Strength color based on value
  Color _strengthColor(double strength) {
    if (strength <= 0.25) return Colors.red;
    if (strength <= 0.5) return Colors.orange;
    if (strength <= 0.75) return Colors.blue;
    return Colors.green;
  }
}
