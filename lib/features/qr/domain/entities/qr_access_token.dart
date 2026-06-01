import 'package:cloud_firestore/cloud_firestore.dart';

class QrAccessToken {
  final String tokenId;
  final String ownerUid;
  final DateTime expiresAt;
  final bool used;

  const QrAccessToken({
    required this.tokenId,
    required this.ownerUid,
    required this.expiresAt,
    required this.used,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !used && !isExpired;

  Map<String, dynamic> toJson() => {
    'tokenId': tokenId,
    'ownerUid': ownerUid,
    'expiresAt': Timestamp.fromDate(expiresAt),
    'used': used,
  };

  factory QrAccessToken.fromJson(Map<String, dynamic> json) => QrAccessToken(
    tokenId: json['tokenId'] as String,
    ownerUid: json['ownerUid'] as String,
    expiresAt: (json['expiresAt'] as Timestamp).toDate(),
    used: json['used'] as bool,
  );
}
