/*

Bill Repo: This repository outline the functionality of bill payment

*/

import '../entity/bill.dart';

abstract class BillRepository {
  /// categories shown on first screen
  Future<List<String>> getBillCategories();

  /// providers based on category
  Future<List<String>> getProvidersByCategory(String category);

  /// simulate bill fetch
  Future<Bill> fetchBillDetails({
    required String userId,
    required String providerName,
    required String consumerId,
    required String category,
  });

  /// pay bill
  Future<Bill> payBill(Bill bill);

  /// recent bills stream
  Stream<List<Bill>> getUserBillsStream(String userId);
}
