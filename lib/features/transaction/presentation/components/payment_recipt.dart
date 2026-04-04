import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class PaymentRecipt extends StatelessWidget {
  final double amount;
  final double serviceFee;
  final double totalAmount;
  final String reciverName;
  final DateTime dateAndTime;
  final String paymentMethod;
  final String transactionID;
  const PaymentRecipt({
    super.key,
    required this.amount,
    required this.serviceFee,
    required this.totalAmount,
    required this.reciverName,
    required this.dateAndTime,
    required this.paymentMethod,
    required this.transactionID,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: context.padSymmetricPx(horizontal: 25, vertical: 20),
          height: context.hPx(136),
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xffE5E5E5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              resuableRow('Amount', amount.toString()),
              resuableRow('Service Fee (Incl. Tax)', serviceFee.toString()),
              resuableRow('Total Amount', totalAmount.toString()),
            ],
          ),
        ),
        context.spaceHPx(24),
        Container(
          padding: context.padSymmetricPx(horizontal: 25, vertical: 20),
          height: context.hPx(170),
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xffE5E5E5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              resuableRow('Recipent', reciverName),
              resuableRow('Date & Time', dateAndTime.toIso8601String()),
              resuableRow('Payment Method', paymentMethod),
              resuableRow('Transaction ID', transactionID),
            ],
          ),
        ),
      ],
    );
  }
}

Widget resuableRow(String fieldName, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(fieldName, style: TextStyle(fontSize: 12, color: Color(0xff737373))),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    ],
  );
}
