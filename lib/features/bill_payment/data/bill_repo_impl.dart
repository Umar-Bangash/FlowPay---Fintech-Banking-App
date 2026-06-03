import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/notification/data/services/local_notification_service.dart';
import '../domain/entity/bill.dart';
import '../domain/repo/bill_repo.dart';

class BillRepositoryImpl implements BillRepository {
  final FirebaseFirestore firestore;
  BillRepositoryImpl(this.firestore);

  final billCollection = "bills";
  final usersCollection = "users";
  final accountsCollection = "accounts";

  /// BILL CATEGORIES
  final List<String> categories = [
    "Electricity",
    "Gas",
    "Water",
    "Internet",
    "Education",
    "Telephone",
    "Insurance",
    "Government",
    "More",
  ];

  /// PROVIDERS PER CATEGORY
  final Map<String, List<String>> providers = {
    "Electricity": ["K-Electric", "LESCO", "IESCO", "FESCO", "PESCO", "GEPCO"],
    "Gas": ["SNGPL", "SSGC"],
    "Water": ["KWSB", "WASA Lahore", "WASA Rawalpindi"],
    "Internet": ["StormFiber", "Nayatel", "PTCL Flash Fiber", "Transworld"],
    "Education": ["University Fees", "College Fees", "School Fees"],
    "Telephone": ["PTCL Landline", "PTCL Evo"],
    "Insurance": ["State Life", "Jubilee Insurance", "EFU Life"],
    "Government": ["Traffic Challan", "FBR Tax", "Excise Token Tax"],
    "More": ["Other Bills"],
  };

  /// GET BILL CATEGORIES
  @override
  Future<List<String>> getBillCategories() async => categories;

  /// GET PROVIDERS BY CATEGORY
  @override
  Future<List<String>> getProvidersByCategory(String category) async =>
      providers[category] ?? [];

  // LOOKUP CONSUMER NAME BY PHONE NUMBER
  //
  // Step 1 - Query `accounts` collection where phone == consumerId - get userId
  // Step 2 - Query `users` collection by userId doc - get name
  Future<String> _getConsumerName(String phone) async {
    // Step 1: find account by phone number
    final accountQuery =
        await firestore
            .collection(accountsCollection)
            .where("phone", isEqualTo: phone)
            .limit(1)
            .get();

    if (accountQuery.docs.isEmpty) {
      return "NOT_FOUND";
    }

    final userId = accountQuery.docs.first.data()["userId"] as String?;

    if (userId == null || userId.isEmpty) {
      return "NOT_FOUND";
    }

    // Step 2: get user name from users collection
    final userDoc =
        await firestore.collection(usersCollection).doc(userId).get();

    if (!userDoc.exists) {
      return "NOT_FOUND";
    }

    final name = userDoc.data()?["name"] as String?;
    return (name != null && name.isNotEmpty) ? name : "NOT_FOUND";
  }

  // FETCH BILL DETAILS (SIMULATED)
  @override
  Future<Bill> fetchBillDetails({
    required String userId,
    required String providerName,
    required String consumerId,
    required String category,
  }) async {
    if (consumerId.trim().isEmpty) {
      throw Exception("Please enter a Consumer ID.");
    }

    final consumerName = await _getConsumerName(consumerId.trim());

    if (consumerName == "NOT_FOUND") {
      throw Exception(
        "No account found for Consumer ID: ${consumerId.trim()}. Please check and try again.",
      );
    }

    final random = Random();
    final amount = (2000 + random.nextInt(8000)).toDouble();
    final billId = firestore.collection(billCollection).doc().id;

    return Bill(
      billId: billId,
      userId: userId,
      providerName: providerName,
      consumerId: consumerId.trim(),
      consumerName: consumerName,
      category: category,
      amount: amount,
      transactionId: "",
      transactionDateTime: DateTime.now(),
      status: "unpaid",
    );
  }

  // PAY BILL
  @override
  Future<Bill> payBill(Bill bill) async {
    final transactionId = "TXN${DateTime.now().millisecondsSinceEpoch}";

    final paidBill = Bill(
      billId: bill.billId,
      userId: bill.userId,
      providerName: bill.providerName,
      consumerId: bill.consumerId,
      consumerName: bill.consumerName,
      category: bill.category,
      amount: bill.amount,
      transactionId: transactionId,
      transactionDateTime: DateTime.now(),
      status: "paid",
    );

    // Save bill to Firestore
    await firestore
        .collection(billCollection)
        .doc(paidBill.billId)
        .set(paidBill.toJson());

    // Save notification in Firestore
    final notificationId = DateTime.now().millisecondsSinceEpoch.toString();
    await firestore.collection("notifications").doc(notificationId).set({
      "notificationId": notificationId,
      "userId": paidBill.userId,
      "title": "${paidBill.category} Bill Paid",
      "message":
          "You paid Rs.${paidBill.amount.toStringAsFixed(0)} to ${paidBill.providerName}",
      "type": "bill",
      "isRead": false,
      "dateTime": Timestamp.now(),
    });

    // Local push notification
    LocalNotificationService.instance().showNotification(
      '${bill.category} Bill Paid',
      'You paid Rs.${bill.amount.toStringAsFixed(0)} to ${bill.providerName}',
      null,
    );

    return paidBill;
  }

  // STREAM USER BILLS (RECENT BILLS — newest first)
  @override
  Stream<List<Bill>> getUserBillsStream(String userId) {
    return firestore
        .collection(billCollection)
        .where("userId", isEqualTo: userId)
        .orderBy("transactionDateTime", descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Bill.fromJson(doc.data())).toList(),
        );
  }
}
