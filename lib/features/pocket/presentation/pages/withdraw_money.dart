import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowpay/features/account/domain/entities/account.dart';
import 'package:flowpay/features/pocket/presentation/components/packet_appbar.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_bottom_sheet.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
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
  final withdrawAmountController = TextEditingController();
  Account? userAccount;
  bool isLoadingAccount = true;

  @override
  void initState() {
    super.initState();
    _loadUserAccount();
  }

  Future<void> _loadUserAccount() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('accounts')
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();

      userAccount = Account(
        accountId: snapshot.docs.first.id,
        userId: data['userId'],
        balance: (data['balance'] as num).toDouble(),
        phone: data['phone'],
      );
    }

    setState(() {
      isLoadingAccount = false;
    });
  }

  Future<void> handleWithdraw() async {
    final enteredAmount = double.tryParse(withdrawAmountController.text) ?? 0;

    if (enteredAmount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a valid amount")));
      return;
    }

    if (enteredAmount > widget.goal.savedAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Insufficient pocket balance")),
      );
      return;
    }

    if (userAccount == null) return;

    await context.read<GoalCubit>().withdrawFromPocket(
      goal: widget.goal,
      accountId: userAccount!.accountId!,
      amount: enteredAmount,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final remainingBalance = widget.goal.savedAmount;

    return Scaffold(
      appBar: pocketAppBar(
        context,
        'Withdraw',
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => ManagePocketBottomSheet(goal: widget.goal),
            );
          },
          child: const Icon(Icons.more_vert_outlined),
        ),
      ),
      body: Padding(
        padding: context.padSymmetricPx(horizontal: 25),
        child: SafeArea(
          child:
              isLoadingAccount
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        context.spaceHPx(20),

                        /// Pocket Icon
                        Container(
                          height: context.hPx(42),
                          width: context.wPx(42),
                          padding: context.padAllPx(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xff007AFF),
                          ),
                          child: Center(
                            child: Image.asset(
                              widget.pocketImage,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        context.spaceHPx(10),
                        Text(
                          widget.goal.goalName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Available: Rs ${remainingBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffA3A3A3),
                          ),
                        ),
                        context.spaceHPx(15),
                        TextFormField(
                          controller: withdrawAmountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 42.41,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            prefixText: 'RS  ',
                            prefixStyle: TextStyle(
                              fontSize: 31.8,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffA3A3A3),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffDADADA)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffDADADA),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        context.spaceHPx(20),

                        /// From Account
                        const Text(
                          'From Account',
                          style: TextStyle(fontSize: 16),
                        ),
                        context.spaceHPx(10),
                        Container(
                          height: context.hPx(74),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xffFAFAFA),
                          ),
                          child: ListTile(
                            leading: Image.asset('assets/pocket/bank.png'),
                            title: const Text(
                              'Main Savings Account',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'Balance: Rs ${userAccount?.balance.toStringAsFixed(0) ?? 0}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xffA3A3A3),
                              ),
                            ),
                            trailing: Image.asset(
                              'assets/pocket/downarrow.png',
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: handleWithdraw,
                          child: Container(
                            height: context.hPx(56),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xff007AFF),
                            ),
                            child: const Center(
                              child: Text(
                                'Withdraw to Bank',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xffFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                        context.spaceHPx(20),
                      ],
                    ),
                  ),
        ),
      ),
      backgroundColor: const Color(0xffFFFFFF),
    );
  }
}

// import 'package:flowpay/features/pocket/presentation/components/packet_appbar.dart';
// import 'package:flowpay/helpers/ui_responsive_helper.dart';
// import 'package:flutter/material.dart';

// import '../components/pocket_bottom_sheet.dart';

// class WithdrawMoney extends StatelessWidget {
//   WithdrawMoney({super.key});

