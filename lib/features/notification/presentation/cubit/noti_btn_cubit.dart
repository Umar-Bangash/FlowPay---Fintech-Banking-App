// Notification Buttons: All and Unread
import 'package:flutter_bloc/flutter_bloc.dart';

enum NotiFilter { all, unread }

// Notifications State
class NotiState {
  final NotiFilter filter;
  final int unreadCount;

  const NotiState({required this.filter, required this.unreadCount});

  NotiState copyWith({NotiFilter? filter, int? unreadCount}) {
    return NotiState(
      filter: filter ?? this.filter,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

// Notifications Button Cubit Logic
class NotiBtnCubit extends Cubit<NotiState> {
  NotiBtnCubit() : super(NotiState(filter: NotiFilter.all, unreadCount: 3));

  // filter method
  void setFilter(NotiFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  // unread count
  void updateUnreadCount(int count) {
    emit(state.copyWith(unreadCount: count));
  }
}
