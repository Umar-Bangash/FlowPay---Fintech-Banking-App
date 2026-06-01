import 'package:flowpay/features/auth/presentation/pages/biometrics/fingerprint/fingerprint_lock_page.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import '../../../../../../helpers/app_animation.dart';
import '../../../../../../helpers/ui_responsive_helper.dart';

class FingerprintSetuptPage extends StatelessWidget {
  const FingerprintSetuptPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: Colors.black,
          ),
        ),
      ),
      body: AppAnimatedPage(
        direction: SlideDirection.right,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: AppResponsive.w(25),
              vertical: AppResponsive.h(12),
            ),
            child: Column(
              children: [
                SizedBox(height: AppResponsive.h(8)),

                // ── Title ────────────────────────────────────────────────
                AppAnimatedItem(
                  index: 0,
                  direction: SlideDirection.left,
                  child: Text(
                    'Fingerprint Setup',
                    style: TextStyle(
                      fontSize: AppResponsive.fs(22),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: AppResponsive.h(12)),

                AppAnimatedItem(
                  index: 1,
                  direction: SlideDirection.right,
                  child: Text(
                    'For faster and safer access, this app uses \nyour fingerprint to log in and confirm \nimportant actions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppResponsive.fs(13),
                      color: const Color(0xff737373),
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(20)),

                // ── Illustration ─────────────────────────────────────────
                AppAnimatedItem(
                  index: 2,
                  direction: SlideDirection.bottom,
                  child: AppScaleIn(
                    child: Image.asset(
                      'assets/images/finger_icon.png',
                      height: AppResponsive.h(200).clamp(140.0, 244.0),
                      width: AppResponsive.w(190).clamp(140.0, 230.0),
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(20)),

                // ── Info box ──────────────────────────────────────────────
                AppAnimatedItem(
                  index: 3,
                  direction: SlideDirection.bottom,
                  child: Container(
                    padding: EdgeInsets.all(AppResponsive.w(15)),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffDEE0E5)),
                      borderRadius: BorderRadius.circular(
                        AppResponsive.radiusMd,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _InfoRow(
                          context: context,
                          text:
                              'Your fingerprint ensures only you can \naccess your money and data.',
                        ),
                        SizedBox(height: AppResponsive.h(12)),
                        _InfoRow(
                          context: context,
                          text: 'Sign in instantly with a single touch.',
                        ),
                        SizedBox(height: AppResponsive.h(12)),
                        _InfoRow(
                          context: context,
                          text:
                              'Confirm transfers and payments securely \nwith your fingerprint.',
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(28)),

                // ── Continue ─────────────────────────────────────────────
                AppAnimatedItem(
                  index: 4,
                  direction: SlideDirection.bottom,
                  child: MainButton(
                    buttonName: 'Continue',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => const FingerprintLockPage(
                                  mode: FingerprintLockMode.register,
                                ),
                          ),
                        ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final BuildContext context;
  final String text;
  const _InfoRow({required this.context, required this.text});

  @override
  Widget build(BuildContext _) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/tick.png',
          height: AppResponsive.sp(16),
          width: AppResponsive.sp(14),
        ),
        SizedBox(width: AppResponsive.w(12)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppResponsive.fs(12),
              fontWeight: FontWeight.w400,
              color: const Color(0xff737373),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
