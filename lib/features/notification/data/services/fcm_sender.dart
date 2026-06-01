import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class FcmSender {
  static const String _fcmUrl =
      'https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send';

  // ─────────────────────────────────────────────
  // Get OAuth2 access token from service account
  // ─────────────────────────────────────────────
  static Future<String?> _getAccessToken() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/service-accounts.json',
      );
      final accountCredentials = ServiceAccountCredentials.fromJson(
        json.decode(jsonString),
      );
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await clientViaServiceAccount(accountCredentials, scopes);
      final token = client.credentials.accessToken.data;
      client.close();
      return token;
    } catch (e) {
      debugPrint('FcmSender._getAccessToken error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // Send push notification to a user by uid
  // ─────────────────────────────────────────────
  static Future<void> sendToUser({
    required String uid,
    required String title,
    required String body,
    Map<String, String> data = const {},
  }) async {
    try {
      debugPrint('FcmSender: sending to uid=$uid title=$title');

      // 1. Get FCM token from Firestore
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!doc.exists) {
        debugPrint('FcmSender: user doc not found for uid=$uid');
        return;
      }

      final fcmToken = doc.data()?['fcmToken'] as String?;
      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('FcmSender: no FCM token for uid=$uid');
        return;
      }

      debugPrint('FcmSender: fcmToken=$fcmToken');

      // 2. Get OAuth access token
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        debugPrint('FcmSender: failed to get access token');
        return;
      }

      // 3. Build payload
      final payload = {
        'message': {
          'token': fcmToken,
          'notification': {'title': title, 'body': body},
          'data': {...data, 'title': title, 'body': body},
          'android': {
            'priority': 'high',
            'notification': {
              'sound': 'default',
              'priority': 'high',
              'channel_id': 'Channel_id',
            },
          },
          'apns': {
            'headers': {'apns-priority': '10'},
            'payload': {
              'aps': {
                'alert': {'title': title, 'body': body},
                'sound': 'default',
                'badge': 1,
                'content-available': 1,
              },
            },
          },
        },
      };

      // 4. Send
      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      debugPrint('FcmSender: response ${response.statusCode} ${response.body}');
    } catch (e) {
      debugPrint('FcmSender.sendToUser error: $e');
    }
  }
}
