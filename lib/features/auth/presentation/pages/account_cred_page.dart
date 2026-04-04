import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/account/domain/entities/account.dart';
import 'package:flowpay/features/account/presentation/cubit/account_cubit.dart';
import 'package:flowpay/features/account/presentation/cubit/account_states.dart';
import 'package:flowpay/features/auth/presentation/components/my_textfield.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'biometrics/biometrics_page.dart';

class AccountCredPage extends StatelessWidget {
  AccountCredPage({super.key});

  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xffFFFFFF)),
      backgroundColor: const Color(0xffFFFFFF),
      body: Padding(
        padding: context.padSymmetricPx(horizontal: 25),
        child: BlocConsumer<AccountCubit, AccountStates>(
          listener: (context, state) {
            if (state is AccountSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.meessage),
                  backgroundColor: Colors.green,
                ),
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const BiometricsPage()),
                    (route) => false,
                  );
                }
              });
            }

            if (state is AccountError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AccountLoading;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'One Last Step!',
                  style: TextStyle(fontSize: 16, color: Color(0xff737373)),
                ),
                context.spaceHPx(8),
                const Text(
                  'Account Credentials',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                context.spaceHPx(8),
                const Text(
                  'Your phone number will be used\nfor account identification.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xff737373),
                    height: 1.5,
                  ),
                ),
                context.spaceHPx(40),

                // ── Phone only ──
                const Text(
                  'Phone Number',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                MyTextField(
                  controller: phoneController,
                  hintText: 'Enter your phone number',
                  obscureText: false,
                ),

                context.spaceHPx(40),

                if (isLoading)
                  Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        context.spaceHPx(10),
                        Text(
                          'Creating account...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MainButton(
                      buttonName: isLoading ? 'Please wait...' : 'Continue',
                      onTap: () {
                        if (isLoading) return;

                        final phone = phoneController.text.trim();

                        if (phone.isEmpty || phone.length < 10) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Enter a valid phone number'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final account = Account(
                          accountId: '',
                          userId: uid,
                          phone: phone,
                          balance: 0.0,
                        );

                        context.read<AccountCubit>().createAccount(account);
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
