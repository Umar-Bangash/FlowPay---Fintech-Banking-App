import 'package:flowpay/features/bill_payment/presentation/components/bill_pages_appbar.dart';
import 'package:flowpay/features/bill_payment/presentation/pages/bill_payment_success_page.dart';
import 'package:flowpay/features/bill_payment/presentation/cubit/bill_cubit.dart';
import 'package:flowpay/features/bill_payment/presentation/cubit/bill_states.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/bill.dart';

class BillSummaryPage extends StatelessWidget {
  const BillSummaryPage({super.key, required this.bill});

  final Bill bill;

  static final Map<String, String> categoryIcons = {
    "Electricity": "assets/bill/electricity.png",
    "Gas": "assets/bill/gas.png",
    "Water": "assets/bill/water.png",
    "Internet": "assets/bill/wifi.png",
    "Education": "assets/bill/education.png",
    "Telephone": "assets/bill/telephone.png",
    "Insurance": "assets/bill/insurance.png",
    "Government": "assets/bill/government.png",
    "More": "assets/bill/more.png",
  };

  /// Due date is 30 days from now (simulated)
  DateTime get _dueDate => DateTime.now().add(const Duration(days: 30));

  /// Billing period: previous month → current month
  String get _billingPeriod {
    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1);
    final formatter = DateFormat('MMM yyyy');
    return "${formatter.format(prev)} – ${formatter.format(now)}";
  }

  String get _formattedDueDate => DateFormat('d MMM, yyyy').format(_dueDate);

  @override
  Widget build(BuildContext context) {
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
        appBar: billAppBar(context, 'Bill Summary'),
        backgroundColor: const Color(0xffFFFFFF),
        body: SizedBox(
          width: double.maxFinite,
          child: Padding(
            padding: context.padSymmetricPx(horizontal: 25),
            child: Column(
              children: [
                context.spaceHPx(40),

                /// PROVIDER ICON
                Container(
                  height: context.hPx(80),
                  width: context.wPx(80),
                  decoration: BoxDecoration(
                    color: const Color(0xffDBEAFE),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Image.asset(
                      categoryIcons[bill.category] ??
                          'assets/bill/electricity.png',
                    ),
                  ),
                ),

                context.spaceHPx(10),

                /// PROVIDER NAME
                Text(
                  bill.providerName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                /// CATEGORY
                Text(
                  '${bill.category} Bill',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff64748B),
                  ),
                ),

                context.spaceHPx(25),

                /// SUMMARY CARD
                Container(
                  width: double.maxFinite,
                  padding: context.padAllPx(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffE2E8F0)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      /// CONSUMER NAME + CONSUMER ID
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _summaryColumn(
                            label: 'CONSUMER NAME',
                            value: bill.consumerName,
                          ),
                          _summaryColumn(
                            label: 'CONSUMER ID',
                            value: bill.consumerId,
                            alignRight: true,
                          ),
                        ],
                      ),

                      context.spaceHPx(16),
                      const Divider(color: Color(0xffF1F5F9), height: 1),
                      context.spaceHPx(16),

                      /// DUE DATE + STATUS BADGE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _summaryColumn(
                            label: 'DUE DATE',
                            value: _formattedDueDate,
                          ),

                          /// UNPAID / PAID badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  bill.status == "paid"
                                      ? const Color(0xffDCFCE7)
                                      : const Color(0xffFEE2E2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              bill.status == "paid" ? "PAID" : "UNPAID",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color:
                                    bill.status == "paid"
                                        ? const Color(0xff16A34A)
                                        : const Color(0xffDC2626),
                              ),
                            ),
                          ),
                        ],
                      ),

                      context.spaceHPx(16),
                      const Divider(color: Color(0xffF1F5F9), height: 1),
                      context.spaceHPx(16),

                      /// BILLING PERIOD
                      Row(
                        children: [
                          _summaryColumn(
                            label: 'BILLING PERIOD',
                            value: _billingPeriod,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                context.spaceHPx(16),

                /// AMOUNT CARD
                Container(
                  height: context.hPx(134),
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: const Color(0xffEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Amount Payable',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff64748B),
                        ),
                      ),
                      context.spaceHPx(8),
                      Text(
                        'Rs ${bill.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff007BFF),
                        ),
                      ),
                      context.spaceHPx(8),
                      const Text(
                        'Inclusive of all taxes & fees',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                context.spaceHPx(25),

                /// PAY NOW BUTTON
                InkWell(
                  onTap: () => context.read<BillCubit>().payBill(bill),
                  child: Container(
                    height: context.hPx(60),
                    decoration: BoxDecoration(
                      color: const Color(0xff007AFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Pay Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffFFFFFF),
                            ),
                          ),
                          context.spaceWPx(10),
                          const Icon(
                            Icons.arrow_forward,
                            color: Color(0xffFFFFFF),
                            size: 20,
                          ),
                        ],
                      ),
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

  /// Reusable label + value column widget
  Widget _summaryColumn({
    required String label,
    required String value,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xff94A3B8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff1E293B),
          ),
        ),
      ],
    );
  }
}

