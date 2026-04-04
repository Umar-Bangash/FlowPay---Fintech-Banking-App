import 'package:flowpay/features/stripe_payment/domain/entities/payment.dart';
import 'package:flowpay/features/stripe_payment/domain/repo/payment_repo.dart';
import 'package:flowpay/features/stripe_payment/presentation/cubit/payment_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentCubit extends Cubit<PaymentStates> {
  final PaymentRepo paymentRepo;
  PaymentCubit(this.paymentRepo) : super(PaymentInitial());

  // fetch all list payments records for a user
  Future<void> getPayments(String userId) async {
    try {
      emit(PaymentLoading());
      final payments = await paymentRepo.getPayments(userId);
      emit(PaymentLoaded(payments));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  // Add new paymwnt
  Future<void> createPayment(Payment payment) async {
    try {
      emit(PaymentLoading());
      await paymentRepo.createPayment(payment);
      emit(PaymentSuccess('Payment save succeessfully'));
      // refresh the payment list after adding new payment record
      await getPayments(payment.userId);
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  // delete payment
  Future<void> deletePayment(String paymentId, String userId) async {
    try {
      emit(PaymentLoading());
      await paymentRepo.deletePayment(paymentId);
      emit(PaymentSuccess('Payment deleted Successfully'));
      // refresh the payment list after deleting payment record
      await getPayments(userId);
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }
}
