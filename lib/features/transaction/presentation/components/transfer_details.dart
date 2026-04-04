import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class TransferDetails extends StatelessWidget {
  final String amountSent;
  final String feeTax;
  final String date;
  final String transactionId;
  const TransferDetails({
    super.key,
    required this.amountSent,
    required this.feeTax,
    required this.date,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.padSymmetricPx(horizontal: 25),
      height: context.hPx(167.4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        color: Color(0xffF9FAFB),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          reusableDtlRow('Amount sent', amountSent),
          Divider(color: Color.fromARGB(255, 222, 221, 221)),
          reusableDtlRow('Fee (including tax)', feeTax),
          Divider(color: Color.fromARGB(255, 222, 221, 221)),
          reusableDtlRow('Date', date),
          Divider(color: Color.fromARGB(255, 222, 221, 221)),
          reusableDtlRow('Transaction ID', transactionId),
        ],
      ),
    );
  }
}

Widget reusableDtlRow(String detailName, String detailValue) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        detailName,
        style: TextStyle(fontSize: 13, color: Color(0xff6A7282)),
      ),
      Text(
        detailValue,
        style: TextStyle(fontSize: 13, color: Color(0xff101828)),
      ),
    ],
  );
}