// import 'package:flowpay/features/bill_payment/presentation/components/bill_pages_appbar.dart';
// import 'package:flowpay/features/bill_payment/presentation/components/bill_summary_card.dart';
// import 'package:flowpay/features/bill_payment/presentation/pages/bill_payment_success_page.dart';
// import 'package:flowpay/helpers/ui_responsive_helper.dart';
// import 'package:flutter/material.dart';

// class BillSummaryPage extends StatelessWidget {
//   const BillSummaryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: billAppBar(context, 'Bill Summary'),
//       body: SizedBox(
//         width: double.maxFinite,
//         child: Padding(
//           padding: context.padSymmetricPx(horizontal: 25),
//           child: Column(
//             children: [
//               context.spaceHPx(40),
//               Container(
//                 height: context.hPx(80),
//                 width: context.wPx(80),
//                 decoration: BoxDecoration(
//                   color: Color(0xffDBEAFE),
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(14.0),
//                   child: Image.asset('assets/bill/electricity.png'),
//                 ),
//               ),
//               context.spaceHPx(10),
//               Text(
//                 'K-Electric',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
//               ),
//               Text(
//                 'Electricity Bill',
//                 style: TextStyle(fontSize: 14, color: Color(0xff64748B)),
//               ),
//               context.spaceHPx(25),
//               BillSummaryCard(
//                 consumerName: 'Umar Bangash',
//                 consumerID: '0326-9114017',
//                 isPaid: false,
//                 dueDate: DateTime.now(),
//                 billingPeriod: DateTime(12, 12, 2026),
//               ),
//               context.spaceHPx(16),
//               Container(
//                 height: context.hPx(134),
//                 width: double.maxFinite,
//                 decoration: BoxDecoration(
//                   color: Color.fromARGB(255, 231, 241, 253),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Amount Payable',
//                       style: TextStyle(fontSize: 14, color: Color(0xff64748B)),
//                     ),
//                     context.spaceHPx(8),
//                     Text(
//                       'Rs 9,539.45',
//                       style: TextStyle(
//                         fontSize: 30,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xff007BFF),
//                       ),
//                     ),
//                     context.spaceHPx(8),
//                     Text(
//                       'Inclusive of all taxes & fees',
//                       style: TextStyle(fontSize: 12, color: Color(0xff94A38B)),
//                     ),
//                   ],
//                 ),
//               ),
//               context.spaceHPx(25),
//               InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => BillPaymentSuccessPage(),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   height: context.hPx(60),
//                   decoration: BoxDecoration(
//                     color: Color(0xff007AFF),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Center(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Pay Now',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xffFFFFFF),
//                           ),
//                         ),
//                         context.spaceWPx(10),
//                         Icon(
//                           Icons.arrow_forward,
//                           color: Color(0xffFFFFFF),
//                           size: 20,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       backgroundColor: Color(0xffFFFFFF),
//     );
//   }
// }
