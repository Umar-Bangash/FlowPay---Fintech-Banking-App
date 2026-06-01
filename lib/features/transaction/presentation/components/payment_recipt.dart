import 'package:flutter/material.dart';

import '../../../../helpers/ui_responsive_helper.dart';

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
    AppResponsive.init(context);
    return Column(
      children: [
        // Amounts card
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppResponsive.w(20),
            vertical: AppResponsive.h(16),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
            border: Border.all(color: const Color(0xffE5E5E5)),
          ),
          child: Column(
            children: [
              _Row('Amount', amount.toStringAsFixed(2)),
              _divider(),
              _Row('Service Fee (Incl. Tax)', serviceFee.toStringAsFixed(2)),
              _divider(),
              _Row('Total Amount', totalAmount.toStringAsFixed(2)),
            ],
          ),
        ),

        SizedBox(height: AppResponsive.h(16)),

        // Details card
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppResponsive.w(20),
            vertical: AppResponsive.h(16),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
            border: Border.all(color: const Color(0xffE5E5E5)),
          ),
          child: Column(
            children: [
              _Row('Recipient', reciverName),
              _divider(),
              _Row('Date & Time', _fmtDate(dateAndTime)),
              _divider(),
              _Row('Payment Method', paymentMethod),
              _divider(),
              _Row('Transaction ID', transactionID, mono: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() => Padding(
    padding: EdgeInsets.symmetric(vertical: AppResponsive.h(8)),
    child: const Divider(height: 1, color: Color(0xffF0F0F0)),
  );

  String _fmtDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool mono;
  const _Row(this.label, this.value, {this.mono = false});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: AppResponsive.fs(12),
          color: const Color(0xff737373),
        ),
      ),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            fontSize: AppResponsive.fs(12),
            fontWeight: FontWeight.w500,
            fontFamily: mono ? 'monospace' : null,
          ),
        ),
      ),
    ],
  );
}
