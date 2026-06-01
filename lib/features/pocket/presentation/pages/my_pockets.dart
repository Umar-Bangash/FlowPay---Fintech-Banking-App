import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/pocket/domain/entities/goal.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_display_card.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_icon.dart';
import 'package:flowpay/features/pocket/presentation/cubit/goal_cubit.dart';
import 'package:flowpay/features/pocket/presentation/pages/pocket_display_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../cubit/goal_states.dart';

class MyPockets extends StatefulWidget {
  const MyPockets({super.key});
  @override
  State<MyPockets> createState() => _MyPocketsState();
}

class _MyPocketsState extends State<MyPockets> {
  double _pct(double saved, double target) =>
      target == 0 ? 0 : ((saved / target) * 100).clamp(0, 100);

  double _rem(double saved, double target) {
    final r = target - saved;
    return r < 0 ? 0 : r;
  }

  double _totalSaved(List<Goal> goals) =>
      goals.fold(0, (s, g) => s + g.savedAmount);

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<GoalCubit>().fetchGoals(
        FirebaseAuth.instance.currentUser!.uid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Pockets',
          style: TextStyle(
            fontSize: AppResponsive.fs(16),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: AppAnimatedPage(
        direction: SlideDirection.bottom,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(24)),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppResponsive.h(8)),

                // ── Header text ───────────────────────────────────────
                AppAnimatedItem(
                  index: 0,
                  direction: SlideDirection.left,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Pockets',
                        style: TextStyle(
                          fontSize: AppResponsive.fs(22),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: AppResponsive.h(4)),
                      Text(
                        'Organize your money your way.',
                        style: TextStyle(
                          fontSize: AppResponsive.fs(13),
                          color: const Color(0xff737373),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppResponsive.h(14)),

                // ── Summary card ──────────────────────────────────────
                AppAnimatedItem(
                  index: 1,
                  direction: SlideDirection.right,
                  child: BlocBuilder<GoalCubit, GoalState>(
                    builder: (context, state) {
                      final goals =
                          state is GoalLoaded ? state.goals : <Goal>[];
                      final total = _totalSaved(goals);
                      final active = goals.length;

                      return LayoutBuilder(
                        builder: (context, c) {
                          return Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppResponsive.w(20),
                                  vertical: AppResponsive.h(16),
                                ),
                                width: c.maxWidth,
                                // Height driven by content, not hardcoded
                                decoration: BoxDecoration(
                                  color: const Color(0xff21496A),
                                  borderRadius: BorderRadius.circular(
                                    AppResponsive.radiusLg,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Total Saved',
                                          style: TextStyle(
                                            fontSize: AppResponsive.fs(15),
                                            color: Colors.white,
                                          ),
                                        ),
                                        const Spacer(),
                                        Image.asset(
                                          'assets/home/eye.png',
                                          height: AppResponsive.sp(16),
                                          width: AppResponsive.sp(20),
                                        ),
                                        SizedBox(width: AppResponsive.w(20)),
                                      ],
                                    ),
                                    SizedBox(height: AppResponsive.h(12)),
                                    Text(
                                      'Rs ${total.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: AppResponsive.fs(28, max: 34),
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: AppResponsive.h(8)),
                                    Text(
                                      '$active active pocket${active != 1 ? "s" : ""}',
                                      style: TextStyle(
                                        fontSize: AppResponsive.fs(13),
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Decorative circle — top-right
                              Positioned(
                                right: 0,
                                top: 0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(
                                      AppResponsive.radiusLg,
                                    ),
                                  ),
                                  child: Image.asset(
                                    'assets/home/sidecircle.png',
                                    height: AppResponsive.h(80),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),

                SizedBox(height: AppResponsive.h(16)),

                // ── Pockets list ──────────────────────────────────────
                BlocBuilder<GoalCubit, GoalState>(
                  builder: (context, state) {
                    if (state is GoalLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final goals = state is GoalLoaded ? state.goals : <Goal>[];

                    if (goals.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppResponsive.w(20)),
                          child: Text(
                            'No pockets found. Create one!',
                            style: TextStyle(
                              fontSize: AppResponsive.fs(14),
                              color: const Color(0xff737373),
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: goals.length,
                      itemBuilder: (context, i) {
                        final goal = goals[i];
                        final icon = pocketIconsList.firstWhere(
                          (e) => e.id == goal.categoryId,
                          orElse: () => pocketIconsList[0],
                        );

                        return AppAnimatedItem(
                          index: i + 2,
                          direction:
                              i.isEven
                                  ? SlideDirection.left
                                  : SlideDirection.right,
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: AppResponsive.h(12),
                            ),
                            child: InkWell(
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => PocketDisplayPage(goal: goal),
                                    ),
                                  ),
                              child: PocketDisplayCard(
                                pocketImage: icon.imagePath,
                                pocketName: goal.goalName,
                                saveAmount: goal.savedAmount,
                                targetAmount: goal.targetAmount,
                                percentage: _pct(
                                  goal.savedAmount,
                                  goal.targetAmount,
                                ),
                                remainAmount: _rem(
                                  goal.savedAmount,
                                  goal.targetAmount,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                SizedBox(height: AppResponsive.h(24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
