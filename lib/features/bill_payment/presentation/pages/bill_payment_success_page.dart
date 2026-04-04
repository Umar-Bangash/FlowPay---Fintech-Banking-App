import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowpay/features/bill_payment/presentation/components/bill_pages_appbar.dart';
import 'package:flowpay/features/bill_payment/presentation/cubit/bill_cubit.dart';
import 'package:flowpay/helpers/text_styles.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:intl/intl.dart';

import '../../../transaction/presentation/components/activity_button.dart';
import '../../../transaction/presentation/components/payment_recipt.dart';
import '../components/categories_icon.dart';
import '../cubit/bill_states.dart';

class BillPaymentSuccessPage extends StatelessWidget {
  const BillPaymentSuccessPage({super.key});

  /// Format: "Oct 9, 2025 at 12:08 PM"
  String _formatDateTime(DateTime dt) {
    return DateFormat("MMM d, yyyy 'at' h:mm a").format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: billAppBar(context, ''),
      backgroundColor: const Color(0xffFFFFFF),
      body: BlocBuilder<BillCubit, BillState>(
        builder: (context, state) {
          if (state is BillLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BillSuccess) {
            final bill = state.bill;

            return SizedBox(
              width: double.maxFinite,
              child: Padding(
                padding: context.padSymmetricPx(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    context.spaceHPx(25),

                    /// SUCCESS ICON
                    Image.asset(
                      'assets/transfer/success.png',
                      height: context.hPx(120),
                      width: context.wPx(120),
                    ),

                    context.spaceHPx(20),

                    boldBigText('Payment Successful!'),

                    const Text(
                      'Your bill has been paid successfully',
                      style: TextStyle(fontSize: 16, color: Color(0xff737373)),
                    ),

                    context.spaceHPx(20),

                    /// AMOUNT PAID CARD
                    Container(
                      height: context.hPx(132),
                      width: context.wPx(342),
                      padding: context.padAllPx(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffE5E5E5)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Amount Paid',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          context.spaceHPx(5),
                          Text(
                            'Rs ${bill.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff21496A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    context.spaceHPx(25),

                    /// TRANSACTION DETAILS CARD
                    Container(
                      width: context.wPx(342),
                      padding: context.padAllPx(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffE5E5E5)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// Bill Info Row
                          Container(
                            width: context.wPx(294),
                            padding: context.padAllPx(16),
                            decoration: BoxDecoration(
                              color: const Color(0xffFAFAFA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: context.hPx(42),
                                  width: context.wPx(42),
                                  padding: context.padAllPx(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffEFF6FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.asset(
                                    BillCategoryIcon.getIcon(bill.category),
                                  ),
                                ),
                                context.spaceWPx(14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${bill.providerName} ${bill.category}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'ID: ${bill.consumerId}',
                                      style: const TextStyle(
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

                          resuableRow('Transaction ID', bill.transactionId),
                          context.spaceHPx(12),

                          /// Properly formatted date
                          resuableRow(
                            'Date & Time',
                            _formatDateTime(bill.transactionDateTime),
                          ),
                          context.spaceHPx(12),

                          /// "Digital Wallet" matches design
                          resuableRow('Payment Method', 'Digital Wallet'),
                        ],
                      ),
                    ),

                    context.spaceHPx(25),

                    /// SHARE + DOWNLOAD BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ActivityButton(
                          imagePath: 'assets/transfer/share_with.png',
                          buttonColor: const Color(0xffDFE5FF),
                          buttonName: 'Share receipt',
                          textColor: const Color(0xff000000),
                          onTap: () {},
                        ),
                        context.spaceWPx(20),
                        ActivityButton(
                          imagePath: 'assets/transfer/download.png',
                          buttonColor: const Color(0xff007AFF),
                          buttonName: 'Download',
                          textColor: const Color(0xffFFFFFF),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is BillError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}

// import 'package:flowpay/features/bill_payment/presentation/components/bill_pages_appbar.dart';
// import 'package:flowpay/helpers/text_styles.dart';
// import 'package:flowpay/helpers/ui_responsive_helper.dart';
// import 'package:flutter/material.dart';
// import '../../../transaction/presentation/components/activity_button.dart';
// import '../../../transaction/presentation/components/payment_recipt.dart';

// class BillPaymentSuccessPage extends StatelessWidget {
//   const BillPaymentSuccessPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: billAppBar(context, ''),
//       body: SizedBox(
//         width: double.maxFinite,
//         child: Padding(
//           padding: context.padSymmetricPx(horizontal: 25),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               context.spaceHPx(25),
//               Image.asset(
//                 'assets/transfer/success.png',
//                 height: context.hPx(120),
//                 width: context.wPx(120),
//               ),
//               context.spaceHPx(20),
//               boldBigText('Payment Successful'),
//               Text(
//                 'Your bill has been paid successfully',
//                 style: TextStyle(fontSize: 16, color: Color(0xff737373)),
//               ),
//               context.spaceHPx(20),
//               Container(
//                 height: context.hPx(132),
//                 width: context.wPx(342),
//                 padding: context.padAllPx(24),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Color(0xffE5E5E5)),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Amount Paid',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     context.spaceHPx(5),
//                     Text(
//                       'RS 9,000',
//                       style: TextStyle(
//                         fontSize: 40,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xff21496A),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               context.spaceHPx(25),
//               Container(
//                 height: context.hPx(224),
//                 width: context.wPx(342),
//                 padding: context.padAllPx(24),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Color(0xffE5E5E5)),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       height: context.hPx(74),
//                       width: context.wPx(294),
//                       padding: context.padAllPx(16),
//                       decoration: BoxDecoration(
//                         color: Color(0xffFAFAFA),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             height: context.hPx(42),
//                             width: context.wPx(42),
//                             padding: context.padAllPx(8),
//                             decoration: BoxDecoration(
//                               color: Color(0xffEFF6FF),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Image.asset('assets/bill/electricity.png'),
//                           ),
//                           context.spaceWPx(14),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'K-Electric',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               Text(
//                                 'ID: 0326-9114017',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Color(0xff737373),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     context.spaceHPx(16),
//                     resuableRow('Transacction ID', 'TXN9986485331'),
//                     context.spaceHPx(12),
//                     resuableRow('Date & Time', 'Jan 10, 2026 at 12:08 PM'),
//                     context.spaceHPx(12),
//                     resuableRow('Payment Method', 'Digital Payment'),
//                   ],
//                 ),
//               ),
//               context.spaceHPx(25),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ActivityButton(
//                     imagePath: 'assets/transfer/share_with.png',
//                     buttonColor: Color(0xffDFE5FF),
//                     buttonName: 'Share recipt',
//                     textColor: Color(0xff000000),
//                     onTap: () {},
//                   ),
//                   context.spaceWPx(20),
//                   ActivityButton(
//                     imagePath: 'assets/transfer/download.png',
//                     buttonColor: Color(0xff007AFF),
//                     buttonName: 'Download',
//                     textColor: Color(0xffFFFFFF),
//                     onTap: () {},
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//       backgroundColor: Color(0xffFFFFFF),
//     );
//   }
// }
