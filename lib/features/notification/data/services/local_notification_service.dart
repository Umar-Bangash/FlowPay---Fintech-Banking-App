import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//  Top-level background handler (MUST be outside class)
@pragma('vm:entry-point') // fixed typo: "entey-point" → "entry-point"
void onNotificationTapBackground(NotificationResponse response) {
  debugPrint('Background notification tapped: ${response.payload}');
}

class LocalNotificationService {
  // Private constructor for singleton pattern
  LocalNotificationService._internal();

  // Singletone instance
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();

  // Factory constructor to return singleton instance
  factory LocalNotificationService.instance() => _instance;

  // Main plugin instance for handling notification
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  // Android specific initilization settings using app launcher icon
  final _androidInitializationSettings = const AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  // iOS specific initialization settings with permission request
  final _iosInitializationSettings = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // Android notification channel configuration
  final _androidChannel = AndroidNotificationChannel(
    'Channel_id',
    'Channel name',
    description: 'Android Push Notification channel',
    importance: Importance.max,
  );

  // Flag to track initialization status
  bool _isFlutterLocalNotificationInitialized = false;

  // Counter for generating unique notification ids
  int _notificationCounter = 0;

  // Initializes the flutter notifications plugin for (Android and iOS)
  Future<void> init() async {
    // check if already initialized to prevent redundant setup
    if (_isFlutterLocalNotificationInitialized) return;

    // create plugin instance
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // combine platform-specific settings
    final initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
      iOS: _iosInitializationSettings,
    );

    // Foreground can use inline closure
    // Background MUST use top-level handler (fixed here)
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Foreground Notification tapped: ${response.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: onNotificationTapBackground,
    );

    // Create Android Notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    // Mark initialization as complete
    _isFlutterLocalNotificationInitialized = true;
  }

  // Show a localnotification with given title , body and payload
  Future<void> showNotification(
    String? title,
    String? body,
    String? payload,
  ) async {
    // Debug print to confirm function is called
    debugPrint(
      'showNotification called! Title: $title, Body: $body, Payload: $payload',
    );

    // Android specific notification details
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    // iOS specific notification details
    const iosDetails = DarwinNotificationDetails();

    // combine platform specific detail
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Display the Notification
    await _flutterLocalNotificationsPlugin.show(
      _notificationCounter++, // as ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
