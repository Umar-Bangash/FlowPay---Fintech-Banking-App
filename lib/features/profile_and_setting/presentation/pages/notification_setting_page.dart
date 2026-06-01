import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/components/custom_switch.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class NotificationSettingPage extends StatelessWidget {
  const NotificationSettingPage({super.key});
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
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        centerTitle: true,
        title: Text(
          'Notification Settings',
          style: TextStyle(
            fontSize: AppResponsive.fs(15),
            fontWeight: FontWeight.w500,
          ),
        ),
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
                child: Column(
                  children: [
                    SizedBox(height: AppResponsive.h(20)),
                    AppAnimatedItem(
                      index: 0,
                      direction: SlideDirection.bottom,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppResponsive.w(16),
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
                            _NotiTile(
                              'assets/home/notification.png',
                              'Show Payment Notifications',
                              'Get push notification when you send or receive',
                              u.paymentNotifEnabled ?? true,
                              () => context
                                  .read<ProfileCubit>()
                                  .togglePaymentNotif(
                                    !(u.paymentNotifEnabled ?? true),
                                  ),
                            ),
                            SizedBox(height: AppResponsive.h(16)),
                            _NotiTile(
                              'assets/home/notification.png',
                              'Show Chat Notifications',
                              'Get push notification when you receive chat',
                              u.chatNotifEnabled ?? true,
                              () =>
                                  context.read<ProfileCubit>().toggleChatNotif(
                                    !(u.chatNotifEnabled ?? true),
                                  ),
                            ),
                            SizedBox(height: AppResponsive.h(16)),
                            _NotiTile(
                              'assets/home/notification.png',
                              'Show System Notifications',
                              'Get push notification when you receive system messages.',
                              u.systemNotifEnabled ?? false,
                              () => context
                                  .read<ProfileCubit>()
                                  .toggleSystemNotif(
                                    !(u.systemNotifEnabled ?? false),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
}

class _NotiTile extends StatelessWidget {
  final String img, title, subtitle;
  final bool value;
  final VoidCallback onTap;
  const _NotiTile(this.img, this.title, this.subtitle, this.value, this.onTap);
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Image.asset(
        img,
        height: AppResponsive.sp(22),
        width: AppResponsive.sp(22),
        color: Colors.black,
      ),
      SizedBox(width: AppResponsive.w(12)),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: AppResponsive.fs(12))),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: AppResponsive.fs(10),
                color: const Color(0xffA2A2A2),
              ),
            ),
          ],
        ),
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
