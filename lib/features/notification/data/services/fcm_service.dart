import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';

Future<String> getAccessToken() async {
  final accountCredentials = ServiceAccountCredentials.fromJson(
    json.decode(await rootBundle.loadString('assets/service-accounts.json')),
  );

  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  final client = await clientViaServiceAccount(accountCredentials, scopes);
  return (client.credentials.accessToken).data;
}
