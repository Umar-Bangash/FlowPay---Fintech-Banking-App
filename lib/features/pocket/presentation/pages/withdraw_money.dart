import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowpay/features/account/domain/entities/account.dart';
import 'package:flowpay/features/pocket/presentation/components/packet_appbar.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_bottom_sheet.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../../domain/entities/goal.dart';
import '../cubit/goal_cubit.dart';

class WithdrawMoney extends StatefulWidget {
  final Goal goal;
  final String pocketImage;
  const WithdrawMoney({
    super.key,
    required this.goal,
    required this.pocketImage,
  });

  @override
  State<WithdrawMoney> createState() => _WithdrawMoneyState();
}

class _WithdrawMoneyState extends State<WithdrawMoney> {
  final _amountCtrl = TextEditingController();
  Account? _account;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAccount() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap =
        await FirebaseFirestore.instance
            .collection('accounts')
            .where('userId', isEqualTo: uid)
            .limit(1)
            .get();
    if (snap.docs.isNotEmpty) {
      final d = snap.docs.first.data();
      _account = Account(
        accountId: snap.docs.first.id,
        userId: d['userId'],
        balance: (d['balance'] as num).toDouble(),
        phone: d['phone'],
      );
    }
    setState(() => _loading = false);
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

  Future<void> _withdraw() async {
    final amt = double.tryParse(_amountCtrl.text) ?? 0;
    if (amt <= 0) {
      _showSnackBar('Please enter a valid amount.');
      return;
    }
    if (amt > widget.goal.savedAmount) {
      _showSnackBar(
        'You only have Rs.${widget.goal.savedAmount.toStringAsFixed(0)} '
        'saved in this pocket.',
      );
      return;
    }
    if (_account == null) return;

    await context.read<GoalCubit>().withdrawFromPocket(
      goal: widget.goal,
      accountId: _account!.accountId!,
      amount: amt,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final largeFontSize = AppResponsive.fs(36, max: 44);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: pocketAppBar(
        context,
        'Withdraw',
        InkWell(
          onTap:
              () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => ManagePocketBottomSheet(goal: widget.goal),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: AppResponsive.h(24)),

                          // Pocket icon
                          AppAnimatedItem(
                            index: 0,
                            direction: SlideDirection.bottom,
                            child: AppScaleIn(
                              child: Container(
                                height: AppResponsive.sp(56),
                                width: AppResponsive.sp(56),
                                padding: EdgeInsets.all(AppResponsive.sp(12)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppResponsive.radiusMd,
                                  ),
                                  color: const Color(0xff007AFF),
                                ),
                                child: Image.asset(
                                  widget.pocketImage,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(10)),

                          AppAnimatedItem(
                            index: 1,
                            direction: SlideDirection.bottom,
                            child: Text(
                              widget.goal.goalName,
                              style: TextStyle(
                                fontSize: AppResponsive.fs(15),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(4)),

                          AppAnimatedItem(
                            index: 1,
                            direction: SlideDirection.bottom,
                            child: Text(
                              'Available: Rs ${widget.goal.savedAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(12),
                                color: const Color(0xffA3A3A3),
                              ),
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(32)),

                          // fully outside InputDecoration — always visible.
                          AppAnimatedItem(
                            index: 2,
                            direction: SlideDirection.right,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Rs',
                                  style: TextStyle(
                                    fontSize: largeFontSize * 0.6,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xffA3A3A3),
                                  ),
                                ),
                                SizedBox(width: AppResponsive.w(8)),
                                // Input takes remaining space
                                Expanded(
                                  child: TextField(
                                    controller: _amountCtrl,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: largeFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                        fontSize: largeFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xffDADADA),
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                        bottom: AppResponsive.h(6),
                                      ),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xffDADADA),
                                        ),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xff007AFF),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(24)),

                          AppAnimatedItem(
                            index: 3,
                            direction: SlideDirection.left,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'To Account',
                                style: TextStyle(
                                  fontSize: AppResponsive.fs(15),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: AppResponsive.h(10)),

                          // Account tile
                          AppAnimatedItem(
                            index: 4,
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

                          // Withdraw button
                          AppAnimatedItem(
                            index: 5,
                            direction: SlideDirection.bottom,
                            child: InkWell(
                              onTap: _withdraw,
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
                                    'Withdraw to Account',
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
