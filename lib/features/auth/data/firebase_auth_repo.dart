// Firebase Auth Repo: Implementation of auth_repo

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/auth/domain/entities/app_user.dart';
import 'package:flowpay/features/auth/domain/repo/auth_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../notification/data/services/save_fcm_token.dart';

class FirebaseAuthRepo implements AuthRepo {
  // get firebase auth and Firestore instance
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // get instance of LocalStorage
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override // Forget Password Method: reset password with email !!
  Future<void> forgetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset falied: $e');
    }
  }

  @override // Get current User Method
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    DocumentSnapshot userDoc =
        await firebaseFirestore.collection('users').doc(firebaseUser.uid).get();
    if (!userDoc.exists) {
      return null;
    }
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      name: userDoc['name'] ?? 'name is null',
    );
  }

  @override // Login Method
  Future<AppUser?> login(String email, password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      debugPrint("userCredential is $userCredential");

      DocumentSnapshot userDoc =
          await firebaseFirestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();
      final data = userDoc.data() as Map<String, dynamic>;

      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: data['name'] ?? '',
      );
      // save credential locally for biometric login
      await _secureStorage.write(key: 'email', value: email);
      await _secureStorage.write(key: 'password', value: password);
      await _secureStorage.write(key: 'uid', value: userCredential.user!.uid);

      await NotificationService.saveUserFcmToken(user.uid);

      return user;
    } catch (e) {
      throw Exception('login falied: $e');
    }
  }

  @override // Logout Method
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> register(String name, email, password, String dob) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      // Create AppUser
      AppUser user = AppUser(uid: uid, email: email, name: name);

      // Create complete ProfileUser with defaults
      final profileUser = {
        'uid': uid,
        'name': name,
        'email': email,
        'dob': dob,
        'profileImageUrl': '', // default empty
        'biometricEnabled': false, // default false
        'deviceInfo': '', // will be updated later using device_info_plus
        'fcmToken': '',
      };

      // Store profile user in Firestore
      await firebaseFirestore.collection('users').doc(uid).set(profileUser);
      // save fcm toekn after registeration
      await NotificationService.saveUserFcmToken(uid);
      return user;
    } catch (e) {
      throw Exception('Register failed: $e');
    }
  }
}
