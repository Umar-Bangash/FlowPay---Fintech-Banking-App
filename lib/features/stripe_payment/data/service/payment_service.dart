import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flowpay/features/notification/data/services/local_notification_service.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stripe keys (Test / Sandbox mode)
  static const String _publishableKey =
      'pk_test_51S3yNrPXLTibCPm7qUsqYj43qlDVDoWY0ykiK0LK7VdGmXXdWKwtMPdAXwIlK0E52AbkuCD1nDRk3SlOaKl5jEtE00uC0skXkA';
  static const String _secretKey =
      'sk_test_51S3yNrPXLTibCPm75wU0CRDSuzAnoIClaBXYpeVsJHq07Y8jrDKfL50uC5eGetr39z7n9QMDpfB9J4WGIZzgY45T00Ifs5PXGn';

  /// Initialize Stripe (mobile only)
  static Future<void> init() async {
    if (kIsWeb) {
      debugPrint("Stripe not initialized: running on Web");
      return;
    }
    try {
      Stripe.publishableKey = _publishableKey;
      await Stripe.instance.applySettings();
      debugPrint("Stripe initialized successfully.");
    } catch (e) {
      debugPrint("Stripe initialization error: $e");
    }
  }

  /// Create Stripe PaymentIntent and return clientSecret
  Future<String?> _createPaymentIntent(double amount, String currency) async {
    try {
      final url = Uri.parse("https://api.stripe.com/v1/payment_intents");
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $_secretKey",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "amount": (amount * 100).toInt().toString(), // Stripe needs cents
          "currency": currency,
        },
      );

      final body = json.decode(response.body);

      if (body['error'] != null) {
        debugPrint("Stripe intent error: ${body['error']['message']}");
        return null;
      }

      return body['client_secret'];
    } catch (e) {
      debugPrint("Stripe payment intent error: $e");
      return null;
    }
  }

  /// Main payment method — deposit money via Stripe into user's FlowPay wallet
  Future<void> makePaymentAndDeposit({required double amount}) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("User not logged in.");

      final senderUserId = currentUser.uid;

      //Step 1: Find user's account by userId only (no accountType filter)
      final accountQuery =
          await _firestore
              .collection('accounts')
              .where('userId', isEqualTo: senderUserId)
              .limit(1)
              .get();

      if (accountQuery.docs.isEmpty) {
        throw Exception("No account found for this user.");
      }

      final accountDoc = accountQuery.docs.first;
      final accountDocId = accountDoc.id;
      final currentBalance = (accountDoc['balance'] as num).toDouble();

      debugPrint("Found account: $accountDocId, balance: $currentBalance");

      // Step 2: Create Stripe PaymentIntent
      String? clientSecret;

      if (!kIsWeb) {
        // Convert PKR → USD
        double usdAmount = amount / 280;

        debugPrint("PKR: $amount → USD: $usdAmount");

        clientSecret = await _createPaymentIntent(usdAmount, 'usd');

        if (clientSecret == null) {
          throw Exception(
            "Failed to create Stripe payment intent. Check your Stripe keys.",
          );
        }

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'FlowPay',
          ),
        );

        await Stripe.instance.presentPaymentSheet();
      } else {
        // Web: simulate success
        debugPrint("Simulating Stripe payment for Web platform...");
        await Future.delayed(const Duration(seconds: 1));
      }

      // Step 4: Deduct amount from balance (payment)
      if (currentBalance < amount) {
        throw Exception("Insufficient balance.");
      }

      await _firestore.collection('accounts').doc(accountDocId).update({
        'balance': currentBalance - amount,
      });

      // Step 5: Store payment record in Firestore
      final paymentId = _firestore.collection('payments').doc().id;
      await _firestore.collection('payments').doc(paymentId).set({
        'paymentId': paymentId,
        'userId': senderUserId,
        'accountId': accountDocId,
        'amount': amount,
        'method': kIsWeb ? 'Simulated (Web)' : 'Stripe',
        'status': 'Completed',
        'dateTime': DateTime.now().toIso8601String(),
        'description': 'Payment via Stripe',
      });

      // Step 6: Store notification in Firestore
      final notificationId = _firestore.collection('notifications').doc().id;
      await _firestore.collection('notifications').doc(notificationId).set({
        'notificationId': notificationId,
        'userId': senderUserId,
        'title': 'Deposit Successful',
        'message':
            'Rs. ${amount.toStringAsFixed(2)} has been deducted from your FlowPay wallet via Stripe.',
        'dateTime': DateTime.now(),
        'type': 'payment',
        'read': false,
      });

      // Step 7: Show local push notification
      if (!kIsWeb) {
        LocalNotificationService.instance().showNotification(
          "Deposit Successful 💰",
          "Rs. ${amount.toStringAsFixed(2)} added to your FlowPay wallet.",
          null,
        );
      }

      debugPrint("Payment and deposit completed successfully.");
    } catch (e) {
      debugPrint("StripeService -> makePaymentAndDeposit Error: $e");
      rethrow; // Let PaymentPage handle it
    }
  }
}
