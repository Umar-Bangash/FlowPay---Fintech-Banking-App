// features/profile_and_setting/domain/repo/profile_repo.dart

import 'dart:io';
import 'package:flowpay/features/profile_and_setting/domain/entities/profile_user.dart';

abstract class ProfileRepo {
  Future<ProfileUser?> fetchProfileUser(String uid);
  Future<void> updateProfileUser(ProfileUser updateProfile, {File? newImage});

  // ── Biometric toggles ──
  Future<void> updateFaceEnabled(String uid, bool value);
  Future<void> updateFingerprintEnabled(String uid, bool value);

  // ── Notification toggles ──
  Future<void> updatePaymentNotif(String uid, bool value);
  Future<void> updateChatNotif(String uid, bool value);
  Future<void> updateSystemNotif(String uid, bool value);

  // ── Device management ──
  Future<void> saveDeviceInfo(String uid, String deviceInfo);
  Future<void> removeDeviceInfo(String uid);
}
