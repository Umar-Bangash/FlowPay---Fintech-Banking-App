// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flowpay/features/account/domain/entities/account.dart';
// import 'package:flowpay/features/account/presentation/cubit/account_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// Future<void> showCreateAccountDialog(BuildContext context) async {
//   String selectedType = 'saving'; // default
//   final accountNumberController = TextEditingController();
//   final balanceController = TextEditingController();
//   final userId = FirebaseAuth.instance.currentUser!.uid;
//
//   await showDialog(
//     context: context,
//     builder: (context) {
//       return StatefulBuilder(
//         builder:
//             (context, setState) => AlertDialog(
//               title: const Text(
//                 "Create Account",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // 1️⃣ Account Type Dropdown
//                     DropdownButtonFormField<String>(
//                       initialValue: selectedType,
//                       decoration: const InputDecoration(
//                         labelText: "Account Type",
//                         border: OutlineInputBorder(),
//                       ),
//                       items: const [
//                         DropdownMenuItem(
//                           value: "saving",
//                           child: Text("Saving"),
//                         ),
//                         DropdownMenuItem(
//                           value: "current",
//                           child: Text("Current"),
//                         ),
//                       ],
//                       onChanged: (value) {
//                         if (value != null) {
//                           setState(() => selectedType = value);
//                         }
//                       },
//                     ),
//                     const SizedBox(height: 12),
//
//                     // 2️⃣ Account Number Field
//                     TextField(
//                       controller: accountNumberController,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         labelText: "Account Number",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//
//                     // 3️⃣ Account Balance Field
//                     TextField(
//                       controller: balanceController,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         labelText: "Initial Balance",
//                         hintText: "Enter starting balance (e.g. 50000)",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("Cancel"),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     final accountNumber = accountNumberController.text.trim();
//                     final balance =
//                         double.tryParse(balanceController.text.trim()) ?? 0.0;
//
//                     if (accountNumber.isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Please enter an account number"),
//                         ),
//                       );
//                       return;
//                     }
//
//                     // ✅ Create new account
//                     final newAccount = Account(
//                       accountId: accountNumber,
//                       userId: userId,
//                       balance: balance,
//                     );
//
//                     // ✅ Call Cubit
//                     context.read<AccountCubit>().createAccount(newAccount);
//
//                     Navigator.pop(context);
//                   },
//                   child: const Text("Create"),
//                 ),
//               ],
//             ),
//       );
//     },
//   );
// }
