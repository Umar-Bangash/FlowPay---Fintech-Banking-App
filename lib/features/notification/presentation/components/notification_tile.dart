import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/notification.dart';

class NotificationTile extends StatelessWidget {
  final Notifications notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use your entity fields (match your Notification entity)
    final isUnread =
        !notification
            .isRead; // Make sure your Notification entity has isRead field

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          padding: context.padSymmetricPx(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: isUnread ? const Color(0xffF5F7FF) : const Color(0xffFFFFFF),
            border: Border.all(color: const Color(0xffDFDFDF)),
            borderRadius: BorderRadius.circular(21),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: context.hPx(47),
                width: context.wPx(47),
                decoration: BoxDecoration(
                  color:
                      notification.title == 'Money Sent'
                          ? Color(0xffFFE3E4)
                          : Color(0xffDBF2E4),
                  borderRadius: BorderRadius.circular(10.07),
                ),
                child: Padding(
                  padding: context.padAllPx(14),
                  child: Image.asset('assets/home/wallet1.png'),
                ),
              ),

              context.spaceWPx(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 11.57,
                        color: Color(0xff707070),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(notification.dateTime.toString()),
                      style: const TextStyle(
                        fontSize: 11.57,
                        color: Color(0xff707070),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String dateTimeStr) {
    // Assuming your Notification.dateTime is a String in Firestore
    final dateTime = DateTime.tryParse(dateTimeStr) ?? DateTime.now();
    return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
