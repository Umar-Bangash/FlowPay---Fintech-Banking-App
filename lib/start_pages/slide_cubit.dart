import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SlideCubit extends Cubit<int> {
  SlideCubit() : super(0); // 0 is a initial index

  // methods for slide
  void nextSlide(int totalslides) {
    if (state < totalslides - 1) {
      emit(state + 1);
    } else {
      debugPrint('Slides finished');
    }
  }

  // skip method
  void skipped() => debugPrint('Skipped');
}
