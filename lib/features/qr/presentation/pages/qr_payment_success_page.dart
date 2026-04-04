import 'package:flowpay/features/transaction/presentation/components/payment_recipt.dart';
import 'package:flowpay/helpers/text_styles.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

import '../../../transaction/presentation/components/activity_button.dart';

class QRPaymentSuccessPage extends StatelessWidget {
  const QRPaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, size: 20),
        ),
        centerTitle: true,
        title: Text(
          'QR Scan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          Image.asset(
            'assets/home/notification.png',
            height: context.hPx(24),
            width: context.wPx(24),
          ),
          context.spaceWPx(20),
        ],
        backgroundColor: Color(0xffFFFFFF),
      ),
      body: SizedBox(
        width: double.maxFinite,
        child: Padding(
          padding: context.padSymmetricPx(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              context.spaceHPx(25),
              Image.asset(
                'assets/transfer/success.png',
                height: context.hPx(120),
                width: context.wPx(120),
              ),
              context.spaceHPx(20),
              boldBigText('Payment Successful'),
              Text(
                'Your payment has been processed',
                style: TextStyle(fontSize: 16, color: Color(0xff737373)),
              ),
              context.spaceHPx(20),
              Container(
                height: context.hPx(132),
                width: context.wPx(342),
                padding: context.padAllPx(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xffE5E5E5)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Amount Paid',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    context.spaceHPx(5),
                    Text(
                      'PKR, 250000',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff21496A),
                      ),
                    ),
                  ],
                ),
              ),
              context.spaceHPx(25),
              Container(
                height: context.hPx(224),
                width: context.wPx(342),
                padding: context.padAllPx(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xffE5E5E5)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: context.hPx(74),
                      width: context.wPx(294),
                      padding: context.padAllPx(16),
                      decoration: BoxDecoration(
                        color: Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: context.hPx(42),
                            width: context.wPx(42),
                            padding: context.padAllPx(8),
                            decoration: BoxDecoration(
                              color: Color(0xff21496A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset('assets/transfer/bucket.png'),
                          ),
                          context.spaceWPx(10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SuperMart Groceries',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'ID: MERCHANT-002',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff737373),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    context.spaceHPx(16),
                    resuableRow('Transacction ID', 'TXN9986485331'),
                    context.spaceHPx(12),
                    resuableRow('Date & Time', 'Oct 9, 2025 at 12:08 PM'),
                    context.spaceHPx(12),
                    resuableRow('Payment Method', 'QR Code Scan'),
                  ],
                ),
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
                    onTap: () {},
                  ),
                  context.spaceWPx(20),
                  ActivityButton(
                    imagePath: 'assets/transfer/download.png',
                    buttonColor: Color(0xff007AFF),
                    buttonName: 'Download',
                    textColor: Color(0xffFFFFFF),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xffFFFFFF),
    );
  }
}
