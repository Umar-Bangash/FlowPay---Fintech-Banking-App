import 'package:flutter_bloc/flutter_bloc.dart';

// Amount Cubit
class AmountCubit extends Cubit<String> {
  AmountCubit() : super('');

  void reflectAmount(String amount) {
    emit(amount);
  }
}

// Comment Length Cubit
class CommentCubit extends Cubit<int> {
  CommentCubit() : super(0);

  void updateCommentLength(int words) => emit(words);
}
