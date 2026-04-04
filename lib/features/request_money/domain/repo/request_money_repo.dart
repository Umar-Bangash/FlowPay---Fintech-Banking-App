import '../entity/request_money.dart';

abstract class RequestRepository {
  Future<void> createRequest(MoneyRequest request);
  Future<void> updateRequestStatus({
    required String requestId,
    required RequestStatus status,
  });
  Future<MoneyRequest> getRequestById(String requestId);
  Future<List<MoneyRequest>> getRequestsForUser(String userId);
}
