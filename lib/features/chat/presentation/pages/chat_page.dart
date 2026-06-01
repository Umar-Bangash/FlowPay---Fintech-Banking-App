import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../../../request_money/presentation/components/request_money_card.dart';
import '../../domain/message_entity.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_states.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverPhone;
  final ChatCubit chatCubit;

  const ChatPage({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPhone,
    required this.chatCubit,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _ctrl = TextEditingController();
  final _editCtrl = TextEditingController();
  late final String _uid;
  bool _showEmoji = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    widget.chatCubit.setActiveChat(widget.receiverId);
    widget.chatCubit.loadMessages(widget.receiverId);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmoji) {
        setState(() => _showEmoji = false);
      }
    });
  }

  @override
  void dispose() {
    widget.chatCubit.clearActiveChat();
    _ctrl.dispose();
    _editCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleEmoji() {
    if (_showEmoji) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
    setState(() => _showEmoji = !_showEmoji);
  }

  // ─────────────────────────────────────────────────────────────────
  // TICK WIDGET — production WhatsApp logic
  //
  //  delivered=false              → single grey tick  (offline / not delivered)
  //  delivered=true, seenAt=null  → double grey tick  (delivered, not read)
  //  delivered=true, seenAt≠null  → double white tick (read)
  //
  // Only shown on sender's (isMe) bubbles.
  // ─────────────────────────────────────────────────────────────────
  Widget _tick(MessageModel m) {
    if (!m.delivered) {
      return const SizedBox(
        width: 14,
        height: 14,
        child: Icon(Icons.check_rounded, size: 14, color: Colors.white54),
      );
    }
    final color = m.seenAt != null ? Colors.white : Colors.white54;
    return SizedBox(
      width: 20,
      height: 14,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Icon(Icons.check_rounded, size: 14, color: color),
          ),
          Positioned(
            left: 6,
            top: 0,
            child: Icon(Icons.check_rounded, size: 14, color: color),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // LONG PRESS — text/image bubble
  // ─────────────────────────────────────────────────────────────────
  void _showBubbleOptions(MessageModel m, bool isMe) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xffD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (isMe && m.type == 'text')
                  ListTile(
                    leading: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xff007AFF),
                    ),
                    title: const Text(
                      'Edit message',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showEditDialog(m);
                    },
                  ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  title: Text(
                    isMe ? 'Delete message' : 'Delete for me',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.redAccent,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(m);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // LONG PRESS — request card
  // ─────────────────────────────────────────────────────────────────
  void _showRequestOptions(MessageModel m, bool isMe) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xffD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  title: Text(
                    isMe ? 'Delete request' : 'Delete for me',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.redAccent,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(m);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  void _showEditDialog(MessageModel m) {
    _editCtrl.text = m.message ?? '';
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Edit message',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            content: TextField(
              controller: _editCtrl,
              autofocus: true,
              maxLines: null,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xffF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xffE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xff007AFF)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xff6B7280)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff007AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final t = _editCtrl.text.trim();
                  if (t.isNotEmpty && t != m.message) {
                    widget.chatCubit.editMessage(
                      receiverId: widget.receiverId,
                      messageId: m.id!,
                      newText: t,
                    );
                  }
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _confirmDelete(MessageModel m) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Delete message',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            content: const Text(
              'This message will be permanently deleted.',
              style: TextStyle(color: Color(0xff6B7280), fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xff6B7280)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  widget.chatCubit.deleteMessage(
                    receiverId: widget.receiverId,
                    messageId: m.id!,
                  );
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    return WillPopScope(
      onWillPop: () async {
        if (_showEmoji) {
          setState(() => _showEmoji = false);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _appBar(),
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
                        final msgs = state.messages;
                        if (msgs.isEmpty) {
                          return Center(
                            child: Text(
                              'Say hello 👋',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: AppResponsive.fs(15),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppResponsive.w(12),
                            vertical: AppResponsive.h(12),
                          ),
                          itemCount: msgs.length,
                          itemBuilder: (context, i) {
                            final cur = msgs[msgs.length - 1 - i];
                            final prev =
                                i + 1 < msgs.length
                                    ? msgs[msgs.length - 2 - i]
                                    : null;
                            final showChip =
                                prev == null ||
                                !_sameDay(cur.timestamp, prev.timestamp);
                            final isMe = cur.senderId == _uid;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (showChip)
                                  _dateChip(_dateLabel(cur.timestamp)),
                                _msgByType(cur, isMe),
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
            // Emoji picker slides up from bottom
            if (_showEmoji)
              SizedBox(
                height: 280,
                child: EmojiPicker(
                  textEditingController: _ctrl,
                  config: Config(
                    height: 280,
                    emojiViewConfig: const EmojiViewConfig(
                      columns: 8,
                      emojiSizeMax: 28,
                      backgroundColor: Colors.white,
                    ),
                    categoryViewConfig: const CategoryViewConfig(
                      backgroundColor: Colors.white,
                      indicatorColor: Color(0xff007AFF),
                      iconColor: Colors.grey,
                      iconColorSelected: Color(0xff007AFF),
                      // Only show these categories — no stickers/GIFs
                      initCategory: Category.SMILEYS,
                    ),
                    bottomActionBarConfig: const BottomActionBarConfig(
                      showSearchViewButton: false,
                      showBackspaceButton: true,
                      backgroundColor: Colors.white,
                    ),
                    searchViewConfig: const SearchViewConfig(
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // APP BAR — matches design: back, avatar+name+phone, no extra icons
  // ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _appBar() => AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    leadingWidth: AppResponsive.w(40),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 18),
      onPressed: () => Navigator.pop(context),
    ),
    title: StreamBuilder<bool>(
      stream: widget.chatCubit.watchOnlineStatus(widget.receiverId),
      builder: (_, snap) {
        final isOnline = snap.data ?? false;
        return Row(
          children: [
            CircleAvatar(
              radius: AppResponsive.sp(18),
              backgroundColor: const Color(0xffE6ECFF),
              child: Icon(
                Icons.person,
                color: Colors.black54,
                size: AppResponsive.sp(18),
              ),
            ),
            SizedBox(width: AppResponsive.w(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: AppResponsive.fs(14),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isOnline ? 'Online' : widget.receiverPhone,
                    style: TextStyle(
                      fontSize: AppResponsive.fs(11),
                      color:
                          isOnline
                              ? const Color(0xff34C759)
                              : const Color(0xff9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  // ─────────────────────────────────────────────────────────────────
  // MESSAGE ROUTER
  // ─────────────────────────────────────────────────────────────────
  Widget _msgByType(MessageModel m, bool isMe) {
    switch (m.type) {
      case 'image':
        return _imgBubble(m, isMe);
      case 'request':
        return _reqBubble(m, isMe);
      default:
        return _txtBubble(m, isMe);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // TEXT BUBBLE — dynamic width via IntrinsicWidth
  // Matches design: white for receiver, blue for sender
  // ─────────────────────────────────────────────────────────────────
  Widget _txtBubble(MessageModel m, bool isMe) {
    final bg = isMe ? const Color(0xff007AFF) : Colors.white;
    final fg = isMe ? Colors.white : Colors.black87;
    final timeFg = isMe ? Colors.white.withOpacity(0.72) : Colors.grey.shade500;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showBubbleOptions(m, isMe),
        child: Container(
          margin: EdgeInsets.only(
            top: AppResponsive.h(2),
            bottom: AppResponsive.h(2),
            left: isMe ? AppResponsive.w(60) : 0,
            right: isMe ? 0 : AppResponsive.w(60),
          ),
          constraints: BoxConstraints(maxWidth: AppResponsive.wp(75)),
          child: IntrinsicWidth(
            child: Container(
              padding: EdgeInsets.only(
                left: AppResponsive.w(12),
                right: AppResponsive.w(10),
                top: AppResponsive.h(8),
                bottom: AppResponsive.h(6),
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      m.message ?? '',
                      style: TextStyle(
                        color: fg,
                        fontSize: AppResponsive.fs(14),
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (m.edited == true)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'edited',
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color:
                              isMe
                                  ? Colors.white.withOpacity(0.6)
                                  : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  SizedBox(height: AppResponsive.h(2)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _timeLabel(m.timestamp),
                        style: TextStyle(fontSize: 10, color: timeFg),
                      ),
                      if (isMe) ...[const SizedBox(width: 3), _tick(m)],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // IMAGE BUBBLE
  // ─────────────────────────────────────────────────────────────────
  Widget _imgBubble(MessageModel m, bool isMe) => Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: GestureDetector(
      onLongPress: () => _showBubbleOptions(m, isMe),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppResponsive.h(4)),
        constraints: BoxConstraints(maxWidth: AppResponsive.wp(65)),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
              child: Image.network(
                m.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder:
                    (_, child, prog) =>
                        prog == null
                            ? child
                            : Container(
                              height: 160,
                              color: const Color(0xffF3F4F6),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
              ),
            ),
            if (isMe)
              Padding(
                padding: const EdgeInsets.only(top: 3, right: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _timeLabel(m.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 3),
                    _tick(m),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );

  // ─────────────────────────────────────────────────────────────────
  // REQUEST BUBBLE
  // ─────────────────────────────────────────────────────────────────
  Widget _reqBubble(MessageModel m, bool isMe) => GestureDetector(
    onLongPress: () => _showRequestOptions(m, isMe),
    child: RequestMoneyCard(
      name: m.senderName,
      amount: m.requestAmount?.toInt() ?? 0,
      purpose: m.requestPurpose ?? '',
      timeLine: m.returnTime ?? DateTime.now(),
      note: m.message ?? '',
      status: m.requestStatus ?? 'pending',
      isMe: isMe,
      onAccept:
          () => context.read<ChatCubit>().updateRequestStatus(
            otherUserId: m.senderId,
            messageId: m.id!,
            status: 'accepted',
            amount: m.requestAmount?.toInt() ?? 0,
          ),
      onReject:
          () => context.read<ChatCubit>().updateRequestStatus(
            otherUserId: m.senderId,
            messageId: m.id!,
            status: 'rejected',
            amount: m.requestAmount?.toInt() ?? 0,
          ),
    ),
  );

  // ─────────────────────────────────────────────────────────────────
  // INPUT BAR — matches design: + | text field | emoji | mic | camera
  // ─────────────────────────────────────────────────────────────────
  Widget _inputBar() => SafeArea(
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.w(10),
        vertical: AppResponsive.h(8),
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xffF3F4F6))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // + button
          _iconBtn(Icons.add, _pickFile),
          SizedBox(width: AppResponsive.w(8)),

          // Text field
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: AppResponsive.h(44),
                maxHeight: AppResponsive.h(120),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xffF9FAFB),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xffE5E7EB)),
                ),
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focusNode,
                  maxLines: null,
                  style: TextStyle(
                    fontSize: AppResponsive.fs(14),
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type here',
                    hintStyle: TextStyle(
                      fontSize: AppResponsive.fs(14),
                      color: const Color(0xffADB5BD),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppResponsive.w(16),
                      vertical: AppResponsive.h(12),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: AppResponsive.w(6)),

          // Emoji toggle — tapping switches between keyboard and emoji picker
          _iconBtn(
            _showEmoji ? Icons.keyboard : Icons.emoji_emotions_outlined,
            _toggleEmoji,
            color:
                _showEmoji ? const Color(0xff007AFF) : const Color(0xff9CA3AF),
          ),

          SizedBox(width: AppResponsive.w(4)),

          // Send button
          GestureDetector(
            onTap: _sendText,
            child: Container(
              width: AppResponsive.sp(42),
              height: AppResponsive.sp(42),
              decoration: BoxDecoration(
                color: const Color(0xff007AFF),
                borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: AppResponsive.sp(18),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _iconBtn(
    IconData icon,
    VoidCallback onTap, {
    Color color = const Color(0xff6B7280),
  }) => GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: AppResponsive.sp(40),
      height: AppResponsive.sp(40),
      child: Icon(icon, color: color, size: AppResponsive.sp(22)),
    ),
  );

  void _sendText() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    widget.chatCubit.sendTextMessage(widget.receiverId, t);
    _ctrl.clear();
  }

  Future<void> _pickFile() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.image);
    if (r == null || r.files.single.path == null) return;
    await widget.chatCubit.sendImageMessage(
      widget.receiverId,
      File(r.files.single.path!),
    );
  }

  Widget _dateChip(String label) => Padding(
    padding: EdgeInsets.symmetric(vertical: AppResponsive.h(8)),
    child: Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppResponsive.w(14),
          vertical: AppResponsive.h(5),
        ),
        decoration: BoxDecoration(
          color: const Color(0xffD5E5FF).withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppResponsive.fs(11),
            color: const Color(0xff4B5563),
          ),
        ),
      ),
    ),
  );

  String _timeLabel(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yest = today.subtract(const Duration(days: 1));
    final md = DateTime(d.year, d.month, d.day);
    if (md == today) return 'Today';
    if (md == yest) return 'Yesterday';
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
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
