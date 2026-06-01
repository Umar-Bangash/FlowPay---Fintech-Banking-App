import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_states.dart';
import 'package:flowpay/features/profile_and_setting/presentation/pages/account_privacy_setting_page.dart';
import 'package:flowpay/features/profile_and_setting/presentation/pages/manage_trust_device.dart';
import 'package:flowpay/features/profile_and_setting/presentation/pages/notification_setting_page.dart';
import 'package:flowpay/features/qr/presentation/cubit/qr_cubit.dart';
import 'package:flowpay/features/qr/presentation/pages/access_qr_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../../../auth/presentation/pages/biometrics/biometrics_page.dart';
import 'edit_profile_page.dart';

class ProfileSettingPage extends StatefulWidget {
  const ProfileSettingPage({super.key});
  @override
  State<ProfileSettingPage> createState() => _ProfileSettingPageState();
}

class _ProfileSettingPageState extends State<ProfileSettingPage> {
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<ProfileCubit>().fetchProfileUser(uid);
      context.read<ProfileCubit>().saveCurrentDeviceInfo();
    }
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final r = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (r == null || r.files.isEmpty) return;
      final file = File(r.files.first.path!);
      context.read<ProfileCubit>().setPickedImage(file);
      final s = context.read<ProfileCubit>().state;
      if (s is ProfileLoaded) {
        await context.read<ProfileCubit>().updateProfileUser(
          s.profileUser,
          newImageMobile: file,
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
    }
  }

  void _showAccessQrDialog(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    context.read<QRCubit>().resetToInitial();
    showDialog(context: context, builder: (_) => AccessQrDialog(ownerUid: uid));
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile & Setting',
          style: TextStyle(
            fontSize: AppResponsive.fs(16),
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Image.asset(
            'assets/home/notification.png',
            height: AppResponsive.sp(22),
            width: AppResponsive.sp(22),
          ),
          SizedBox(width: AppResponsive.w(22)),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileStates>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) return Center(child: Text(state.message));
          if (state is ProfileLoaded) {
            final user = state.profileUser;
            final picked = state.pickedImage;
            return AppAnimatedPage(
              direction: SlideDirection.bottom,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
                child: Column(
                  children: [
                    SizedBox(height: AppResponsive.h(20)),

                    // ── Avatar ─────────────────────────────────────────
                    AppAnimatedItem(
                      index: 0,
                      direction: SlideDirection.bottom,
                      child: AppScaleIn(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppResponsive.radiusLg,
                              ),
                              child: Container(
                                height: AppResponsive.sp(100),
                                width: AppResponsive.sp(100),
                                color: const Color(0xffDFE5FF),
                                child:
                                    picked != null
                                        ? Image.file(picked, fit: BoxFit.cover)
                                        : (user.profileImageUrl?.isNotEmpty ??
                                            false)
                                        ? Image.network(
                                          user.profileImageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) => Icon(
                                                Icons.person,
                                                size: AppResponsive.sp(50),
                                              ),
                                        )
                                        : Icon(
                                          Icons.person,
                                          size: AppResponsive.sp(50),
                                        ),
                              ),
                            ),
                            Positioned(
                              right: 3,
                              bottom: 3,
                              child: InkWell(
                                onTap: () => _pickAndUpload(context),
                                child: Image.asset(
                                  'assets/chat/blueeye.png',
                                  height: AppResponsive.sp(18),
                                  width: AppResponsive.sp(18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: AppResponsive.h(10)),

                    AppAnimatedItem(
                      index: 1,
                      direction: SlideDirection.bottom,
                      child: Text(
                        user.name,
                        style: TextStyle(
                          fontSize: AppResponsive.fs(15),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    AppAnimatedItem(
                      index: 1,
                      direction: SlideDirection.bottom,
                      child: FutureBuilder<String>(
                        future: _getAccountNumber(user.uid),
                        builder:
                            (_, snap) => Text(
                              'Account No : ${snap.data ?? '...'}',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(11),
                                color: const Color(0xff707070),
                              ),
                              textAlign: TextAlign.center,
                            ),
                      ),
                    ),

                    SizedBox(height: AppResponsive.h(20)),

                    // ── Settings menu ──────────────────────────────────
                    AppAnimatedItem(
                      index: 2,
                      direction: SlideDirection.bottom,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppResponsive.w(20),
                          vertical: AppResponsive.h(20),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffFBFCFF),
                          borderRadius: BorderRadius.circular(
                            AppResponsive.radiusLg,
                          ),
                        ),
                        child: Column(
                          children: [
                            _SettingRow(
                              'assets/setting/profile.png',
                              'Profile setting',
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfilePage(),
                                ),
                              ),
                            ),
                            _divider(),
                            _SettingRow(
                              'assets/home/notification.png',
                              'Notification setting',
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => const NotificationSettingPage(),
                                ),
                              ),
                            ),
                            _divider(),
                            _SettingRow(
                              'assets/setting/history.png',
                              'Transaction History',
                              () {},
                            ),
                            _divider(),
                            _SettingRow(
                              'assets/setting/phone.png',
                              'Manage trusted Devices',
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ManageTrustDevice(),
                                ),
                              ),
                            ),
                            _divider(),
                            _SettingRow(
                              'assets/setting/securityshield.png',
                              'Account & Privacy Setting',
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => const AccountPrivacySettingPage(),
                                ),
                              ),
                            ),
                            _divider(),
                            _SettingRow(
                              'assets/transfer/qr_icon.png',
                              'Share Account Access',
                              () => _showAccessQrDialog(context),
                            ),
                            _divider(),
                            _SettingRow(
                              'assets/images/fingerprint.png',
                              'Set Biometric',
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BiometricsPage(),
                                ),
                              ),
                            ),
                            _divider(),
                            _SettingRow(
                              'assets/setting/help.png',
                              'Help Center',
                              () {},
                            ),
                            _divider(),
                            _SettingRow(
                              'assets/setting/aboutus.png',
                              'About Us',
                              () {},
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: AppResponsive.h(16)),

                    // logout
                    AppAnimatedItem(
                      index: 3,
                      direction: SlideDirection.bottom,
                      child: InkWell(
                        onTap: () {
                          context.read<AuthCubit>().logout();
                        },
                        borderRadius: BorderRadius.circular(
                          AppResponsive.radiusMd,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: AppResponsive.h(54),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppResponsive.w(16),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppResponsive.radiusMd,
                            ),
                            color: const Color(0xffFFEAEC),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/home/logout.png',
                                height: AppResponsive.sp(22),
                                width: AppResponsive.sp(22),
                              ),
                              SizedBox(width: AppResponsive.w(12)),
                              Text(
                                'Log Out',
                                style: TextStyle(
                                  fontSize: AppResponsive.fs(14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppResponsive.h(30)),
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _divider() => Padding(
    padding: EdgeInsets.symmetric(vertical: AppResponsive.h(14)),
    child: const Divider(color: Color(0xffF0F0F0), height: 1),
  );

  Future<String> _getAccountNumber(String uid) async {
    try {
      final d =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return d.data()?['phone'] ?? 'N/A';
    } catch (_) {
      return 'N/A';
    }
  }
}

class _SettingRow extends StatelessWidget {
  final String image, name;
  final VoidCallback onTap;
  const _SettingRow(this.image, this.name, this.onTap);
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Row(
      children: [
        Image.asset(
          image,
          height: AppResponsive.sp(22),
          width: AppResponsive.sp(22),
        ),
        SizedBox(width: AppResponsive.w(12)),
        Expanded(
          child: Text(name, style: TextStyle(fontSize: AppResponsive.fs(13))),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: AppResponsive.sp(13),
          color: const Color(0xffA3A3A3),
        ),
      ],
    ),
  );
}
