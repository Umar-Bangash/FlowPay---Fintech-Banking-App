import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/components/custom_switch.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_states.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'edit_profile_page.dart';

class AccountPrivacySettingPage extends StatelessWidget {
  const AccountPrivacySettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch fresh profile when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<ProfileCubit>().fetchProfileUser(uid);
      }
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text(
          'Account & Privacy Setting',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          Image.asset(
            'assets/home/notification.png',
            height: context.hPx(24),
            width: context.wPx(24),
          ),
          context.spaceWPx(20),
        ],
        backgroundColor: const Color(0xffFFFFFF),
      ),
      backgroundColor: const Color(0xffFFFFFF),
      body: BlocBuilder<ProfileCubit, ProfileStates>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded) {
            final user = state.profileUser;

            return Padding(
              padding: context.padSymmetricPx(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Privacy Setting',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  context.spaceHPx(10),

                  // ── Privacy toggles ──
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(21),
                      color: const Color(0xffFBFCFF),
                    ),
                    child: Padding(
                      padding: context.padSymmetricPx(
                        horizontal: 12,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          // Pay with Biometric (Fingerprint)
                          biometricRow(
                            context,
                            image: 'assets/images/fingerprint.png',
                            name: 'Pay with Biometric',
                            value: user.fingerprintEnabled ?? false,
                            onTap: () {
                              context
                                  .read<ProfileCubit>()
                                  .toggleFingerprintEnabled(
                                    !(user.fingerprintEnabled ?? false),
                                  );
                            },
                          ),
                          context.spaceHPx(16),

                          // Log in with Biometric (Fingerprint)
                          biometricRow(
                            context,
                            image: 'assets/images/fingerprint.png',
                            name: 'Log in with Biometric',
                            value: user.fingerprintEnabled ?? false,
                            onTap: () {
                              context
                                  .read<ProfileCubit>()
                                  .toggleFingerprintEnabled(
                                    !(user.fingerprintEnabled ?? false),
                                  );
                            },
                          ),
                          context.spaceHPx(16),

                          // Pay with Face
                          biometricRow(
                            context,
                            image: 'assets/images/face.png',
                            name: 'Pay with Face',
                            value: user.faceEnabled ?? false,
                            onTap: () {
                              context.read<ProfileCubit>().toggleFaceEnabled(
                                !(user.faceEnabled ?? false),
                              );
                            },
                          ),
                          context.spaceHPx(16),

                          // Log in with Face
                          biometricRow(
                            context,
                            image: 'assets/images/face.png',
                            name: 'Log in with Face',
                            value: user.faceEnabled ?? false,
                            onTap: () {
                              context.read<ProfileCubit>().toggleFaceEnabled(
                                !(user.faceEnabled ?? false),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  context.spaceHPx(20),

                  const Text(
                    'Account Setting',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  context.spaceHPx(10),

                  // ── Account settings ──
                  // ── Account settings ──
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(21),
                      color: const Color(0xffFBFCFF),
                    ),
                    child: Padding(
                      padding: context.padSymmetricPx(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          // CNIC — read only
                          accountRow(
                            context,
                            image: 'assets/setting/cnic.png',
                            name: 'CNIC',
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfilePage(),
                                  ),
                                ),
                          ),
                          const Divider(color: Color(0xffF0F0F0)),

                          // Close Account
                          accountRow(
                            context,
                            image: 'assets/pocket/delete.png',
                            name: 'Close Account',
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfilePage(),
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

Widget biometricRow(
  BuildContext context, {
  required String image,
  required String name,
  required bool value,
  required VoidCallback onTap,
}) {
  return Row(
    children: [
      Image.asset(
        image,
        height: context.hPx(24),
        width: context.wPx(24),
        color: const Color(0xff000000),
      ),
      context.spaceWPx(12),
      Text(name, style: const TextStyle(fontSize: 12.8)),
      const Spacer(),
      CustomSwitch(
        width: context.wPx(35),
        height: context.hPx(18.57),
        thumbSize: 12.86,
        value: value,
        onTap: onTap,
      ),
    ],
  );
}

Widget accountRow(
  BuildContext context, {
  required String image,
  required String name,
  required VoidCallback onTap,
}) {
  return Row(
    children: [
      Image.asset(
        image,
        height: context.hPx(24),
        width: context.wPx(24),
        color: const Color(0xff000000),
      ),
      context.spaceWPx(12),
      Text(name, style: const TextStyle(fontSize: 12.8)),
      const Spacer(),
      IconButton(
        onPressed: onTap,
        icon: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    ],
  );
}
