import 'package:flowpay/features/auth/domain/repo/biometric_auth_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthImpl implements BiometricAuthRepo {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Store email + password securely after successful login
  @override
  Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.write(key: 'email', value: email);
    await _secureStorage.write(key: 'password', value: password);
  }

  // Retrieve stored credentials
  @override
  Future<Map<String, String?>> getStoredCredentials() async {
    final email = await _secureStorage.read(key: 'email');
    final password = await _secureStorage.read(key: 'password');
    return {'email': email, 'password': password};
  }

  // Clear stored credentials on logout
  @override
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: 'email');
    await _secureStorage.delete(key: 'password');
  }

  @override
  Future<bool> authenticateWithFingerprint() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!isSupported || !canCheck) return false;

      final available = await _localAuth.getAvailableBiometrics();
      if (!available.contains(BiometricType.fingerprint)) {
        debugPrint('Fingerprint not available on this device');
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Use your fingerprint to log in securely',
        /* options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),*/
      );
    } catch (e) {
      debugPrint('Fingerprint authentication error: $e');
      return false;
    }
  }

  @override
  Future<bool> authenticateWithFaceId() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!isSupported || !canCheck) return false;

      final available = await _localAuth.getAvailableBiometrics();
      if (!available.contains(BiometricType.face)) {
        debugPrint('Face ID not available on this device');
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate using Face ID',
        /* options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),*/
      );
    } catch (e) {
      debugPrint('Face ID authentication error: $e');
      return false;
    }
  }
}
