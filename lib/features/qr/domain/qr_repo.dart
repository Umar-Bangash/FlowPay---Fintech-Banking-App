import 'package:flowpay/features/auth/domain/entities/app_user.dart';

import 'qr_transaction.dart';

abstract class QrRepo {
  /// get receiver account after scanning QR
  Future<AppUser?> getReceiverById(String userId);

  /// process QR payment transaction
  Future<void> payViaQr(QrTransaction transaction);

  /// fetch transaction details for success screen
  Future<QrTransaction?> getTransaction(String transactionId);
}
