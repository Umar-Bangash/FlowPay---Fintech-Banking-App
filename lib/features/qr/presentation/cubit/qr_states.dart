abstract class QRStates {}

/// Initial state
class QRInitial extends QRStates {}

/// Loading state (API / Firestore operations)
class QRLoading extends QRStates {}

/// Success state
class QRLoaded extends QRStates {
  final dynamic data;

  QRLoaded(this.data);
}

/// Error state
class QRError extends QRStates {
  final String message;

  QRError(this.message);
}
