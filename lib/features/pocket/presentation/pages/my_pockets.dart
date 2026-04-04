import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/pocket/domain/entities/goal.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_display_card.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_icon.dart';
import 'package:flowpay/features/pocket/presentation/cubit/goal_cubit.dart';
import 'package:flowpay/features/pocket/presentation/pages/pocket_display_page.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/goal_states.dart';

class MyPockets extends StatefulWidget {
  const MyPockets({super.key});

  @override
  State<MyPockets> createState() => _MyPocketsState();
}

class _MyPocketsState extends State<MyPockets> {
  double calculatePercentage(double saved, double target) {
    if (target == 0) return 0;
    return ((saved / target) * 100).clamp(0, 100);
  }

  double calculateRemaining(double saved, double target) {
    final remaining = target - saved;
    return remaining < 0 ? 0 : remaining;
  }

  double calculateTotalSaved(List<Goal> goals) {
    return goals.fold(0, (sum, g) => sum + g.savedAmount);
  }

  @override
  void initState() {
    super.initState();
    // Fetch goals for current user
    Future.microtask(() async {
      await context.read<GoalCubit>().fetchGoals(
        FirebaseAuth.instance.currentUser!.uid,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(
        title: const Text('My Pockets'),
        backgroundColor: Color(0xffFFFFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Pockets',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              Text(
                'Organize your money your way.',
                style: TextStyle(fontSize: 13),
              ),
              context.spaceHPx(16),
              BlocBuilder<GoalCubit, GoalState>(
                builder: (context, state) {
                  List<Goal> goals = [];
                  if (state is GoalLoaded) {
                    // Map dynamic list to Goal objects
                    goals = state.goals.map((e) => e).toList();
                  }

                  final totalSaved = calculateTotalSaved(goals);
                  final activePockets = goals.length;

                  return Stack(
                    children: [
                      Container(
                        padding: context.padSymmetricPx(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        height: context.hPx(144),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: const Color(0xff21496A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Total Saved',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                Image.asset(
                                  'assets/home/eye.png',
                                  height: context.hPx(16),
                                  width: context.wPx(20),
                                ),
                                context.spaceWPx(24),
                              ],
                            ),
                            context.spaceHPx(16),
                            Text(
                              'Rs ${totalSaved.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 31,
                                color: Colors.white,
                              ),
                            ),
                            context.spaceHPx(12),
                            Text(
                              '$activePockets active pocket${activePockets != 1 ? "s" : ""}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: Image.asset(
                          'assets/home/sidecircle.png',
                          height: context.hPx(81),
                        ),
                      ),
                    ],
                  );
                },
              ),
              context.spaceHPx(16),
              BlocBuilder<GoalCubit, GoalState>(
                builder: (context, state) {
                  List<Goal> goals = [];
                  if (state is GoalLoaded) {
                    goals = state.goals.map((e) => e).toList();
                  }

                  if (goals.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('No pockets found. Create one!'),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final eachGoal = goals[index];
                      final icon = pocketIconsList.firstWhere(
                        (element) => element.id == eachGoal.categoryId,
                        orElse: () => pocketIconsList[0],
                      );

                      final percentage = calculatePercentage(
                        eachGoal.savedAmount,
                        eachGoal.targetAmount,
                      );

                      final remainingAmount = calculateRemaining(
                        eachGoal.savedAmount,
                        eachGoal.targetAmount,
                      );

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PocketDisplayPage(goal: eachGoal),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: PocketDisplayCard(
                            pocketImage: icon.imagePath,
                            pocketName: eachGoal.goalName,
                            saveAmount: eachGoal.savedAmount,
                            targetAmount: eachGoal.targetAmount,
                            percentage: percentage,
                            remainAmount: remainingAmount,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flowpay/features/pocket/presentation/pages/pocket_display_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../../helpers/ui_responsive_helper.dart';
// import '../../domain/entities/goal.dart';
// import '../components/pocket_display_card.dart';
// import '../components/pocket_icon.dart';
// import '../cubit/goal_cubit.dart';
// import '../cubit/goal_states.dart';

// class MyPockets extends StatefulWidget {
//   const MyPockets({super.key});

//   @override
//   State<MyPockets> createState() => _MyPocketsState();
// }

// class _MyPocketsState extends State<MyPockets> {
//   late List<Goal> goals;

//   double calculatePercentage(double saved, double target) {
//     if (target == 0) return 0;
//     return ((saved / target) * 100).clamp(0, 100);
//   }

//   double calculateRemaining(double saved, double target) {
//     final remaining = target - saved;
//     return remaining < 0 ? 0 : remaining;
//   }

//   @override
//   void initState() {
//     super.initState();
//     goals = [];
//     Future.microtask(() async {
//       await context.read<GoalCubit>().fetchGoals(
//         FirebaseAuth.instance.currentUser!.uid,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //backgroundColor: Color(0xffFFFFFF),
//       appBar: AppBar(
//         title: const Text('My Pockets'),
//         //backgroundColor: Color(0xffFFFFFF),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 28.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Your Pockets',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
//               ),

//               Text(
//                 'Organize your money your way.',
//                 style: TextStyle(fontSize: 13),
//               ),
//               context.spaceHPx(16),
//               Stack(
//                 children: [
//                   Container(
//                     padding: context.padSymmetricPx(
//                       horizontal: 20,
//                       vertical: 14,
//                     ),
//                     height: context.hPx(144),
//                     width: double.maxFinite,
//                     decoration: BoxDecoration(
//                       color: Color(0xff21496A),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Text(
//                               'Total Saved',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Color(0xffFFFFFF),
//                               ),
//                             ),
//                             Spacer(),
//                             Image.asset(
//                               'assets/home/eye.png',
//                               height: context.hPx(16),
//                               width: context.wPx(20),
//                             ),
//                             context.spaceWPx(24),
//                           ],
//                         ),
//                         context.spaceHPx(16),
//                         Text(
//                           'Rs 9,539.45',
//                           style: TextStyle(
//                             fontSize: 31,
//                             color: Color(0xffFFFFFF),
//                           ),
//                         ),
//                         context.spaceHPx(12),
//                         Text(
//                           '0 active pockets',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Color(0xffFFFFFF),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Positioned(
//                     right: 0,
//                     child: Image.asset(
//                       'assets/home/sidecircle.png',
//                       height: context.hPx(81),
//                     ),
//                   ),
//                 ],
//               ),

//               context.spaceHPx(16),
//               BlocBuilder<GoalCubit, GoalState>(
//                 builder: (context, state) {
//                   final goals = state is GoalLoaded ? state.goals : [];
//                   debugPrint("goal length is ${goals.length}");
//                   return ListView.builder(
//                     physics: NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: goals.length,
//                     itemBuilder: (context, index) {
//                       final eachGoal = goals[index];
//                       final icon = pocketIconsList.firstWhere(
//                         (element) => element.id == eachGoal.categoryId,
//                       );

//                       final percentage = calculatePercentage(
//                         eachGoal.savedAmount,
//                         eachGoal.targetAmount,
//                       );

//                       final remainingAmount = calculateRemaining(
//                         eachGoal.savedAmount,
//                         eachGoal.targetAmount,
//                       );

//                       return InkWell(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder:
//                                   (_) => PocketDisplayPage(
//                                     pocketImage: icon.imagePath,
//                                     pocketName: eachGoal.goalName,
//                                     targetAmount: eachGoal.targetAmount,
//                                   ),
//                             ),
//                           );
//                         },
//                         child: PocketDisplayCard(
//                           pocketImage: icon.imagePath,
//                           pocketName: eachGoal.goalName,
//                           saveAmount: eachGoal.savedAmount,
//                           targetAmount: eachGoal.targetAmount,
//                           percentage: percentage,
//                           remainAmount: remainingAmount,
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
