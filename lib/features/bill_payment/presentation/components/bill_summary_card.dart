import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class BillSummaryCard extends StatelessWidget {
  final String consumerName;
  final String consumerID;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime billingPeriod;
  const BillSummaryCard({
    super.key,
    required this.consumerName,
    required this.consumerID,
    required this.dueDate,
    this.isPaid = false,
    required this.billingPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.hPx(264),
      padding: context.padAllPx(20),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffF1F5F9)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONSUMER NAME',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff94A3B8),
                    ),
                  ),
                  context.spaceHPx(8),
                  Text(
                    consumerName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Spacer(),
              Column(
                children: [
                  Text(
                    'CONSUMER ID',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff94A3B8),
                    ),
                  ),
                  context.spaceHPx(8),
                  Text(
                    consumerID,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          context.spaceHPx(10),
          Divider(color: Color(0xffF1F5F9)),
          context.spaceHPx(10),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DUE DATE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff94A3B8),
                    ),
                  ),
                  context.spaceHPx(8),
                  Text(
                    dueDate.toIso8601String(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Spacer(),
              Container(
                height: context.hPx(24),
                width: context.wPx(70),
                decoration: BoxDecoration(
                  color:
                      isPaid
                          ? Color.fromARGB(255, 202, 251, 239)
                          : Color(0xffFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    isPaid ? 'PAID' : 'UNPAID',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isPaid ? Color(0xff10B981) : Color(0xffEF4444),
                    ),
                  ),
                ),
              ),
            ],
          ),
          context.spaceHPx(10),
          Divider(color: Color(0xffF1F5F9)),
          context.spaceHPx(10),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BILLING PERIOD',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff94A3B8),
                    ),
                  ),
                  context.spaceHPx(8),
                  Text(
                    billingPeriod.toIso8601String(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
