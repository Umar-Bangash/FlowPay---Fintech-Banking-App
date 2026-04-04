import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/stripe_payment/domain/entities/payment.dart';
import 'package:flowpay/features/stripe_payment/domain/repo/payment_repo.dart';

class PaymentRepoImpl implements PaymentRepo {
  // get firestore instance
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  @override
  Future<void> createPayment(Payment payment) async {
    try {
      // store payment record in firestore payments collection !!
      await _firebaseFirestore
          .collection('payments')
          .doc(payment.paymentId)
          .set(payment.toJson());
    } catch (e) {
      throw Exception('Falied to create payment record: $e');
    }
  }

  @override
  Future<void> deletePayment(String paymentId) async {
    try {
      // delete payment record from firestore payments collecction
      await _firebaseFirestore.collection('payments').doc(paymentId).delete();
    } catch (e) {
      throw Exception('Falied to delete payment record: $e');
    }
  }

  @override
  Future<List<Payment>> getPayments(String userId) async {
    try {
      final paymentRecord =
          await _firebaseFirestore
              .collection('payments')
              .where('userId', isEqualTo: userId)
              .get();
      return paymentRecord.docs
          .map((doc) => Payment.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Falied to load payment record: $e');
    }
  }
}
