import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../request_money/presentation/components/request_money_card.dart';
import '../../domain/message_entity.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_states.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final ChatCubit chatCubit;

  const ChatPage({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.chatCubit,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  late final String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    widget.chatCubit.loadMessages(widget.receiverId);
  }

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/chat/chatbg.png',
                    fit: BoxFit.cover,
                  ),
                ),
                BlocBuilder<ChatCubit, ChatState>(
                  bloc: widget.chatCubit,
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is ChatError) {
                      return Center(child: Text(state.message));
                    }

                    if (state is ChatLoaded) {
                      final messages = state.messages;

                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final current = messages[messages.length - 1 - index];

                          final prev =
                              index + 1 < messages.length
                                  ? messages[messages.length - 2 - index]
                                  : null;

                          final showDateChip =
                              prev == null ||
                              !_isSameDay(current.timestamp, prev.timestamp);

                          final isMe = current.senderId == uid;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (showDateChip)
                                _dateChip(_getDateLabel(current.timestamp)),
                              _buildMessageByType(current, isMe),
                            ],
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  // ───────────────────────── APP BAR ─────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leadingWidth: 30,
      leading: const BackButton(color: Colors.black),
      title: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xffE6ECFF),
            child: Icon(Icons.person, color: Colors.black),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.receiverName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────── MESSAGE TYPES ─────────────────────────

  Widget _buildMessageByType(MessageModel message, bool isMe) {
    switch (message.type) {
      case "image":
        return _imageBubble(message.imageUrl!, isMe);
      case "request":
        // Request card is always centered — isMe only affects action buttons
        return _requestBubble(message, isMe);
      default:
        return _textBubble(message.message ?? "", isMe);
    }
  }

  // ───────────────────────── TEXT BUBBLE ─────────────────────────

  Widget _textBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xff007AFF) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft:
                isMe ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight:
                isMe ? const Radius.circular(4) : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ───────────────────────── IMAGE BUBBLE ─────────────────────────

  Widget _imageBubble(String url, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: const BoxConstraints(maxWidth: 260),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(url),
        ),
      ),
    );
  }

  // ───────────────────────── REQUEST BUBBLE ─────────────────────────

  Widget _requestBubble(MessageModel message, bool isMe) {
    return RequestMoneyCard(
      name: message.senderName,
      amount: message.requestAmount?.toInt() ?? 0,
      purpose: message.requestPurpose ?? "",
      timeLine: message.returnTime ?? DateTime.now(),
      note: message.message ?? "",
      status: message.requestStatus ?? "pending",
      isMe: isMe,
      onAccept: () {
        context.read<ChatCubit>().updateRequestStatus(
          otherUserId: message.senderId,
          messageId: message.id!,
          status: "accepted",
          amount: message.requestAmount?.toInt() ?? 0,
        );
      },
      onReject: () {
        context.read<ChatCubit>().updateRequestStatus(
          otherUserId: message.senderId,
          messageId: message.id!,
          status: "rejected",
          amount: message.requestAmount?.toInt() ?? 0,
        );
      },
    );
  }

  // ───────────────────────── INPUT BAR ─────────────────────────

  Widget _inputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xffF3F4F6), width: 1)),
        ),
        child: Row(
          children: [
            // ── + button ──
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xffF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add,
                  color: Color(0xff6B7280),
                  size: 22,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // ── Text field ──
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xffF9FAFB),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xffE5E7EB)),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: 'Type here',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xffADB5BD),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // ── Send button ──
            GestureDetector(
              onTap: _sendText,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xff007AFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── ACTIONS ─────────────────────────

  void _sendText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.chatCubit.sendTextMessage(widget.receiverId, text);
    _controller.clear();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);
    await widget.chatCubit.sendImageMessage(widget.receiverId, file);
  }

  // ───────────────────────── DATE CHIP ─────────────────────────

  Widget _dateChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xffD5E5FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xff4B5563)),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(date.year, date.month, date.day);

    if (msgDay == today) return 'Today';
    if (msgDay == yesterday) return 'Yesterday';

    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }
}

// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flowpay/helpers/ui_responsive_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../cubit/chat_cubit.dart';
// import '../cubit/chat_states.dart';

// class ChatPage extends StatefulWidget {
//   final String receiverId;
//   final String receiverName;
//   final ChatCubit chatCubit;
//   final Widget? requestCard;

//   const ChatPage({
//     super.key,
//     required this.receiverId,
//     required this.receiverName,
//     required this.chatCubit,
//     this.requestCard,
//   });

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _controller = TextEditingController();

//   late final String uid;

//   @override
//   void initState() {
//     super.initState();
//     uid = FirebaseAuth.instance.currentUser!.uid;
//     widget.chatCubit.loadMessages(widget.receiverId);
//   }

//   // ───────────────────────── BUILD ─────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffFFFFFF),
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           Expanded(
//             child: Stack(
//               children: [
//                 // Background stays
//                 Positioned.fill(
//                   child: Image.asset(
//                     'assets/chat/chatbg.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),

//                 BlocBuilder<ChatCubit, ChatState>(
//                   bloc: widget.chatCubit,
//                   builder: (context, state) {
//                     if (state is ChatLoading) {
//                       return const Center(child: CircularProgressIndicator());
//                     }

//                     if (state is ChatError) {
//                       return Center(child: Text(state.message));
//                     }

//                     if (state is ChatLoaded) {
//                       final messages = state.messages;
//                       final hasCard = widget.requestCard != null;

//                       return ListView.builder(
//                         reverse: true,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 12,
//                         ),
//                         itemCount: messages.length + (hasCard ? 1 : 0),
//                         itemBuilder: (context, index) {
//                           /// 🔥 SHOW CARD AT BOTTOM (index 0 because reverse = true)
//                           if (hasCard && index == 0) {
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 6),
//                               child: Align(
//                                 alignment: Alignment.centerRight,
//                                 child: Material(
//                                   elevation: 3,
//                                   borderRadius: BorderRadius.circular(16),
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(16),
//                                     child: widget.requestCard!,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }

//                           /// 🔥 ADJUST MESSAGE INDEX
//                           final msgIndex = hasCard ? index - 1 : index;

//                           final current =
//                               messages[messages.length - 1 - msgIndex];

//                           final prev =
//                               msgIndex + 1 < messages.length
//                                   ? messages[messages.length - 2 - msgIndex]
//                                   : null;

//                           final showDateChip =
//                               prev == null ||
//                               !_isSameDay(current.timestamp, prev.timestamp);

//                           final isMe = current.senderId == uid;

//                           return Column(
//                             children: [
//                               if (showDateChip)
//                                 _dateChip(_getDateLabel(current.timestamp)),
//                               _messageBubble(
//                                 message: current.message,
//                                 imageUrl: current.imageUrl,
//                                 isMe: isMe,
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                     }

//                     return const SizedBox.shrink();
//                   },
//                 ),
//               ],
//             ),
//           ),

//           // Input bar at bottom
//           _inputBar(),
//         ],
//       ),
//     );
//   }

