import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowpay/features/account/domain/entities/account.dart';
import 'package:flowpay/features/pocket/presentation/components/packet_appbar.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_bottom_sheet.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_display_card.dart';
import 'package:flowpay/features/pocket/presentation/components/amount_button.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../../domain/entities/goal.dart';
import '../components/pocket_icon.dart';
import '../cubit/goal_cubit.dart';
import '../cubit/addamount_to_pocket_cubit.dart';

class AddMoneyToPocket extends StatefulWidget {
  final Goal goal;
  const AddMoneyToPocket({super.key, required this.goal});

  @override
  State<AddMoneyToPocket> createState() => _AddMoneyToPocketState();
}

class _AddMoneyToPocketState extends State<AddMoneyToPocket> {
  late TextEditingController _amountCtrl;
  Account? _account;
  bool _loading = true;

  late double _liveSavedAmount;
  late double _liveTargetAmount;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
    _liveSavedAmount = widget.goal.savedAmount;
    _liveTargetAmount = widget.goal.targetAmount;
    context.read<PocketAmountCubit>().setAmount(0);
    _loadData();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Fetch account + freshest goal data in parallel
    final results = await Future.wait([
      FirebaseFirestore.instance
          .collection('accounts')
          .where('userId', isEqualTo: uid)
          .limit(1)
          .get(),
      FirebaseFirestore.instance
          .collection('goals')
          .doc(widget.goal.goalId)
          .get(),
    ]);

    final acctSnap = results[0] as QuerySnapshot;
    final goalSnap = results[1] as DocumentSnapshot;

    if (acctSnap.docs.isNotEmpty) {
      final d = acctSnap.docs.first.data() as Map<String, dynamic>;
      _account = Account(
        accountId: acctSnap.docs.first.id,
        userId: d['userId'],
        balance: (d['balance'] as num).toDouble(),
        phone: d['phone'],
      );
    }

    if (goalSnap.exists) {
      final gd = goalSnap.data() as Map<String, dynamic>;
      _liveSavedAmount = (gd['savedAmount'] as num).toDouble();
      _liveTargetAmount = (gd['targetAmount'] as num).toDouble();
    }

