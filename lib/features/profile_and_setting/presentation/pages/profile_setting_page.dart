import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/pages/login_page.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_states.dart';
import 'package:flowpay/features/profile_and_setting/presentation/pages/account_privacy_setting_page.dart';
import 'package:flowpay/features/profile_and_setting/presentation/pages/manage_trust_device.dart';
import 'package:flowpay/features/profile_and_setting/presentation/pages/notification_setting_page.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      // Save device info on profile open
      context.read<ProfileCubit>().saveCurrentDeviceInfo();
    }
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.first.path!);
      context.read<ProfileCubit>().setPickedImage(file);

      final cubit = context.read<ProfileCubit>();
      final currentState = cubit.state;
      if (currentState is ProfileLoaded) {
        await cubit.updateProfileUser(
          currentState.profileUser,
          newImageMobile: file,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Profile & Setting',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          Image.asset(
            'assets/home/notification.png',
            height: context.hPx(24),
            width: context.wPx(24),
          ),
          context.spaceWPx(25),
        ],
        backgroundColor: const Color(0xffFFFFFF),
      ),
      backgroundColor: const Color(0xffFFFFFF),
      body: BlocBuilder<ProfileCubit, ProfileStates>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }

          if (state is ProfileLoaded) {
            final user = state.profileUser;
            final pickedImage = state.pickedImage;

            return SingleChildScrollView(
              child: Padding(
                padding: context.padSymmetricPx(horizontal: 25),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ── Profile image ──
                    Stack(
                      children: [
                        Container(
                          height: context.hPx(104),
                          width: context.wPx(104),
                          decoration: BoxDecoration(
                            color: const Color(0xffDFE5FF),
                            border: Border.all(color: const Color(0xffF2F2F2)),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child:
                                pickedImage != null
                                    ? Image.file(pickedImage, fit: BoxFit.cover)
                                    : (user.profileImageUrl != null &&
                                            user.profileImageUrl!.isNotEmpty
                                        ? Image.network(
                                          user.profileImageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (c, e, s) => const Icon(
                                                Icons.person,
                                                size: 60,
                                              ),
                                        )
                                        : const Icon(Icons.person, size: 60)),
                          ),
                        ),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: InkWell(
                            onTap: () => _pickAndUploadImage(context),
                            child: Image.asset(
                              'assets/chat/blueeye.png',
                              height: context.hPx(16),
                              width: context.wPx(16),
                            ),
                          ),
                        ),
                      ],
                    ),

                    context.spaceHPx(10),

                    // ── Name — dynamic ✅ ──
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // ── Account number — dynamic ✅ ──
                    FutureBuilder<String>(
                      future: _getAccountNumber(user.uid),
                      builder: (context, snapshot) {
                        return Text(
                          'Account No : ${snapshot.data ?? '...'}',
                          style: const TextStyle(
                            fontSize: 11.57,
                            color: Color(0xff707070),
                          ),
                        );
                      },
                    ),

                    context.spaceHPx(20),

                    // ── Settings menu ──
                    Container(
                      width: double.maxFinite,
                      padding: context.padSymmetricPx(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffFBFCFF),
                        borderRadius: BorderRadius.circular(21),
                      ),
                      child: Column(
                        children: [
                          // Profile setting row
                          reusableSettingRow(
                            context,
                            image: 'assets/setting/profile.png',
                            name: 'Profile setting',
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfilePage(),
                                  ),
                                ),
                          ),
                          const SizedBox(height: 20),
                          reusableSettingRow(
                            context,
                            image: 'assets/home/notification.png',
                            name: 'Notification setting',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => const NotificationSettingPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          reusableSettingRow(
                            context,
                            image: 'assets/setting/history.png',
                            name: 'Transaction History',
                            onTap: () {},
                          ),
                          const SizedBox(height: 20),
                          reusableSettingRow(
                            context,
                            image: 'assets/setting/phone.png',
                            name: 'Manage trusted Devices',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ManageTrustDevice(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          reusableSettingRow(
                            context,
                            image: 'assets/setting/securityshield.png',
                            name: 'Account & Privacy Setting',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => const AccountPrivacySettingPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          reusableSettingRow(
                            context,
                            image: 'assets/setting/help.png',
                            name: 'Help Center',
                            onTap: () {},
                          ),
                          const SizedBox(height: 20),
                          reusableSettingRow(
                            context,
                            image: 'assets/setting/aboutus.png',
                            name: 'About Us',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    context.spaceHPx(18),

                    // ── Logout ──
                    InkWell(
                      onTap: () {
                        context.read<AuthCubit>().logout();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginPage(onTap: () {}),
                          ),
                        );
                      },
                      child: Container(
                        height: context.hPx(58),
                        padding: context.padSymmetricPx(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xffFFEAEC),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/home/logout.png',
                              height: context.hPx(25),
                              width: context.wPx(24),
                            ),
                            context.spaceWPx(12),
                            const Text(
                              'Log Out',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),

                    context.spaceHPx(30),
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

  // Get phone number as account number from Firestore
  Future<String> _getAccountNumber(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return doc.data()?['phone'] ?? 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }
}

Widget reusableSettingRow(
  BuildContext context, {
  required String image,
  required String name,
  required void Function() onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Row(
      children: [
        Image.asset(image, height: context.hPx(24), width: context.wPx(24)),
        context.spaceWPx(12),
        Text(name, style: const TextStyle(fontSize: 14)),
      ],
    ),
  );
}

// class _ProfileEditSheet extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'Edit Profile',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 20),

//           // Change Name
//           ListTile(
//             leading: const Icon(Icons.person_outline, color: Color(0xff3B6FE8)),
//             title: const Text('Change Name'),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//             onTap: () {
//               Navigator.pop(context);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder:
//                       (_) => const EditProfilePage(),
//                 ),
//               );
//             },
//           ),
//           const Divider(color: Color(0xffF0F0F0)),

//           // Change Phone
//           ListTile(
//             leading: const Icon(Icons.phone_outlined, color: Color(0xff3B6FE8)),
//             title: const Text('Change Phone'),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//             onTap: () {
//               Navigator.pop(context);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder:
//                       (_) => const EditProfilePage(type: EditProfileType.phone),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }
