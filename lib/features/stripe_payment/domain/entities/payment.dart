class Payment {
  final String paymentId;
  final String userId;
  final double amount;
  final String method;
  final String status;
  final DateTime dateTime;

  Payment({
    required this.paymentId,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    required this.dateTime,
  });

  // convert Payment to Json to store in DB !!
  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'userId': userId,
      'amount': amount,
      'method': method,
      'status': status,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  // convert Json back to Payment to use in app !!
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'],
      userId: json['userId'],
      amount: json['amount'],
      method: json['method'],
      status: json['status'],
      dateTime: DateTime.parse(json['dateTime']),
    );
  }
}
