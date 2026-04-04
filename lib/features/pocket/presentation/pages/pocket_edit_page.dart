import 'package:flowpay/features/pocket/domain/entities/goal.dart';
import 'package:flowpay/features/pocket/presentation/components/packet_appbar.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_icon.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../components/pocket_setting_card.dart';
import '../cubit/goal_cubit.dart';
import '../cubit/goal_states.dart';

class PocketEditPage extends StatelessWidget {
  final Goal goal;
  const PocketEditPage({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final pocketNameController = TextEditingController(text: goal.goalName);
    final targetAmountController = TextEditingController(
      text: goal.targetAmount.toString(),
    );
    final cubit = context.read<GoalCubit>();

    // initialize selected icon
    int initialIconIndex = pocketIconsList.indexWhere(
      (icon) => icon.id == goal.categoryId,
    );
    if (initialIconIndex == -1) initialIconIndex = 0;
    cubit.selectGoalIcon(initialIconIndex);

    return Scaffold(
      appBar: pocketAppBar(context, 'Edit Pocket', Icon(Icons.close)),
      body: Padding(
        padding: context.padSymmetricPx(horizontal: 25),
        child: BlocBuilder<GoalCubit, GoalState>(
          builder: (context, state) {
            int selectedIndex = 0;
            if (state is GoalLoaded && state.selectedIconIndex != null) {
              selectedIndex = state.selectedIconIndex!;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Edit your pocket',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const Text(
                  'You can edit your pocket icon, name, and target amount',
                  style: TextStyle(fontSize: 13, color: Color(0xff0A0A0A)),
                ),
                context.spaceHPx(20),
                Center(
                  child: PocketSettingCard(
                    pocketImage: pocketIconsList[selectedIndex].imagePath,
                    pocketName: pocketNameController.text,
                    saveAmount: goal.savedAmount,
                    targetAmount:
                        double.tryParse(targetAmountController.text) ?? 0,
                  ),
                ),
                context.spaceHPx(20),
                const Text('Pocket Name', style: TextStyle(fontSize: 16)),
                TextField(
                  controller: pocketNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter Pocket Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                context.spaceHPx(10),
                const Text('Target Amount', style: TextStyle(fontSize: 16)),
                TextField(
                  controller: targetAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Rs. 00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                context.spaceHPx(10),
                const Text('Select Icon', style: TextStyle(fontSize: 16)),
                SizedBox(
                  height: context.hPx(125),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
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
                        imagePath: pocketIcon.imagePath,
                        selected: selectedIndex == index,
                        onClick: () => cubit.selectGoalIcon(index),
                      );
                    },
                  ),
                ),
                context.spaceHPx(15),
                InkWell(
                  onTap: () async {
                    try {
                      final updatedGoal = goal.copyWith(
                        goalName: pocketNameController.text,
                        targetAmount:
                            double.tryParse(targetAmountController.text) ??
                            goal.targetAmount,
                        categoryId: pocketIconsList[selectedIndex].id,
                      );

                      await cubit.updateGoal(updatedGoal);
                      Navigator.pop(context); // close edit page
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  child: Container(
                    height: context.hPx(56),
                    decoration: BoxDecoration(
                      color: const Color(0xff007AFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
