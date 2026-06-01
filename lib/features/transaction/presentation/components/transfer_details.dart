import 'package:flutter/material.dart';
import '../../../../helpers/ui_responsive_helper.dart';

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
    AppResponsive.init(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.w(20),
        vertical: AppResponsive.h(14),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
        color: const Color(0xffF9FAFB),
      ),
      child: Column(
        children: [
          _DtlRow('Amount sent', amountSent),
          _divider(),
          _DtlRow('Fee (including tax)', feeTax),
          _divider(),
          _DtlRow('Date', date),
          _divider(),
          _DtlRow('Transaction ID', transactionId, mono: true),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
    padding: EdgeInsets.symmetric(vertical: AppResponsive.h(6)),
    child: const Divider(height: 1, color: Color.fromARGB(255, 222, 221, 221)),
  );
}

class _DtlRow extends StatelessWidget {
  final String label, value;
  final bool mono;
  const _DtlRow(this.label, this.value, {this.mono = false});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: AppResponsive.fs(12),
          color: const Color(0xff6A7282),
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
            color: const Color(0xff101828),
            fontFamily: mono ? 'monospace' : null,
          ),
        ),
      ),
    ],
  );
}

// Keep top-level for back-compat
Widget reusableDtlRow(String n, String v) => _DtlRow(n, v);
