import 'package:flowpay/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String? profileImageUrl;
  final bool? biometricEnabled;
  final String? deviceInfo;

  // ── Biometric flags ──
  final bool? faceEnabled;
  final bool? fingerprintEnabled;

  // ── Notification flags ──
  final bool? paymentNotifEnabled;
  final bool? chatNotifEnabled;
  final bool? systemNotifEnabled;

  ProfileUser({
    required super.uid,
    required super.name,
    required super.email,
    this.profileImageUrl,
    this.biometricEnabled,
    this.deviceInfo,
    this.faceEnabled,
    this.fingerprintEnabled,
    this.paymentNotifEnabled,
    this.chatNotifEnabled,
    this.systemNotifEnabled,
  });

  ProfileUser copyWith({
    String? profileImageUrl,
    bool? biometricEnabled,
    String? deviceInfo,
    bool? faceEnabled,
    bool? fingerprintEnabled,
    bool? paymentNotifEnabled,
    bool? chatNotifEnabled,
    bool? systemNotifEnabled,
  }) {
    return ProfileUser(
      uid: uid,
      name: name,
      email: email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      faceEnabled: faceEnabled ?? this.faceEnabled,
      fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
      paymentNotifEnabled: paymentNotifEnabled ?? this.paymentNotifEnabled,
      chatNotifEnabled: chatNotifEnabled ?? this.chatNotifEnabled,
      systemNotifEnabled: systemNotifEnabled ?? this.systemNotifEnabled,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'biometricEnabled': biometricEnabled,
      'deviceInfo': deviceInfo,
      'faceEnabled': faceEnabled,
      'fingerprintEnabled': fingerprintEnabled,
      'paymentNotifEnabled': paymentNotifEnabled,
      'chatNotifEnabled': chatNotifEnabled,
      'systemNotifEnabled': systemNotifEnabled,
    };
  }

  @override
  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      biometricEnabled: json['biometricEnabled'] ?? false,
      deviceInfo: json['deviceInfo'],
      faceEnabled: json['faceEnabled'] ?? false,
      fingerprintEnabled: json['fingerprintEnabled'] ?? false,
      paymentNotifEnabled: json['paymentNotifEnabled'] ?? true,
      chatNotifEnabled: json['chatNotifEnabled'] ?? true,
      systemNotifEnabled: json['systemNotifEnabled'] ?? false,
    );
  }
}
