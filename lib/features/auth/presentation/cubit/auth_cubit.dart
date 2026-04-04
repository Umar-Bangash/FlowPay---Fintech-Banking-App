import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/auth/domain/entities/app_user.dart';
import 'package:flowpay/features/auth/domain/repo/auth_repo.dart';
import 'package:flowpay/features/auth/domain/repo/biometric_auth_repo.dart';
import 'package:flowpay/features/auth/domain/repo/face_auth_repo.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowpay/features/notification/data/services/save_fcm_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class AuthCubit extends Cubit<AuthStates> {
  final AuthRepo _authRepo;
  final BiometricAuthRepo _biometricAuthRepo;
  final FaceAuthRepo _faceAuthRepo;

  AppUser? _currentUser;

  FaceAuthRepo get faceAuthRepo => _faceAuthRepo;
  BiometricAuthRepo get biometricAuthRepo => _biometricAuthRepo;

  AuthCubit({
    required AuthRepo authRepo,
    required BiometricAuthRepo biometricAuthRepo,
    required FaceAuthRepo faceAuthRepo,
  }) : _authRepo = authRepo,
       _biometricAuthRepo = biometricAuthRepo,
       _faceAuthRepo = faceAuthRepo,
       super(AuthInitial());

  AppUser? get currentUser => _currentUser;

  // ─────────────────────────────────────────────
  // CHECK AUTH SESSION
  // ─────────────────────────────────────────────
  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        await NotificationService.saveUserFcmToken(user.uid);
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError('Error checking auth: $e'));
    }
  }

  // ─────────────────────────────────────────────
  // EMAIL + PASSWORD LOGIN
  // ─────────────────────────────────────────────
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.login(email, password);

      if (user == null) {
        emit(AuthError('Invalid email or password'));
        return;
      }

      _currentUser = user;
      await _biometricAuthRepo.saveCredentials(email, password);
      await NotificationService.saveUserFcmToken(user.uid);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────────
  Future<void> register(
    String name,
    String email,
    String password,
    String dob,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.register(name, email, password, dob);
      if (user != null) {
        _currentUser = user;
        await _biometricAuthRepo.saveCredentials(email, password);
        await NotificationService.saveUserFcmToken(user.uid);

        // emit FaceSetupRequired instead of Authenticated
        // so root FlowPay routes to BiometricsPage first
        emit(FaceSetupRequired(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError('Registration failed: $e'));
    }
  }

  // ─────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authRepo.logout();
      emit(UnAuthenticated());
    } catch (e) {
      emit(AuthError('Logout failed: $e'));
    }
  }

  // ─────────────────────────────────────────────
  // FORGET PASSWORD
  // ─────────────────────────────────────────────
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> forgetPassword(String email) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      emit(PasswordResetEmailSent(email));
      await Future.delayed(const Duration(milliseconds: 300));
      emit(AuthInitial());
    } on FirebaseAuthException catch (e) {
      emit(PasswordResetError(e.message ?? 'Password reset failed'));
    } catch (e) {
      emit(AuthError('Password reset error: $e'));
    }
  }

  // ─────────────────────────────────────────────
  // FINGERPRINT LOGIN (keeping as is)
  // ─────────────────────────────────────────────
  Future<void> loginWithFingerprint() async {
    emit(AuthLoading());
    try {
      final success = await _biometricAuthRepo.authenticateWithFingerprint();
      if (!success) {
        emit(AuthError('Fingerprint authentication failed'));
        return;
      }

      final creds = await _biometricAuthRepo.getStoredCredentials();
      final email = creds['email'];
      final password = creds['password'];

      if (email != null && password != null) {
        await login(email, password);
      } else {
        emit(AuthError('No stored credentials found'));
      }
    } catch (e) {
      emit(AuthError('Fingerprint error: $e'));
    }
  }

  // ─────────────────────────────────────────────
  // FACE REGISTRATION
  // Called from FaceIdSetupPage after camera capture
  // ─────────────────────────────────────────────
  Future<void> registerFaceEmbedding(XFile capturedImage) async {
    emit(FaceRegistrationLoading());
    try {
      // Make sure user is logged in
      final uid = _currentUser?.uid;
      if (uid == null) {
        emit(FaceRegistrationError('User not logged in'));
        return;
      }

      // Read image bytes from captured XFile
      final imageBytes = await capturedImage.readAsBytes();

      // Call repo → API → store in Firestore
      await _faceAuthRepo.registerFaceEmbedding(
        uid: uid,
        imageBytes: imageBytes,
      );

      emit(FaceRegistrationSuccess());
    } catch (e) {
      emit(FaceRegistrationError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // FACE LOGIN
  // Called from Login page face button
  // ─────────────────────────────────────────────
  Future<void> loginWithFace({
    required String uid,
    required XFile capturedImage,
  }) async {
    emit(FaceVerificationLoading());
    try {
      final imageBytes = await capturedImage.readAsBytes();

      final isMatch = await _faceAuthRepo.verifyFace(
        uid: uid,
        imageBytes: imageBytes,
      );

      if (isMatch) {
        // Face matched → now do actual Firebase login with stored credentials
        final creds = await _biometricAuthRepo.getStoredCredentials();
        final email = creds['email'];
        final password = creds['password'];

        if (email != null && password != null) {
          emit(FaceVerificationSuccess());
          // Small delay so UI can show success state
          await Future.delayed(const Duration(milliseconds: 500));
          await login(email, password);
        } else {
          emit(
            AuthError(
              'No stored credentials. Please login with password first.',
            ),
          );
        }
      } else {
        emit(FaceVerificationFailed());
      }
    } catch (e) {
      emit(FaceVerificationError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // FACE VERIFICATION FOR TRANSACTION
  // Called during payment/transfer for extra security
  // ─────────────────────────────────────────────
  Future<void> verifyFaceForTransaction({
    required String uid,
    required XFile capturedImage,
  }) async {
    emit(FaceVerificationLoading());
    try {
      final imageBytes = await capturedImage.readAsBytes();

      final isMatch = await _faceAuthRepo.verifyFace(
        uid: uid,
        imageBytes: imageBytes,
      );

      if (isMatch) {
        emit(FaceVerificationSuccess());
      } else {
        emit(FaceVerificationFailed());
      }
    } catch (e) {
      emit(FaceVerificationError(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // CHECK IF USER HAS FACE REGISTERED
  // Call this on login page to show/hide face login button
  // ─────────────────────────────────────────────
  Future<bool> hasFaceRegistered() async {
    try {
      final uid = _currentUser?.uid;
      if (uid == null) return false;
      return await _faceAuthRepo.hasFaceRegistered(uid);
    } catch (e) {
      return false;
    }
  }

  // In auth_cubit.dart — add this method
  Future<void> markFingerprintEnabled(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fingerprintEnabled': true,
      });
    } catch (e) {
      debugPrint('markFingerprintEnabled error: $e');
    }
  }
}
