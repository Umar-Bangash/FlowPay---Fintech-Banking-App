import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/request_noti_service.dart';
import '../../domain/entity/request_money.dart';
import '../../domain/repo/request_money_repo.dart';
import 'request_states.dart';

class RequestCubit extends Cubit<RequestState> {
  final RequestRepository repository;
  final RequestMoneyNotificationService notificationService;

  RequestCubit(this.repository, this.notificationService)
    : super(RequestInitial());

  // ─────────────────────────────────────────────
  // CREATE REQUEST
  // Called on: requester's device
  // Requester → local popup ("Request Sent")
  // Receiver  → FCM push ("Someone requested money from you")
  // ─────────────────────────────────────────────
  Future<void> createRequest({
    required String requestId,
    required String requesterId,
    required String receiverId,
    required double amount,
    String? note,
    DateTime? returnDate,
  }) async {
    try {
      emit(RequestLoading());

      final request = MoneyRequest(
        requestId: requestId,
        requesterId: requesterId,
        receiverId: receiverId,
        amount: amount,
        note: note,
        returnDate: returnDate,
        status: RequestStatus.pending,
        createdAt: DateTime.now(),
      );

      await repository.createRequest(request);

      // Fire notifications after successful save
      await notificationService.notifyRequestSent(
        requesterId: requesterId,
        receiverId: receiverId,
        amount: amount,
      );

      emit(RequestSuccess());
    } catch (e) {
      emit(RequestFailure(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // ACCEPT REQUEST
  // Called on: receiver's device
  // Receiver  → local popup ("You accepted")
  // Requester → FCM push ("Your request was accepted")
  // ─────────────────────────────────────────────
  Future<void> acceptRequest({
    required String requestId,
    required String requesterId,
    required String receiverId,
    required double amount,
  }) async {
    try {
      await repository.updateRequestStatus(
        requestId: requestId,
        status: RequestStatus.accepted,
      );

      await notificationService.notifyRequestAccepted(
        requesterId: requesterId,
        receiverId: receiverId,
        amount: amount,
      );
    } catch (e) {
      emit(RequestFailure(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // DECLINE REQUEST
  // Called on: receiver's device
  // Receiver  → local popup ("You declined")
  // Requester → FCM push ("Your request was declined")
  // ─────────────────────────────────────────────
  Future<void> declineRequest({
    required String requestId,
    required String requesterId,
    required String receiverId,
    required double amount,
  }) async {
    try {
      await repository.updateRequestStatus(
        requestId: requestId,
        status: RequestStatus.declined,
      );

      await notificationService.notifyRequestDeclined(
        requesterId: requesterId,
        receiverId: receiverId,
        amount: amount,
      );
    } catch (e) {
      emit(RequestFailure(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // PAY REQUEST
  // Called on: payer's device
  // Payer     → local popup ("You paid")
  // Requester → FCM push ("Your request was paid")
  // ─────────────────────────────────────────────
  Future<void> payRequest({
    required String requestId,
    required String requesterId,
    required String payerId,
    required double amount,
  }) async {
    try {
      await repository.updateRequestStatus(
        requestId: requestId,
        status: RequestStatus.paid,
      );

      await notificationService.notifyRequestPaid(
        requesterId: requesterId,
        payerId: payerId,
        amount: amount,
      );
    } catch (e) {
      emit(RequestFailure(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // LOAD REQUESTS
  // ─────────────────────────────────────────────
  Future<void> loadRequests(String userId) async {
    try {
      emit(RequestLoading());
      final requests = await repository.getRequestsForUser(userId);
      emit(RequestLoaded(requests));
    } catch (e) {
      emit(RequestFailure(e.toString()));
    }
  }
}
