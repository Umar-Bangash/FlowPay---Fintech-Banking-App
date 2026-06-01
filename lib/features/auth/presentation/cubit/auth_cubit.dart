import 'dart:convert';
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
import 'package:http/http.dart' as http;
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
  // LOGIN WITH ID TOKEN
  // B calls this after owner accepts
  // Uses Firebase REST API to exchange ID token
  // for a fresh session — no password needed
  // ─────────────────────────────────────────────
  Future<void> loginWithIdToken({
    required String ownerIdToken,
    required String ownerUid,
    required String ownerEmail,
  }) async {
    emit(AuthLoading());
    try {
      // Sign out any current session (anonymous)
      await FirebaseAuth.instance.signOut();

      // Exchange ID token via Firebase REST API
      // This signs in as the token's owner
      const apiKey = 'YOUR_FIREBASE_WEB_API_KEY'; // ← replace this

      final response = await http.post(
        Uri.parse(
          'https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=$apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': ownerIdToken, 'returnSecureToken': true}),
      );

      if (response.statusCode == 200) {
        // REST sign-in succeeded
        // Now get current Firebase user
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final doc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .get();

          final appUser = AppUser(
            uid: currentUser.uid,
            email: ownerEmail,
            name: doc.data()?['name'] ?? '',
          );

          _currentUser = appUser;
          await NotificationService.saveUserFcmToken(appUser.uid);
          emit(Authenticated(appUser));
          return;
        }
      }

      debugPrint(
        'loginWithIdToken REST response: ${response.statusCode} ${response.body}',
      );

      // Fallback: if REST exchange fails, try
      // signInWithCredential using the ID token
      GoogleAuthProvider.credential(idToken: ownerIdToken);
      // Note: ID token from Firebase Auth is NOT a Google token
      // so we use a different approach below

      // Direct approach: since we have the owner's uid
      // and they're currently authenticated on their device
      // we use the ID token to verify and create a session
      // via custom token exchange
      emit(AuthError('Authentication failed. Please try again.'));
    } catch (e) {
      debugPrint('loginWithIdToken error: $e');
      emit(AuthError('Failed to authenticate: $e'));
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
        emit(FaceSetupRequired(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError('Registration failed: $e'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authRepo.logout();
      emit(UnAuthenticated());
    } catch (e) {
      emit(AuthError('Logout failed: $e'));
    }
  }

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

  Future<void> registerFaceEmbedding(XFile capturedImage) async {
    emit(FaceRegistrationLoading());
    try {
      final uid = _currentUser?.uid;
      if (uid == null) {
        emit(FaceRegistrationError('User not logged in'));
        return;
      }
      final imageBytes = await capturedImage.readAsBytes();
      await _faceAuthRepo.registerFaceEmbedding(
        uid: uid,
        imageBytes: imageBytes,
      );
      emit(FaceRegistrationSuccess());
    } catch (e) {
      emit(FaceRegistrationError(e.toString()));
    }
  }

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
        emit(FaceVerificationSuccess());
        final creds = await _biometricAuthRepo.getStoredCredentials();
        final email = creds['email'];
        final password = creds['password'];

        if (email != null && password != null) {
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

  Future<bool> hasFaceRegistered() async {
    try {
      final uid = _currentUser?.uid;
      if (uid == null) return false;
      return await _faceAuthRepo.hasFaceRegistered(uid);
    } catch (e) {
      return false;
    }
  }

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
