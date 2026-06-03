import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/components/custom_switch.dart';
import 'package:flowpay/features/auth/presentation/components/my_textfield.dart';
import 'package:flowpay/features/pocket/domain/entities/goal.dart';
import 'package:flowpay/features/pocket/presentation/components/packet_appbar.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_icon.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_setting_card.dart';
import 'package:flowpay/features/pocket/presentation/cubit/goal_cubit.dart';
import 'package:flowpay/features/pocket/presentation/pages/my_pockets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../components/pocket_created_successfully.dart';
import '../cubit/goal_states.dart';

class CreatePocketPage extends StatefulWidget {
  final String? categoryImage, categoryName, categoryId;
  final int? index;

  const CreatePocketPage({
    super.key,
    required this.categoryImage,
    required this.categoryId,
    required this.categoryName,
    required this.index,
  });

  @override
  State<CreatePocketPage> createState() => _CreatePocketPageState();
}

class _CreatePocketPageState extends State<CreatePocketPage> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();

  // FIX 5: Notification toggle state — default ON
  bool _notifyOnComplete = true;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<PocketIconCubit>();
    if (widget.categoryName != null) _nameCtrl.text = widget.categoryName!;
    if (widget.index != null) cubit.selectIcon(widget.index!);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final cubit = context.read<PocketIconCubit>();

    return BlocConsumer<GoalCubit, GoalState>(
      listener: (context, state) {
        if (state is GoalSuccess) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MyPockets()),
                );
              });
              return Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppResponsive.w(20)),
                  child: const PocketCreatedSuccessfully(),
                ),
              );
            },
          );
        }
      },
      builder: (context, goalState) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: pocketAppBar(
            context,
            'My Pocket',
            Image.asset(
              'assets/home/notification.png',
              height: AppResponsive.sp(22),
              width: AppResponsive.sp(22),
            ),
          ),
          body: AppAnimatedPage(
            direction: SlideDirection.right,
            child: BlocBuilder<PocketIconCubit, PocketIconState>(
              builder: (context, state) {
                final selIdx = state.selectedIndex;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.w(25),
                    vertical: AppResponsive.h(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      AppAnimatedItem(
                        index: 0,
                        direction: SlideDirection.left,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create new pocket',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(22),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: AppResponsive.h(4)),
                            Text(
                              'Set a goal and start saving for something meaningful.',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(12),
                                color: const Color(0xff737373),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(18)),

                      // Preview card
                      AppAnimatedItem(
                        index: 1,
                        direction: SlideDirection.bottom,
                        child: Center(
                          child: PocketSettingCard(
                            pocketImage: pocketIconsList[selIdx].imagePath,
                            pocketName: _nameCtrl.text,
                            saveAmount: 0,
                            targetAmount:
                                double.tryParse(_targetCtrl.text) ?? 0,
                          ),
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(18)),

                      AppAnimatedItem(
                        index: 2,
                        direction: SlideDirection.left,
                        child: _FieldLabel('Pocket Name'),
                      ),
                      AppAnimatedItem(
                        index: 2,
                        direction: SlideDirection.left,
                        child: MyTextField(
                          controller: _nameCtrl,
                          hintText: 'Enter Pocket Name',
                          obscureText: false,
                        ),
                      ),

                      AppAnimatedItem(
                        index: 3,
                        direction: SlideDirection.right,
                        child: _FieldLabel('Enter your target amount'),
                      ),
                      AppAnimatedItem(
                        index: 3,
                        direction: SlideDirection.right,
                        child: MyTextField(
                          controller: _targetCtrl,
                          hintText: 'Rs. 00',
                          obscureText: false,
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(10)),

                      AppAnimatedItem(
                        index: 4,
                        direction: SlideDirection.left,
                        child: _FieldLabel(
                          'Add an icon to personalize your pocket',
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(10)),

                      // Icon grid
                      AppAnimatedItem(
                        index: 5,
                        direction: SlideDirection.bottom,
                        child: SizedBox(
                          height: AppResponsive.h(120),
                          child: GridView.builder(
                            itemCount: pocketIconsList.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                ),
                            itemBuilder: (context, i) {
                              final p = pocketIconsList[i];
                              return PocketIcon(
                                id: p.id,
                                onClick: () => cubit.selectIcon(i),
                                imagePath: p.imagePath,
                                selected: selIdx == i,
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(14)),

                      // FIX 5: Notify tile — fully dynamic, wired to
                      // _notifyOnComplete state
                      AppAnimatedItem(
                        index: 6,
                        direction: SlideDirection.bottom,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppResponsive.radiusMd,
                            ),
                            color: const Color(0xffF9FAFB),
                            border: Border.all(color: const Color(0xffE5E7EB)),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppResponsive.w(16),
                              vertical: AppResponsive.h(4),
                            ),
                            title: Text(
                              'Notify when goal is reached',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(14),
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              _notifyOnComplete
                                  ? 'You will be notified when your savings are complete.'
                                  : 'Notifications are turned off for this pocket.',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(12),
                                color: const Color(0xff6A7282),
                              ),
                            ),
                            trailing: CustomSwitch(
                              width: AppResponsive.w(44),
                              height: AppResponsive.h(24),
                              thumbSize: 15.99,
                              // Pass real state value
                              value: _notifyOnComplete,
                              // Toggle and rebuild
                              onTap: () {
                                setState(() {
                                  _notifyOnComplete = !_notifyOnComplete;
                                });
                              },
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(14)),

                      // Create button
                      AppAnimatedItem(
                        index: 7,
                        direction: SlideDirection.bottom,
                        child: InkWell(
                          onTap: () {
                            final uid = FirebaseAuth.instance.currentUser!.uid;
                            if (_nameCtrl.text.isNotEmpty &&
                                _targetCtrl.text.isNotEmpty) {
                              context.read<GoalCubit>().createGoal(
                                Goal(
                                  categoryId: pocketIconsList[selIdx].id,
                                  goalId: '',
                                  userId: uid,
                                  goalName: _nameCtrl.text.trim(),
                                  targetAmount:
                                      double.tryParse(_targetCtrl.text) ?? 0,
                                  savedAmount: 0,
                                  deadline: DateTime.now(),
                                  // FIX 5: Persist user's choice
                                  notifyOnComplete: _notifyOnComplete,
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: AppResponsive.h(54),
                            decoration: BoxDecoration(
                              color: const Color(0xff007AFF),
                              borderRadius: BorderRadius.circular(
                                AppResponsive.radiusMd,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add, color: Colors.white),
                                SizedBox(width: AppResponsive.w(10)),
                                Text(
                                  'Create Pocket',
                                  style: TextStyle(
                                    fontSize: AppResponsive.fs(15),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(24)),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(fontSize: AppResponsive.fs(14)));
}
