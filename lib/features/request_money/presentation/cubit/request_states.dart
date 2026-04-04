import '../../domain/entity/request_money.dart';

abstract class RequestState {}

class RequestInitial extends RequestState {}

class RequestLoading extends RequestState {}

class RequestSuccess extends RequestState {}

class RequestFailure extends RequestState {
  final String message;
  RequestFailure(this.message);
}

class RequestLoaded extends RequestState {
  final List<MoneyRequest> requests;
  RequestLoaded(this.requests);
}
