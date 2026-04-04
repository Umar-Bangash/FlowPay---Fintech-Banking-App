import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/components/custom_switch.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_states.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationSettingPage extends StatelessWidget {
  const NotificationSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<ProfileCubit>().fetchProfileUser(uid);
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        centerTitle: true,
        title: const Text(
          'Notification Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
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
                children: [
                  context.spaceHPx(20),
                  Container(
                    padding: context.padSymmetricPx(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffFBFCFF),
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Payment notifications
                        notificationTile(
                          context,
                          image: 'assets/home/notification.png',
                          title: 'Show Payment Notifications',
                          subTitle:
                              'Get push notification when you send or receive',
                          value: user.paymentNotifEnabled ?? true,
                          onTap: () {
                            context.read<ProfileCubit>().togglePaymentNotif(
                              !(user.paymentNotifEnabled ?? true),
                            );
                          },
                        ),

                        context.spaceHPx(16),

                        // Chat notifications
                        notificationTile(
                          context,
                          image: 'assets/home/notification.png',
                          title: 'Show Chat Notifications',
                          subTitle:
                              'Get push notification when you receive chat',
                          value: user.chatNotifEnabled ?? true,
                          onTap: () {
                            context.read<ProfileCubit>().toggleChatNotif(
                              !(user.chatNotifEnabled ?? true),
                            );
                          },
                        ),

                        context.spaceHPx(16),

                        // System notifications
                        notificationTile(
                          context,
                          image: 'assets/home/notification.png',
                          title: 'Show System Notifications',
                          subTitle:
                              'Get push notification when you receive system messages.',
                          value: user.systemNotifEnabled ?? false,
                          onTap: () {
                            context.read<ProfileCubit>().toggleSystemNotif(
                              !(user.systemNotifEnabled ?? false),
                            );
                          },
                        ),
                      ],
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

Widget notificationTile(
  BuildContext context, {
  required String image,
  required String title,
  required String subTitle,
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
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12.8)),
            Text(
              subTitle,
              style: const TextStyle(fontSize: 9.8, color: Color(0xffA2A2A2)),
            ),
          ],
        ),
      ),
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
