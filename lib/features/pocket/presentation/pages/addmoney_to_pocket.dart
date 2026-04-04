import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowpay/features/account/domain/entities/account.dart';
import 'package:flowpay/features/pocket/presentation/components/packet_appbar.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_bottom_sheet.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_display_card.dart';
import 'package:flowpay/features/pocket/presentation/components/amount_button.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
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
  late TextEditingController amountController;

  Account? userAccount;
  bool isLoadingAccount = true;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController();
    context.read<PocketAmountCubit>().setAmount(0);
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

  double calculatePercentage(double saved, double target) {
    if (target == 0) return 0;
    return ((saved / target) * 100).clamp(0, 100);
  }

  double calculateRemaining(double saved, double target) {
    final remaining = target - saved;
    return remaining < 0 ? 0 : remaining;
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;

    final icon = pocketIconsList.firstWhere(
      (element) => element.id == goal.categoryId,
      orElse: () => pocketIconsList[0],
    );

    final percentage = calculatePercentage(goal.savedAmount, goal.targetAmount);

    final remainingAmount = calculateRemaining(
      goal.savedAmount,
      goal.targetAmount,
    );

    return Scaffold(
      appBar: pocketAppBar(
        context,
        'Add Money',
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => ManagePocketBottomSheet(goal: goal),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        context.spaceHPx(20),

                        /// Pocket Display Card (UNCHANGED UI)
                        PocketDisplayCard(
                          pocketImage: icon.imagePath,
                          pocketName: goal.goalName,
                          saveAmount: goal.savedAmount,
                          targetAmount: goal.targetAmount,
                          percentage: percentage,
                          remainAmount: remainingAmount,
                        ),

                        context.spaceHPx(10),
                        const Text(
                          'Enter Amount',
                          style: TextStyle(fontSize: 16),
                        ),

                        /// Amount Input
                        BlocListener<PocketAmountCubit, int>(
                          listener: (context, amount) {
                            amountController.text = amount.toString();
                          },
                          child: TextFormField(
                            controller: amountController,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              prefixText: 'RS  ',
                              prefixStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffA3A3A3),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xffDADADA),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xffDADADA),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              context.read<PocketAmountCubit>().setAmount(
                                int.tryParse(value) ?? 0,
                              );
                            },
                          ),
                        ),

                        context.spaceHPx(15),
                        _amountButtons(),
                        context.spaceHPx(20),

                        const Text(
                          'From Account',
                          style: TextStyle(fontSize: 16),
                        ),
                        context.spaceHPx(20),

                        /// Account Card (UI KEPT SAME)
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
                            subtitle: Row(
                              children: [
                                const Text(
                                  '****4017',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xff353535),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Balance: Rs ${userAccount?.balance.toStringAsFixed(0) ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xffA3A3A3),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Image.asset(
                              'assets/pocket/downarrow.png',
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),

                        const Spacer(),

                        /// Confirm Button
                        InkWell(
                          onTap: () async {
                            final depositAmount =
                                double.tryParse(amountController.text) ?? 0;

                            if (depositAmount <= 0) return;
                            if (userAccount == null) return;

                            await context.read<GoalCubit>().addMoneyToPocket(
                              goal: goal,
                              accountId: userAccount!.accountId!,
                              amount: depositAmount,
                            );

                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            height: context.hPx(56),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xff007AFF),
                            ),
                            child: const Center(
                              child: Text(
                                'Confirm Deposit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xffFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
      backgroundColor: const Color(0xffFFFFFF),
    );
  }

  Widget _amountButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [amountButton(500), amountButton(1000), amountButton(5000)],
    );
  }
}

// import 'package:flowpay/features/pocket/presentation/components/packet_appbar.dart';
// import 'package:flowpay/features/pocket/presentation/cubit/addamount_to_pocket_cubit.dart';
// import 'package:flowpay/helpers/ui_responsive_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../components/amount_button.dart';
// import '../components/pocket_bottom_sheet.dart';
// import '../components/pocket_display_card.dart';

// class AddMoneyToPocket extends StatelessWidget {
//   AddMoneyToPocket({super.key});

//   final amountController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: pocketAppBar(
//         context,
//         'Add Money ',
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
//       body: SizedBox(
//         width: double.maxFinite,
//         child: Padding(
//           padding: context.padSymmetricPx(horizontal: 25),
//           child: SafeArea(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 context.spaceHPx(20),
//                 PocketDisplayCard(
//                   pocketImage: 'assets/pocket/travel.png',
//                   pocketName: 'pocketName',
//                   saveAmount: 0,
//                   targetAmount: 0.0,
//                   percentage: 000,
//                   remainAmount: 00000,
//                 ),
//                 context.spaceHPx(10),
//                 Text('Enter Amount', style: TextStyle(fontSize: 16)),
//                 BlocListener<PocketAmountCubit, int>(
//                   listener: (context, amount) {
//                     amountController.text = amount.toString();
//                   },
//                   child: TextFormField(
//                     controller: amountController,
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                     decoration: InputDecoration(
//                       prefixText: 'RS  ',
//                       prefixStyle: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xffA3A3A3),
//                       ),
//                       enabledBorder: UnderlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Color(0xffDADADA),
//                           width: 1,
//                         ),
//                       ),
//                       focusedBorder: UnderlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Color(0xffDADADA),
//                           width: 1.5,
//                         ),
//                       ),
//                     ),
//                     onChanged: (value) {
//                       context.read<PocketAmountCubit>().setAmount(
//                         int.tryParse(value) ?? 0,
//                       );
//                     },
//                   ),
//                 ),
//                 context.spaceHPx(15),
//                 _amountButtons(),
//                 context.spaceHPx(20),
//                 Text('From Account', style: TextStyle(fontSize: 16)),
//                 context.spaceHPx(20),
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
//                         'Confirm Deposit',
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

//   Widget _amountButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [amountButton(500), amountButton(1000), amountButton(5000)],
//     );
//   }
// }
