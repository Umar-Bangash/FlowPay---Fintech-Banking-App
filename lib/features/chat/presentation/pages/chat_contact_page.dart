import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../../domain/chat_repo.dart';
import '../cubit/chat_cubit.dart';
import 'chat_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ChatContactPage
//
// Room list is now driven entirely by chat_room collection:
//   getChatRooms() → query chat_room where participants array-contains _uid
//
// Users collection is still fetched once for display names / photos.
// We cache the user map so it isn't rebuilt on every room-list update.
// ─────────────────────────────────────────────────────────────────────────────

class ChatContactPage extends StatelessWidget {
  const ChatContactPage({super.key});

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(date.year, date.month, date.day);
    if (msgDay == today) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (msgDay == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    }
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year.toString().substring(2)}';
  }

  String _preview(String type, String lastMessage) {
    if (type == 'image') return '📷 Photo';
    if (type == 'request') return '💸 Money request';
    return lastMessage;
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final chatCubit = context.read<ChatCubit>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(context, uid),
      body: AppAnimatedPage(
        direction: SlideDirection.bottom,
        child: StreamBuilder<List<ChatRoomSummary>>(
          // chat_room collection — single query, no user_chats fan-out
          stream: chatCubit.repo.getChatRooms(),
          builder: (context, roomSnap) {
            final rooms = roomSnap.data ?? [];
            final roomUserIds = rooms.map((r) => r.otherUserId).toSet();

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              // Users collection — one snapshot for display names/photos
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, userSnap) {
                if (userSnap.connectionState == ConnectionState.waiting &&
                    rooms.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // uid → profile map (O(1) lookups below)
                final userMap = <String, Map<String, dynamic>>{};
                for (final doc in userSnap.data?.docs ?? []) {
                  final data = doc.data();
                  final docUid = (data['uid'] as String?) ?? doc.id;
                  if (docUid != uid) userMap[docUid] = data;
                }

                // ── Recent chats (already sorted desc by Firestore) ──────────
                final roomTiles =
                    rooms.map((room) {
                      final u = userMap[room.otherUserId] ?? {};
                      return _Tile(
                        name: u['name'] as String? ?? 'User',
                        photoUrl: u['profileImageUrl'] as String? ?? '',
                        subtitle: _preview(
                          room.lastMessageType,
                          room.lastMessage,
                        ),
                        trailingTime: _formatTime(room.lastTimestamp),
                        onTap:
                            () => _open(
                              context,
                              chatCubit,
                              room.otherUserId,
                              u['name'] as String? ?? 'User',
                              u['phone'] as String? ?? '',
                            ),
                      );
                    }).toList();

                // ── Users with no chat yet ──────────────────────────────────
                final freshTiles =
                    userMap.entries
                        .where((e) => !roomUserIds.contains(e.key))
                        .map(
                          (e) => _Tile(
                            name: e.value['name'] as String? ?? 'User',
                            photoUrl:
                                e.value['profileImageUrl'] as String? ?? '',
                            subtitle: 'Tap to start a conversation',
                            trailingTime: '',
                            onTap:
                                () => _open(
                                  context,
                                  chatCubit,
                                  e.key,
                                  e.value['name'] as String? ?? 'User',
                                  e.value['phone'] as String? ?? '',
                                ),
                          ),
                        )
                        .toList();

                final all = [...roomTiles, ...freshTiles];

                if (all.isEmpty) {
                  return Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(15),
                        color: Colors.grey.shade500,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: all.length,
                  itemBuilder:
                      (_, i) => AppAnimatedItem(
                        index: i,
                        direction: SlideDirection.left,
                        child: all[i],
                      ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, String uid) => AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    automaticallyImplyLeading: false,
    title: StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (_, snap) {
        final data = snap.data?.data() as Map<String, dynamic>? ?? {};
        final photoUrl = data['profileImageUrl'] as String? ?? '';
        return CircleAvatar(
          radius: AppResponsive.sp(20),
          backgroundColor: const Color(0xffEEEEEE),
          backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
          child:
              photoUrl.isEmpty
                  ? Icon(
                    Icons.person,
                    size: AppResponsive.sp(20),
                    color: Colors.grey.shade600,
                  )
                  : null,
        );
      },
    ),
    actions: [
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.search, color: Colors.black87, size: 22),
      ),
      IconButton(
        onPressed: () {},
        icon: const Icon(
          Icons.notifications_none_outlined,
          color: Colors.black87,
          size: 22,
        ),
      ),
      SizedBox(width: AppResponsive.w(6)),
    ],
  );

  void _open(
    BuildContext context,
    ChatCubit chatCubit,
    String userId,
    String name,
    String phone,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: chatCubit,
              child: ChatPage(
                receiverId: userId,
                receiverName: name,
                receiverPhone: phone,
                chatCubit: chatCubit,
              ),
            ),
      ),
    );
  }
}

// ── Tile widget ──────────────────────────────────────────────────────────────
class _Tile extends StatelessWidget {
  final String name;
  final String photoUrl;
  final String subtitle;
  final String trailingTime;
  final VoidCallback onTap;

  const _Tile({
    required this.name,
    required this.photoUrl,
    required this.subtitle,
    required this.trailingTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppResponsive.w(20),
              vertical: AppResponsive.h(11),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: AppResponsive.sp(22),
                  backgroundColor: const Color(0xffEEEEEE),
                  backgroundImage:
                      photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl) as ImageProvider
                          : null,
                  child:
                      photoUrl.isEmpty
                          ? Icon(
                            Icons.person,
                            size: AppResponsive.sp(22),
                            color: Colors.grey.shade500,
                          )
                          : null,
                ),
                SizedBox(width: AppResponsive.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: AppResponsive.fs(15),
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: AppResponsive.h(3)),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppResponsive.fs(12),
                          color: const Color(0xff9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailingTime.isNotEmpty)
                  Text(
                    trailingTime,
                    style: TextStyle(
                      fontSize: AppResponsive.fs(11),
                      color: const Color(0xff9CA3AF),
                    ),
                  ),
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: AppResponsive.w(68),
            color: const Color(0xffF3F4F6),
          ),
        ],
      ),
    );
  }
}
