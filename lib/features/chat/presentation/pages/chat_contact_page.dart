import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/chat_tile.dart';
import '../cubit/chat_cubit.dart';
import 'chat_page.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';

class ChatContactPage extends StatelessWidget {
  const ChatContactPage({super.key});

  // ── WhatsApp-style time label ──
  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(date.year, date.month, date.day);

    if (msgDay == today) {
      // Show HH:MM
      final h = date.hour.toString().padLeft(2, '0');
      final m = date.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else if (msgDay == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      // Show weekday name
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    } else {
      // Show DD/MM/YY
      final d = date.day.toString().padLeft(2, '0');
      final mo = date.month.toString().padLeft(2, '0');
      final y = date.year.toString().substring(2);
      return '$d/$mo/$y';
    }
  }

  // ── Build a short preview text for any message type ──
  String _previewText(Map<String, dynamic> data) {
    final type = data['type'] ?? 'text';
    switch (type) {
      case 'image':
        return '📷 Photo';
      case 'request':
        final amount = data['requestAmount'];
        return '💸 Request: PKR ${amount?.toInt() ?? ''}';
      default:
        return data['message'] ?? '';
    }
  }

  // ── Sorted chat room ID (same logic as ChatRepoImpl) ──
  String _chatRoomId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Container(
            height: context.hPx(43),
            width: context.wPx(43),
            decoration: BoxDecoration(
              color: const Color(0xffEEEEEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          // ───────────── Loading ─────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ───────────── Error ─────────────
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Colors.red.shade400),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final users =
              docs
                  .where((doc) => doc.data()['uid'] != currentUid)
                  .map((doc) {
                    final data = doc.data();
                    return {
                      'uid': data['uid'] ?? '',
                      'name': data['name'] ?? 'User',
                      'profileImageUrl': data['profileImageUrl'] ?? '',
                    };
                  })
                  .where((user) => user['uid'] != '')
                  .toList();

          if (users.isEmpty) {
            return const Center(
              child: Text('No contacts found', style: TextStyle(fontSize: 16)),
            );
          }

          final chatCubit = context.read<ChatCubit>();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = user['uid']!;
              final userName = user['name']!;
              final userPhoto = user['profileImageUrl']!;
              final roomId = _chatRoomId(currentUid, userId);

              // ── Per-tile last message stream ──
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream:
                    FirebaseFirestore.instance
                        .collection('chat_room')
                        .doc(roomId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                builder: (context, msgSnapshot) {
                  String subtitle = 'Tap to start chat';
                  String trailing = '';

                  if (msgSnapshot.hasData &&
                      msgSnapshot.data!.docs.isNotEmpty) {
                    final lastMsg = msgSnapshot.data!.docs.first.data();
                    subtitle = _previewText(lastMsg);

                    final ts = lastMsg['timestamp'];
                    if (ts != null && ts is Timestamp) {
                      trailing = _formatTime(ts.toDate());
                    }
                  }

                  return ChatTile(
                    imagePath:
                        userPhoto.isNotEmpty
                            ? userPhoto
                            : 'assets/pocket/travel.png',
                    name: userName,
                    message: subtitle,
                    dateTime: DateTime.now(), // kept for ChatTile API compat
                    trailingLabel: trailing, // ← pass formatted string directly
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => BlocProvider.value(
                                value: chatCubit,
                                child: ChatPage(
                                  receiverId: userId,
                                  receiverName: userName,
                                  chatCubit: chatCubit,
                                ),
                              ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
