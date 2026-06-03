// features/profile_and_setting/presentation/cubit/profile_cubit.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/profile_and_setting/domain/entities/profile_user.dart';
import 'package:flowpay/features/profile_and_setting/domain/repo/profile_repo.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_states.dart';
import 'package:flowpay/features/storage/domain/storage_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit(this.profileRepo, this.storageRepo) : super(ProfileInitial());

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // FETCH PROFILE
  Future<void> fetchProfileUser(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchProfileUser(uid);
      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError('No user found'));
      }
    } catch (e) {
      emit(ProfileError('Failed to fetch user: $e'));
    }
  }

  // UPDATE FULL PROFILE
  Future<void> updateProfileUser(
    ProfileUser updatedUser, {
    File? newImageMobile,
    Uint8List? newImageWeb,
    File? newImage,
  }) async {
    try {
      emit(ProfileLoading());
      String? imageUrl = updatedUser.profileImageUrl;

      if (newImageMobile != null) {
        final uploaded = await storageRepo.uploadProfileImageMobile(
          newImageMobile.path,
          updatedUser.uid,
        );
        if (uploaded != null) imageUrl = uploaded;
      } else if (newImageWeb != null) {
        final uploaded = await storageRepo.uploadProfileImageWeb(
          newImageWeb,
          updatedUser.uid,
        );
        if (uploaded != null) imageUrl = uploaded;
      }

      final updated = updatedUser.copyWith(profileImageUrl: imageUrl);
      await profileRepo.updateProfileUser(updated);

      final refreshed = await profileRepo.fetchProfileUser(updated.uid);
      if (refreshed != null) {
        emit(ProfileLoaded(refreshed));
      } else {
        emit(ProfileError('User update failed'));
      }
    } catch (e) {
      emit(ProfileError('Failed to update profile: $e'));
    }
  }

  // BIOMETRIC TOGGLES
  Future<void> toggleFaceEnabled(bool value) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await profileRepo.updateFaceEnabled(uid, value);
      _updateLocalState((user) => user.copyWith(faceEnabled: value));
    } catch (e) {
      emit(ProfileError('Failed to update Face ID: $e'));
    }
  }

  Future<void> toggleFingerprintEnabled(bool value) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await profileRepo.updateFingerprintEnabled(uid, value);
      _updateLocalState((user) => user.copyWith(fingerprintEnabled: value));
    } catch (e) {
      emit(ProfileError('Failed to update Fingerprint: $e'));
    }
  }

  // NOTIFICATION TOGGLES
  Future<void> togglePaymentNotif(bool value) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await profileRepo.updatePaymentNotif(uid, value);
      _updateLocalState((user) => user.copyWith(paymentNotifEnabled: value));
    } catch (e) {
      emit(ProfileError('Failed to update notification: $e'));
    }
  }

  Future<void> toggleChatNotif(bool value) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await profileRepo.updateChatNotif(uid, value);
      _updateLocalState((user) => user.copyWith(chatNotifEnabled: value));
    } catch (e) {
      emit(ProfileError('Failed to update notification: $e'));
    }
  }

  Future<void> toggleSystemNotif(bool value) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await profileRepo.updateSystemNotif(uid, value);
      _updateLocalState((user) => user.copyWith(systemNotifEnabled: value));
    } catch (e) {
      emit(ProfileError('Failed to update notification: $e'));
    }
  }

  // DEVICE INFO — save current device to Firestore

  Future<void> saveCurrentDeviceInfo() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final deviceInfo = await _getDeviceInfo();
      await profileRepo.saveDeviceInfo(uid, deviceInfo);
      _updateLocalState((user) => user.copyWith(deviceInfo: deviceInfo));
    } catch (e) {
      debugPrint('saveDeviceInfo error: $e');
    }
  }

  Future<void> removeDeviceInfo() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await profileRepo.removeDeviceInfo(uid);
      _updateLocalState((user) => user.copyWith(deviceInfo: ''));
    } catch (e) {
      emit(ProfileError('Failed to remove device: $e'));
    }
  }

  // GET DEVICE INFO STRING
  Future<String> _getDeviceInfo() async {
    final plugin = DeviceInfoPlugin();
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await plugin.iosInfo;
        return '${info.name}|${info.systemName}|${info.model}';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await plugin.androidInfo;
        return '${info.model}|Android|${info.brand}';
      }
      return 'Unknown Device|Unknown OS|Unknown';
    } catch (e) {
      return 'Unknown Device|Unknown OS|Unknown';
    }
  }

  // LOCAL IMAGE PREVIEW
  void setPickedImage(File file) {
    if (state is ProfileLoaded) {
      final user = (state as ProfileLoaded).profileUser;
      emit(ProfileLoaded(user, pickedImage: file));
    }
  }

  void clearPickedImage() {
    if (state is ProfileLoaded) {
      final user = (state as ProfileLoaded).profileUser;
      emit(ProfileLoaded(user, pickedImage: null));
    }
  }

  // HELPER — update local state without Firestore
  void _updateLocalState(ProfileUser Function(ProfileUser) update) {
    if (state is ProfileLoaded) {
      final current = (state as ProfileLoaded).profileUser;
      emit(ProfileLoaded(update(current)));
    }
  }
}
