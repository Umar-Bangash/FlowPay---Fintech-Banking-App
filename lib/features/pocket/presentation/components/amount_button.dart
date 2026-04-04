import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/addamount_to_pocket_cubit.dart';

Widget amountButton(int value) {
  return BlocBuilder<PocketAmountCubit, int>(
    builder: (context, amount) {
      final bool isActive = amount == value;

      return GestureDetector(
        onTap: () {
          context.read<PocketAmountCubit>().setAmount(value);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Color(0xffEAF2FF) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive ? Colors.blue : Color(0xffDADADA),
              width: 1.5,
            ),
          ),
          child: Text(
            '+ Rs $value',
            style: TextStyle(
              color: isActive ? Colors.blue : Color(0xff707070),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    },
  );
}
