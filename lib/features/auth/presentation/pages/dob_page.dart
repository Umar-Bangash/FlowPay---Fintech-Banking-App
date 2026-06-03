import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class DateOfBirthPicker extends StatefulWidget {
  const DateOfBirthPicker({super.key});
  @override
  State<DateOfBirthPicker> createState() => _DateOfBirthPickerState();
}

class _DateOfBirthPickerState extends State<DateOfBirthPicker> {
  int _day = 23;
  String _month = 'Jul';
  int _year = 2003;
  int _age = 0;

  final _dayCtrl = FixedExtentScrollController(initialItem: 22);
  final _monthCtrl = FixedExtentScrollController(initialItem: 6);
  final _yearCtrl = FixedExtentScrollController(initialItem: 2003 - 1950);

  final _days = List.generate(31, (i) => i + 1);
  final _months = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  late final List<int> _years;

  @override
  void initState() {
    super.initState();
    _years = List.generate(DateTime.now().year - 1949, (i) => 1950 + i);
    _calcAge();
  }

  @override
  void dispose() {
    _dayCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  void _calcAge() {
    final now = DateTime.now();
    final mi = _months.indexOf(_month) + 1;
    int age = now.year - _year;
    if (now.month < mi || (now.month == mi && now.day < _day)) age--;
    setState(() => _age = age);
  }

  DateTime get _selectedDate =>
      DateTime(_year, _months.indexOf(_month) + 1, _day);

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    const blue = Color(0xff007AFF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AppAnimatedPage(
        direction: SlideDirection.bottom,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppResponsive.w(24),
              vertical: AppResponsive.h(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppAnimatedItem(
                  index: 0,
                  direction: SlideDirection.left,
                  child: Text(
                    "What's Your Date of Birth?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppResponsive.fs(22),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(36)),

                // ── Wheel picker — height from AppResponsive
                AppAnimatedItem(
                  index: 1,
                  direction: SlideDirection.bottom,
                  child: SizedBox(
                    height: AppResponsive.h(200),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _wheel<int>(
                              ctrl: _dayCtrl,
                              items: _days,
                              onChange: (i) {
                                setState(() => _day = _days[i]);
                                _calcAge();
                              },
                            ),
                            _wheel<String>(
                              ctrl: _monthCtrl,
                              items: _months,
                              onChange: (i) {
                                setState(() => _month = _months[i]);
                                _calcAge();
                              },
                            ),
                            _wheel<int>(
                              ctrl: _yearCtrl,
                              items: _years,
                              onChange: (i) {
                                setState(() => _year = _years[i]);
                                _calcAge();
                              },
                            ),
                          ],
                        ),

                        // Selection border — centred with responsive height
                        Positioned(
                          top: (AppResponsive.h(200) - AppResponsive.h(50)) / 2,
                          left: AppResponsive.w(16),
                          right: AppResponsive.w(16),
                          child: IgnorePointer(
                            child: Container(
                              height: AppResponsive.h(50),
                              decoration: BoxDecoration(
                                border: Border.all(color: blue, width: 1.2),
                                borderRadius: BorderRadius.circular(
                                  AppResponsive.radiusMd,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(22)),

                // ── Age display
                AppAnimatedItem(
                  index: 2,
                  direction: SlideDirection.right,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/calender_icon.png',
                        height: AppResponsive.sp(18),
                        width: AppResponsive.sp(16),
                      ),
                      SizedBox(width: AppResponsive.w(6)),
                      Text(
                        'I am $_age years old',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: AppResponsive.fs(14),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppResponsive.h(40)),

                AppAnimatedItem(
                  index: 3,
                  direction: SlideDirection.bottom,
                  child: MainButton(
                    buttonName: 'Continue',
                    onTap: () => Navigator.pop(context, _selectedDate),
                  ),
                ),

                // Breathing room at bottom so button never clips on SE
                SizedBox(height: AppResponsive.h(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _wheel<T>({
    required FixedExtentScrollController ctrl,
    required List<T> items,
    required Function(int) onChange,
  }) {
    return SizedBox(
      // Width fraction of screen so it scales on all devices
      width: AppResponsive.w(90),
      child: ListWheelScrollView.useDelegate(
        controller: ctrl,
        itemExtent: AppResponsive.h(42),
        perspective: 0.0001,
        diameterRatio: 10,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChange,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length,
          builder: (context, i) {
            if (i < 0 || i >= items.length) return null;
            final selected = ctrl.selectedItem == i;
            return Center(
              child: Text(
                items[i].toString(),
                style: TextStyle(
                  fontSize: AppResponsive.fs(19),
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                  color:
                      selected
                          ? const Color(0xff112942)
                          : Colors.black.withOpacity(0.55),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
