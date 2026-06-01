import 'package:flowpay/features/auth/domain/repo/biometric_auth_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricAuthImpl implements BiometricAuthRepo {
  // ── Direct channel to our native BiometricHelper ──
  // This bypasses local_auth entirely and uses
  // BiometricPrompt with BIOMETRIC_STRONG (fingerprint only)
  static const _channel = MethodChannel('com.example.flow_pay/biometric');

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.write(key: 'email', value: email);
    await _secureStorage.write(key: 'password', value: password);
  }

  @override
  Future<Map<String, String?>> getStoredCredentials() async {
    final email = await _secureStorage.read(key: 'email');
    final password = await _secureStorage.read(key: 'password');
    return {'email': email, 'password': password};
  }

  @override
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: 'email');
    await _secureStorage.delete(key: 'password');
  }

  // ─────────────────────────────────────────────
  // FINGERPRINT ONLY
  // Uses BiometricPrompt with BIOMETRIC_STRONG
  // PIN / pattern / face are NOT accepted
  // User MUST touch the fingerprint sensor
  // ─────────────────────────────────────────────
  @override
  Future<bool> authenticateWithFingerprint() async {
    try {
      debugPrint('=== CALLING NATIVE CHANNEL ===');
      final canAuth =
          await _channel.invokeMethod<bool>('canAuthenticate') ?? false;
      debugPrint('canAuthenticate: $canAuth');
      final result = await _channel.invokeMethod<bool>('authenticate') ?? false;
      debugPrint('Fingerprint result: $result');
      return result;
    } catch (e) {
      debugPrint('=== CHANNEL ERROR: $e ===');
      return false;
    }
  }
}