//   // ───────────────────────── APP BAR ─────────────────────────

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.white,
//       leadingWidth: 30,
//       leading: const BackButton(color: Colors.black),
//       title: Row(
//         children: [
//           const CircleAvatar(
//             radius: 18,
//             backgroundColor: Color(0xffE6ECFF),
//             child: Icon(Icons.person, color: Colors.black),
//           ),
//           const SizedBox(width: 10),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 widget.receiverName,
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const Text(
//                 '0922103921233',
//                 style: TextStyle(color: Colors.grey, fontSize: 12),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ───────────────────────── BACKGROUND ─────────────────────────

//   Widget _chatBackground() {
//     return Positioned.fill(
//       child: Image.asset('assets/chat/chatbg.png', fit: BoxFit.cover),
//     );
//   }

//   // ───────────────────────── DATE CHIP ─────────────────────────

//   Widget _dateChip(String label) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 12, bottom: 6),
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//           decoration: BoxDecoration(
//             color: const Color(0xffD5E5FF),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(label, style: const TextStyle(fontSize: 12)),
//         ),
//       ),
//     );
//   }

//   // ───────────────────────── MESSAGE BUBBLE ─────────────────────────

//   Widget _messageBubble({
//     required String message,
//     required bool isMe,
//     String? imageUrl,
//   }) {
//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 6),
//         padding: const EdgeInsets.all(12),
//         constraints: const BoxConstraints(maxWidth: 260),
//         decoration: BoxDecoration(
//           color: isMe ? const Color(0xff007AFF) : Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: const Radius.circular(14),
//             topRight: const Radius.circular(14),
//             bottomLeft: isMe ? const Radius.circular(14) : Radius.zero,
//             bottomRight: isMe ? Radius.zero : const Radius.circular(14),
//           ),
//         ),
//         child:
//             imageUrl != null
//                 ? ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: Image.network(imageUrl),
//                 )
//                 : Text(
//                   message,
//                   style: TextStyle(
//                     color: isMe ? Colors.white : Colors.black,
//                     fontSize: 14,
//                   ),
//                 ),
//       ),
//     );
//   }

//   // ───────────────────────── INPUT BAR ─────────────────────────

//   Widget _inputBar() {
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//         decoration: const BoxDecoration(color: Colors.white),
//         child: Row(
//           children: [
//             IconButton(
//               icon: const Icon(
//                 Icons.add_circle_outline_sharp,
//                 color: Colors.grey,
//               ),
//               onPressed: _pickFile,
//             ),
//             const SizedBox(width: 6),
//             Expanded(
//               child: TextField(
//                 controller: _controller,
//                 decoration: InputDecoration(
//                   hintText: 'Type here',
//                   hintStyle: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xff707070),
//                   ),
//                   filled: true,
//                   fillColor: Colors.white,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 14,
//                     vertical: 12,
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(24),
//                     borderSide: const BorderSide(color: Color(0xffDADADA)),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(24),
//                     borderSide: const BorderSide(color: Color(0xffDADADA)),
//                   ),
//                   suffixIcon: Padding(
//                     padding: context.padAllPx(10),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Image.asset(
//                           'assets/chat/sticker.png',
//                           height: context.hPx(18),
//                           width: context.wPx(18),
//                         ),
//                         context.spaceWPx(6),
//                         Image.asset(
//                           'assets/chat/emoji.png',
//                           height: context.hPx(24),
//                           width: context.wPx(24),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.send, color: Color(0xff007AFF)),
//               onPressed: _sendText,
//             ),
//             Container(
//               height: context.hPx(36),
//               width: context.wPx(36),
//               decoration: BoxDecoration(
//                 color: Color(0xff007AFF),
//                 shape: BoxShape.circle,
//               ),
//               child: Padding(
//                 padding: context.padAllPx(6),
//                 child: Image.asset(
//                   'assets/pocket/money.png',
//                   color: Color(0xffFFFFFF),
//                 ),
//               ),
//             ),
//             context.spaceWPx(4),
//           ],
//         ),
//       ),
//     );
//   }

//   // ───────────────────────── ACTIONS ─────────────────────────

//   Future<void> _pickFile() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.image,
//       allowMultiple: false,
//     );

//     if (result == null || result.files.single.path == null) return;

//     final file = File(result.files.single.path!);

//     await widget.chatCubit.sendImageMessage(widget.receiverId, file);
//   }

//   void _sendText() {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;

//     widget.chatCubit.sendMessage(widget.receiverId, text);
//     _controller.clear();
//   }

//   // ───────────────────────── DATE HELPERS ─────────────────────────

//   bool _isSameDay(DateTime a, DateTime b) {
//     return a.year == b.year && a.month == b.month && a.day == b.day;
//   }

//   String _getDateLabel(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final msgDay = DateTime(date.year, date.month, date.day);

//     if (msgDay == today) return 'Today';
//     if (msgDay == yesterday) return 'Yesterday';

//     return '${date.day} ${_monthName(date.month)} ${date.year}';
//   }

//   String _monthName(int m) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return months[m - 1];
//   }
// }
