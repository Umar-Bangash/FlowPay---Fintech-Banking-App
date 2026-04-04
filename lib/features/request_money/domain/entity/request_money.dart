enum RequestStatus { pending, accepted, paid, declined }

class MoneyRequest {
  final String requestId;
  final String requesterId;
  final String receiverId;
  final double amount;
  final String? note;
  final DateTime? returnDate;
  final RequestStatus status;
  final DateTime createdAt;

  const MoneyRequest({
    required this.requestId,
    required this.requesterId,
    required this.receiverId,
    required this.amount,
    this.note,
    this.returnDate,
    required this.status,
    required this.createdAt,
  });

  MoneyRequest copyWith({
    String? requestId,
    String? requesterId,
    String? receiverId,
    double? amount,
    String? note,
    DateTime? returnDate,
    RequestStatus? status,
    DateTime? createdAt,
  }) {
    return MoneyRequest(
      requestId: requestId ?? this.requestId,
      requesterId: requesterId ?? this.requesterId,
      receiverId: receiverId ?? this.receiverId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // convert request_money object -> json store in DB
  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'requesterId': requesterId,
      'receiverId': receiverId,
      'amount': amount,
      'note': note,
      'returnDate': returnDate?.toIso8601String(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // conver json -> request_money to use in app
  factory MoneyRequest.fromJson(Map<String, dynamic> json) {
    return MoneyRequest(
      requestId: json['requestId'],
      requesterId: json['requesterId'],
      receiverId: json['receiverId'],
      amount: (json['amount'] as num).toDouble(),
      note: json['note'],
      returnDate:
          json['returnDate'] != null
              ? DateTime.parse(json['returnDate'])
              : null,
      status: RequestStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
