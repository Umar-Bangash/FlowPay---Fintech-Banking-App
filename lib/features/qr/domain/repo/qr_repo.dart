import 'package:flowpay/features/auth/domain/entities/app_user.dart';
import '../entities/qr_access_request.dart';
import '../entities/qr_access_token.dart';
import '../entities/qr_transaction.dart';

abstract class QrRepo {
  Future<AppUser?> getReceiverById(String userId);
  Future<void> payViaQr(QrTransaction transaction);
  Future<QrTransaction?> getTransaction(String transactionId);

  Future<QrAccessRequest> sendAccessRequest({
    required String requesterId,
    required String requesterName,
    required String ownerId,
  });

  Future<void> respondToAccessRequest({
    required String requestId,
    required String status,
  });

  Stream<QrAccessRequest?> watchAccessRequest(String requestId);

  Future<QrAccessToken> generateAccessToken(String ownerUid);
  Future<QrAccessToken?> validateAndConsumeToken(String tokenId);
}
