import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/account/domain/entities/account.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final String? fcmToken;
  final DateTime? dob; // Date of Birth
  String? profileImageUrl;
  Account? account;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.dob,
    this.fcmToken,
    this.profileImageUrl,
    this.account,
  });

  // convert app-user to json to store in db
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'fcmToken': fcmToken,
      'profileImageUrl': profileImageUrl,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null, // safer
      'account': account?.toJson(),
    };
  }

  // convert json to app-user to use in app
  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    DateTime? dob;

    if (jsonUser['dob'] != null) {
      final dobValue = jsonUser['dob'];
      if (dobValue is Timestamp) {
        dob = dobValue.toDate();
      } else if (dobValue is String) {
        dob = DateTime.tryParse(dobValue);
      }
    }

    return AppUser(
      uid: jsonUser['uid'] ?? '',
      email: jsonUser['email'] ?? '',
      name: jsonUser['name'] ?? '',
      fcmToken: jsonUser['fcmToken'],
      profileImageUrl: jsonUser['profileImageUrl'],
      dob: dob,
      account:
          jsonUser['account'] != null
              ? Account.fromJson(jsonUser['account'])
              : null,
    );
  }
}