//   final withdrawAmountcontroller = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: pocketAppBar(
//         context,
//         'Withdraw',
//         InkWell(
//           onTap: () {
//             showModalBottomSheet(
//               context: context,
//               backgroundColor: Colors.transparent,
//               isScrollControlled: true,
//               builder:
//                   (context) => ManagePocketBottomSheet(
//                     pocketImage: 'assets/pocket/travel.png',
//                     pocketName: 'pocketName',
//                     targetAmount: 0.0,
//                   ),
//             );
//           },
//           child: Icon(Icons.more_vert_outlined),
//         ),
//       ),
//       body: Padding(
//         padding: context.padSymmetricPx(horizontal: 25),
//         child: SafeArea(
//           child: SizedBox(
//             width: double.maxFinite,
//             child: Column(
//               children: [
//                 Container(
//                   height: context.hPx(42),
//                   width: context.wPx(42),
//                   padding: context.padAllPx(8),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: Color(0xff007AFF),
//                   ),
//                   child: Center(
//                     child: Image.asset(
//                       'assets/pocket/money.png',
//                       color: Color(0xffFFFFFF),
//                     ),
//                   ),
//                 ),
//                 context.spaceHPx(10),
//                 Text(
//                   'Saving For Trip',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                 ),

//                 Text(
//                   'Avliable: Rs 9,539',
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xffA3A3A3),
//                   ),
//                 ),
//                 context.spaceHPx(15),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     SizedBox(
//                       width: 140, // controls cursor area width
//                       child: TextFormField(
//                         controller: withdrawAmountcontroller,
//                         keyboardType: TextInputType.number,
//                         textAlign: TextAlign.left,
//                         style: TextStyle(
//                           fontSize: 31.8,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                         decoration: InputDecoration(
//                           prefixText: 'Rs  ',
//                           prefixStyle: TextStyle(
//                             fontSize: 21.2,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xffA3A3A3),
//                           ),
//                           isDense: true,
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.zero,
//                           // enabledBorder: UnderlineInputBorder(
//                           //   borderSide: BorderSide(
//                           //     color: Color(0xffDADADA),
//                           //     width: 1,
//                           //   ),
//                           // ),
//                           // focusedBorder: UnderlineInputBorder(
//                           //   borderSide: BorderSide(
//                           //     color: Color(0xffDADADA),
//                           //     width: 1.5,
//                           //   ),
//                           // ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   margin: EdgeInsets.only(top: 6),
//                   width: double.maxFinite,
//                   height: 1,
//                   color: Color(0xffDADADA),
//                 ),
//                 context.spaceHPx(10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Remaining balance: ',
//                       style: TextStyle(fontSize: 14, color: Color(0xff737373)),
//                     ),
//                     Text(
//                       'Rs 6,539 ',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Color(0xff737373),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 context.spaceHPx(15),
//                 Row(
//                   children: [
//                     Text('To Account', style: TextStyle(fontSize: 16)),
//                   ],
//                 ),
//                 context.spaceHPx(15),
//                 Container(
//                   height: context.hPx(74),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: Color(0xffFAFAFA),
//                   ),
//                   child: ListTile(
//                     leading: Image.asset('assets/pocket/bank.png'),
//                     title: Text(
//                       'Main Savings Account',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     subtitle: Row(
//                       children: [
//                         Text(
//                           '****4017',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Color(0xff353535),
//                           ),
//                         ),
//                         context.spaceWPx(12),
//                         Text(
//                           'Balance: Rs 45,200',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Color(0xffA3A3A3),
//                           ),
//                         ),
//                       ],
//                     ),
//                     trailing: Image.asset(
//                       'assets/pocket/downarrow.png',
//                       height: context.hPx(24),
//                       width: context.wPx(24),
//                     ),
//                   ),
//                 ),
//                 Spacer(),
//                 InkWell(
//                   onTap: () {},
//                   child: Container(
//                     height: context.hPx(56),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       color: Color(0xff007AFF),
//                     ),
//                     child: Center(
//                       child: Text(
//                         'Withdraw to Bank',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xffFFFFFF),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       backgroundColor: Color(0xffFFFFFF),
//     );
//   }
// }
