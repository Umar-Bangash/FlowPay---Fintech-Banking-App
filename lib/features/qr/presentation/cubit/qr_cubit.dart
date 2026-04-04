import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowpay/features/auth/domain/entities/app_user.dart';
import '../../domain/qr_repo.dart';
import '../../domain/qr_transaction.dart';
import 'qr_states.dart';

class QRCubit extends Cubit<QRStates> {
  final QrRepo qrRepo;

  QRCubit(this.qrRepo) : super(QRInitial());

  // Get Receiver After QR Scan
  Future<void> getReceiver(String receiverId) async {
    emit(QRLoading());

    try {
      final AppUser? receiver = await qrRepo.getReceiverById(receiverId);

      if (receiver == null) {
        emit(QRError("Receiver not found"));
        return;
      }

      emit(QRLoaded(receiver));
    } catch (e) {
      emit(QRError(e.toString()));
    }
  }

  // Pay via QR
  Future<void> payViaQr(QrTransaction transaction) async {
    emit(QRLoading());

    try {
      await qrRepo.payViaQr(transaction);

      emit(QRLoaded(transaction));
    } catch (e) {
      emit(QRError(e.toString()));
    }
  }

  // Get Transaction Details
  Future<void> getTransaction(String transactionId) async {
    emit(QRLoading());

    try {
      final trx = await qrRepo.getTransaction(transactionId);

      if (trx == null) {
        emit(QRError("Transaction not found"));
        return;
      }

      emit(QRLoaded(trx));
    } catch (e) {
      emit(QRError(e.toString()));
    }
  }
}
