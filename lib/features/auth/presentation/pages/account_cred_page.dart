import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/account/domain/entities/account.dart';
import 'package:flowpay/features/account/presentation/cubit/account_cubit.dart';
import 'package:flowpay/features/account/presentation/cubit/account_states.dart';
import 'package:flowpay/features/auth/presentation/components/my_textfield.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import 'biometrics/biometrics_page.dart';

class AccountCredPage extends StatelessWidget {
  AccountCredPage({super.key});
  final _phoneCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      backgroundColor: Colors.white,
      body: AppAnimatedPage(
        direction: SlideDirection.right,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
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
                        MaterialPageRoute(
                          builder: (_) => const BiometricsPage(),
                        ),
                        (r) => false,
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
                    AppAnimatedItem(
                      index: 0,
                      direction: SlideDirection.left,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'One Last Step!',
                            style: TextStyle(
                              fontSize: AppResponsive.fs(15),
                              color: const Color(0xff737373),
                            ),
                          ),
                          SizedBox(height: AppResponsive.h(6)),
                          Text(
                            'Account Credentials',
                            style: TextStyle(
                              fontSize: AppResponsive.fs(24),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppResponsive.h(6)),
                          Text(
                            'Your phone number will be used\nfor account identification.',
                            style: TextStyle(
                              fontSize: AppResponsive.fs(13),
                              color: const Color(0xff737373),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppResponsive.h(38)),

                    AppAnimatedItem(
                      index: 1,
                      direction: SlideDirection.right,
                      child: Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: AppResponsive.fs(15),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    AppAnimatedItem(
                      index: 1,
                      direction: SlideDirection.right,
                      child: MyTextField(
                        controller: _phoneCtrl,
                        hintText: 'Enter your phone number',
                        obscureText: false,
                      ),
                    ),

                    SizedBox(height: AppResponsive.h(38)),

                    if (isLoading)
                      AppAnimatedItem(
                        index: 2,
                        direction: SlideDirection.bottom,
                        child: Center(
                          child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              SizedBox(height: AppResponsive.h(10)),
                              Text(
                                'Creating account...',
                                style: TextStyle(
                                  fontSize: AppResponsive.fs(15),
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    AppAnimatedItem(
                      index: isLoading ? 3 : 2,
                      direction: SlideDirection.bottom,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MainButton(
                            buttonName:
                                isLoading ? 'Please wait...' : 'Continue',
                            onTap: () {
                              if (isLoading) return;
                              final phone = _phoneCtrl.text.trim();
                              if (phone.isEmpty || phone.length < 10) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Enter a valid phone number'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              context.read<AccountCubit>().createAccount(
                                Account(
                                  accountId: '',
                                  userId: uid,
                                  phone: phone,
                                  balance: 0.0,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
