import 'package:flowpay/features/auth/presentation/components/my_textfield.dart';
import 'package:flowpay/features/auth/presentation/pages/dob_page.dart';
import 'package:flowpay/features/request_money/presentation/pages/contact_search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../../../chat/presentation/cubit/chat_cubit.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../transaction/presentation/cubit/amnt_plus_cmnt_cubit.dart';

class RequestMoney extends StatefulWidget {
  const RequestMoney({super.key});
  @override
  State<RequestMoney> createState() => _RequestMoneyState();
}

class _RequestMoneyState extends State<RequestMoney> {
  final _amountCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _timelineCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  Map<String, String>? _contact;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _purposeCtrl.dispose();
    _timelineCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        centerTitle: true,
        title: Text(
          'Request Money',
          style: TextStyle(
            fontSize: AppResponsive.fs(17),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Image.asset(
            'assets/home/notification.png',
            height: AppResponsive.sp(22),
            width: AppResponsive.sp(22),
          ),
          SizedBox(width: AppResponsive.w(20)),
        ],
      ),
      body: AppAnimatedPage(
        direction: SlideDirection.bottom,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppResponsive.h(10)),

              // ── Section title ─────────────────────────────────────────
              AppAnimatedItem(
                index: 0,
                direction: SlideDirection.left,
                child: Text(
                  'Requesting from',
                  style: TextStyle(
                    fontSize: AppResponsive.fs(14),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              SizedBox(height: AppResponsive.h(12)),

              // ── Contact selector card ─────────────────────────────────
              AppAnimatedItem(
                index: 1,
                direction: SlideDirection.right,
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ContactSearchPage(),
                      ),
                    );
                    if (result != null) setState(() => _contact = result);
                  },
                  borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppResponsive.w(12)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppResponsive.radiusLg,
                      ),
                      color: const Color(0xffFBFCFF),
                      border: Border.all(color: const Color(0xffF0F0F0)),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppResponsive.radiusSm,
                          ),
                          child: Container(
                            height: AppResponsive.sp(46),
                            width: AppResponsive.sp(46),
                            color: const Color(0xff007AFF),
                            child:
                                _contact == null
                                    ? Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: AppResponsive.sp(24),
                                    )
                                    : _contact!['image']!.startsWith('http')
                                    ? Image.network(
                                      _contact!['image']!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: AppResponsive.sp(24),
                                          ),
                                    )
                                    : Image.asset(
                                      _contact!['image']!,
                                      color: Colors.white,
                                    ),
                          ),
                        ),
                        SizedBox(width: AppResponsive.w(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _contact == null
                                    ? 'Select Contact'
                                    : _contact!['name']!,
                                style: TextStyle(
                                  fontSize: AppResponsive.fs(14),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _contact == null
                                    ? 'Select contact from your contact list'
                                    : _contact!['phone']!,
                                style: TextStyle(
                                  fontSize: AppResponsive.fs(11),
                                  color: const Color(0xff707070),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _contact == null
                              ? Icons.arrow_forward_ios
                              : Icons.check_circle,
                          size: AppResponsive.sp(16),
                          color: _contact == null ? null : Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppResponsive.h(14)),

              // ── Amount ────────────────────────────────────────────────
              AppAnimatedItem(
                index: 2,
                direction: SlideDirection.left,
                child: _Label('Amount'),
              ),
              AppAnimatedItem(
                index: 2,
                direction: SlideDirection.left,
                child: MyTextField(
                  controller: _amountCtrl,
                  hintText: 'Rs. 00',
                  obscureText: false,
                ),
              ),

              SizedBox(height: AppResponsive.h(10)),

              // ── Purpose ───────────────────────────────────────────────
              AppAnimatedItem(
                index: 3,
                direction: SlideDirection.right,
                child: _Label('Purpose'),
              ),
              AppAnimatedItem(
                index: 3,
                direction: SlideDirection.right,
                child: MyTextField(
                  controller: _purposeCtrl,
                  hintText: 'e.g., Dinner bill, Rent',
                  obscureText: false,
                ),
              ),

              SizedBox(height: AppResponsive.h(10)),

              // ── Timeline ──────────────────────────────────────────────
              AppAnimatedItem(
                index: 4,
                direction: SlideDirection.left,
                child: _Label('Return Timeline (Optional)'),
              ),
              AppAnimatedItem(
                index: 4,
                direction: SlideDirection.left,
                child: MyTextField(
                  controller: _timelineCtrl,
                  hintText: 'Set date of Return Timeline',
                  obscureText: false,
                  suffixIcon: InkWell(
                    onTap: () async {
                      final r = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DateOfBirthPicker(),
                        ),
                      );
                      if (r != null && r is DateTime)
                        _timelineCtrl.text = r.toIso8601String();
                    },
                    child: Image.asset(
                      'assets/images/calender.png',
                      height: 56,
                      width: 85,
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppResponsive.h(10)),

              // ── Comment ───────────────────────────────────────────────
              AppAnimatedItem(
                index: 5,
                direction: SlideDirection.right,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _Label('Comment (Optional)'),
                ),
              ),
              AppAnimatedItem(
                index: 5,
                direction: SlideDirection.right,
                child: TextFormField(
                  controller: _noteCtrl,
                  style: TextStyle(fontSize: AppResponsive.fs(14)),
                  onChanged: (text) {
                    if (text.trim().isEmpty) {
                      context.read<CommentCubit>().updateCommentLength(0);
                      return;
                    }
                    var words = text.trim().split(RegExp(r'\s+'));
                    if (words.length > 50) {
                      words = words.sublist(0, 50);
                      _noteCtrl.text = words.join(' ');
                      _noteCtrl.selection = TextSelection.fromPosition(
                        TextPosition(offset: _noteCtrl.text.length),
                      );
                    }
                    context.read<CommentCubit>().updateCommentLength(
                      words.length,
                    );
                  },
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter Comment',
                    hintStyle: TextStyle(
                      color: const Color(0xffA3A3A3),
                      fontSize: AppResponsive.fs(13),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xffE5E5E5)),
                      borderRadius: BorderRadius.circular(
                        AppResponsive.radiusMd,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xff007AFF)),
                      borderRadius: BorderRadius.circular(
                        AppResponsive.radiusMd,
                      ),
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: BlocBuilder<CommentCubit, int>(
                  builder:
                      (_, len) => Text(
                        '$len/50',
                        style: TextStyle(
                          fontSize: AppResponsive.fs(12),
                          color: const Color(0xffA3A3A3),
                        ),
                      ),
                ),
              ),

              SizedBox(height: AppResponsive.h(22)),

              // ── Request button ────────────────────────────────────────
              AppAnimatedItem(
                index: 6,
                direction: SlideDirection.bottom,
                child: InkWell(
                  onTap: () async {
                    if (_contact == null || _amountCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select contact and enter amount',
                          ),
                        ),
                      );
                      return;
                    }
                    final receiverId = _contact!['userId']!;
                    final receiverName = _contact!['name']!;
                    final reciverPhone = _contact!['phone']!;
                    final amount = double.tryParse(_amountCtrl.text) ?? 0;
                    final purpose = _purposeCtrl.text;
                    final timeline =
                        DateTime.tryParse(_timelineCtrl.text) ?? DateTime.now();
                    final note = _noteCtrl.text;
                    final chatCubit = context.read<ChatCubit>();
                    await chatCubit.sendRequestMessage(
                      receiverId: receiverId,
                      amount: amount,
                      purpose: purpose,
                      returnTime: timeline,
                      note: note,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ChatPage(
                              receiverId: receiverId,
                              receiverName: receiverName,
                              chatCubit: chatCubit,
                              receiverPhone: reciverPhone,
                            ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
                  child: Container(
                    width: double.infinity,
                    height: AppResponsive.h(54),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppResponsive.radiusMd,
                      ),
                      color: const Color(0xff007AFF),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Request Money',
                          style: TextStyle(
                            fontSize: AppResponsive.fs(15),
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: AppResponsive.w(12)),
                        Image.asset(
                          'assets/transfer/request.png',
                          height: AppResponsive.sp(22),
                          width: AppResponsive.sp(22),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppResponsive.h(30)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: AppResponsive.fs(14),
      fontWeight: FontWeight.w500,
    ),
  );
}
