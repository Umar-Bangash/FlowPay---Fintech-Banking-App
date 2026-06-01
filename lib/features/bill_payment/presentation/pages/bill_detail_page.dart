import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/bill_payment/presentation/components/bill_pages_appbar.dart';
import 'package:flowpay/features/bill_payment/presentation/pages/bill_summary_page.dart';
import 'package:flowpay/features/bill_payment/presentation/cubit/bill_cubit.dart';
import 'package:flowpay/features/bill_payment/presentation/cubit/bill_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class BillDetailPage extends StatelessWidget {
  BillDetailPage({
    super.key,
    required this.providerName,
    required this.category,
  });

  final String providerName;
  final String category;
  final _numCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
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
        backgroundColor: Colors.white,
        appBar: billAppBar(context, 'Enter Bill Details'),
        body: AppAnimatedPage(
          direction: SlideDirection.bottom,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppResponsive.h(36)),

                // ── Title ─────────────────────────────────────────────
                AppAnimatedItem(
                  index: 0,
                  direction: SlideDirection.left,
                  child: Text(
                    'Pay Your Bill',
                    style: TextStyle(
                      fontSize: AppResponsive.fs(22),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(6)),

                AppAnimatedItem(
                  index: 1,
                  direction: SlideDirection.right,
                  child: Text(
                    'Enter your Consumer ID or Account Number as\n'
                    'mentioned on your physical bill to proceed.',
                    style: TextStyle(
                      fontSize: AppResponsive.fs(13),
                      color: const Color(0xff64748B),
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(22)),

                // ── Label ─────────────────────────────────────────────
                AppAnimatedItem(
                  index: 2,
                  direction: SlideDirection.left,
                  child: Text(
                    'CONSUMER ID / ACCOUNT NUMBER',
                    style: TextStyle(
                      fontSize: AppResponsive.fs(11),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff64748B),
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(10)),

                // ── Input field ───────────────────────────────────────
                AppAnimatedItem(
                  index: 3,
                  direction: SlideDirection.right,
                  child: TextFormField(
                    controller: _numCtrl,
                    style: TextStyle(fontSize: AppResponsive.fs(15)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xffF8FAFC),
                      hintText: 'e.g. 20074356256900',
                      hintStyle: TextStyle(
                        fontSize: AppResponsive.fs(15),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xffCBD5E1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppResponsive.radiusMd,
                        ),
                        borderSide: const BorderSide(color: Color(0xffF1F5F9)),
                      ),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(
                          top: AppResponsive.h(8),
                          bottom: AppResponsive.h(8),
                          right: AppResponsive.w(16),
                        ),
                        child: Image.asset(
                          'assets/bill/qr_scan.png',
                          height: AppResponsive.h(28),
                          width: AppResponsive.w(22),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(12)),

                // ── Scan bill card ────────────────────────────────────
                AppAnimatedItem(
                  index: 4,
                  direction: SlideDirection.left,
                  child: DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      color: const Color(0xffE2E8F0),
                      strokeWidth: 1.5,
                      dashPattern: const [6, 3],
                      radius: const Radius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppResponsive.w(14),
                        vertical: AppResponsive.h(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: AppResponsive.sp(44),
                            width: AppResponsive.sp(44),
                            decoration: BoxDecoration(
                              color: const Color(0xffDBEAFE),
                              borderRadius: BorderRadius.circular(
                                AppResponsive.radiusSm,
                              ),
                            ),
                            padding: EdgeInsets.all(AppResponsive.sp(9)),
                            child: Image.asset('assets/bill/bill.png'),
                          ),
                          SizedBox(width: AppResponsive.w(12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Scan physical bill',
                                  style: TextStyle(
                                    fontSize: AppResponsive.fs(13),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Quickly capture ID from barcode',
                                  style: TextStyle(
                                    fontSize: AppResponsive.fs(11),
                                    color: const Color(0xff64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: const Color(0xffCBD5E1),
                            size: AppResponsive.sp(12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(14)),

                // ── Tip box ───────────────────────────────────────────
                AppAnimatedItem(
                  index: 5,
                  direction: SlideDirection.right,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffFFFBEB),
                      border: Border.all(color: const Color(0xffFEF3C7)),
                      borderRadius: BorderRadius.circular(
                        AppResponsive.radiusMd,
                      ),
                    ),
                    padding: EdgeInsets.all(AppResponsive.w(12)),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/bill/tipicon.png',
                          height: AppResponsive.sp(22),
                          width: AppResponsive.sp(22),
                        ),
                        SizedBox(width: AppResponsive.w(10)),
                        Expanded(
                          child: Text(
                            'You can find the Consumer ID at the top right\n'
                            'corner of your electricity, water, or gas bill.',
                            style: TextStyle(
                              fontSize: AppResponsive.fs(11),
                              color: const Color(0xff92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(20)),

                // ── Fetch bill button ─────────────────────────────────
                AppAnimatedItem(
                  index: 6,
                  direction: SlideDirection.bottom,
                  child: InkWell(
                    onTap:
                        () => context.read<BillCubit>().fetchBill(
                          userId: userId,
                          providerName: providerName,
                          consumerId: _numCtrl.text,
                          category: category,
                        ),
                    borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
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
                            'Fetch Bill',
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
      ),
    );
  }
}
