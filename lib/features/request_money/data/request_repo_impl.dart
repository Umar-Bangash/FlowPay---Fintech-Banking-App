import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entity/request_money.dart';
import '../domain/repo/request_money_repo.dart';

class RequestRepositoryImpl implements RequestRepository {
  final FirebaseFirestore firestore;

  RequestRepositoryImpl(this.firestore);

  @override
  Future<void> createRequest(MoneyRequest request) async {
    final model = MoneyRequest(
      requestId: request.requestId,
      requesterId: request.requesterId,
      receiverId: request.receiverId,
      amount: request.amount,
      note: request.note,
      returnDate: request.returnDate,
      status: request.status,
      createdAt: request.createdAt,
    );

    await firestore
        .collection('money_requests')
        .doc(request.requestId)
        .set(model.toJson());
  }

  @override
  Future<void> updateRequestStatus({
    required String requestId,
    required RequestStatus status,
  }) async {
    await firestore.collection('money_requests').doc(requestId).update({
      'status': status.name,
    });
  }

  @override
  Future<MoneyRequest> getRequestById(String requestId) async {
    final doc =
        await firestore.collection('money_requests').doc(requestId).get();

    return MoneyRequest.fromJson(doc.data()!);
  }

  @override
  Future<List<MoneyRequest>> getRequestsForUser(String userId) async {
    final snapshot =
        await firestore
            .collection('money_requests')
            .where('receiverId', isEqualTo: userId)
            .get();

    return snapshot.docs.map((e) => MoneyRequest.fromJson(e.data())).toList();
  }
}
