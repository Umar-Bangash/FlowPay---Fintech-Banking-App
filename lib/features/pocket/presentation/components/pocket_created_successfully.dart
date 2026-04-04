import 'package:flowpay/helpers/text_styles.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/cupertino.dart';

class PocketCreatedSuccessfully extends StatelessWidget {
  const PocketCreatedSuccessfully({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/transfer/success.png',
          height: context.hPx(120),
          width: context.wPx(120),
        ),
        context.spaceHPx(20),
        boldBigText('Pocket Created'),
        mediumGreyText('Your Pocket successfully created'),
      ],
    );
  }
}
