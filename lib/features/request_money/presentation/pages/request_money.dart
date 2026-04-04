import 'package:flowpay/features/auth/presentation/components/my_textfield.dart';
import 'package:flowpay/features/auth/presentation/pages/dob_page.dart';
import 'package:flowpay/features/request_money/presentation/pages/contact_search_page.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../chat/presentation/cubit/chat_cubit.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../transaction/presentation/cubit/amnt_plus_cmnt_cubit.dart';

class RequestMoney extends StatefulWidget {
  const RequestMoney({super.key});

  @override
  State<RequestMoney> createState() => _RequestMoneyState();
}

class _RequestMoneyState extends State<RequestMoney> {
  final amountController = TextEditingController();
  final purposecontroller = TextEditingController();
  final timelineController = TextEditingController();
  final noteController = TextEditingController();

  Map<String, String>? selectedContact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        centerTitle: true,
        title: const Text(
          'Request Money',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          Image.asset(
            'assets/home/notification.png',
            height: context.hPx(24),
            width: context.wPx(24),
          ),
          context.spaceWPx(20),
        ],
        backgroundColor: const Color(0xffFFFFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Requesting from',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            context.spaceHPx(15),
            InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ContactSearchPage()),
                );

                if (result != null) {
                  setState(() {
                    selectedContact = result;
                  });
                }
              },
              child: Container(
                height: context.hPx(88),
                width: double.maxFinite,
                padding: context.padAllPx(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21),
                  color: const Color(0xffFBFCFF),
                ),
                child: ListTile(
                  leading: Container(
                    height: context.hPx(50.5),
                    width: context.wPx(52.6),
                    decoration: BoxDecoration(
                      color: const Color(0xff007AFF),
                      borderRadius: BorderRadius.circular(10.56),
                    ),
                    child: Padding(
                      padding: context.padAllPx(8),
                      child: Image.asset(
                        selectedContact == null
                            ? 'assets/navigation/profile.png'
                            : selectedContact!['image']!,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  title: Text(
                    selectedContact == null
                        ? 'Select Contact'
                        : selectedContact!['name']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    selectedContact == null
                        ? 'Select contact from your contact list'
                        : selectedContact!['phone']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 11.57,
                      color: Color(0xff707070),
                    ),
                  ),
                  trailing: Icon(
                    selectedContact == null
                        ? Icons.arrow_forward_ios
                        : Icons.check_circle,
                    size: 18,
                    color: selectedContact == null ? null : Colors.green,
                  ),
                ),
              ),
            ),
            context.spaceHPx(15),
            const Text(
              'Amount',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            MyTextField(
              controller: amountController,
              hintText: 'Rs. 00',
              obscureText: false,
            ),
            context.spaceHPx(12),
            const Text(
              'Purpose',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            MyTextField(
              controller: purposecontroller,
              hintText: 'e.g., Dinner bill, Rent',
              obscureText: false,
            ),
            context.spaceHPx(12),
            const Text(
              'Return Timeline (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            MyTextField(
              controller: timelineController,
              hintText: 'Set date of Return Timeline',
              obscureText: false,
              suffixIcon: InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DateOfBirthPicker(),
                    ),
                  );

                  if (result != null && result is DateTime) {
                    timelineController.text = result.toIso8601String();
                  }
                },
                child: Image.asset(
                  'assets/images/calender.png',
                  height: 56,
                  width: 85,
                ),
              ),
            ),
            context.spaceHPx(12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Comment (Optional)', style: TextStyle(fontSize: 16)),
            ),
            TextFormField(
              controller: noteController,
              onChanged: (text) {
                if (text.trim().isEmpty) {
                  context.read<CommentCubit>().updateCommentLength(0);
                  return;
                }

                List<String> words = text.trim().split(RegExp(r'\s+'));

                if (words.length > 50) {
                  words = words.sublist(0, 50);
                  noteController.text = words.join(" ");
                  noteController.selection = TextSelection.fromPosition(
                    TextPosition(offset: noteController.text.length),
                  );
                }

                context.read<CommentCubit>().updateCommentLength(words.length);
              },
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter Comment',
                hintStyle: const TextStyle(color: Color(0xffA3A3A3)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xffE5E5E5)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xffE5E5E5)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: BlocBuilder<CommentCubit, int>(
                builder: (context, length) {
                  return Text(
                    '$length/50',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xffA3A3A3),
                    ),
                  );
                },
              ),
            ),
            context.spaceHPx(30),
            InkWell(
              onTap: () async {
                if (selectedContact == null || amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select contact and enter amount'),
                    ),
                  );
                  return;
                }

                final receiverId = selectedContact!['userId']!;
                final receiverName = selectedContact!['name']!;
                final amount = double.tryParse(amountController.text) ?? 0;
                final purpose = purposecontroller.text;
                final returnTime =
                    DateTime.tryParse(timelineController.text) ??
                    DateTime.now();
                final note = noteController.text;

                final chatCubit = context.read<ChatCubit>();

                // Send the request message
                await chatCubit.sendRequestMessage(
                  receiverId: receiverId,
                  amount: amount,
                  purpose: purpose,
                  returnTime: returnTime,
                  note: note,
                );

                // Navigate to chat page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ChatPage(
                          receiverId: receiverId,
                          receiverName: receiverName,
                          chatCubit: chatCubit,
                        ),
                  ),
                );
              },
              child: Container(
                width: double.maxFinite,
                height: context.hPx(56),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xff007AFF),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Request Money',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xffFFFFFF),
                      ),
                    ),
                    context.spaceWPx(15),
                    Image.asset(
                      'assets/transfer/request.png',
                      height: 24,
                      width: 24,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xffFFFFFF),
    );
  }
}

