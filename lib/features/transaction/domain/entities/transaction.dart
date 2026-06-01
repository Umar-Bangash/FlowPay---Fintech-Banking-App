class TransactionModel {
  final String transactionId;
  final String accountId;
  final String userId;
  final String receiverId;
  final String type;
  final double amount;
  final DateTime dateTime;
  final String description;
  final String docId;

  TransactionModel({
    required this.transactionId,
    required this.accountId,
    required this.userId,
    required this.receiverId,
    required this.type,
    required this.amount,
    required this.dateTime,
    required this.description,
    required this.docId,
  });

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'accountId': accountId,
      'userId': userId,
      'receiverId': receiverId,
      'type': type,
      'amount': amount,
      'dateTime': dateTime.toIso8601String(),
      'description': description,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json, String docId) {
    return TransactionModel(
      transactionId: json['transactionId'],
      accountId: json['accountId'],
      userId: json['userId'] ?? '',
      receiverId: json['receiverId'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      dateTime: DateTime.parse(json['dateTime']),
      description: json['description'],
      docId: docId,
    );
  }
}
