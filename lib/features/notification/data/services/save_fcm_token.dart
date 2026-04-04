import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static Future<void> saveUserFcmToken(String uid) async {
    try {
      // Get the FCM token
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint("Saving FCM token: $token for user $uid");

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
      }

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        if (newToken.isNotEmpty) {
          debugPrint("Refreshing FCM token: $newToken for user $uid");

          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'fcmToken': newToken,
          }, SetOptions(merge: true));
        }
      });
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }
}
  // static Future<void> saveUserFcmToken(String uid) async {
  //   try {
  //     final token = await FirebaseMessaging.instance.getToken();
  //     if (token != null && token.isNotEmpty) {
  //       await FirebaseFirestore.instance.collection('users').doc(uid).set({
  //         'fcmToken': token,
  //       }, SetOptions(merge: true));
  //     }

  //     // keep token updated when it refreshes
  //     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
  //       if (newToken.isNotEmpty) {
  //         await FirebaseFirestore.instance.collection('users').doc(uid).set({
  //           'fcmToken': newToken,
  //         }, SetOptions(merge: true));
  //       }
  //     });
  //   } catch (e) {
  //     debugPrint('Failed to save FCM token: $e');
  //   }
  // }

