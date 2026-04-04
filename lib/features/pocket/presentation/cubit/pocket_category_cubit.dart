import 'package:flutter_bloc/flutter_bloc.dart';

class PocketCategoryState {
  final int selectedIndex;

  PocketCategoryState({required this.selectedIndex});
}

class PocketCategoryCubit extends Cubit<PocketCategoryState> {
  PocketCategoryCubit() : super(PocketCategoryState(selectedIndex: -1));

  void selectPocket(int index) {
    emit(PocketCategoryState(selectedIndex: index));
  }
}
