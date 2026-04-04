import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flowpay/features/notification/data/services/local_notification_service.dart';

class FirebaseMessagingService {
  // Singleton
  FirebaseMessagingService._internal();
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService.instance() => _instance;

  LocalNotificationService? _localNotificationService;

  /// Initialize Firebase Messaging
  Future<void> init({
    required LocalNotificationService localNotificationService,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    _localNotificationService = localNotificationService;

    // Request permission (iOS only)
    await _requestPermission();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Handle token (Android and iOS)
    _handlePushNotificationToken();

    // Android: Background & terminated messages work
    // iOS: Only foreground messages work without APNs
    if (!Platform.isIOS) {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    }

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // App opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _onMessageOpenedApp(message, navigatorKey);
    });

    // Check initial message if app was terminated
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage, navigatorKey);
    }
  }

  /// Request notification permission (iOS only)
  Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('iOS Permission granted: ${settings.authorizationStatus}');
    }
  }

  /// Handle FCM token
  Future<void> _handlePushNotificationToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM token: $token');

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint('FCM token refreshed: $newToken');
      });
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  // Foreground message handler
  void _onForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.data}');

    final String? title = message.notification?.title ?? message.data['title'];
    final String? body = message.notification?.body ?? message.data['body'];
    final String? type = message.data['type']; // 'payment','chat','system'

    if (title == null || body == null) return;

    // ── Check user notification preference ──
    final shouldShow = await _shouldShowNotification(type);
    if (!shouldShow) {
      debugPrint('Notification blocked by user preference: $type');
      return;
    }

    _localNotificationService?.showNotification(
      title,
      body,
      message.data.toString(),
    );
  }

  // ─────────────────────────────────────────────
  // CHECK notification flag from Firestore
  // ─────────────────────────────────────────────
  Future<bool> _shouldShowNotification(String? type) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return true; // default show if not logged in

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
          return true; // unknown type → show by default
      }
    } catch (e) {
      debugPrint('_shouldShowNotification error: $e');
      return true; // on error → show by default
    }
  }

  /// When app opened from notification
  void _onMessageOpenedApp(
    RemoteMessage message,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    debugPrint('Notification opened app: ${message.data}');
    final data = message.data;
    if (data.containsKey('screen')) {
      final screen = data['screen'];
      navigatorKey.currentState?.pushNamed(screen, arguments: data);
    }
  }
}

// Top-level background message handler (Android only)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.data}');
  await LocalNotificationService.instance().showNotification(
    message.notification?.title,
    message.notification?.body,
    message.data.toString(),
  );
}
