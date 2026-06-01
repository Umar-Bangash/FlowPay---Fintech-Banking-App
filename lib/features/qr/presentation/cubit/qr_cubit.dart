import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowpay/features/auth/domain/entities/app_user.dart';
import 'package:flowpay/features/qr/presentation/cubit/qr_states.dart';
import '../../domain/entities/qr_transaction.dart';
import '../../domain/repo/qr_repo.dart';

class QRCubit extends Cubit<QRStates> {
  final QrRepo qrRepo;
  StreamSubscription<dynamic>? _accessRequestSub;

  QRCubit(this.qrRepo) : super(QRInitial());

  void resetToInitial() {
    _accessRequestSub?.cancel();
    emit(QRInitial());
  }

  Future<AppUser?> getReceiverById(String receiverId) async {
    try {
      return await qrRepo.getReceiverById(receiverId);
    } catch (e) {
      emit(QRError(e.toString()));
      return null;
    }
  }

  Future<void> payViaQr(QrTransaction transaction) async {
    emit(QRLoading());
    try {
      await qrRepo.payViaQr(transaction);
      emit(QRLoaded(transaction));
    } catch (e) {
      emit(QRError(e.toString()));
    }
  }

  Future<void> getTransaction(String transactionId) async {
    emit(QRLoading());
    try {
      final trx = await qrRepo.getTransaction(transactionId);
      if (trx == null) {
        emit(QRError('Transaction not found'));
        return;
      }
      emit(QRLoaded(trx));
    } catch (e) {
      emit(QRError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // REQUEST ACCOUNT ACCESS
  // ─────────────────────────────────────────────
  Future<void> requestAccountAccess({
    required String requesterId,
    required String requesterName,
    required String ownerId,
  }) async {
    emit(QRLoading());
    try {
      final request = await qrRepo.sendAccessRequest(
        requesterId: requesterId,
        requesterName: requesterName,
        ownerId: ownerId,
      );

      emit(QRAccessRequestSent(request));

      _accessRequestSub?.cancel();
      _accessRequestSub = qrRepo
          .watchAccessRequest(request.requestId)
          .listen(
            (updated) async {
              if (updated == null) return;

              if (updated.status == 'accepted') {
                _accessRequestSub?.cancel();

                // Emit granted with tempPassword
                emit(
                  QRAccessGranted(
                    ownerUid: updated.ownerId,
                    ownerEmail: updated.ownerEmail,
                    ownerName: updated.ownerName,
                    tempPassword: updated.tempPassword,
                  ),
                );

                // Delete temp credentials from Firestore
                // immediately after reading them
                try {
                  await FirebaseFirestore.instance
                      .collection('qr_access_requests')
                      .doc(updated.requestId)
                      .update({
                        'tempPassword': FieldValue.delete(),
                        'tempEmail': FieldValue.delete(),
                        'tempExpiresAt': FieldValue.delete(),
                      });
                } catch (e) {
                  // Non-critical — temp data will expire anyway
                }
              } else if (updated.status == 'rejected') {
                _accessRequestSub?.cancel();
                emit(QRAccessDenied(ownerName: updated.ownerName));
              }
            },
            onError: (e) {
              emit(QRError(e.toString()));
            },
          );
    } catch (e) {
      emit(QRError(e.toString()));
    }
  }

  Future<void> respondToAccessRequest({
    required String requestId,
    required String status,
  }) async {
    try {
      await qrRepo.respondToAccessRequest(requestId: requestId, status: status);
    } catch (e) {
      emit(QRError(e.toString()));
    }
  }

  Future<void> generateAccessToken(String ownerUid) async {
    emit(QRTokenGenerating());
    try {
      final token = await qrRepo.generateAccessToken(ownerUid);
      emit(QRTokenGenerated(token));
    } catch (e) {
      emit(QRError(e.toString()));
    }
  }

  Future<void> validateAndConsumeToken(String tokenId) async {
    emit(QRTokenValidating());
    try {
      final token = await qrRepo.validateAndConsumeToken(tokenId);
      if (token == null) {
        emit(QRTokenInvalid('expired or already used'));
        return;
      }
      emit(QRTokenValid(token.ownerUid));
    } catch (e) {
      emit(QRError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _accessRequestSub?.cancel();
    return super.close();
  }
}