// import 'package:flowpay/features/auth/presentation/components/my_textfield.dart';
// import 'package:flowpay/features/auth/presentation/pages/dob_page.dart';
// import 'package:flowpay/features/request_money/presentation/pages/contact_search_page.dart';
// import 'package:flowpay/helpers/ui_responsive_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../chat/presentation/pages/chat_page.dart';
// import '../../../transaction/presentation/cubit/amnt_plus_cmnt_cubit.dart';
// import '../components/request_money_card.dart';

// class RequestMoney extends StatefulWidget {
//   const RequestMoney({super.key});

//   @override
//   State<RequestMoney> createState() => _RequestMoneyState();
// }

// class _RequestMoneyState extends State<RequestMoney> {
//   final amountController = TextEditingController();
//   final purposecontroller = TextEditingController();
//   final timelineController = TextEditingController();
//   final noteController = TextEditingController();

//   Map<String, String>? selectedContact;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: InkWell(
//           onTap: () => Navigator.pop(context),
//           child: const Icon(Icons.arrow_back_ios, size: 20),
//         ),
//         centerTitle: true,
//         title: const Text(
//           'Request Money',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//         actions: [
//           Image.asset(
//             'assets/home/notification.png',
//             height: context.hPx(24),
//             width: context.wPx(24),
//           ),
//           context.spaceWPx(20),
//         ],
//         backgroundColor: const Color(0xffFFFFFF),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 25.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Requesting from',
//               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
//             ),
//             context.spaceHPx(15),
//             InkWell(
//               onTap: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => ContactSearchPage()),
//                 );

