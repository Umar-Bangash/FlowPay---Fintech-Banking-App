import 'package:flowpay/features/auth/presentation/pages/biometrics/face_lock/face_lock_page.dart';
import 'package:flowpay/helpers/text_styles.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';

class FaceIdSetupPage extends StatelessWidget {
  const FaceIdSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(backgroundColor: Color(0xffFFFFFF)),
      body: SizedBox(
        width: double.maxFinite,
        child: Column(
          children: [
            boldBigText('Face ID Setup'),
            context.spaceHPx(15),
            mediumGreyText(
              'To enhance your security, this app uses \nFace ID to verify your identity and \nauthorize transactions.',
            ),
            context.spaceHPx(20),
            Image.asset('assets/images/face_icon.png', height: 244, width: 230),
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
                    'Facial recognition adds an extra layer of \nprotection to keep your account safe.',
                  ),
                  instructText(
                    context,
                    'Unlock your account instantly by simply \nlooking at your device.',
                  ),
                  instructText(
                    context,
                    'Approve payments and transfers securely \nusing your face.',
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
                    builder:
                        (context) =>
                            const FaceLockPage(mode: FaceLockMode.register),
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

Widget instructText(BuildContext context, String text) {
  return Row(
    children: [
      Image.asset(
        'assets/images/tick.png',
        height: context.hPx(18),
        width: context.wPx(14),
      ),
      context.spaceWPx(15),
      Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Color(0xff737373),
        ),
      ),
    ],
  );
}
