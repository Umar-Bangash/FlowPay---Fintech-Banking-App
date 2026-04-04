import 'package:flowpay/features/transaction/presentation/components/activity_button.dart';
import 'package:flowpay/features/transaction/presentation/components/payment_recipt.dart';
import 'package:flowpay/features/transaction/presentation/cubit/recipt_cubit.dart';
import 'package:flowpay/helpers/text_styles.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/app_user.dart';

class PaymentSuccessPage extends StatelessWidget {
  final double amount;
  final AppUser reciver;
  final String transactionId;
  const PaymentSuccessPage({
    super.key,
    required this.amount,
    required this.reciver,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(backgroundColor: Color(0xffFFFFFF)),
      body: SizedBox(
        width: double.maxFinite,
        child: Padding(
          padding: context.padSymmetricPx(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              context.spaceHPx(50),
              Image.asset(
                'assets/transfer/success.png',
                height: context.hPx(120),
                width: context.wPx(120),
              ),
              context.spaceHPx(25),
              boldBigText('Payment Successful!'),
              context.spaceHPx(4),
              mediumGreyText('Your payment has been processed'),
              context.spaceHPx(25),
              PaymentRecipt(
                amount: amount,
                serviceFee: 00.00,
                totalAmount: amount,
                reciverName: reciver.name,
                dateAndTime: DateTime.now(),
                paymentMethod: 'FlowPay',
                transactionID: transactionId,
              ),
              context.spaceHPx(25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ActivityButton(
                    imagePath: 'assets/transfer/share_with.png',
                    buttonColor: Color(0xffDFE5FF),
                    buttonName: 'Share recipt',
                    textColor: Color(0xff000000),
                    onTap: () {
                      context.read<ReceiptCubit>().shareReceipt(
                        receiverName: reciver.name,
                        amount: amount,
                        transactionId: transactionId,
                      );
                    },
                  ),
                  context.spaceWPx(20),
                  ActivityButton(
                    imagePath: 'assets/transfer/download.png',
                    buttonColor: Color(0xff007AFF),
                    buttonName: 'Download',
                    textColor: Color(0xffFFFFFF),
                    onTap: () async {
                      await context.read<ReceiptCubit>().downloadReceipt(
                        receiverName: reciver.name,
                        amount: amount,
                        transactionId: transactionId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
