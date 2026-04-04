import 'package:flowpay/features/pocket/domain/entities/goal.dart';
import 'package:flowpay/features/pocket/presentation/cubit/goal_cubit.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PocketDialog extends StatelessWidget {
  final Goal goal;
  const PocketDialog({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GoalCubit>();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: context.padSymmetricPx(horizontal: 25, vertical: 8),
        child: SizedBox(
          height: context.hPx(210),
          width: context.wPx(362),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 24),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Are you sure to Delete this\npocket?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              context.spaceHPx(12),
              Text(
                'Rs. ${goal.savedAmount.toStringAsFixed(0)} will be transferred back to your\nmain account. This action cannot be undone.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xff6A7282),
                  fontWeight: FontWeight.w400,
                ),
              ),
              context.spaceHPx(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cancel Button
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: dialogButton(
                      context,
                      const Color(0xffFFFFFF),
                      const Color(0xffD1D5DC),
                      'Cancel',
                      const Color(0xff000000),
                    ),
                  ),
                  context.spaceWPx(6),
                  // Delete Button
                  InkWell(
                    onTap: () async {
                      try {
                        final accountSnap =
                            await FirebaseFirestore.instance
                                .collection('accounts')
                                .where('userId', isEqualTo: goal.userId)
                                .limit(1)
                                .get();

                        if (accountSnap.docs.isEmpty) {
                          throw Exception("Main account not found");
                        }

                        final accountDoc = accountSnap.docs.first;
                        final currentBalance =
                            (accountDoc['balance'] as num).toDouble();
                        final refundAmount = goal.savedAmount;

                        // Batch update: delete goal + refund account
                        final batch = FirebaseFirestore.instance.batch();
                        batch.update(accountDoc.reference, {
                          'balance': currentBalance + refundAmount,
                        });
                        batch.delete(
                          FirebaseFirestore.instance
                              .collection('goals')
                              .doc(goal.goalId),
                        );

                        await batch.commit();

                        // Refresh state
                        await cubit.fetchGoals(goal.userId);

                        Navigator.pop(context); // Close dialog
                      } catch (e) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                    child: dialogButton(
                      context,
                      const Color(0xffE7000B),
                      const Color(0xffE7000B),
                      'Delete',
                      const Color(0xffFFFFFF),
                    ),
                  ),
                ],
              ),
              context.spaceHPx(8),
            ],
          ),
        ),
      ),
    );
  }

  Widget dialogButton(
    BuildContext context,
    Color btnColor,
    Color btnBorderColor,
    String buttonName,
    Color textColor,
  ) {
    return Container(
      height: context.hPx(48),
      width: context.wPx(152),
      decoration: BoxDecoration(
        color: btnColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: btnBorderColor),
      ),
      child: Center(
        child: Text(
          buttonName,
          style: TextStyle(fontSize: 16, color: textColor),
        ),
      ),
    );
  }
}

// import 'package:flowpay/helpers/ui_responsive_helper.dart';
// import 'package:flutter/material.dart';

// class PocketDialog extends StatelessWidget {
//   final double saveAmount;
//   const PocketDialog({super.key, required this.saveAmount});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       child: Padding(
//         padding: context.padSymmetricPx(horizontal: 25, vertical: 8),
//         child: SizedBox(
//           height: context.hPx(210),
//           width: context.wPx(362),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: const Icon(Icons.close, size: 24),
//                 ),
//               ),
//               Text(
//                 'Are you sure to Delete this\npocket?',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//               ),
//               context.spaceHPx(12),
//               Text(
//                 'Rs. ${saveAmount.toStringAsFixed(00)} will be transferred back to your\nmain account. This action cannot be undone.',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Color(0xff6A7282),
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//               context.spaceHPx(16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: dialogButton(
//                       context,
//                       Color(0xffFFFFFF),
//                       Color(0xffD1D5DC),
//                       'Cancel',
//                       Color(0xff000000),
//                     ),
//                   ),
//                   context.spaceWPx(6),
//                   InkWell(
//                     onTap: () {},
//                     child: dialogButton(
//                       context,
//                       Color(0xffE7000B),
//                       Color(0xffE7000B),
//                       'Delete',
//                       Color(0xffFFFFFF),
//                     ),
//                   ),
//                 ],
//               ),
//               context.spaceHPx(10),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget dialogButton(
//     BuildContext context,
//     Color btnColor,
//     Color btnBorderColor,
//     String buttonName,
//     Color textColor,
//   ) {
//     return Container(
//       height: context.hPx(48),
//       width: context.wPx(152),
//       decoration: BoxDecoration(
//         color: btnColor,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: btnBorderColor),
//       ),
//       child: Center(
//         child: Text(
//           buttonName,
//           style: TextStyle(fontSize: 16, color: textColor),
//         ),
//       ),
//     );
//   }
// }
