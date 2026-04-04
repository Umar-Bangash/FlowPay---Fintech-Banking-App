class TransactionModel {
  final String transactionId;
  final String accountId; // refrence to account (Foreign Key)
  final String type; // 'credit or debit'
  final double amount;
  final DateTime dateTime;
  final String description;
  final String docId;

  TransactionModel({
    required this.transactionId,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.dateTime,
    required this.description,
    required this.docId,
  });

  // convert transaction to json to store in DB
  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'accountId': accountId,
      'type': type,
      'amount': amount,
      'dateTime': dateTime.toIso8601String(), // Iso8601 is datetime formate
      'description': description,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json, String docId) {
    return TransactionModel(
      transactionId: json['transactionId'],
      accountId: json['accountId'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(), // convert to num -> double.
      dateTime: DateTime.parse(json['dateTime']), // convert string back to DT.
      description: json['description'],
      docId: docId,
    );
  }
}
