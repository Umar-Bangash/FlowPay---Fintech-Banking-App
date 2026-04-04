// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flowpay/features/account/presentation/cubit/account_cubit.dart';
// import 'package:flowpay/features/account/presentation/cubit/account_states.dart';
// import 'package:flowpay/features/account/presentation/components/create_acc_dialog.dart'; // ✅ use your existing dialog file
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// class AccountPage extends StatefulWidget {
//   const AccountPage({super.key});
//
//   @override
//   State<AccountPage> createState() => _AccountPageState();
// }
//
// class _AccountPageState extends State<AccountPage> {
//   final userId = FirebaseAuth.instance.currentUser!.uid;
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<AccountCubit>().loadAccounts(userId);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("My Accounts"),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: BlocConsumer<AccountCubit, AccountStates>(
//         listener: (context, state) {
//           if (state is AccountError) {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text(state.message)));
//           } else if (state is AccountSuccess) {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text(state.meessage)));
//           }
//         },
//         builder: (context, state) {
//           if (state is AccountLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is AccountLoaded) {
//             final accounts = state.accounts;
//
//             if (accounts.isEmpty) {
//               return const Center(
//                 child: Text(
//                   "No accounts yet. Tap + to create one!",
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               );
//             }
//
//             return ListView.builder(
//               itemCount: accounts.length,
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//               itemBuilder: (context, index) {
//                 final account = accounts[index];
//                 final isSaving = account.accountType.toLowerCase() == "saving";
//
//                 return Card(
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.all(16),
//                     leading: CircleAvatar(
//                       backgroundColor:
//                           isSaving
//                               ? Colors.green.shade100
//                               : Colors.blue.shade100,
//                       child: Icon(
//                         isSaving
//                             ? Icons.savings_rounded
//                             : Icons.account_balance,
//                         color: isSaving ? Colors.green : Colors.blue,
//                       ),
//                     ),
//                     title: Text(
//                       "Account No: ${account.accountId}",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     subtitle: Padding(
//                       padding: const EdgeInsets.only(top: 4.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Type: ${account.accountType}",
//                             style: const TextStyle(fontSize: 13),
//                           ),
//                           const SizedBox(height: 3),
//                           Text(
//                             "Balance: Rs.${account.balance.toStringAsFixed(2)}",
//                             style: const TextStyle(
//                               fontSize: 16,
//                               color: Colors.green,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     trailing: IconButton(
//                       onPressed: () {
//                         context.read<AccountCubit>().deleteAccount(
//                           account.accountId,
//                           account.userId,
//                         );
//                       },
//                       icon: const Icon(Icons.delete_outline, color: Colors.red),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//           return const Center(child: Text("No data found."));
//         },
//       ),
//       // Now it uses your shared dialog
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => showCreateAccountDialog(context),
//         icon: const Icon(Icons.add),
//         label: const Text("Add Account"),
//       ),
//     );
//   }
// }
