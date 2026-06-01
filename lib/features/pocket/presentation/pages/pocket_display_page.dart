import 'package:flowpay/features/pocket/domain/entities/goal.dart';
import 'package:flowpay/features/pocket/presentation/components/packet_appbar.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_bottom_sheet.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_display_card.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_money_tile.dart';
import 'package:flowpay/features/pocket/presentation/pages/addmoney_to_pocket.dart';
import 'package:flowpay/features/pocket/presentation/pages/withdraw_money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
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
    AppResponsive.init(context);

    return BlocBuilder<GoalCubit, GoalState>(
      builder: (context, state) {
        if (state is GoalLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is GoalLoaded) {
          Goal? goal;
          try {
            goal = state.goals.firstWhere(
              (g) => g.goalId == widget.goal.goalId,
            );
          } catch (_) {
            goal = null;
          }

          if (goal == null) {
            return Scaffold(
              appBar: pocketAppBar(context, 'My Pocket', const SizedBox()),
              backgroundColor: Colors.white,
              body: Center(
                child: Text(
                  'Pocket deleted or not found',
                  style: TextStyle(
                    fontSize: AppResponsive.fs(15),
                    color: Colors.grey[600],
                  ),
                ),
              ),
            );
          }

          final icon = pocketIconsList.firstWhere(
            (e) => e.id == goal!.categoryId,
            orElse: () => pocketIconsList[0],
          );
          final pct =
              ((goal.savedAmount / goal.targetAmount) * 100)
                  .clamp(0, 100)
                  .toDouble();
          final rem =
              (goal.targetAmount - goal.savedAmount)
                  .clamp(0, double.infinity)
                  .toDouble();

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: pocketAppBar(
              context,
              'My Pocket',
              InkWell(
                onTap:
                    () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => ManagePocketBottomSheet(goal: goal!),
                    ),
                child: const Icon(Icons.more_vert_outlined),
              ),
            ),
            body: AppAnimatedPage(
              direction: SlideDirection.bottom,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(20)),
                child: Column(
                  children: [
                    SizedBox(height: AppResponsive.h(18)),

                    // ── Pocket card ────────────────────────────────────
                    AppAnimatedItem(
                      index: 0,
                      direction: SlideDirection.bottom,
                      child: PocketDisplayCard(
                        pocketImage: icon.imagePath,
                        pocketName: goal.goalName,
                        saveAmount: goal.savedAmount,
                        targetAmount: goal.targetAmount,
                        percentage: pct,
                        remainAmount: rem,
                      ),
                    ),

                    SizedBox(height: AppResponsive.h(16)),

                    // ── Add / Withdraw buttons — Expanded so NEVER overflow
                    AppAnimatedItem(
                      index: 1,
                      direction: SlideDirection.bottom,
                      child: Row(
                        children: [
                          Expanded(
                            child: _MoneyButton(
                              label: 'Add Money',
                              icon: 'assets/pocket/up.png',
                              bgColor: const Color(0xff007AFF),
                              textColor: Colors.white,
                              borderColor: const Color(0xff007AFF),
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => AddMoneyToPocket(goal: goal!),
                                    ),
                                  ),
                            ),
                          ),
                          SizedBox(width: AppResponsive.w(10)),
                          Expanded(
                            child: _MoneyButton(
                              label: 'Withdraw',
                              icon: 'assets/pocket/down.png',
                              bgColor: Colors.white,
                              textColor: const Color(0xff007AFF),
                              borderColor: const Color(0xff007AFF),
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => WithdrawMoney(
                                            goal: goal!,
                                            pocketImage: icon.imagePath,
                                          ),
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppResponsive.h(22)),

                    // ── Activity title ────────────────────────────────
                    AppAnimatedItem(
                      index: 2,
                      direction: SlideDirection.left,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Activity',
                          style: TextStyle(
                            fontSize: AppResponsive.fs(17),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppResponsive.h(10)),

                    // ── Transaction stream ────────────────────────────
                    Expanded(
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: context
                            .read<GoalCubit>()
                            .goalTransactionsStream(widget.goal.goalId),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final txns = snap.data!;
                          if (txns.isEmpty) {
                            return Center(
                              child: Text(
                                'No transactions yet',
                                style: TextStyle(
                                  fontSize: AppResponsive.fs(13),
                                  color: Colors.grey[500],
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: txns.length,
                            itemBuilder: (context, i) {
                              final txn = txns[i];
                              final txnId =
                                  (txn['transactionId'] ?? '').toString();
                              if (txnId.isEmpty) return const SizedBox.shrink();
                              final isAdd = txn['type'] == 'goal_saving';

                              return AppAnimatedItem(
                                index: i,
                                direction:
                                    i.isEven
                                        ? SlideDirection.left
                                        : SlideDirection.right,
                                child: Dismissible(
                                  key: Key(txnId),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.only(
                                      right: AppResponsive.w(20),
                                    ),
                                    color: Colors.red,
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: AppResponsive.sp(26),
                                    ),
                                  ),
                                  confirmDismiss:
                                      (_) async => await showDialog(
                                        context: context,
                                        builder:
                                            (_) => AlertDialog(
                                              title: Text(
                                                'Delete Transaction',
                                                style: TextStyle(
                                                  fontSize: AppResponsive.fs(
                                                    15,
                                                  ),
                                                ),
                                              ),
                                              content: Text(
                                                'Are you sure you want to delete this transaction?',
                                                style: TextStyle(
                                                  fontSize: AppResponsive.fs(
                                                    13,
                                                  ),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(true),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                      ),
                                  onDismissed:
                                      (_) => context
                                          .read<GoalCubit>()
                                          .deleteGoalTransaction(
                                            widget.goal.goalId,
                                            txnId,
                                          ),
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
          );
        }

        if (state is GoalError)
          return Scaffold(body: Center(child: Text(state.message)));
        return const SizedBox.shrink();
      },
    );
  }
}

// Reusable money button — width:double.infinity so Expanded controls it
class _MoneyButton extends StatelessWidget {
  final String label, icon;
  final Color bgColor, textColor, borderColor;
  final VoidCallback onTap;
  const _MoneyButton({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
    child: Container(
      width: double.infinity,
      height: AppResponsive.h(52),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppResponsive.fs(14),
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: AppResponsive.w(8)),
          Image.asset(
            icon,
            height: AppResponsive.sp(18),
            width: AppResponsive.sp(18),
          ),
        ],
      ),
    ),
  );
}
