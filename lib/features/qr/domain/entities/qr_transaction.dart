class QrTransaction {
  final String senderId;
  final String receiverId;
  final double amount;
  final String status;
  final DateTime dateTime;

  const QrTransaction({
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.status,
    required this.dateTime,
  });

  /// Convert object → Map (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'status': status,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  /// Convert Map → Object
  factory QrTransaction.fromJson(Map<String, dynamic> json) {
    return QrTransaction(
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      dateTime: DateTime.parse(json['dateTime']),
    );
  }
}
