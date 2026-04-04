import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entity/bill.dart';
import '../../domain/repo/bill_repo.dart';
import 'bill_states.dart';

class BillCubit extends Cubit<BillState> {
  final BillRepository repository;

  BillCubit(this.repository) : super(BillInitial());

  /// FETCH BILL DETAILS
  Future<void> fetchBill({
    required String userId,
    required String providerName,
    required String consumerId,
    required String category,
  }) async {
    try {
      emit(BillLoading());

      final bill = await repository.fetchBillDetails(
        userId: userId,
        providerName: providerName,
        consumerId: consumerId,
        category: category,
      );

      emit(BillLoaded(bill));
    } catch (e) {
      emit(BillError(e.toString()));
    }
  }

  /// PAY BILL
  Future<void> payBill(Bill bill) async {
    try {
      emit(BillLoading());

      final paidBill = await repository.payBill(bill);

      emit(BillSuccess(paidBill));
    } catch (e) {
      emit(BillError(e.toString()));
    }
  }

  /// STREAM USER BILLS (RECENT BILLS)
  Stream<List<Bill>> getUserBillsStream(String userId) {
    return repository.getUserBillsStream(userId);
  }

  /// GET BILL CATEGORIES
  Future<List<String>> getCategories() async {
    return await repository.getBillCategories();
  }

  /// GET PROVIDERS BY CATEGORY
  Future<List<String>> getProviders(String category) async {
    return await repository.getProvidersByCategory(category);
  }
}
