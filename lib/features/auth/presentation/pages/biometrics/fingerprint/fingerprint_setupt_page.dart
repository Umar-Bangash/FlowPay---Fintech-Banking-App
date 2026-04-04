import 'package:flowpay/features/auth/presentation/pages/biometrics/face_lock/face_id_setup_page.dart';
import 'package:flowpay/features/auth/presentation/pages/biometrics/fingerprint/fingerprint_lock_page.dart';
import 'package:flowpay/helpers/text_styles.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';

class FingerprintSetuptPage extends StatelessWidget {
  const FingerprintSetuptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(backgroundColor: Color(0xffFFFFFF)),
      body: SizedBox(
        width: double.maxFinite,
        child: Column(
          children: [
            boldBigText('Fingerprint Setup'),
            context.spaceHPx(15),
            mediumGreyText(
              'For faster and safer access, this app uses \nyour fingerprint to log in and confirm \nimportant actions.',
            ),
            context.spaceHPx(20),
            Image.asset(
              'assets/images/finger_icon.png',
              height: 244,
              width: 230,
            ),
            context.spaceHPx(20),
            Container(
              padding: context.padAllPx(15),
              width: context.wPx(342),
              height: context.hPx(176),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffDEE0E5)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  instructText(
                    context,
                    'Your fingerprint ensures only you can \naccess your money and data.',
                  ),
                  instructText(
                    context,
                    'Sign in instantly with a single touch.',
                  ),
                  instructText(
                    context,
                    'Confirm transfers and payments securely \nwith your fingerprint.',
                  ),
                ],
              ),
            ),
            context.spaceHPx(30),
            MainButton(
              buttonName: 'Continue',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FingerprintLockPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
