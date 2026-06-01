import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flowpay/features/notification/data/services/local_notification_service.dart';
import 'package:flutter/material.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._internal();
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService.instance() => _instance;

  Future<void> init({
    required LocalNotificationService localNotificationService,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    // ── Initialize local notifications FIRST ──
    await LocalNotificationService.instance().init();

    // ── Request permission ──
    await _requestPermission();

    // ── iOS foreground display options ──
    // This makes FCM show banner natively on iOS
    // even when app is in foreground
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // ── Token ──
    await _handlePushNotificationToken();

    // ── Background handler ──
    // Register for ALL platforms including iOS
    // Previously was excluded for iOS — that was the bug
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ── Foreground messages ──
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint(
        'FOREGROUND message: title=${message.notification?.title} data=${message.data}',
      );
      await _handleMessage(message);
    });

    // ── App opened via notification tap ──
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _onMessageOpenedApp(message, navigatorKey);
    });

    // ── App was terminated — opened via notification ──
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage, navigatorKey);
    }
  }

  // ─────────────────────────────────────────────
  // REQUEST PERMISSION
  // ─────────────────────────────────────────────
  Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  // ─────────────────────────────────────────────
  // TOKEN
  // ─────────────────────────────────────────────
  Future<void> _handlePushNotificationToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM token: $token');
      FirebaseMessaging.instance.onTokenRefresh.listen((t) {
        debugPrint('FCM token refreshed: $t');
      });
    } catch (e) {
      debugPrint('FCM token error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // HANDLE FOREGROUND MESSAGE
  // ─────────────────────────────────────────────
  static Future<void> _handleMessage(RemoteMessage message) async {
    debugPrint(
      'Handling message: title=${message.notification?.title} type=${message.data['type']}',
    );

    final String? title = message.notification?.title ?? message.data['title'];
    final String? body = message.notification?.body ?? message.data['body'];
    final String? type = message.data['type'];

    if (title == null || body == null) {
      debugPrint('No title/body found — skipping');
      return;
    }

    // QR access always shows — no preference check
    if (_isQrAccessType(type)) {
      debugPrint('Showing QR notification banner: $title');
      await LocalNotificationService.instance().showNotification(
        title,
        body,
        message.data.toString(),
      );
      return;
    }

    // All other types respect user preferences
    final shouldShow = await _shouldShowNotification(type);
    if (!shouldShow) {
      debugPrint('Suppressed by user preference: $type');
      return;
    }

    await LocalNotificationService.instance().showNotification(
      title,
      body,
      message.data.toString(),
    );
  }

  static bool _isQrAccessType(String? type) {
    return type == 'qr_access_request' ||
        type == 'qr_access_accepted' ||
        type == 'qr_access_rejected' ||
        type == 'qr_access_pending' ||
        type == 'qr_access_owner_confirm';
  }

  static Future<bool> _shouldShowNotification(String? type) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return true;

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!doc.exists) return true;
      final data = doc.data()!;

      switch (type) {
        case 'payment':
          return data['paymentNotifEnabled'] ?? true;
        case 'chat':
          return data['chatNotifEnabled'] ?? true;
        case 'system':
          return data['systemNotifEnabled'] ?? false;
        default:
          return true;
      }
    } catch (e) {
      debugPrint('_shouldShowNotification error: $e');
      return true;
    }
  }

  void _onMessageOpenedApp(
    RemoteMessage message,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    debugPrint('App opened from notification: ${message.data}');
    final data = message.data;
    if (data.containsKey('screen')) {
      navigatorKey.currentState?.pushNamed(data['screen'], arguments: data);
    }
  }
}

// ─────────────────────────────────────────────
// BACKGROUND + TERMINATED handler
// Top-level function — required by Firebase
// Registers for ALL platforms including iOS
// ─────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.data}');

  final title = message.notification?.title ?? message.data['title'];
  final body = message.notification?.body ?? message.data['body'];

  if (title == null || body == null) return;

  await LocalNotificationService.instance().init();
  await LocalNotificationService.instance().showNotification(
    title,
    body,
    message.data.toString(),
  );
}
