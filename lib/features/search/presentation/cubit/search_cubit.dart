import 'package:flowpay/features/search/domain/search_repo.dart';
import 'package:flowpay/features/search/presentation/cubit/search_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo searchRepo;
  SearchCubit(this.searchRepo) : super(SearchInitial());

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    try {
      emit(SearchLoading());
      final users = await searchRepo.searchUsers(query); // List<ProfileUser>
      emit(SearchLoaded(users));
    } catch (e) {
      emit(SearchError('Error fetching search results: $e'));
    }
  }
}

// import 'package:flowpay/features/auth/domain/entities/app_user.dart';
// import 'package:flowpay/features/search/domain/search_repo.dart';
// import 'package:flowpay/features/search/presentation/cubit/search_states.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flowpay/features/account/domain/entities/account.dart';

// class SearchCubit extends Cubit<SearchState> {
//   final SearchRepo searchRepo;
//   SearchCubit(this.searchRepo) : super(SearchInitial());

//   Future<void> searchUsers(String query) async {
//     if (query.isEmpty) {
//       emit(SearchInitial());
//       return;
//     }

//     try {
//       emit(SearchLoading());

//       final users = await searchRepo.searchUsers(query);

//       final List<AppUser> usersWithAccounts = [];
//       for (var user in users) {
//         final accountSnapshot =
//             await FirebaseFirestore.instance
//                 .collection('accounts')
//                 .where('userId', isEqualTo: user.uid)
//                 .limit(1)
//                 .get();

//         Account? account;
//         if (accountSnapshot.docs.isNotEmpty) {
//           account = Account.fromJson(accountSnapshot.docs.first.data());
//         }

//         usersWithAccounts.add(
//           AppUser(
//             uid: user.uid,
//             name: user.name,
//             email: user.email,
//             account: account, // may be null if no account
//           ),
//         );
//       }

//       emit(SearchLoaded(usersWithAccounts.cast<AppUser>()));
//     } catch (e) {
//       emit(SearchError('Error fetching search result'));
//     }
//   }
// }