//                 if (result != null) {
//                   setState(() {
//                     selectedContact = result;
//                   });
//                 }
//               },
//               child: Container(
//                 height: context.hPx(88),
//                 width: double.maxFinite,
//                 padding: context.padAllPx(8),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(21),
//                   color: const Color(0xffFBFCFF),
//                 ),
//                 child: ListTile(
//                   leading: Container(
//                     height: context.hPx(50.5),
//                     width: context.wPx(52.6),
//                     decoration: BoxDecoration(
//                       color: const Color(0xff007AFF),
//                       borderRadius: BorderRadius.circular(10.56),
//                     ),
//                     child: Padding(
//                       padding: context.padAllPx(8),
//                       child: Image.asset(
//                         selectedContact == null
//                             ? 'assets/navigation/profile.png'
//                             : selectedContact!['image']!,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   title: Text(
//                     selectedContact == null
//                         ? 'Select Contact'
//                         : selectedContact!['name']!,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   subtitle: Text(
//                     selectedContact == null
//                         ? 'Select contact from your contact list'
//                         : selectedContact!['phone']!,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w400,
//                       fontSize: 11.57,
//                       color: Color(0xff707070),
//                     ),
//                   ),
//                   trailing: Icon(
//                     selectedContact == null
//                         ? Icons.arrow_forward_ios
//                         : Icons.check_circle,
//                     size: 18,
//                     color: selectedContact == null ? null : Colors.green,
//                   ),
//                 ),
//               ),
//             ),
//             context.spaceHPx(15),
//             const Text(
//               'Amount',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//             MyTextField(
//               controller: amountController,
//               hintText: 'Rs. 00',
//               obscureText: false,
//             ),
//             context.spaceHPx(12),
//             const Text(
//               'Purpose',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//             MyTextField(
//               controller: purposecontroller,
//               hintText: 'e.g., Dinner bill, Rent',
//               obscureText: false,
//             ),
//             context.spaceHPx(12),
//             const Text(
//               'Return Timeline (Optional)',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//             MyTextField(
//               controller: timelineController,
//               hintText: 'Set date of Return Timeline',
//               obscureText: false,
//               suffixIcon: InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const DateOfBirthPicker(),
//                     ),
//                   );
//                 },
//                 child: Image.asset(
//                   'assets/images/calender.png',
//                   height: 56,
//                   width: 85,
//                 ),
//               ),
//             ),

//             context.spaceHPx(12),
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text('Comment (Optional)', style: TextStyle(fontSize: 16)),
//             ),
//             TextFormField(
//               controller: noteController,
//               onChanged: (text) {
//                 if (text.trim().isEmpty) {
//                   context.read<CommentCubit>().updateCommentLength(0);
//                   return;
//                 }

//                 List<String> words = text.trim().split(RegExp(r'\s+'));

//                 if (words.length > 50) {
//                   words = words.sublist(0, 50);
//                   noteController.text = words.join(" ");
//                   noteController.selection = TextSelection.fromPosition(
//                     TextPosition(offset: noteController.text.length),
//                   );
//                 }

//                 context.read<CommentCubit>().updateCommentLength(words.length);
//               },
//               maxLines: 3,
//               decoration: InputDecoration(
//                 hintText: 'Enter Comment',
//                 hintStyle: const TextStyle(color: Color(0xffA3A3A3)),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: Color(0xffE5E5E5)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: Color(0xffE5E5E5)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             Align(
//               alignment: Alignment.bottomRight,
//               child: BlocBuilder<CommentCubit, int>(
//                 builder: (context, length) {
//                   return Text(
//                     '$length/50',
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: Color(0xffA3A3A3),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             context.spaceHPx(30),
//             InkWell(
//               onTap: () {
//                 if (selectedContact == null || amountController.text.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Please select contact and enter amount'),
//                     ),
//                   );
//                   return;
//                 }

//                 // Create the card dynamically
//                 final card = RequestMoneyCard(
//                   name: selectedContact!['name']!,
//                   amount: int.tryParse(amountController.text) ?? 0,
//                   purpose: purposecontroller.text,
//                   timeLine:
//                       DateTime.tryParse(timelineController.text) ??
//                       DateTime.now(),
//                   note: noteController.text,
//                 );

//                 // Navigate to chat page with the card
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder:
//                         (context) => ChatPage(
//                          // requestCard: card,
//                           receiverId: '',
//                           receiverName: '',
//                           chatCubit: context.read(),
//                         ),
//                   ),
//                 );
//               },
//               child: Container(
//                 width: double.maxFinite,
//                 height: context.hPx(56),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16),
//                   color: const Color(0xff007AFF),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Request Money',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Color(0xffFFFFFF),
//                       ),
//                     ),
//                     context.spaceWPx(15),
//                     Image.asset(
//                       'assets/transfer/request.png',
//                       height: 24,
//                       width: 24,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: const Color(0xffFFFFFF),
//     );
//   }
// }
