import 'package:flowpay/features/pocket/domain/entities/goal.dart';
import 'package:flowpay/features/pocket/presentation/cubit/goal_cubit.dart';
import 'package:flowpay/features/pocket/presentation/pages/pocket_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../helpers/ui_responsive_helper.dart';

class ManagePocketBottomSheet extends StatelessWidget {
  final Goal goal;
  const ManagePocketBottomSheet({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    // FIX 1: Get the bottom safe-area (home indicator on iOS)
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // FIX 1: Add bottom padding so content clears the iOS home indicator
      padding: EdgeInsets.only(
        left: AppResponsive.w(20),
        right: AppResponsive.w(20),
        top: AppResponsive.h(16),
        bottom: AppResponsive.h(16) + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: AppResponsive.w(36),
            height: AppResponsive.h(4),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          SizedBox(height: AppResponsive.h(18)),

          // Edit option
          _SheetOption(
            icon: Icons.edit_outlined,
            label: 'Edit Pocket',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PocketEditPage(goal: goal)),
              );
            },
          ),

          Divider(height: AppResponsive.h(16), color: const Color(0xffF0F0F0)),

          // Delete option
          _SheetOption(
            icon: Icons.delete_outline,
            label: 'Delete Pocket',
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierColor: Colors.black54,
                builder: (_) => _DeleteConfirmDialog(goal: goal),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SheetOption({
    required this.icon,
    required this.label,
    this.color = Colors.black,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: AppResponsive.h(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppResponsive.sp(20)),
          SizedBox(width: AppResponsive.w(12)),
          Text(
            label,
            style: TextStyle(
              fontSize: AppResponsive.fs(14),
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

class _DeleteConfirmDialog extends StatelessWidget {
  final Goal goal;
  const _DeleteConfirmDialog({required this.goal});

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final cubit = context.read<GoalCubit>();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: AppResponsive.w(24),
        vertical: AppResponsive.h(40),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppResponsive.w(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, size: AppResponsive.sp(20)),
              ),
            ),
            SizedBox(height: AppResponsive.h(6)),
            Text(
              'Delete this pocket?',
              style: TextStyle(
                fontSize: AppResponsive.fs(16),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppResponsive.h(8)),
            Text(
              'Rs. ${goal.savedAmount.toStringAsFixed(0)} will be transferred '
              'back to your main account. This cannot be undone.',
              style: TextStyle(
                fontSize: AppResponsive.fs(13),
                color: const Color(0xff6A7282),
              ),
            ),
            SizedBox(height: AppResponsive.h(18)),
            Row(
              children: [
                Expanded(
                  child: _Btn(
                    label: 'Cancel',
                    bgColor: Colors.white,
                    borderColor: const Color(0xffD1D5DC),
                    textColor: Colors.black,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: AppResponsive.w(8)),
                Expanded(
                  child: _Btn(
                    label: 'Delete',
                    bgColor: const Color(0xffE7000B),
                    borderColor: const Color(0xffE7000B),
                    textColor: Colors.white,
                    onTap: () async {
                      try {
                        final snap =
                            await FirebaseFirestore.instance
                                .collection('accounts')
                                .where('userId', isEqualTo: goal.userId)
                                .limit(1)
                                .get();
                        if (snap.docs.isEmpty) {
                          throw Exception('Account not found');
                        }
                        final doc = snap.docs.first;
                        final balance = (doc['balance'] as num).toDouble();
                        final batch = FirebaseFirestore.instance.batch();
                        batch.update(doc.reference, {
                          'balance': balance + goal.savedAmount,
                        });
                        batch.delete(
                          FirebaseFirestore.instance
                              .collection('goals')
                              .doc(goal.goalId),
                        );
                        await batch.commit();
                        await cubit.fetchGoals(goal.userId);
                        Navigator.pop(context);
                      } catch (e) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final Color bgColor, borderColor, textColor;
  final VoidCallback onTap;
  const _Btn({
    required this.label,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
    child: Container(
      height: AppResponsive.h(46),
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppResponsive.fs(13),
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}
