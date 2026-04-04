/*

Auth States

*/

import 'package:flowpay/features/auth/domain/entities/app_user.dart';

abstract class AuthStates {}

// Initial
class AuthInitial extends AuthStates {}

// Loading
class AuthLoading extends AuthStates {}

// Authenticated
class Authenticated extends AuthStates {
  final AppUser user;
  Authenticated(this.user);
}

// UnAuthenticated
class UnAuthenticated extends AuthStates {}

// Error
class AuthError extends AuthStates {
  final String message;
  AuthError(this.message);
}

// Password Reset
class PasswordResetEmailSent extends AuthStates {
  final String email;
  PasswordResetEmailSent(this.email);
}

// Password Reset Error
class PasswordResetError extends AuthStates {
  final String message;
  PasswordResetError(this.message);
}

// Fingerprint enabled
class AuthFingerPrintEnabled extends AuthStates {}

// Fingerprint Login Falied
class AuthFingerPrintLoginFailed extends AuthStates {}

// User just registered — needs to go through biometrics setup
class FaceSetupRequired extends AuthStates {
  final AppUser user;
  FaceSetupRequired(this.user);
}

// Face Registeration
class FaceRegistrationLoading extends AuthStates {}

class FaceRegistrationSuccess extends AuthStates {}

class FaceRegistrationError extends AuthStates {
  final String message;
  FaceRegistrationError(this.message);
}

// Face Verification
class FaceVerificationLoading extends AuthStates {}

class FaceVerificationSuccess extends AuthStates {}

class FaceVerificationFailed extends AuthStates {}

class FaceVerificationError extends AuthStates {
  final String message;
  FaceVerificationError(this.message);
}
