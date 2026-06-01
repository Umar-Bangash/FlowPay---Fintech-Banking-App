import 'package:flowpay/features/notification/presentation/components/notification_tile.dart';
import 'package:flowpay/features/notification/presentation/cubit/noti_btn_cubit.dart';
import 'package:flowpay/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:flowpay/features/notification/presentation/cubit/notification_states.dart';
import 'package:flowpay/features/qr/presentation/cubit/qr_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowpay/features/notification/domain/entities/notification.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';

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
    Future.microtask(
      () => context.read<NotificationCubit>().getNotifications(widget.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: AppResponsive.fs(16),
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          // Notification bell with badge
          BlocBuilder<NotificationCubit, NotificationStates>(
            builder: (context, state) {
              final unread =
                  state is NotificationLoaded
                      ? state.notifications.where((n) => !n.isRead).length
                      : 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/home/notification.png',
                      height: AppResponsive.sp(22),
                      width: AppResponsive.sp(22),
                    ),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: AppResponsive.sp(15),
                          minHeight: AppResponsive.sp(15),
                        ),
                        child: Center(
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppResponsive.fs(8),
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
          SizedBox(width: AppResponsive.w(14)),
        ],
      ),

      body: AppAnimatedPage(
        direction: SlideDirection.bottom,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
          child: Column(
            children: [
              SizedBox(height: AppResponsive.h(12)),

              // ── Filter buttons ─────────────────────────────────────────
              AppAnimatedItem(
                index: 0,
                direction: SlideDirection.left,
                child: BlocBuilder<NotiBtnCubit, NotiState>(
                  builder: (context, btnState) {
                    final cubit = context.read<NotiBtnCubit>();
                    return Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: btnState.filter == NotiFilter.all,
                          onTap: () => cubit.setFilter(NotiFilter.all),
                        ),
                        SizedBox(width: AppResponsive.w(10)),
                        _FilterChip(
                          label: 'Unread',
                          selected: btnState.filter == NotiFilter.unread,
                          onTap: () => cubit.setFilter(NotiFilter.unread),
                        ),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(height: AppResponsive.h(10)),

              // ── Mark all as read ───────────────────────────────────────
              AppAnimatedItem(
                index: 1,
                direction: SlideDirection.right,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap:
                        () => context.read<NotificationCubit>().markAllAsRead(
                          widget.userId,
                        ),
                    child: Text(
                      'Mark all as read',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(12),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff4C6EF5),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppResponsive.h(10)),

              // ── Notifications list ─────────────────────────────────────
              Expanded(
                child: BlocBuilder<NotificationCubit, NotificationStates>(
                  builder: (context, state) {
                    if (state is NotificationLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is NotificationLoaded) {
                      final filter = context.watch<NotiBtnCubit>().state.filter;
                      final items =
                          filter == NotiFilter.unread
                              ? state.notifications
                                  .where((n) => !n.isRead)
                                  .toList()
                              : state.notifications;

                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            'No notifications',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: AppResponsive.fs(14),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final notif = items[i];
                          return AppAnimatedItem(
                            index: i,
                            direction:
                                i.isEven
                                    ? SlideDirection.left
                                    : SlideDirection.right,
                            child: NotificationTile(
                              notification: notif,
                              onTap: () {
                                if (notif.type == 'qr_access_request') {
                                  _showQrDialog(context, notif);
                                } else {
                                  _showReadDialog(context, notif);
                                }
                              },
                            ),
                          );
                        },
                      );
                    }

                    if (state is NotificationError) {
                      return Center(child: Text(state.message));
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── QR access request dialog ──────────────────────────────────────────────
  void _showQrDialog(BuildContext pCtx, Notifications notif) {
    final requestId = notif.data?['requestId'] as String? ?? '';
    final requesterName = notif.data?['requesterName'] as String? ?? 'Someone';

    if (requestId.isEmpty) {
      pCtx.read<NotificationCubit>().markAsRead(
        notif.notificationId,
        widget.userId,
      );
      return;
    }

    showDialog(
      context: pCtx,
      barrierDismissible: false,
      builder: (dCtx) {
        bool responding = false;
        return StatefulBuilder(
          builder: (ctx, setDS) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
              ),
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(
                horizontal: AppResponsive.w(24),
                vertical: AppResponsive.h(40),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppResponsive.w(24),
                  vertical: AppResponsive.h(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      padding: EdgeInsets.all(AppResponsive.sp(13)),
                      decoration: const BoxDecoration(
                        color: Color(0xffFFF3CD),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.qr_code_scanner,
                        size: AppResponsive.sp(28),
                        color: const Color(0xff856404),
                      ),
                    ),

                    SizedBox(height: AppResponsive.h(16)),

                    Text(
                      'Account Access Request',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppResponsive.fs(17),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: AppResponsive.h(10)),

                    Text(
                      '$requesterName wants to access your account.\n'
                      'Do you want to allow this?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppResponsive.fs(13),
                        color: const Color(0xff707070),
                      ),
                    ),

                    SizedBox(height: AppResponsive.h(22)),

                    responding
                        ? const CircularProgressIndicator(
                          color: Color(0xff007AFF),
                        )
                        : Row(
                          children: [
                            // Reject
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppResponsive.radiusMd,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppResponsive.h(13),
                                  ),
                                ),
                                onPressed: () async {
                                  setDS(() => responding = true);
                                  await pCtx
                                      .read<QRCubit>()
                                      .respondToAccessRequest(
                                        requestId: requestId,
                                        status: 'rejected',
                                      );
                                  await pCtx
                                      .read<NotificationCubit>()
                                      .markAsRead(
                                        notif.notificationId,
                                        widget.userId,
                                      );
                                  if (dCtx.mounted) Navigator.of(dCtx).pop();
                                },
                                child: Text(
                                  'Reject',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppResponsive.fs(13),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: AppResponsive.w(10)),

                            // Accept
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff34C759),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppResponsive.radiusMd,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppResponsive.h(13),
                                  ),
                                ),
                                onPressed: () async {
                                  setDS(() => responding = true);
                                  await pCtx
                                      .read<QRCubit>()
                                      .respondToAccessRequest(
                                        requestId: requestId,
                                        status: 'accepted',
                                      );
                                  await pCtx
                                      .read<NotificationCubit>()
                                      .markAsRead(
                                        notif.notificationId,
                                        widget.userId,
                                      );
                                  if (dCtx.mounted) Navigator.of(dCtx).pop();
                                },
                                child: Text(
                                  'Accept',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppResponsive.fs(13),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Standard read dialog ──────────────────────────────────────────────────
  void _showReadDialog(BuildContext pCtx, Notifications notif) {
    showDialog(
      context: pCtx,
      builder:
          (dCtx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
            ),
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(
              horizontal: AppResponsive.w(24),
              vertical: AppResponsive.h(40),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppResponsive.w(24),
                vertical: AppResponsive.h(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppResponsive.sp(13)),
                    decoration: const BoxDecoration(
                      color: Color(0xffDFE5FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      size: AppResponsive.sp(28),
                      color: const Color(0xff4C6EF5),
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(16)),

                  Text(
                    notif.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppResponsive.fs(17),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(10)),

                  Text(
                    notif.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppResponsive.fs(13),
                      color: const Color(0xff707070),
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(22)),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4C6EF5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppResponsive.radiusMd,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: AppResponsive.h(13),
                        ),
                      ),
                      onPressed: () async {
                        await pCtx.read<NotificationCubit>().markAsRead(
                          notif.notificationId,
                          widget.userId,
                        );
                        if (dCtx.mounted) Navigator.of(dCtx).pop();
                      },
                      child: Text(
                        'Got it',
                        style: TextStyle(
                          fontSize: AppResponsive.fs(13),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

// ── Reusable filter chip ──────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.w(16),
        vertical: AppResponsive.h(8),
      ),
      decoration: BoxDecoration(
        color: selected ? const Color(0xffDFE5FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? const Color(0xff4C6EF5) : const Color(0xffE0E0E0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppResponsive.fs(13),
          fontWeight: FontWeight.w500,
          color: selected ? const Color(0xff4C6EF5) : const Color(0xff737373),
        ),
      ),
    ),
  );
}
