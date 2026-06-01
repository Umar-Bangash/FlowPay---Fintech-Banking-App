import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/account/presentation/cubit/account_cubit.dart';
import 'package:flowpay/features/account/presentation/cubit/account_states.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import 'qr_scan_page.dart';

class QRPage extends StatelessWidget {
  const QRPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final authState = context.watch<AuthCubit>().state;
    final userName = authState is Authenticated ? authState.user.name : '';
    final accountState = context.watch<AccountCubit>().state;
    final phone =
        accountState is AccountLoaded && accountState.accounts.isNotEmpty
            ? accountState.accounts.first.phone
            : '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        actions: [
          InkWell(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QRScanPage()),
                ),
            child: Image.asset(
              'assets/transfer/qr_icon.png',
              height: AppResponsive.sp(22),
              width: AppResponsive.sp(22),
            ),
          ),
          SizedBox(width: AppResponsive.w(10)),
          Image.asset(
            'assets/home/notification.png',
            height: AppResponsive.sp(22),
            width: AppResponsive.sp(22),
          ),
          SizedBox(width: AppResponsive.w(20)),
        ],
      ),
      body: AppAnimatedPage(
        direction: SlideDirection.bottom,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ────────────────────────────────────────────────
              AppAnimatedItem(
                index: 0,
                direction: SlideDirection.left,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Pay',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(22),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Flow pay',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(14),
                        color: const Color(0xff737373),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppResponsive.h(20)),

              // ── QR Card — LayoutBuilder so it NEVER overflows ─────────
              AppAnimatedItem(
                index: 1,
                direction: SlideDirection.bottom,
                child: AppScaleIn(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      // QR size = 44% of available width, clamped
                      final qrSize = (c.maxWidth * 0.44).clamp(130.0, 200.0);

                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppResponsive.w(20),
                          vertical: AppResponsive.h(24),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppResponsive.radiusLg,
                          ),
                          color: Colors.white,
                          border: Border.all(color: const Color(0xffE5E5E5)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo
                            Image.asset(
                              'assets/images/flowpay.png',
                              height: AppResponsive.h(26),
                              width: AppResponsive.w(140),
                            ),

                            SizedBox(height: AppResponsive.h(24)),

                            // QR code
                            Container(
                              padding: EdgeInsets.all(AppResponsive.w(8)),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppResponsive.radiusMd,
                                ),
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xffF0F0F0),
                                ),
                              ),
                              child: QrImageView(
                                data: userId,
                                size: qrSize,
                                backgroundColor: Colors.white,
                              ),
                            ),

                            SizedBox(height: AppResponsive.h(20)),

                            // Name
                            Text(
                              userName.isNotEmpty ? userName : '—',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(16),
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: AppResponsive.h(8)),

                            // Phone
                            Text(
                              phone.isNotEmpty
                                  ? 'Account No : $phone'
                                  : 'Account No : —',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(14),
                                color: const Color(0xff737373),
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              const Spacer(),

              // ── Done button ───────────────────────────────────────────
              AppAnimatedItem(
                index: 2,
                direction: SlideDirection.bottom,
                child: MainButton(buttonName: 'Done', onTap: () {}),
              ),

              SizedBox(height: AppResponsive.h(40)),
            ],
          ),
        ),
      ),
    );
  }
}
