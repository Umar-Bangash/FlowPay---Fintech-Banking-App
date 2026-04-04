class Account {
  final String? accountId;
  final String userId;
  final String phone;
  double balance;

  Account({
    this.accountId,
    required this.userId,
    required this.phone,
    this.balance = 0.0,
  });

  // copywith method
  Account copyWith({
    String? accountId,
    String? userId,
    String? phone,
    double? balance,
  }) {
    return Account(
      accountId: accountId ?? this.accountId,
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      balance: balance ?? this.balance,
    );
  }

  // convert account to json (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'userId': userId,
      'phone': phone,
      'balance': balance,
    };
  }

  // convert Firestore json to Account
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: json['accountId'],
      userId: json['userId'],
      phone: json['phone'],
      balance: (json['balance'] as num).toDouble(),
    );
  }
}
