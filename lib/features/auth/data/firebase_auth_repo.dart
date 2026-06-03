import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/auth/domain/entities/app_user.dart';
import 'package:flowpay/features/auth/domain/repo/auth_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../notification/data/services/save_fcm_token.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> forgetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    final userDoc =
        await firebaseFirestore.collection('users').doc(firebaseUser.uid).get();
    if (!userDoc.exists) return null;
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      name: userDoc['name'] ?? '',
    );
  }

  @override
  Future<AppUser?> login(String email, password) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('userCredential is $userCredential');

      final userDoc =
          await firebaseFirestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();
      final data = userDoc.data() as Map<String, dynamic>;

      final user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: data['name'] ?? '',
      );

      // Save credentials locally for biometric login
      await _secureStorage.write(key: 'email', value: email);
      await _secureStorage.write(key: 'password', value: password);
      await _secureStorage.write(key: 'uid', value: userCredential.user!.uid);

      // Mark user as online on login
      await firebaseFirestore.collection('users').doc(user.uid).update({
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      await NotificationService.saveUserFcmToken(user.uid);
      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    // Mark offline before signing out
    final uid = firebaseAuth.currentUser?.uid;
    if (uid != null) {
      await firebaseFirestore.collection('users').doc(uid).update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> register(String name, email, password, String dob) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;

      final user = AppUser(uid: uid, email: email, name: name);

      // ── User doc with ALL required fields including presence ──────
      await firebaseFirestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'dob': dob,
        'profileImageUrl': '',
        'biometricEnabled': false,
        'deviceInfo': '',
        'fcmToken': '',
        // Required by PresenceWrapper / tick logic
        'isOnline': true, // new added
        'lastSeen': FieldValue.serverTimestamp(), // ← new added
      });

      await NotificationService.saveUserFcmToken(uid);
      return user;
    } catch (e) {
      throw Exception('Register failed: $e');
    }
  }
}
