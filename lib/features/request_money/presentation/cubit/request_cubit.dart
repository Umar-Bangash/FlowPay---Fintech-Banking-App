import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entity/request_money.dart';
import '../../domain/repo/request_money_repo.dart';
import 'request_states.dart';

class RequestCubit extends Cubit<RequestState> {
  final RequestRepository repository;

  RequestCubit(this.repository) : super(RequestInitial());

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

      emit(RequestSuccess());
    } catch (e) {
      emit(RequestFailure(e.toString()));
    }
  }

  Future<void> acceptRequest(String requestId) async {
    await repository.updateRequestStatus(
      requestId: requestId,
      status: RequestStatus.accepted,
    );
  }

  Future<void> payRequest(String requestId) async {
    await repository.updateRequestStatus(
      requestId: requestId,
      status: RequestStatus.paid,
    );
  }
}
