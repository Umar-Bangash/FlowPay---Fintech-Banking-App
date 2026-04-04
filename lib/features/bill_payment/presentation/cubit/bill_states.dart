import '../../domain/entity/bill.dart';

abstract class BillState {}

/// initial
class BillInitial extends BillState {}

/// loading
class BillLoading extends BillState {}

/// bill data loaded
class BillLoaded extends BillState {
  final Bill bill;

  BillLoaded(this.bill);
}

/// bill payment success
class BillSuccess extends BillState {
  final Bill bill;

  BillSuccess(this.bill);
}

/// error
class BillError extends BillState {
  final String message;

  BillError(this.message);
}
