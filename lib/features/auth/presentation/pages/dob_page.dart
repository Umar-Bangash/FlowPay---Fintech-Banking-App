import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';

class DateOfBirthPicker extends StatefulWidget {
  const DateOfBirthPicker({super.key});

  @override
  State<DateOfBirthPicker> createState() => _DateOfBirthPickerState();
}

class _DateOfBirthPickerState extends State<DateOfBirthPicker> {
  int selectedDay = 23;
  String selectedMonth = "Jul";
  int selectedYear = 2003;
  int age = 0;

  final FixedExtentScrollController _dayController =
      FixedExtentScrollController(initialItem: 22);
  final FixedExtentScrollController _monthController =
      FixedExtentScrollController(initialItem: 6);
  final FixedExtentScrollController _yearController =
      FixedExtentScrollController(initialItem: 2003 - 1950);

  List<int> days = List.generate(31, (index) => index + 1);
  List<String> months = const [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  List<int> years = List.generate(
    DateTime.now().year - 1949,
    (index) => 1950 + index,
  );

  @override
  void initState() {
    super.initState();
    _calculateAge();
  }

  void _calculateAge() {
    final today = DateTime.now();
    int monthIndex = months.indexOf(selectedMonth) + 1;
    int calculatedAge = today.year - selectedYear;
    if (today.month < monthIndex ||
        (today.month == monthIndex && today.day < selectedDay)) {
      calculatedAge--;
    }
    setState(() => age = calculatedAge);
  }

  DateTime get selectedDateOfBirth {
    final monthNumber = months.indexOf(selectedMonth) + 1;

    return DateTime(selectedYear, monthNumber, selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("The value is ${selectedMonth}");
    const blueColor = Color(0xff007AFF);

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
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.wPx(24),
          vertical: context.hPx(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            const Text(
              "What's Your Date of Birth?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 40),

            // Scrollable Date Picker
            SizedBox(
              height: context.hPx(200),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWheel<int>(
                        controller: _dayController,
                        items: days,
                        onSelectedItemChanged: (i) {
                          setState(() => selectedDay = days[i]);
                          _calculateAge();
                        },
                      ),
                      _buildWheel<String>(
                        controller: _monthController,
                        items: months,
                        onSelectedItemChanged: (i) {
                          setState(() => selectedMonth = months[i]);
                          _calculateAge();
                        },
                      ),
                      _buildWheel<int>(
                        controller: _yearController,
                        items: years,
                        onSelectedItemChanged: (i) {
                          setState(() => selectedYear = years[i]);
                          _calculateAge();
                        },
                      ),
                    ],
                  ),

                  Positioned(
                    top: context.hPx(200) / 2 - context.hPx(26.5),
                    left: context.wPx(24),
                    right: context.wPx(24),
                    child: Container(
                      height: context.hPx(53),
                      decoration: BoxDecoration(
                        border: Border.all(color: blueColor, width: 1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Age Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/calender_icon.png',
                  height: context.hPx(19.5),
                  width: context.wPx(18),
                ),
                const SizedBox(width: 6),
                Text(
                  "I am $age years old",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            context.spaceHPx(45),
            MainButton(
              buttonName: 'Continue',
              onTap: () {
                Navigator.pop(context, selectedDateOfBirth);
              },
            ),
            context.spaceHPx(100),
          ],
        ),
      ),
    );
  }

  Widget _buildWheel<T>({
    required FixedExtentScrollController controller,
    required List<T> items,
    required Function(int) onSelectedItemChanged,
  }) {
    return SizedBox(
      width: 90,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 40,
        perspective: 0.0001,
        // removes curve completely
        diameterRatio: 10,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelectedItemChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            if (index < 0 || index >= items.length) return null;
            final isSelected = controller.selectedItem == index;
            return Center(
              child: Text(
                items[index].toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color:
                      isSelected
                          ? const Color.fromARGB(255, 17, 41, 66)
                          : Colors.black.withOpacity(0.6),
                ),
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}
