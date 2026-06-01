import 'package:flowpay/features/bill_payment/presentation/components/bill_pages_appbar.dart';
import 'package:flowpay/features/bill_payment/presentation/pages/bill_payment_success_page.dart';
import 'package:flowpay/features/bill_payment/presentation/cubit/bill_cubit.dart';
import 'package:flowpay/features/bill_payment/presentation/cubit/bill_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../../domain/entity/bill.dart';

class BillSummaryPage extends StatelessWidget {
  const BillSummaryPage({super.key, required this.bill});
  final Bill bill;

  static const Map<String, String> _icons = {
    'Electricity': 'assets/bill/electricity.png',
    'Gas': 'assets/bill/gas.png',
    'Water': 'assets/bill/water.png',
    'Internet': 'assets/bill/wifi.png',
    'Education': 'assets/bill/education.png',
    'Telephone': 'assets/bill/telephone.png',
    'Insurance': 'assets/bill/insurance.png',
    'Government': 'assets/bill/government.png',
    'More': 'assets/bill/more.png',
  };

  DateTime get _dueDate => DateTime.now().add(const Duration(days: 30));
  String get _billingPeriod {
    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1);
    final fmt = DateFormat('MMM yyyy');
    return '${fmt.format(prev)} – ${fmt.format(now)}';
  }

  String get _formattedDue => DateFormat('d MMM, yyyy').format(_dueDate);

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return BlocListener<BillCubit, BillState>(
      listener: (context, state) {
        if (state is BillSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BillPaymentSuccessPage()),
          );
        }
        if (state is BillError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: billAppBar(context, 'Bill Summary'),
        body: AppAnimatedPage(
          direction: SlideDirection.bottom,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
            child: Column(
              children: [
                SizedBox(height: AppResponsive.h(32)),

                // ── Provider icon + name ──────────────────────────────────
                AppAnimatedItem(
                  index: 0,
                  direction: SlideDirection.bottom,
                  child: AppScaleIn(
                    child: Container(
                      height: AppResponsive.sp(72),
                      width: AppResponsive.sp(72),
                      decoration: BoxDecoration(
                        color: const Color(0xffDBEAFE),
                        borderRadius: BorderRadius.circular(
                          AppResponsive.radiusLg,
                        ),
                      ),
                      padding: EdgeInsets.all(AppResponsive.sp(13)),
                      child: Image.asset(
                        _icons[bill.category] ?? 'assets/bill/electricity.png',
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(10)),

                AppAnimatedItem(
                  index: 1,
                  direction: SlideDirection.bottom,
                  child: Text(
                    bill.providerName,
                    style: TextStyle(
                      fontSize: AppResponsive.fs(19),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                AppAnimatedItem(
                  index: 1,
                  direction: SlideDirection.bottom,
                  child: Text(
                    '${bill.category} Bill',
                    style: TextStyle(
                      fontSize: AppResponsive.fs(13),
                      color: const Color(0xff64748B),
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(22)),

                // ── Summary card ──────────────────────────────────────────
                AppAnimatedItem(
                  index: 2,
                  direction: SlideDirection.right,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppResponsive.w(16)),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffE2E8F0)),
                      borderRadius: BorderRadius.circular(
                        AppResponsive.radiusMd,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _SummaryCol(
                              label: 'CONSUMER NAME',
                              value: bill.consumerName,
                            ),
                            _SummaryCol(
                              label: 'CONSUMER ID',
                              value: bill.consumerId,
                              alignRight: true,
                            ),
                          ],
                        ),

                        SizedBox(height: AppResponsive.h(14)),
                        const Divider(color: Color(0xffF1F5F9), height: 1),
                        SizedBox(height: AppResponsive.h(14)),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _SummaryCol(
                              label: 'DUE DATE',
                              value: _formattedDue,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppResponsive.w(10),
                                vertical: AppResponsive.h(4),
                              ),
                              decoration: BoxDecoration(
                                color:
                                    bill.status == 'paid'
                                        ? const Color(0xffDCFCE7)
                                        : const Color(0xffFEE2E2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                bill.status == 'paid' ? 'PAID' : 'UNPAID',
                                style: TextStyle(
                                  fontSize: AppResponsive.fs(11),
                                  fontWeight: FontWeight.w700,
                                  color:
                                      bill.status == 'paid'
                                          ? const Color(0xff16A34A)
                                          : const Color(0xffDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: AppResponsive.h(14)),
                        const Divider(color: Color(0xffF1F5F9), height: 1),
                        SizedBox(height: AppResponsive.h(14)),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: _SummaryCol(
                            label: 'BILLING PERIOD',
                            value: _billingPeriod,
                          ),
                        ),

                        SizedBox(height: AppResponsive.h(14)),

                        // ── Amount card ───────────────────────────────────────────
                        AppAnimatedItem(
                          index: 3,
                          direction: SlideDirection.left,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: AppResponsive.h(20),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffEFF6FF),
                              borderRadius: BorderRadius.circular(
                                AppResponsive.radiusMd,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Amount Payable',
                                  style: TextStyle(
                                    fontSize: AppResponsive.fs(13),
                                    color: const Color(0xff64748B),
                                  ),
                                ),
                                SizedBox(height: AppResponsive.h(6)),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Rs ${bill.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: AppResponsive.fs(28, max: 34),
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xff007BFF),
                                    ),
                                  ),
                                ),
                                SizedBox(height: AppResponsive.h(6)),
                                Text(
                                  'Inclusive of all taxes & fees',
                                  style: TextStyle(
                                    fontSize: AppResponsive.fs(11),
                                    color: const Color(0xff94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: AppResponsive.h(22)),

                        // ── Pay now button ────────────────────────────────────────
                        AppAnimatedItem(
                          index: 4,
                          direction: SlideDirection.bottom,
                          child: InkWell(
                            onTap:
                                () => context.read<BillCubit>().payBill(bill),
                            borderRadius: BorderRadius.circular(
                              AppResponsive.radiusMd,
                            ),
                            child: Container(
                              width: double.infinity,
                              height: AppResponsive.h(56),
                              decoration: BoxDecoration(
                                color: const Color(0xff007AFF),
                                borderRadius: BorderRadius.circular(
                                  AppResponsive.radiusMd,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Pay Now',
                                    style: TextStyle(
                                      fontSize: AppResponsive.fs(15),
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: AppResponsive.w(8)),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: AppResponsive.sp(18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: AppResponsive.h(30)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable summary column
class _SummaryCol extends StatelessWidget {
  final String label, value;
  final bool alignRight;
  const _SummaryCol({
    required this.label,
    required this.value,
    this.alignRight = false,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment:
        alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: AppResponsive.fs(10),
          fontWeight: FontWeight.w500,
          color: const Color(0xff94A3B8),
        ),
      ),
      SizedBox(height: AppResponsive.h(3)),
      Text(
        value,
        style: TextStyle(
          fontSize: AppResponsive.fs(13),
          fontWeight: FontWeight.w600,
          color: const Color(0xff1E293B),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}
