abstract class BiometricAuthRepo {
  Future<bool> authenticateWithFingerprint();

  // credential helper used by AuthCubit
  Future<void> saveCredentials(String email, String password);
  Future<Map<String, String?>> getStoredCredentials();
  Future<void> clearCredentials();
}
