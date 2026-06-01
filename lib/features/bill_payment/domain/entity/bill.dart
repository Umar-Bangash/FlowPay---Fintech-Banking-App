import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  final String billId;
  final String userId;
  final String providerName;
  final String consumerId; // phone number used as account number
  final String consumerName; // fetched from Firestore by phone lookup
  final String category;
  final double amount;
  final String transactionId;
  final DateTime transactionDateTime;
  final String status; // paid | unpaid

  Bill({
    required this.billId,
    required this.userId,
    required this.providerName,
    required this.consumerId,
    required this.consumerName,
    required this.category,
    required this.amount,
    required this.transactionId,
    required this.transactionDateTime,
    required this.status,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      billId: json["billId"],
      userId: json["userId"],
      providerName: json["providerName"],
      consumerId: json["consumerId"],
      consumerName: json["consumerName"] ?? "Unknown",
      category: json["category"],
      amount: (json["amount"] as num).toDouble(),
      transactionId: json["transactionId"],
      transactionDateTime: (json["transactionDateTime"] as Timestamp).toDate(),
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "billId": billId,
      "userId": userId,
      "providerName": providerName,
      "consumerId": consumerId,
      "consumerName": consumerName,
      "category": category,
      "amount": amount,
      "transactionId": transactionId,
      "transactionDateTime": Timestamp.fromDate(transactionDateTime),
      "status": status,
    };
  }
}
