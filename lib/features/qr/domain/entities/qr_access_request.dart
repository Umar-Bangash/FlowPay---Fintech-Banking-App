import 'package:cloud_firestore/cloud_firestore.dart';

class QrAccessRequest {
  final String requestId;
  final String requesterId;
  final String ownerId;
  final String ownerEmail;
  final String ownerName;
  final String requesterName;
  final String status;
  final DateTime createdAt;
  final String? tempPassword;
  final String? tempEmail;

  const QrAccessRequest({
    required this.requestId,
    required this.requesterId,
    required this.ownerId,
    required this.ownerEmail,
    required this.ownerName,
    required this.requesterName,
    required this.status,
    required this.createdAt,
    this.tempPassword,
    this.tempEmail,
  });

  QrAccessRequest copyWith({String? status}) => QrAccessRequest(
    requestId: requestId,
    requesterId: requesterId,
    ownerId: ownerId,
    ownerEmail: ownerEmail,
    ownerName: ownerName,
    requesterName: requesterName,
    status: status ?? this.status,
    createdAt: createdAt,
    tempPassword: tempPassword,
    tempEmail: tempEmail,
  );

  Map<String, dynamic> toJson() => {
    'requestId': requestId,
    'requesterId': requesterId,
    'ownerId': ownerId,
    'ownerEmail': ownerEmail,
    'ownerName': ownerName,
    'requesterName': requesterName,
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory QrAccessRequest.fromJson(Map<String, dynamic> json) =>
      QrAccessRequest(
        requestId: json['requestId'] as String,
        requesterId: json['requesterId'] as String,
        ownerId: json['ownerId'] as String,
        ownerEmail: json['ownerEmail'] as String? ?? '',
        ownerName: json['ownerName'] as String? ?? '',
        requesterName: json['requesterName'] as String,
        status: json['status'] as String,
        createdAt: (json['createdAt'] as Timestamp).toDate(),
        tempPassword: json['tempPassword'] as String?,
        tempEmail: json['tempEmail'] as String?,
      );
}
