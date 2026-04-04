abstract class BiometricAuthRepo {
  Future<bool> authenticateWithFingerprint();
  Future<bool> authenticateWithFaceId();

  // credential helper used by AuthCubit
  Future<void> saveCredentials(String email, String password);
  Future<Map<String, String?>> getStoredCredentials();
  Future<void> clearCredentials();
}
