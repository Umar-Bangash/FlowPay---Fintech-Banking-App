import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/components/custom_switch.dart';
import 'package:flowpay/features/auth/presentation/components/my_textfield.dart';
import 'package:flowpay/features/pocket/domain/entities/goal.dart';
import 'package:flowpay/features/pocket/presentation/components/packet_appbar.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_icon.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_setting_card.dart';
import 'package:flowpay/features/pocket/presentation/cubit/goal_cubit.dart';
import 'package:flowpay/features/pocket/presentation/pages/my_pockets.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../components/pocket_created_successfully.dart';
import '../cubit/goal_states.dart';

class CreatePocketPage extends StatelessWidget {
  final String? categoryImage;
  final String? categoryName;
  final int? index;
  final String? categoryId;

  CreatePocketPage({
    super.key,
    required this.categoryImage,
    required this.categoryId,
    required this.categoryName,
    required this.index,
  });

  final pocketNameController = TextEditingController();
  final targetAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //final userId = FirebaseAuth.instance.currentUser!.uid;
    final cubit = context.read<PocketIconCubit>();

    // Pre-fill values if editing
    if (categoryName != null) pocketNameController.text = categoryName!;
    if (index != null) cubit.selectIcon(index!);

    return BlocConsumer<GoalCubit, GoalState>(
      listener: (context, state) {
        if (state is GoalSuccess) {
          //final selectedIndex = cubit.state.selectedIndex;

          // // Build Goal object to pass dynamically
          // final goal = Goal(
          //   categoryId: pocketIconsList[selectedIndex].id,
          //   goalId: '', // returned from GoalCubit after creation
          //   userId: userId,
          //   goalName: pocketNameController.text.trim(),
          //   targetAmount: double.tryParse(targetAmountController.text) ?? 0,
          //   savedAmount: 0,
          //   deadline: DateTime.now(),
          // );

          // Show success dialog, then navigate to PocketDisplayPage
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyPockets()),
                );
              });

              return Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: PocketCreatedSuccessfully(),
                ),
              );
            },
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: pocketAppBar(
            context,
            'My Pocket',
            Image.asset(
              'assets/home/notification.png',
              height: context.hPx(24),
              width: context.wPx(24),
            ),
          ),
          body: Padding(
            padding: context.padSymmetricPx(horizontal: 25),
            child: BlocBuilder<PocketIconCubit, PocketIconState>(
              builder: (context, state) {
                final selectedIndex = state.selectedIndex;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Create new pocket',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Set a goal and start saving for something\nmeaningful,',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xff0A0A0A),
                        ),
                      ),
                      context.spaceHPx(20),
                      Center(
                        child: PocketSettingCard(
                          pocketImage: pocketIconsList[selectedIndex].imagePath,
                          pocketName: pocketNameController.text,
                          saveAmount: 0,
                          targetAmount:
                              double.tryParse(targetAmountController.text) ?? 0,
                        ),
                      ),
                      context.spaceHPx(20),
                      const Text('Pocket Name', style: TextStyle(fontSize: 16)),
                      MyTextField(
                        controller: pocketNameController,
                        hintText: 'Enter Pocket Name',
                        obscureText: false,
                      ),
                      context.spaceHPx(3),
                      const Text(
                        'Enter your target amount',
                        style: TextStyle(fontSize: 16),
                      ),
                      MyTextField(
                        controller: targetAmountController,
                        hintText: 'Rs. 00',
                        obscureText: false,
                      ),
                      context.spaceHPx(10),
                      const Text(
                        'Add an icon to personalize your pocket',
                        style: TextStyle(fontSize: 16),
                      ),
                      context.spaceHPx(10),
                      SizedBox(
                        height: context.hPx(125),
                        child: GridView.builder(
                          itemCount: pocketIconsList.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                          itemBuilder: (context, index) {
                            final pocketIcon = pocketIconsList[index];
                            return PocketIcon(
                              id: pocketIcon.id,
                              onClick: () => cubit.selectIcon(index),
                              imagePath: pocketIcon.imagePath,
                              selected: state.selectedIndex == index,
                            );
                          },
                        ),
                      ),
                      context.spaceHPx(15),
                      Container(
                        height: context.hPx(80),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xffF9FAFB),
                        ),
                        child: ListTile(
                          title: const Text(
                            'Notify me',
                            style: TextStyle(fontSize: 16),
                          ),
                          subtitle: const Text(
                            'Get reminded about your goal',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff6A7282),
                            ),
                          ),
                          trailing: CustomSwitch(
                            width: context.wPx(44),
                            height: context.hPx(24),
                            thumbSize: 15.99,
                            value: true,
                            onTap: () {},
                          ),
                        ),
                      ),
                      context.spaceHPx(12),
                      Center(
                        child: InkWell(
                          onTap: () {
                            final userId =
                                FirebaseAuth.instance.currentUser!.uid;
                            if (pocketNameController.text.isNotEmpty &&
                                targetAmountController.text.isNotEmpty) {
                              final goal = Goal(
                                categoryId: pocketIconsList[selectedIndex].id,
                                goalId: "", // will be updated by GoalCubit
                                userId: userId,
                                goalName: pocketNameController.text.trim(),
                                targetAmount:
                                    double.tryParse(
                                      targetAmountController.text,
                                    ) ??
                                    0,
                                savedAmount: 0,
                                deadline: DateTime.now(),
                              );
                              context.read<GoalCubit>().createGoal(goal);
                            }
                          },
                          child: Container(
                            height: context.hPx(56),
                            width: context.wPx(341),
                            decoration: BoxDecoration(
                              color: const Color(0xff007AFF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add, color: Color(0xffFFFFFF)),
                                SizedBox(width: 12),
                                Text(
                                  'Create Pocket',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xffFFFFFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
          backgroundColor: const Color(0xffFFFFFF),
        );
      },
    );
  }
}
