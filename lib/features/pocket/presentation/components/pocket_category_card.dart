import 'package:flowpay/helpers/text_styles.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class PocketCategoryCard extends StatefulWidget {
  final String pocketImage;
  final String pocketName;
  final String id;
  final void Function() onClick;
  final bool isSelected;

  const PocketCategoryCard({
    super.key,
    required this.pocketImage,
    required this.id,
    required this.pocketName,
    required this.onClick,
    required this.isSelected,
  });

  @override
  State<PocketCategoryCard> createState() => _PocketCategoryCardState();
}

class _PocketCategoryCardState extends State<PocketCategoryCard> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onClick,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isSelected ? Color(0xffF0F9FF) : Color(0xffFFFFFF),
          border: Border.all(
            color: widget.isSelected ? Color(0xff007AFF) : Color(0xffFFFFFF),
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 15,
              spreadRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: context.padSymmetricPx(horizontal: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: context.hPx(48),
                width: context.wPx(48),
                decoration: BoxDecoration(
                  color: widget.isSelected ? Color(0xffDDEFFF) : Color(0xffF7F8F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Image.asset(
                    widget.pocketImage,
                    height: context.hPx(24),
                    width: context.wPx(24),
                    color: widget.isSelected ? Color(0xff007AFF) : Color(0xff000000),
                  ),
                ),
              ),
              mediumText(widget.pocketName),
            ],
          ),
        ),
      ),
    );
  }
}

List<PocketCategoryCard> pocketsList = [
  PocketCategoryCard(
    id: 'education',
    pocketImage: 'assets/pocket/education.png',
    pocketName: 'Education',
    onClick: () {},
    isSelected: false,
  ),
  PocketCategoryCard(
    id: 'wedding',
    pocketImage: 'assets/pocket/wedding.png',
    pocketName: 'Wedding',
    onClick: () {},
    isSelected: false,
  ),
  PocketCategoryCard(
    id: 'hajjumra',
    pocketImage: 'assets/pocket/hajjumra.png',
    pocketName: 'Hajj / Umrah',
    onClick: () {},
    isSelected: false,
  ),
  PocketCategoryCard(
    id: 'travel',
    pocketImage: 'assets/pocket/travel.png',
    pocketName: 'Travel',
    onClick: () {},
    isSelected: false,
  ),
  PocketCategoryCard(
    id: 'emergency',
    pocketImage: 'assets/pocket/emergency.png',
    pocketName: 'Emergency',
    onClick: () {},
    isSelected: false,
  ),
  PocketCategoryCard(
    id: 'car',
    pocketImage: 'assets/pocket/car.png',
    pocketName: 'Car',
    onClick: () {},
    isSelected: false,
  ),
  PocketCategoryCard(
    id: 'gadget',
    pocketImage: 'assets/pocket/gadget.png',
    pocketName: 'Gadget',
    onClick: () {},
    isSelected: false,
  ),
  PocketCategoryCard(
    id: 'custom',
    pocketImage: 'assets/pocket/plus.png',
    pocketName: 'Custom Pocket',
    onClick: () {},
    isSelected: false,
  ),
];

