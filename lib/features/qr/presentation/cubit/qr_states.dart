import '../../domain/entities/qr_access_request.dart';
import '../../domain/entities/qr_access_token.dart';

abstract class QRStates {}

class QRInitial extends QRStates {}

class QRLoading extends QRStates {}

class QRLoaded extends QRStates {
  final dynamic data;
  QRLoaded(this.data);
}

class QRError extends QRStates {
  final String message;
  QRError(this.message);
}

class QRAccessRequestSent extends QRStates {
  final QrAccessRequest request;
  QRAccessRequestSent(this.request);
}

class QRAccessGranted extends QRStates {
  final String ownerUid;
  final String ownerEmail;
  final String ownerName;
  final String? tempPassword; // ← login directly with this
  QRAccessGranted({
    required this.ownerUid,
    required this.ownerEmail,
    required this.ownerName,
    this.tempPassword,
  });
}

class QRAccessDenied extends QRStates {
  final String ownerName;
  QRAccessDenied({this.ownerName = ''});
}

class QRTokenGenerating extends QRStates {}

class QRTokenGenerated extends QRStates {
  final QrAccessToken token;
  QRTokenGenerated(this.token);
}

class QRTokenValidating extends QRStates {}

class QRTokenValid extends QRStates {
  final String ownerUid;
  QRTokenValid(this.ownerUid);
}

class QRTokenInvalid extends QRStates {
  final String reason;
  QRTokenInvalid(this.reason);
}
