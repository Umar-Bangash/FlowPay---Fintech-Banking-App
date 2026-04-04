import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowpay/features/notification/domain/repo/notification_repo.dart';
import 'package:flowpay/features/notification/presentation/cubit/notification_states.dart';

import '../../domain/entities/notification.dart';

class NotificationCubit extends Cubit<NotificationStates> {
  final NotificationRepo notificationRepo;
  StreamSubscription? _notiSub;

  NotificationCubit(this.notificationRepo) : super(NotificationInitial());

  // real time notification listener
  void listenToNotifications(String userId) {
    emit(NotificationLoading());

    _notiSub?.cancel();

    _notiSub = notificationRepo.streamNotifications(userId).listen((
      notifications,
    ) {
      emit(NotificationLoaded(notifications));
    });
  }

  /// Fetch notifications from repo
  Future<void> getNotifications(String userId) async {
    try {
      emit(NotificationLoading());
      final notifications = await notificationRepo.getNotification(userId);
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Mark a single notification as read (persist & refresh)
  Future<void> markAsRead(String notificationId, String userId) async {
    try {
      await notificationRepo.markAsRead(notificationId);
      // Refresh canonical state from repo
      await getNotifications(userId);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Mark all notifications as read for user (persist & refresh)
  Future<void> markAllAsRead(String userId) async {
    try {
      await notificationRepo.markAllAsRead(userId);
      await getNotifications(userId);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Delete a notification (persist & refresh)
  Future<void> deleteNotification(String notificationId, String userId) async {
    try {
      await notificationRepo.deleteNotification(notificationId);
      await getNotifications(userId);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Keep for compatibility if used elsewhere: clear local badge view only.
  /// Prefer using markAllAsRead to persist change.
  void clearBadgeLocally() {
    if (state is NotificationLoaded) {
      final current = (state as NotificationLoaded).notifications;
      // mark all read locally without touching backend
      final updated =
          current
              .map(
                (n) => Notifications(
                  notificationId: n.notificationId,
                  userId: n.userId,
                  title: n.title,
                  message: n.message,
                  dateTime: n.dateTime,
                  type: n.type,
                  isRead: true,
                ),
              )
              .toList();
      emit(NotificationLoaded(updated));
    }
  }

  @override
  Future<void> close() {
    _notiSub?.cancel();
    return super.close();
  }
}
