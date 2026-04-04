import 'package:flowpay/features/notification/presentation/components/noti_btn.dart';
import 'package:flowpay/features/notification/presentation/components/notification_tile.dart';
import 'package:flowpay/features/notification/presentation/cubit/noti_btn_cubit.dart';
import 'package:flowpay/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowpay/features/notification/domain/entities/notification.dart';

import '../cubit/notification_states.dart';

class NotificationPage extends StatefulWidget {
  final String userId;
  const NotificationPage({super.key, required this.userId});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();

    // load notifications when page opens
    Future.microtask(() {
      context.read<NotificationCubit>().getNotifications(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          BlocBuilder<NotificationCubit, NotificationStates>(
            builder: (context, state) {
              int unreadCount = 0;

              if (state is NotificationLoaded) {
                unreadCount =
                    state.notifications.where((n) => !n.isRead).length;
              }

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    'assets/home/notification.png',
                    height: context.hPx(24),
                    width: context.wPx(24),
                  ),

                  // Badge
                  if (unreadCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          context.spaceWPx(14),
        ],
        backgroundColor: const Color(0xffFFFFFF),
      ),
      body: Padding(
        padding: context.padSymmetricPx(horizontal: 25),
        child: Column(
          children: [
            BlocBuilder<NotiBtnCubit, NotiState>(
              builder: (context, btnState) {
                final cubit = context.read<NotiBtnCubit>();
                return Row(
                  children: [
                    NotificationButton(
                      buttonName: 'All',
                      onClick: () => cubit.setFilter(NotiFilter.all),
                      isSelected: btnState.filter == NotiFilter.all,
                      btnColor:
                          btnState.filter == NotiFilter.all
                              ? const Color(0xffDFE5FF)
                              : const Color(0xffFFFFFF),
                    ),
                    context.spaceWPx(10),
                    NotificationButton(
                      buttonName: 'Unread',
                      onClick: () => cubit.setFilter(NotiFilter.unread),
                      isSelected: btnState.filter == NotiFilter.unread,
                      btnColor:
                          btnState.filter == NotiFilter.unread
                              ? const Color(0xffDFE5FF)
                              : const Color(0xffFFFFFF),
                    ),
                  ],
                );
              },
            ),

            context.spaceHPx(10),

            // mark all as read ....
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () async {
                  await context.read<NotificationCubit>().markAllAsRead(
                    widget.userId,
                  );
                },
                child: const Text(
                  'Mark all as read',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff4C6EF5),
                  ),
                ),
              ),
            ),

            context.spaceHPx(10),

            // list of notifications
            Expanded(
              child: BlocBuilder<NotificationCubit, NotificationStates>(
                builder: (context, state) {
                  if (state is NotificationLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is NotificationLoaded) {
                    final notifications = state.notifications;
                    final filter = context.watch<NotiBtnCubit>().state.filter;

                    final filtered =
                        filter == NotiFilter.unread
                            ? notifications.where((n) => !n.isRead).toList()
                            : notifications;

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          'No unread notifications',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final notification = filtered[index];

                        return NotificationTile(
                          notification: notification,
                          onTap:
                              () => _showBeautifulDialog(context, notification),
                        );
                      },
                    );
                  }

                  if (state is NotificationError) {
                    return Center(child: Text(state.message));
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xffFFFFFF),
    );
  }

  // Dialog box : it's used for reading the notification ...
  void _showBeautifulDialog(
    BuildContext parentContext,
    Notifications notification,
  ) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0xffDFE5FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    size: 30,
                    color: Color(0xff4C6EF5),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  notification.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  notification.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff707070),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff4C6EF5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      // Use parentContext
                      await parentContext.read<NotificationCubit>().markAsRead(
                        notification.notificationId,
                        notification.userId,
                      );

                      // Close dialog safely
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text(
                      "Got it",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
