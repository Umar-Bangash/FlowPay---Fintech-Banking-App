// features/profile_and_setting/data/profile_repo_impl.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/profile_and_setting/domain/entities/profile_user.dart';
import 'package:flowpay/features/profile_and_setting/domain/repo/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepoImpl implements ProfileRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // ─────────────────────────────────────────────
  // FETCH PROFILE USER
  // ─────────────────────────────────────────────
  @override
  Future<ProfileUser?> fetchProfileUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return ProfileUser.fromJson({...doc.data()!, 'uid': uid});
    } catch (e, stack) {
      debugPrint('PROFILE FETCH ERROR: $e');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // UPDATE FULL PROFILE
  // ─────────────────────────────────────────────
  @override
  Future<void> updateProfileUser(
    ProfileUser updatedProfile, {
    File? newImage,
  }) async {
    try {
      String imageUrl = updatedProfile.profileImageUrl ?? '';

      if (newImage != null) {
        final uploaded = await uploadProfileImage(newImage, updatedProfile.uid);
        if (uploaded != null) imageUrl = uploaded;
      }

      await _firestore.collection('users').doc(updatedProfile.uid).update({
        'name': updatedProfile.name,
        'email': updatedProfile.email,
        'profileImageUrl': imageUrl,
        'biometricEnabled': updatedProfile.biometricEnabled ?? false,
        'deviceInfo': updatedProfile.deviceInfo ?? '',
        'faceEnabled': updatedProfile.faceEnabled ?? false,
        'fingerprintEnabled': updatedProfile.fingerprintEnabled ?? false,
        'paymentNotifEnabled': updatedProfile.paymentNotifEnabled ?? true,
        'chatNotifEnabled': updatedProfile.chatNotifEnabled ?? true,
        'systemNotifEnabled': updatedProfile.systemNotifEnabled ?? false,
      });
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // ─────────────────────────────────────────────
  // UPLOAD PROFILE IMAGE
  // ─────────────────────────────────────────────
  Future<String?> uploadProfileImage(File file, String uid) async {
    try {
      final path = '$uid/profile.png';
      await _supabase.storage.from('profileImages').remove([path]);
      await _supabase.storage
          .from('profileImages')
          .upload(path, file, fileOptions: const FileOptions(upsert: true));
      return _supabase.storage.from('profileImages').getPublicUrl(path);
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  // ─────────────────────────────────────────────
  // BIOMETRIC TOGGLES
  // ─────────────────────────────────────────────
  @override
  Future<void> updateFaceEnabled(String uid, bool value) async {
    await _firestore.collection('users').doc(uid).update({
      'faceEnabled': value,
    });
  }

  @override
  Future<void> updateFingerprintEnabled(String uid, bool value) async {
    await _firestore.collection('users').doc(uid).update({
      'fingerprintEnabled': value,
    });
  }

  // ─────────────────────────────────────────────
  // NOTIFICATION TOGGLES
  // ─────────────────────────────────────────────
  @override
  Future<void> updatePaymentNotif(String uid, bool value) async {
    await _firestore.collection('users').doc(uid).update({
      'paymentNotifEnabled': value,
    });
  }

  @override
  Future<void> updateChatNotif(String uid, bool value) async {
    await _firestore.collection('users').doc(uid).update({
      'chatNotifEnabled': value,
    });
  }

  @override
  Future<void> updateSystemNotif(String uid, bool value) async {
    await _firestore.collection('users').doc(uid).update({
      'systemNotifEnabled': value,
    });
  }

  // ─────────────────────────────────────────────
  // DEVICE MANAGEMENT
  // ─────────────────────────────────────────────
  @override
  Future<void> saveDeviceInfo(String uid, String deviceInfo) async {
    await _firestore.collection('users').doc(uid).update({
      'deviceInfo': deviceInfo,
    });
  }

  @override
  Future<void> removeDeviceInfo(String uid) async {
    await _firestore.collection('users').doc(uid).update({'deviceInfo': ''});
  }
}
