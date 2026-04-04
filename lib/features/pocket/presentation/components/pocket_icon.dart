import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PocketIcon extends StatelessWidget {
  final String imagePath;
  final String id;
  final void Function()? onClick;
  final bool selected;

  const PocketIcon({
    super.key,
    required this.imagePath,
    required this.id,
    this.onClick,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        height: 49,
        width: 49,
        decoration: BoxDecoration(
          color: selected ? Color(0xffDDEFFF) : Color(0xffF7F7F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            height: 24,
            width: 24,
            color: selected ? Color(0xff007AFF) : Color(0xff000000),
          ),
        ),
      ),
    );
  }
}

List<PocketIcon> pocketIconsList = [
  PocketIcon(
    imagePath: 'assets/pocket/education.png',
    selected: false,
    id: "education",
  ),
  PocketIcon(
    imagePath: 'assets/pocket/wedding.png',
    selected: false,
    id: "wedding",
  ),
  PocketIcon(
    imagePath: 'assets/pocket/hajjumra.png',
    selected: false,
    id: "hajjumra",
  ),
  PocketIcon(
    imagePath: 'assets/pocket/travel.png',
    selected: false,
    id: "travel",
  ),
  PocketIcon(
    imagePath: 'assets/pocket/emergency.png',
    selected: false,
    id: "emergency",
  ),
  PocketIcon(imagePath: 'assets/pocket/car.png', selected: false, id: "car"),
  PocketIcon(
    imagePath: 'assets/pocket/gadget.png',
    selected: false,
    id: "gadget",
  ),
  PocketIcon(
    imagePath: 'assets/pocket/money.png',
    selected: false,
    id: "money",
  ),
  PocketIcon(imagePath: 'assets/pocket/gift.png', selected: false, id: "gift"),
  PocketIcon(
    imagePath: 'assets/pocket/bussiness.png',
    selected: false,
    id: "bussiness",
  ),
  PocketIcon(imagePath: 'assets/pocket/food.png', selected: false, id: "food"),
  PocketIcon(
    imagePath: 'assets/pocket/random.png',
    selected: false,
    id: "random",
  ),
];

class PocketIconState {
  final int selectedIndex;

  PocketIconState({required this.selectedIndex});
}

class PocketIconCubit extends Cubit<PocketIconState> {
  PocketIconCubit() : super(PocketIconState(selectedIndex: 0));

  void selectIcon(int index) {
    emit(PocketIconState(selectedIndex: index));
  }
}
