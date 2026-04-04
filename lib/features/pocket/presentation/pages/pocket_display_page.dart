import 'package:flowpay/features/pocket/domain/entities/goal.dart';
import 'package:flowpay/features/pocket/presentation/components/packet_appbar.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_bottom_sheet.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_display_card.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_money_tile.dart';
import 'package:flowpay/features/pocket/presentation/pages/addmoney_to_pocket.dart';
import 'package:flowpay/features/pocket/presentation/pages/withdraw_money.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../components/pocket_icon.dart';
import '../cubit/goal_cubit.dart';
import '../cubit/goal_states.dart';

class PocketDisplayPage extends StatefulWidget {
  final Goal goal;

  const PocketDisplayPage({super.key, required this.goal});

  @override
  State<PocketDisplayPage> createState() => _PocketDisplayPageState();
}

class _PocketDisplayPageState extends State<PocketDisplayPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalCubit, GoalState>(
      builder: (context, state) {
        if (state is GoalLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is GoalLoaded) {
          /// Find updated goal from state
          Goal? goalData;
          try {
            goalData = state.goals.firstWhere(
              (g) => g.goalId == widget.goal.goalId,
            );
          } catch (_) {
            goalData = null;
          }

          /// If pocket deleted
          if (goalData == null) {
            return Scaffold(
              appBar: pocketAppBar(context, 'My Pocket', const SizedBox()),
              body: Center(
                child: Text(
                  'Pocket deleted or not found',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              backgroundColor: Colors.white,
            );
          }

          /// Get pocket icon
          final icon = pocketIconsList.firstWhere(
            (element) => element.id == goalData!.categoryId,
            orElse: () => pocketIconsList[0],
          );

          /// Calculate percentage
          final percentage = ((goalData.savedAmount / goalData.targetAmount) *
                  100)
              .clamp(0, 100);

          /// Calculate remaining
          final remainingAmount = (goalData.targetAmount - goalData.savedAmount)
              .clamp(0, double.infinity);

          /// Transactions
          // final transactions = state.transactions;

          return Scaffold(
            appBar: pocketAppBar(
              context,
              'My Pocket',
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => ManagePocketBottomSheet(goal: goalData!),
                  );
                },
                child: const Icon(Icons.more_vert_outlined),
              ),
            ),
            body: SizedBox(
              width: double.maxFinite,
              child: Padding(
                padding: context.padSymmetricPx(horizontal: 20),
                child: Column(
                  children: [
                    context.spaceHPx(20),

                    /// Pocket Card (UI SAME)
                    PocketDisplayCard(
                      pocketImage: icon.imagePath,
                      pocketName: goalData.goalName,
                      saveAmount: goalData.savedAmount,
                      targetAmount: goalData.targetAmount,
                      percentage: percentage.toDouble(),
                      remainAmount: remainingAmount.toDouble(),
                    ),

                    context.spaceHPx(16),

                    /// Add / Withdraw Buttons (UI SAME)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        moneyButton(
                          context,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => AddMoneyToPocket(goal: goalData!),
                              ),
                            );
                          },
                          'Add Money',
                          'assets/pocket/up.png',
                          const Color(0xff007AFF),
                          const Color(0xff007AFF),
                          const Color(0xffFFFFFF),
                        ),
                        context.spaceWPx(10),
                        moneyButton(
                          context,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => WithdrawMoney(
                                      goal: goalData!,
                                      pocketImage: icon.imagePath,
                                    ),
                              ),
                            );
                          },
                          'Withdraw',
                          'assets/pocket/down.png',
                          const Color(0xffFFFFFF),
                          const Color(0xff007AFF),
                          const Color(0xff007AFF),
                        ),
                      ],
                    ),

                    context.spaceHPx(24),

                    /// Activity Title
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Activity",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    context.spaceHPx(10),

                    /// Transactions List
                    Expanded(
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: context
                            .read<GoalCubit>()
                            .goalTransactionsStream(widget.goal.goalId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final transactions = snapshot.data!;
                          if (transactions.isEmpty) {
                            return Center(
                              child: Text(
                                "No transactions yet",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final txn = transactions[index];
                              final String txnId =
                                  (txn['transactionId'] ?? '').toString();
                              if (txnId.isEmpty) return const SizedBox();

                              final bool isAdd = txn['type'] == 'goal_saving';

                              return Dismissible(
                                key: Key(txnId),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  color: Colors.red,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: const Text(
                                            "Delete Transaction",
                                          ),
                                          content: const Text(
                                            "Are you sure you want to delete this transaction?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                              child: const Text("Delete"),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                                onDismissed: (direction) {
                                  context
                                      .read<GoalCubit>()
                                      .deleteGoalTransaction(
                                        widget.goal.goalId,
                                        txnId,
                                      );
                                },
                                child: PocketMoneyTile(
                                  iconContainerColor:
                                      isAdd
                                          ? const Color(0xffE7F0FF)
                                          : const Color(0xffFBE9E7),
                                  icon:
                                      isAdd
                                          ? 'assets/pocket/up.png'
                                          : 'assets/pocket/down.png',
                                  iconColor:
                                      isAdd
                                          ? const Color(0xff007AFF)
                                          : const Color(0xffD92D20),
                                  titleText:
                                      isAdd ? 'Add money' : 'Withdraw money',
                                  date: txn['dateTime'].toString().substring(
                                    0,
                                    10,
                                  ),
                                  amount: (txn['amount'] as num).toDouble(),
                                  textColor:
                                      isAdd
                                          ? const Color(0xff007AFF)
                                          : const Color(0xffD92D20),
                                  currenyColor:
                                      isAdd
                                          ? const Color(0xff007AFF)
                                          : const Color(0xffD92D20),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            backgroundColor: const Color(0xffFFFFFF),
          );
        }

        if (state is GoalError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }

        return const SizedBox();
      },
    );
  }

  /// Money Button (UNCHANGED)
  Widget moneyButton(
    BuildContext context,
    VoidCallback onTap,
    String buttonName,
    String buttonIcon,
    Color buttonColor,
    Color btnBorderColor,
    Color btnTextColor,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: context.padSymmetricPx(horizontal: 18),
        height: context.hPx(56),
        width: context.wPx(180),
        decoration: BoxDecoration(
          color: buttonColor,
          border: Border.all(color: btnBorderColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              buttonName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: btnTextColor,
              ),
            ),
            Image.asset(
              buttonIcon,
              height: context.hPx(24),
              width: context.wPx(24),
            ),
          ],
        ),
      ),
    );
  }
}

