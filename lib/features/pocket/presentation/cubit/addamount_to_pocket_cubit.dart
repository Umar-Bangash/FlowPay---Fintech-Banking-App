/*

This Cubit manage the state when i do click on button to add money to the pocket.

*/

import 'package:flutter_bloc/flutter_bloc.dart';

class PocketAmountCubit extends Cubit<int> {
  PocketAmountCubit() : super(0);

  void addAmount(int value) {
    emit(state + value);
  }

  void setAmount(int value) {
    emit(value);
  }
}
