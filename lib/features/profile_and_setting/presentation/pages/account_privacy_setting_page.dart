import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/components/custom_switch.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import 'edit_profile_page.dart';

class AccountPrivacySettingPage extends StatelessWidget {
  const AccountPrivacySettingPage({super.key});
  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) context.read<ProfileCubit>().fetchProfileUser(uid);
    });
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          'Account & Privacy Setting',
          style: TextStyle(
            fontSize: AppResponsive.fs(15),
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Image.asset(
            'assets/home/notification.png',
            height: AppResponsive.sp(22),
            width: AppResponsive.sp(22),
          ),
          SizedBox(width: AppResponsive.w(20)),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileStates>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileLoaded) {
            final u = state.profileUser;
            return AppAnimatedPage(
              direction: SlideDirection.bottom,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppResponsive.h(16)),
                      AppAnimatedItem(
                        index: 0,
                        direction: SlideDirection.left,
                        child: Text(
                          'Privacy Setting',
                          style: TextStyle(
                            fontSize: AppResponsive.fs(13),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: AppResponsive.h(10)),
                      AppAnimatedItem(
                        index: 1,
                        direction: SlideDirection.right,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppResponsive.radiusLg,
                            ),
                            color: const Color(0xffFBFCFF),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppResponsive.w(14),
                            vertical: AppResponsive.h(16),
                          ),
                          child: Column(
                            children: [
                              _BiometricRow(
                                'assets/images/fingerprint.png',
                                'Pay with Biometric',
                                u.fingerprintEnabled ?? false,
                                () => context
                                    .read<ProfileCubit>()
                                    .toggleFingerprintEnabled(
                                      !(u.fingerprintEnabled ?? false),
                                    ),
                              ),
                              SizedBox(height: AppResponsive.h(14)),
                              _BiometricRow(
                                'assets/images/fingerprint.png',
                                'Log in with Biometric',
                                u.fingerprintEnabled ?? false,
                                () => context
                                    .read<ProfileCubit>()
                                    .toggleFingerprintEnabled(
                                      !(u.fingerprintEnabled ?? false),
                                    ),
                              ),
                              SizedBox(height: AppResponsive.h(14)),
                              _BiometricRow(
                                'assets/images/face.png',
                                'Pay with Face',
                                u.faceEnabled ?? false,
                                () => context
                                    .read<ProfileCubit>()
                                    .toggleFaceEnabled(
                                      !(u.faceEnabled ?? false),
                                    ),
                              ),
                              SizedBox(height: AppResponsive.h(14)),
                              _BiometricRow(
                                'assets/images/face.png',
                                'Log in with Face',
                                u.faceEnabled ?? false,
                                () => context
                                    .read<ProfileCubit>()
                                    .toggleFaceEnabled(
                                      !(u.faceEnabled ?? false),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppResponsive.h(20)),
                      AppAnimatedItem(
                        index: 2,
                        direction: SlideDirection.left,
                        child: Text(
                          'Account Setting',
                          style: TextStyle(
                            fontSize: AppResponsive.fs(13),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: AppResponsive.h(10)),
                      AppAnimatedItem(
                        index: 3,
                        direction: SlideDirection.right,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppResponsive.radiusLg,
                            ),
                            color: const Color(0xffFBFCFF),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppResponsive.w(14),
                            vertical: AppResponsive.h(8),
                          ),
                          child: Column(
                            children: [
                              _AccountRow(
                                'assets/setting/cnic.png',
                                'CNIC',
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfilePage(),
                                  ),
                                ),
                              ),
                              const Divider(color: Color(0xffF0F0F0)),
                              _AccountRow(
                                'assets/pocket/delete.png',
                                'Close Account',
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
                      SizedBox(height: AppResponsive.h(24)),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _BiometricRow extends StatelessWidget {
  final String image, name;
  final bool value;
  final VoidCallback onTap;
  const _BiometricRow(this.image, this.name, this.value, this.onTap);
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Image.asset(
        image,
        height: AppResponsive.sp(22),
        width: AppResponsive.sp(22),
        color: Colors.black,
      ),
      SizedBox(width: AppResponsive.w(12)),
      Expanded(
        child: Text(name, style: TextStyle(fontSize: AppResponsive.fs(12))),
      ),
      CustomSwitch(
        width: AppResponsive.w(35),
        height: AppResponsive.h(19),
        thumbSize: 13,
        value: value,
        onTap: onTap,
      ),
    ],
  );
}

class _AccountRow extends StatelessWidget {
  final String image, name;
  final VoidCallback onTap;
  const _AccountRow(this.image, this.name, this.onTap);
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: AppResponsive.h(10)),
      child: Row(
        children: [
          Image.asset(
            image,
            height: AppResponsive.sp(22),
            width: AppResponsive.sp(22),
            color: Colors.black,
          ),
          SizedBox(width: AppResponsive.w(12)),
          Expanded(
            child: Text(name, style: TextStyle(fontSize: AppResponsive.fs(12))),
          ),
          Icon(Icons.arrow_forward_ios, size: AppResponsive.sp(14)),
        ],
      ),
    ),
  );
}
