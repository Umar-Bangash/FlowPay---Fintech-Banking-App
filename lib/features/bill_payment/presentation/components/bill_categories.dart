import 'package:flutter/material.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class BillCategories extends StatelessWidget {
  final String imagePath;
  final String billName;
  const BillCategories({
    super.key,
    required this.imagePath,
    required this.billName,
  });

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    return LayoutBuilder(
      builder: (context, c) {
        // Container takes 72% of cell width, ensuring it fits with text below
        final boxSz = (c.maxWidth * 0.72).clamp(44.0, 52.0);
        final imgSz = (boxSz * 0.50).clamp(22.0, 36.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // never expands beyond content
          children: [
            Container(
              height: boxSz,
              width: boxSz,
              decoration: BoxDecoration(
                color: const Color(0xffEFF6FF),
                borderRadius: BorderRadius.circular(boxSz * 0.28),
              ),
              child: Center(
                child: Image.asset(imagePath, height: imgSz, width: imgSz),
              ),
            ),
            SizedBox(height: AppResponsive.h(3)),
            // FittedBox: text shrinks to fit, NEVER overflows cell
            SizedBox(
              width: c.maxWidth,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  billName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: AppResponsive.fs(11),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff475569),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

final List<BillCategories> lisofBillCategories = [
  const BillCategories(
    imagePath: 'assets/bill/electricity.png',
    billName: 'Electricity',
  ),
  const BillCategories(imagePath: 'assets/bill/gas.png', billName: 'Gas'),
  const BillCategories(imagePath: 'assets/bill/water.png', billName: 'Water'),
  const BillCategories(
    imagePath: 'assets/bill/internet.png',
    billName: 'Internet',
  ),
  const BillCategories(
    imagePath: 'assets/bill/education.png',
    billName: 'Education',
  ),
  const BillCategories(
    imagePath: 'assets/bill/telephone.png',
    billName: 'Telephone',
  ),
  const BillCategories(
    imagePath: 'assets/bill/insurance.png',
    billName: 'Insurance',
  ),
  const BillCategories(
    imagePath: 'assets/bill/governoment.png',
    billName: 'Government',
  ),
  const BillCategories(imagePath: 'assets/bill/more.png', billName: 'More'),
];
