import 'package:flowpay/features/stripe_payment/data/service/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flowpay/configuration/firebase_options.dart';
import 'package:flowpay/features/notification/data/services/local_notification_service.dart';
import 'package:flowpay/features/notification/data/services/firebase_messaging_service.dart';
import 'package:flowpay/app.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe only for non-web platforms
  if (!kIsWeb) {
    await StripeService.init();
  } else {
    debugPrint('Skipping Stripe initialization for web');
  }

  // Initialize Firebase (works on all platforms)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase (works on all platforms)
  await Supabase.initialize(
    url: 'https://uskkuwbbklcndystdtxi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVza2t1d2Jia2xjbmR5c3RkdHhpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcyNDQwMjUsImV4cCI6MjA3MjgyMDAyNX0.qbg9aPed2pQaVH1lKfPtaY8zrGW5pNHmSboLgQL-Cag',
  );

  // Notification setup (only on mobile)
  if (!kIsWeb) {
    final localNotificationService = LocalNotificationService.instance();
    await localNotificationService.init();

    final firebaseMessagingService = FirebaseMessagingService.instance();
    await firebaseMessagingService.init(
      localNotificationService: localNotificationService,
      navigatorKey: navigatorKey,
    );
  } else {
    debugPrint('Skipping Notification setup for web');
  }

  runApp(FlowPay(navigator: navigatorKey));
}