    setState(() => _loading = false);
  }

  double _pct(double s, double t) => t == 0 ? 0 : ((s / t) * 100).clamp(0, 100);

  double _rem(double s, double t) => (t - s).clamp(0, double.infinity);

  Future<void> _confirmDeposit() async {
    final amt = double.tryParse(_amountCtrl.text) ?? 0;
    if (amt <= 0 || _account == null) return;

    final remaining = (_liveTargetAmount - _liveSavedAmount).clamp(
      0.0,
      double.infinity,
    );

    if (remaining == 0) {
      _showSnackBar('This pocket is already complete!');
      return;
    }

    if (amt > remaining) {
      _showSnackBar(
        'You are only Rs.${remaining.toStringAsFixed(0)} away from your '
        'target. You cannot add more than the remaining amount.',
      );
      return;
    }

    await context.read<GoalCubit>().addMoneyToPocket(
      goal: widget.goal,
      accountId: _account!.accountId!,
      amount: amt,
    );
    if (mounted) Navigator.pop(context);
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xff1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final goal = widget.goal;
    final icon = pocketIconsList.firstWhere(
      (e) => e.id == goal.categoryId,
      orElse: () => pocketIconsList[0],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: pocketAppBar(
        context,
        'Add Money',
        InkWell(
          onTap:
              () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => ManagePocketBottomSheet(goal: goal),
              ),
          child: const Icon(Icons.more_vert_outlined),
        ),
      ),
      body: AppAnimatedPage(
        direction: SlideDirection.bottom,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
          child: SafeArea(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppResponsive.h(18)),

                          // Pocket card — shows live amounts from Firestore
                          AppAnimatedItem(
                            index: 0,
                            direction: SlideDirection.bottom,
                            child: PocketDisplayCard(
                              pocketImage: icon.imagePath,
                              pocketName: goal.goalName,
                              saveAmount: _liveSavedAmount,
                              targetAmount: _liveTargetAmount,
                              percentage: _pct(
                                _liveSavedAmount,
                                _liveTargetAmount,
                              ),
                              remainAmount: _rem(
                                _liveSavedAmount,
                                _liveTargetAmount,
                              ),
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(14)),

                          AppAnimatedItem(
                            index: 1,
                            direction: SlideDirection.left,
                            child: Text(
                              'Enter Amount',
                              style: TextStyle(fontSize: AppResponsive.fs(15)),
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(8)),

                          AppAnimatedItem(
                            index: 2,
                            direction: SlideDirection.right,
                            child: BlocListener<PocketAmountCubit, int>(
                              listener:
                                  (_, amt) =>
                                      _amountCtrl.text =
                                          amt == 0 ? '' : amt.toString(),
                              child: _RsInputRow(
                                controller: _amountCtrl,
                                fontSize: AppResponsive.fs(22),
                                onChanged:
                                    (v) => context
                                        .read<PocketAmountCubit>()
                                        .setAmount(int.tryParse(v) ?? 0),
                              ),
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(14)),

                          // Quick amount buttons
                          AppAnimatedItem(
                            index: 3,
                            direction: SlideDirection.bottom,
                            child: Row(
                              children: [
                                Expanded(child: amountButton(500)),
                                SizedBox(width: AppResponsive.w(8)),
                                Expanded(child: amountButton(1000)),
                                SizedBox(width: AppResponsive.w(8)),
                                Expanded(child: amountButton(5000)),
                              ],
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(20)),

                          AppAnimatedItem(
                            index: 4,
                            direction: SlideDirection.left,
                            child: Text(
                              'From Account',
                              style: TextStyle(fontSize: AppResponsive.fs(15)),
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(12)),

                          // Account tile
                          AppAnimatedItem(
                            index: 5,
                            direction: SlideDirection.right,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppResponsive.radiusLg,
                                ),
                                color: const Color(0xffFAFAFA),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppResponsive.w(14),
                                  vertical: AppResponsive.h(4),
                                ),
                                leading: Image.asset(
                                  'assets/pocket/bank.png',
                                  height: AppResponsive.sp(32),
                                  width: AppResponsive.sp(32),
                                ),
                                title: Text(
                                  'Main Savings Account',
                                  style: TextStyle(
                                    fontSize: AppResponsive.fs(13),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  'Balance: Rs ${_account?.balance.toStringAsFixed(0) ?? 0}',
                                  style: TextStyle(
                                    fontSize: AppResponsive.fs(11),
                                    color: const Color(0xffA3A3A3),
                                  ),
                                ),
                                trailing: Image.asset(
                                  'assets/pocket/downarrow.png',
                                  height: AppResponsive.sp(20),
                                  width: AppResponsive.sp(20),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(28)),

                          // Confirm button
                          AppAnimatedItem(
                            index: 6,
                            direction: SlideDirection.bottom,
                            child: InkWell(
                              onTap: _confirmDeposit,
                              child: Container(
                                width: double.infinity,
                                height: AppResponsive.h(54),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppResponsive.radiusMd,
                                  ),
                                  color: const Color(0xff007AFF),
                                ),
                                child: Center(
                                  child: Text(
                                    'Confirm Deposit',
                                    style: TextStyle(
                                      fontSize: AppResponsive.fs(15),
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(24)),
                        ],
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}

class _RsInputRow extends StatelessWidget {
  final TextEditingController controller;
  final double fontSize;
  final ValueChanged<String>? onChanged;

  const _RsInputRow({
    required this.controller,
    required this.fontSize,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Always-visible "Rs" label — not inside TextField at all
        Text(
          'Rs',
          style: TextStyle(
            fontSize: fontSize * 0.7,
            fontWeight: FontWeight.bold,
            color: const Color(0xffA3A3A3),
          ),
        ),
        SizedBox(width: AppResponsive.w(8)),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffDADADA),
              ),
              isDense: true,
              contentPadding: EdgeInsets.only(bottom: AppResponsive.h(6)),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xffDADADA), width: 1),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xff007AFF), width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
