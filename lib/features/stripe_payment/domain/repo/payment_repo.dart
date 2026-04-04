/*

Payment Repository: outline the functionalties of the payment

*/

import 'package:flowpay/features/stripe_payment/domain/entities/payment.dart';

abstract class PaymentRepo {
  Future<void> createPayment(Payment payment);
  Future<List<Payment>> getPayments(String userId);
  Future<void> deletePayment(String paymentId);
}
