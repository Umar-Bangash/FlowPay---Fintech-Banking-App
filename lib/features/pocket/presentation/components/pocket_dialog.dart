import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/pocket/domain/entities/goal.dart';
import 'package:flowpay/features/pocket/presentation/cubit/goal_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class PocketDialog extends StatelessWidget {
  final Goal goal;
  const PocketDialog({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final cubit = context.read<GoalCubit>();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
      ),
      // insetPadding ensures dialog never touches screen edges
      insetPadding: EdgeInsets.symmetric(
        horizontal: AppResponsive.w(24),
        vertical: AppResponsive.h(40),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppResponsive.w(20),
          vertical: AppResponsive.h(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, size: AppResponsive.sp(22)),
              ),
            ),

            SizedBox(height: AppResponsive.h(6)),

            Text(
              'Are you sure to Delete this pocket?',
              style: TextStyle(
                fontSize: AppResponsive.fs(17),
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: AppResponsive.h(10)),

            Text(
              'Rs. ${goal.savedAmount.toStringAsFixed(0)} will be transferred back '
              'to your main account. This action cannot be undone.',
              style: TextStyle(
                fontSize: AppResponsive.fs(13),
                color: const Color(0xff6A7282),
              ),
            ),

            SizedBox(height: AppResponsive.h(18)),

            // Buttons — Expanded so they ALWAYS fit any screen width
            Row(
              children: [
                Expanded(
                  child: _DialogBtn(
                    label: 'Cancel',
                    bgColor: Colors.white,
                    borderColor: const Color(0xffD1D5DC),
                    textColor: Colors.black,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: AppResponsive.w(8)),
                Expanded(
                  child: _DialogBtn(
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
                          throw Exception('Main account not found');
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

            SizedBox(height: AppResponsive.h(4)),
          ],
        ),
      ),
    );
  }
}

class _DialogBtn extends StatelessWidget {
  final String label;
  final Color bgColor, borderColor, textColor;
  final VoidCallback onTap;
  const _DialogBtn({
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
      width: double.infinity, // fills Expanded
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppResponsive.fs(14),
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}
