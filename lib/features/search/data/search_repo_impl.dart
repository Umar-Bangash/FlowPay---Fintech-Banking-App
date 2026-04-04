import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/account/domain/entities/account.dart';
import 'package:flowpay/features/profile_and_setting/domain/entities/profile_user.dart';
import 'package:flowpay/features/search/domain/search_repo.dart';

class SearchRepoImpl implements SearchRepo {
  @override
  Future<List<ProfileUser>> searchUsers(String query) async {
    try {
      final normalized = query.replaceAll(RegExp(r'\s+'), '');

      // 🔹 1) Find account by account number
      final accSnap =
          await FirebaseFirestore.instance
              .collection('accounts')
              .where('accountId', isEqualTo: normalized)
              .limit(1)
              .get();

      if (accSnap.docs.isEmpty) return [];

      final account = Account.fromJson(accSnap.docs.first.data());

      // 🔹 2) Find the user who owns this account
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(account.userId)
              .get();

      if (!userDoc.exists) return [];

      final userData = userDoc.data()!;

      // 🔹 3) Convert to ProfileUser (includes profileImageUrl)
      final profileUser = ProfileUser.fromJson(userData);

      // 🔹 4) Compose account into ProfileUser
      profileUser.account = account;

      return [profileUser];
    } catch (e) {
      throw Exception('Error searching user by account number: $e');
    }
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flowpay/features/profile/domain/entities/profile_user.dart';
// import 'package:flowpay/features/search/domain/search_repo.dart';

// class SearchRepoImpl implements SearchRepo {
//   @override
//   Future<List<ProfileUser>> searchUsers(String query) async {
//     try {
//       final result =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .where('name', isGreaterThanOrEqualTo: query)
//               .where('name', isLessThanOrEqualTo: '$query\uf8ff')
//               .get();
//       return result.docs
//           .map((doc) => ProfileUser.fromJson(doc.data()))
//           .toList();
//     } catch (e) {
//       throw Exception('Error searching user: $e');
//     }
//   }
// }
