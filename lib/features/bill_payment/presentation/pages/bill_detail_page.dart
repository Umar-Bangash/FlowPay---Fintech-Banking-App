import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/bill_payment/presentation/components/bill_pages_appbar.dart';
import 'package:flowpay/features/bill_payment/presentation/pages/bill_summary_page.dart';
import 'package:flowpay/features/bill_payment/presentation/cubit/bill_cubit.dart';
import 'package:flowpay/features/bill_payment/presentation/cubit/bill_states.dart';
import 'package:flowpay/helpers/text_styles.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BillDetailPage extends StatelessWidget {
  BillDetailPage({
    super.key,
    required this.providerName,
    required this.category,
  });

  final String providerName;
  final String category;

  final numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return BlocListener<BillCubit, BillState>(
      listener: (context, state) {
        if (state is BillLoaded) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BillSummaryPage(bill: state.bill),
            ),
          );
        }

        if (state is BillError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: billAppBar(context, 'Enter Bill Details'),
        body: Padding(
          padding: context.padSymmetricPx(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              context.spaceHPx(40),

              boldBigText('Pay Your Bill'),

              context.spaceHPx(6),

              Text(
                'Enter your Consumer ID or Account Number as\nmentioned on your physical bill to proceed with the\npayment.',
                style: TextStyle(fontSize: 14, color: Color(0xff64748B)),
              ),

              context.spaceHPx(25),

              Text(
                'CONSUMER ID / ACCOUNT NUMBER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff64748B),
                ),
              ),

              context.spaceHPx(10),

              TextFormField(
                controller: numberController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xffF8FAFC),
                  hintText: 'e.g. 20074356256900',
                  hintStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xffCBD5E1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Color(0xffF1F5F9)),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 8,
                      right: 18,
                    ),
                    child: Image.asset(
                      'assets/bill/qr_scan.png',
                      height: context.hPx(32),
                      width: context.wPx(24.02),
                    ),
                  ),
                ),
              ),

              context.spaceHPx(12),

              /// SCAN BILL CARD
              DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: const Color(0xffE2E8F0),
                  strokeWidth: 1.5,
                  dashPattern: const [6, 3],
                  radius: const Radius.circular(16),
                ),
                child: Container(
                  height: context.hPx(82),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: ListTile(
                      dense: true,
                      minVerticalPadding: 0,
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        height: context.hPx(48),
                        width: context.wPx(48),
                        decoration: BoxDecoration(
                          color: const Color(0xffDBEAFE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: context.padAllPx(10),
                        child: Image.asset('assets/bill/bill.png'),
                      ),
                      title: const Text(
                        'Scan physical bill',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Quickly capture ID from barcode',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff64748B),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xffCBD5E1),
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ),

              context.spaceHPx(16),

              /// TIP BOX
              Container(
                height: context.hPx(73),
                decoration: BoxDecoration(
                  color: Color(0xffFFFBEB),
                  border: Border.all(color: Color(0xffFEF3C7)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: context.padAllPx(10),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/bill/tipicon.png',
                        height: context.hPx(24),
                        width: context.wPx(24),
                      ),
                      context.spaceWPx(10),
                      Text(
                        'You can find the Consumer ID at the top right\ncorner of your electricity, water, or gas bill.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff92400E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              context.spaceHPx(20),

              /// FETCH BILL BUTTON
              InkWell(
                onTap: () {
                  context.read<BillCubit>().fetchBill(
                    userId: userId,
                    providerName: providerName,
                    consumerId: numberController.text,
                    category: category,
                  );
                },
                child: Container(
                  height: context.hPx(60),
                  decoration: BoxDecoration(
                    color: Color(0xff007AFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Fetch Bill',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffFFFFFF),
                          ),
                        ),
                        context.spaceWPx(10),
                        Icon(
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
        backgroundColor: Color(0xffFFFFFF),
      ),
    );
  }
}

// import 'package:dotted_border/dotted_border.dart';
// import 'package:flowpay/features/bill_payment/presentation/components/bill_pages_appbar.dart';
// import 'package:flowpay/features/bill_payment/presentation/pages/bill_summary_page.dart';
// import 'package:flowpay/helpers/text_styles.dart';
// import 'package:flowpay/helpers/ui_responsive_helper.dart';
// import 'package:flutter/material.dart';

// class BillDetailPage extends StatelessWidget {
//   BillDetailPage({super.key});

//   final numberController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: billAppBar(context, 'Enter Bill Details'),
//       body: Padding(
//         padding: context.padSymmetricPx(horizontal: 25),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             context.spaceHPx(40),
//             boldBigText('Pay Your Bill'),
//             context.spaceHPx(6),
//             Text(
//               'Enter your Consumer ID or Account Number as\nmentioned on your physical bill to proceed with the\npayment.',
//               style: TextStyle(fontSize: 14, color: Color(0xff64748B)),
//             ),
//             context.spaceHPx(25),
//             Text(
//               'CONSUMER ID / ACCOUNT NUMBER',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xff64748B),
//               ),
//             ),
//             context.spaceHPx(10),
//             TextFormField(
//               controller: numberController,
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Color(0xffF8FAFC),
//                 hintText: 'e.g. 20074356256900',
//                 hintStyle: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                   color: Color(0xffCBD5E1),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide(color: Color(0xffF1F5F9)),
//                 ),
//                 suffixIcon: Padding(
//                   padding: const EdgeInsets.only(
//                     top: 8.0,
//                     bottom: 8,
//                     right: 18,
//                   ),
//                   child: Image.asset(
//                     'assets/bill/qr_scan.png',
//                     height: context.hPx(32),
//                     width: context.wPx(24.02),
//                   ),
//                 ),
//               ),
//             ),
//             context.spaceHPx(12),
//             DottedBorder(
//               options: RoundedRectDottedBorderOptions(
//                 color: const Color(0xffE2E8F0),
//                 strokeWidth: 1.5,
//                 dashPattern: const [6, 3],
//                 radius: const Radius.circular(16),
//               ),
//               child: Container(
//                 height: context.hPx(82),
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Center(
//                   child: ListTile(
//                     dense: true,
//                     minVerticalPadding: 0,
//                     contentPadding: EdgeInsets.zero,
//                     leading: Container(
//                       height: context.hPx(48),
//                       width: context.wPx(48),
//                       decoration: BoxDecoration(
//                         color: const Color(0xffDBEAFE),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       padding: context.padAllPx(10),
//                       child: Image.asset('assets/bill/bill.png'),
//                     ),
//                     title: const Text(
//                       'Scan physical bill',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     subtitle: const Text(
//                       'Quickly capture ID from barcode',
//                       style: TextStyle(fontSize: 12, color: Color(0xff64748B)),
//                     ),
//                     trailing: const Icon(
//                       Icons.arrow_forward_ios,
//                       color: Color(0xffCBD5E1),
//                       size: 12,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             context.spaceHPx(16),
//             Container(
//               height: context.hPx(73),
//               decoration: BoxDecoration(
//                 color: Color(0xffFFFBEB),
//                 border: Border.all(color: Color(0xffFEF3C7)),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Padding(
//                 padding: context.padAllPx(10),
//                 child: Row(
//                   children: [
//                     Image.asset(
//                       'assets/bill/tipicon.png',
//                       height: context.hPx(24),
//                       width: context.wPx(24),
//                     ),
//                     context.spaceWPx(10),
//                     Text(
//                       'You can find the Consumer ID at the top right\ncorner of your electricity, water, or gas bill.',
//                       style: TextStyle(fontSize: 12, color: Color(0xff92400E)),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             context.spaceHPx(20),
//             InkWell(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => BillSummaryPage()),
//                 );
//               },
//               child: Container(
//                 height: context.hPx(60),
//                 decoration: BoxDecoration(
//                   color: Color(0xff007AFF),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Center(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Fetch Bill',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xffFFFFFF),
//                         ),
//                       ),
//                       context.spaceWPx(10),
//                       Icon(
//                         Icons.arrow_forward,
//                         color: Color(0xffFFFFFF),
//                         size: 20,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: Color(0xffFFFFFF),
//     );
//   }
// }
