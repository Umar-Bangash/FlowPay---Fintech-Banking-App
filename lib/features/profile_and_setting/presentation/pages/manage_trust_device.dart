import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_states.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageTrustDevice extends StatelessWidget {
  const ManageTrustDevice({super.key});

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
          'Manage Trusted Devices',
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
            final deviceInfo = state.profileUser.deviceInfo ?? '';
            final hasDevice = deviceInfo.isNotEmpty;

            // Parse device info string: 'name|OS|model'
            final parts = deviceInfo.split('|');
            final deviceName = parts.isNotEmpty ? parts[0] : 'Unknown Device';
            final deviceOS = parts.length > 1 ? parts[1] : 'Unknown OS';

            return Padding(
              padding: context.padSymmetricPx(horizontal: 25, vertical: 16),
              child: Column(
                children: [
                  if (!hasDevice)
                    const Center(
                      child: Text(
                        'No trusted devices found',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff707070),
                        ),
                      ),
                    )
                  else
                    Container(
                      height: context.hPx(94),
                      padding: context.padSymmetricPx(
                        horizontal: 11,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffFBFCFF),
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(color: const Color(0xffDFDFDF)),
                      ),
                      child: Row(
                        children: [
                          // Device icon
                          Container(
                            height: context.hPx(47),
                            width: context.wPx(47),
                            decoration: BoxDecoration(
                              color: const Color(0xffDFE5FF),
                              borderRadius: BorderRadius.circular(10.07),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  'assets/setting/phone.png',
                                  color: const Color(0xff007AFF),
                                ),
                              ),
                            ),
                          ),

                          context.spaceWPx(12),

                          // Device name + OS — dynamic
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deviceName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                deviceOS,
                                style: const TextStyle(
                                  fontSize: 11.57,
                                  color: Color(0xff707070),
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

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
                              height: context.hPx(41),
                              width: context.wPx(78),
                              decoration: BoxDecoration(
                                color: const Color(0xffFFDFEE),
                                borderRadius: BorderRadius.circular(17.14),
                              ),
                              child: const Center(
                                child: Text(
                                  'Remove',
                                  style: TextStyle(
                                    fontSize: 10.2,
                                    color: Color(0xffFF0207),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
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
