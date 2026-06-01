import 'package:flowpay/features/pocket/domain/entities/goal.dart';
import 'package:flowpay/features/pocket/presentation/components/packet_appbar.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../components/pocket_setting_card.dart';
import '../cubit/goal_cubit.dart';

// FIX 4: Map icon id → display name for the pocket name field auto-fill
const Map<String, String> _iconCategoryNames = {
  'education': 'Education',
  'wedding': 'Wedding',
  'hajjumra': 'Hajj / Umrah',
  'travel': 'Travel',
  'emergency': 'Emergency',
  'car': 'Car',
  'gadget': 'Gadget',
  'money': 'Money',
  'gift': 'Gift',
  'bussiness': 'Business',
  'food': 'Food',
  'random': 'Custom Pocket',
};

// FIX 4: Converted to StatefulWidget so controllers and selectedIndex
// are stable across rebuilds — previously as StatelessWidget, every
// GoalCubit emit caused _nameCtrl, _targetCtrl and initIdx to reset.
class PocketEditPage extends StatefulWidget {
  final Goal goal;
  const PocketEditPage({super.key, required this.goal});

  @override
  State<PocketEditPage> createState() => _PocketEditPageState();
}

class _PocketEditPageState extends State<PocketEditPage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _targetCtrl;
  // FIX 4: selectedIndex lives in local state — not driven by GoalCubit
  late int _selectedIdx;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.goal.goalName);
    _targetCtrl = TextEditingController(
      text: widget.goal.targetAmount.toStringAsFixed(0),
    );

    // Resolve initial icon index from the goal's categoryId
    int idx = pocketIconsList.indexWhere((i) => i.id == widget.goal.categoryId);
    _selectedIdx = idx == -1 ? 0 : idx;
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
    final cubit = context.read<GoalCubit>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: pocketAppBar(
        context,
        'Edit Pocket',
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close),
        ),
      ),
      body: AppAnimatedPage(
        direction: SlideDirection.right,
        child: SingleChildScrollView(
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
                      'Edit your pocket',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(22),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppResponsive.h(4)),
                    Text(
                      'Update your pocket icon, name, and target amount.',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(12),
                        color: const Color(0xff737373),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppResponsive.h(18)),

              // Preview card — live preview using setState
              AppAnimatedItem(
                index: 1,
                direction: SlideDirection.bottom,
                child: Center(
                  child: PocketSettingCard(
                    pocketImage: pocketIconsList[_selectedIdx].imagePath,
                    pocketName: _nameCtrl.text,
                    saveAmount: widget.goal.savedAmount,
                    targetAmount: double.tryParse(_targetCtrl.text) ?? 0,
                  ),
                ),
              ),

              SizedBox(height: AppResponsive.h(18)),

              // Pocket Name
              AppAnimatedItem(
                index: 2,
                direction: SlideDirection.left,
                child: _FieldLabel('Pocket Name'),
              ),
              AppAnimatedItem(
                index: 2,
                direction: SlideDirection.left,
                // FIX 5 (style match): same style as create page fields
                child: _StyledTextField(
                  controller: _nameCtrl,
                  hintText: 'Enter Pocket Name',
                  keyboardType: TextInputType.text,
                  onChanged: (_) => setState(() {}),
                ),
              ),

              SizedBox(height: AppResponsive.h(10)),

              // Target Amount
              AppAnimatedItem(
                index: 3,
                direction: SlideDirection.right,
                child: _FieldLabel('Target Amount'),
              ),
              AppAnimatedItem(
                index: 3,
                direction: SlideDirection.right,
                child: _StyledTextField(
                  controller: _targetCtrl,
                  hintText: 'Rs. 0',
                  keyboardType: TextInputType.number,
                  // FIX 3: Rs prefix always visible
                  prefix: Text(
                    'Rs  ',
                    style: TextStyle(
                      fontSize: AppResponsive.fs(14),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xffA3A3A3),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),

              SizedBox(height: AppResponsive.h(14)),

              AppAnimatedItem(
                index: 4,
                direction: SlideDirection.left,
                child: _FieldLabel('Select Icon'),
              ),

              SizedBox(height: AppResponsive.h(8)),

              // Icon grid
              AppAnimatedItem(
                index: 5,
                direction: SlideDirection.bottom,
                child: SizedBox(
                  height: AppResponsive.h(120),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
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
                        imagePath: p.imagePath,
                        selected: _selectedIdx == i,
                        onClick: () {
                          setState(() {
                            _selectedIdx = i;
                            // FIX 4: Auto-fill pocket name when icon has
                            // a known category name (only if field is
                            // currently empty or matches a known category)
                            final categoryName = _iconCategoryNames[p.id];
                            if (categoryName != null) {
                              final currentText = _nameCtrl.text.trim();
                              final isKnownName = _iconCategoryNames.values
                                  .contains(currentText);
                              // Only auto-fill if blank or currently a
                              // known preset name (don't overwrite custom)
                              if (currentText.isEmpty || isKnownName) {
                                _nameCtrl.text = categoryName;
                              }
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: AppResponsive.h(18)),

              // Save button
              AppAnimatedItem(
                index: 6,
                direction: SlideDirection.bottom,
                child: InkWell(
                  onTap: () async {
                    try {
                      await cubit.updateGoal(
                        widget.goal.copyWith(
                          goalName: _nameCtrl.text.trim(),
                          targetAmount:
                              double.tryParse(_targetCtrl.text) ??
                              widget.goal.targetAmount,
                          // FIX 4: categoryId now correctly uses local
                          // _selectedIdx — not the GoalCubit's stale index
                          categoryId: pocketIconsList[_selectedIdx].id,
                        ),
                      );
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
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
                    child: Center(
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: AppResponsive.fs(15),
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppResponsive.h(24)),
            ],
          ),
        ),
      ),
    );
  }
}

// FIX 5: Unified styled text field matching create page aesthetic
class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final Widget? prefix;
  final ValueChanged<String>? onChanged;

  const _StyledTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.prefix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(fontSize: AppResponsive.fs(14), color: Colors.black),
      decoration: InputDecoration(
        prefix: prefix,
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: AppResponsive.fs(14),
          color: const Color(0xffA3A3A3),
        ),
        filled: true,
        fillColor: const Color(0xffF9FAFB),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppResponsive.w(16),
          vertical: AppResponsive.h(14),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
          borderSide: const BorderSide(color: Color(0xffE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
          borderSide: const BorderSide(color: Color(0xffE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
          borderSide: const BorderSide(color: Color(0xff007AFF), width: 1.5),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: AppResponsive.h(6)),
    child: Text(
      text,
      style: TextStyle(
        fontSize: AppResponsive.fs(14),
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
