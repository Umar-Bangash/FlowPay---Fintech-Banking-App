/*

Payment States: Outline all possible payment states 

*/

import 'package:flowpay/features/stripe_payment/domain/entities/payment.dart';

abstract class PaymentStates {}

// initial
class PaymentInitial extends PaymentStates {}

// laoding
class PaymentLoading extends PaymentStates {}

// loaded
class PaymentLoaded extends PaymentStates {
  final List<Payment> payments;

  PaymentLoaded(this.payments);
}

// success
class PaymentSuccess extends PaymentStates {
  final String message;

  PaymentSuccess(this.message);
}

// error
class PaymentError extends PaymentStates {
  final String message;

  PaymentError(this.message);
}