// class PocketDisplayPage extends StatelessWidget {
//   final String? pocketImage;
//   final String? pocketName;
//   final double? targetAmount;

//   const PocketDisplayPage({
//     super.key,
//     this.pocketImage,
//     this.pocketName,
//     this.targetAmount,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: pocketAppBar(
//         context,
//         'My Pocket',
//         InkWell(
//           onTap: () {
//             showModalBottomSheet(
//               context: context,
//               backgroundColor: Colors.transparent,
//               isScrollControlled: true,
//               builder:
//                   (context) => ManagePocketBottomSheet(
//                     pocketImage: pocketImage ?? "",
//                     pocketName: pocketName ?? "",
//                     targetAmount: targetAmount ?? 0,
//                   ),
//             );
//           },
//           child: const Icon(Icons.more_vert_outlined),
//         ),
//       ),
//       body: SizedBox(
//         width: double.maxFinite,
//         child: Padding(
//           padding: context.padSymmetricPx(horizontal: 10),
//           child: Column(
//             children: [
//               context.spaceHPx(20),
//               PocketDisplayCard(
//                 pocketImage: pocketImage ?? "",
//                 pocketName: pocketName ?? "",
//                 saveAmount: 0,
//                 targetAmount: targetAmount ?? 0,
//                 percentage: 0,
//                 remainAmount: 0,
//               ),
//               context.spaceHPx(16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   moneyButton(
//                     context,
//                     () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AddMoneyToPocket(goal: goal),
//                         ),
//                       );
//                     },
//                     'Add Money',
//                     'assets/pocket/up.png',
//                     const Color(0xff007AFF),
//                     const Color(0xff007AFF),
//                     const Color(0xffFFFFFF),
//                   ),
//                   context.spaceWPx(10),
//                   moneyButton(
//                     context,
//                     () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => WithdrawMoney(),
//                         ),
//                       );
//                     },
//                     'Withdraw',
//                     'assets/pocket/down.png',
//                     const Color(0xffFFFFFF),
//                     const Color(0xff007AFF),
//                     const Color(0xff007AFF),
//                   ),
//                 ],
//               ),
//               context.spaceHPx(10),
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: const Text(
//                   'Activity',
//                   style: TextStyle(fontSize: 16, color: Color(0xff101828)),
//                 ),
//               ),
//               context.spaceHPx(10),
//               InkWell(
//                 onTap: () {},
//                 child: PocketMoneyTile(
//                   iconContainerColor: const Color(0xffE8EDFF),
//                   icon: 'assets/pocket/up.png',
//                   iconColor: const Color(0xff007AFF),
//                   titleText: 'Add Money',
//                   date: '11/16/2025',
//                   amount: 1000,
//                   textColor: const Color(0xff007AFF),
//                   currenyColor: const Color(0xff007AFF),
//                 ),
//               ),
//               PocketMoneyTile(
//                 iconContainerColor: const Color(0xffFFEDD4),
//                 icon: 'assets/pocket/down.png',
//                 iconColor: const Color(0xffCA3500),
//                 titleText: 'Withdraw Money',
//                 date: '11/16/2025',
//                 amount: 500,
//                 textColor: const Color(0xffCA3500),
//                 currenyColor: const Color(0xffCA3500),
//               ),
//             ],
//           ),
//         ),
//       ),
//       backgroundColor: const Color(0xffFFFFFF),
//     );
//   }

//   Widget moneyButton(
//     BuildContext context,
//     VoidCallback onTap,
//     String buttonName,
//     String buttonIcon,
//     Color buttonColor,
//     Color btnBorderColor,
//     Color btnTextColor,
//   ) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: context.padSymmetricPx(horizontal: 18),
//         height: context.hPx(56),
//         width: context.wPx(180),
//         decoration: BoxDecoration(
//           color: buttonColor,
//           border: Border.all(color: btnBorderColor),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Text(
//               buttonName,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: btnTextColor,
//               ),
//             ),
//             Image.asset(
//               buttonIcon,
//               height: context.hPx(24),
//               width: context.wPx(24),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
