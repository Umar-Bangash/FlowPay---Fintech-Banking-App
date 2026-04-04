import 'package:flowpay/features/notification/domain/entities/notification.dart';

abstract class NotificationStates {}

// initial
class NotificationInitial extends NotificationStates {}

// loading
class NotificationLoading extends NotificationStates {}

// loaded
class NotificationLoaded extends NotificationStates {
  final List<Notifications> notifications;

  NotificationLoaded(this.notifications);
}

// success
class NotificationSuccess extends NotificationStates {
  final String message;

  NotificationSuccess(this.message);
}

// error
class NotificationError extends NotificationStates {
  final String message;

  NotificationError(this.message);
}
