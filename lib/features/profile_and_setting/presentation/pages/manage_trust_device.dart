import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class ManageTrustDevice extends StatelessWidget {
  const ManageTrustDevice({super.key});
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
          'Manage Trusted Devices',
          style: TextStyle(
            fontSize: AppResponsive.fs(15),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: BlocBuilder<ProfileCubit, ProfileStates>(
        builder: (context, state) {
          if (state is ProfileLoading)
            return const Center(child: CircularProgressIndicator());
          if (state is ProfileLoaded) {
            final info = state.profileUser.deviceInfo ?? '';
            final hasDev = info.isNotEmpty;
            final parts = info.split('|');
            final devName = parts.isNotEmpty ? parts[0] : 'Unknown Device';
            final devOS = parts.length > 1 ? parts[1] : 'Unknown OS';
            return AppAnimatedPage(
              direction: SlideDirection.bottom,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppResponsive.w(25),
                  vertical: AppResponsive.h(16),
                ),
                child: Column(
                  children: [
                    if (!hasDev)
                      Center(
                        child: Text(
                          'No trusted devices found',
                          style: TextStyle(
                            fontSize: AppResponsive.fs(13),
                            color: const Color(0xff707070),
                          ),
                        ),
                      )
                    else
                      AppAnimatedItem(
                        index: 0,
                        direction: SlideDirection.right,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppResponsive.w(12),
                            vertical: AppResponsive.h(14),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffFBFCFF),
                            borderRadius: BorderRadius.circular(
                              AppResponsive.radiusLg,
                            ),
                            border: Border.all(color: const Color(0xffDFDFDF)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: AppResponsive.sp(46),
                                width: AppResponsive.sp(46),
                                decoration: BoxDecoration(
                                  color: const Color(0xffDFE5FF),
                                  borderRadius: BorderRadius.circular(
                                    AppResponsive.radiusSm,
                                  ),
                                ),
                                padding: EdgeInsets.all(AppResponsive.sp(9)),
                                child: Image.asset(
                                  'assets/setting/phone.png',
                                  color: const Color(0xff007AFF),
                                ),
                              ),
                              SizedBox(width: AppResponsive.w(12)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      devName,
                                      style: TextStyle(
                                        fontSize: AppResponsive.fs(14),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      devOS,
                                      style: TextStyle(
                                        fontSize: AppResponsive.fs(11),
                                        color: const Color(0xff707070),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Remove button
                              InkWell(
                                onTap: () async {
                                  await context
                                      .read<ProfileCubit>()
                                      .removeDeviceInfo();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Device removed'),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppResponsive.w(12),
                                    vertical: AppResponsive.h(8),
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffFFDFEE),
                                    borderRadius: BorderRadius.circular(
                                      AppResponsive.radiusSm,
                                    ),
                                  ),
                                  child: Text(
                                    'Remove',
                                    style: TextStyle(
                                      fontSize: AppResponsive.fs(11),
                                      color: const Color(0xffFF0207),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
