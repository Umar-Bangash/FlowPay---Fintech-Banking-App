import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/account/presentation/cubit/account_cubit.dart';
import 'package:flowpay/features/account/presentation/cubit/account_states.dart';
import 'package:flowpay/features/auth/domain/entities/app_user.dart';
import 'package:flowpay/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_states.dart';
import 'package:flowpay/features/transaction/presentation/components/card_detail.dart';
import 'package:flowpay/features/transaction/presentation/components/transfer_details.dart';
import 'package:flowpay/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:flowpay/features/transaction/presentation/cubit/transaction_states.dart';
import 'package:flowpay/features/transaction/presentation/pages/payment_success_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../../../auth/presentation/components/auth_bottom_sheet.dart';

class TransferMoney2 extends StatefulWidget {
  final String senderAccountId;
  final AppUser receiver;
  final double amount;
  final String comment;
  final String transactionId;

  const TransferMoney2({
    super.key,
    required this.senderAccountId,
    required this.receiver,
    required this.amount,
    required this.comment,
    required this.transactionId,
  });

  @override
  State<TransferMoney2> createState() => _TransferMoney2State();
}

class _TransferMoney2State extends State<TransferMoney2>
    with SingleTickerProviderStateMixin {
  bool _isSending = false;

  late AnimationController _btnCtrl;
  late Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    context.read<ProfileCubit>().fetchProfileUser(uid);

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _btnScale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _btnCtrl.dispose();
    super.dispose();
  }

  String _formattedDate() {
    final now = DateTime.now();
    const m = [
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
    return '${now.year} - ${m[now.month - 1]} - ${now.day}';
  }

  Future<void> _showAuthSheet() async {
    if (_isSending) return;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder:
          (_) => AuthBottomSheet(
            uid: uid,
            onVerified: _executeTransaction,
            onSkip: _executeTransaction,
          ),
    );
  }

  void _executeTransaction() {
    if (widget.amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    if (widget.receiver.account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receiver account not found')),
      );
      return;
    }
    setState(() => _isSending = true);
    context.read<TransactionCubit>().transferMoney(
      widget.senderAccountId,
      widget.receiver.account!.userId,
      widget.amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    final safeImg =
        (widget.receiver.profileImageUrl != null &&
                widget.receiver.profileImageUrl!.trim().isNotEmpty &&
                widget.receiver.profileImageUrl != 'null')
            ? widget.receiver.profileImageUrl
            : null;

    return BlocListener<TransactionCubit, TransactionStates>(
      listener: (context, state) {
        if (state is TransactionSuccess) {
          setState(() => _isSending = false);
          context.read<AccountCubit>().deductBalance(widget.amount);
          context.read<NotificationCubit>().getNotifications(
            widget.senderAccountId,
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => PaymentSuccessPage(
                    amount: widget.amount,
                    reciver: widget.receiver,
                    transactionId: widget.transactionId,
                  ),
            ),
          );
        } else if (state is TransactionError) {
          setState(() => _isSending = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
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
            'Transfer',
            style: TextStyle(
              fontSize: AppResponsive.fs(16),
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            Icon(Icons.notifications_outlined, size: AppResponsive.sp(22)),
            SizedBox(width: AppResponsive.w(14)),
          ],
        ),
        body: AppAnimatedPage(
          direction: SlideDirection.bottom,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppResponsive.h(18)),

                  AppAnimatedItem(
                    index: 0,
                    direction: SlideDirection.left,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confirm Transfer',
                          style: TextStyle(
                            fontSize: AppResponsive.fs(16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppResponsive.h(4)),
                        Text(
                          'Please review all details carefully before sending.',
                          style: TextStyle(
                            fontSize: AppResponsive.fs(12),
                            color: const Color(0xff737373),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(18)),

                  // ── Sender + Receiver cards ────────────────────────────
                  AppAnimatedItem(
                    index: 1,
                    direction: SlideDirection.bottom,
                    child: SizedBox(
                      width: double.infinity,
                      child: LayoutBuilder(
                        builder: (context, c) {
                          // //final cardW =
                          //     (c.maxWidth -
                          //         AppResponsive.sp(24) -
                          //         AppResponsive.w(10)) /
                          //     2;
                          // //final cardH = cardW * 0.94;
                          return Row(
                            children: [
                              // ================= SENDER =================
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        AppResponsive.radiusMd,
                                      ),
                                      child: Image.asset(
                                        'assets/transfer/flowpay_card.png',
                                        width: double.infinity,
                                        height: AppResponsive.h(
                                          140,
                                        ), // fixed height ONLY
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    BlocBuilder<ProfileCubit, ProfileStates>(
                                      builder: (context, ps) {
                                        final name =
                                            ps is ProfileLoaded
                                                ? ps.profileUser.name
                                                : '';
                                        final img =
                                            ps is ProfileLoaded
                                                ? ps.profileUser.profileImageUrl
                                                : null;
                                        final acct =
                                            context.read<AccountCubit>().state;
                                        final phone =
                                            acct is AccountLoaded &&
                                                    acct.accounts.isNotEmpty
                                                ? acct.accounts.first.phone
                                                : '';

                                        return CardDetail(
                                          image: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              AppResponsive.radiusMd,
                                            ),
                                            child:
                                                (img?.isNotEmpty ?? false)
                                                    ? Image.network(
                                                      img!,
                                                      fit: BoxFit.cover,
                                                      width: double.maxFinite,
                                                      height: double.maxFinite,
                                                    )
                                                    : const Icon(
                                                      Icons.person,
                                                      size: 40,
                                                    ),
                                          ),
                                          imageCardColor: const Color(
                                            0xffCFE8FE,
                                          ),
                                          name: name,
                                          titleColor: Colors.white,
                                          subTitle: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: AppResponsive.w(
                                                    6,
                                                  ),
                                                  vertical: AppResponsive.h(2),
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: Colors.white
                                                      .withOpacity(0.4),
                                                ),
                                                child: Text(
                                                  'Flowpay',
                                                  style: TextStyle(
                                                    fontSize: AppResponsive.fs(
                                                      7,
                                                    ),
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: AppResponsive.w(6),
                                              ),
                                              Flexible(
                                                child: Text(
                                                  phone,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: AppResponsive.fs(
                                                      9,
                                                    ),
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: AppResponsive.w(8)),

                              // ================= ARROW =================
                              Image.asset(
                                'assets/transfer/arrow.png',
                                height: AppResponsive.sp(22),
                              ),

                              SizedBox(width: AppResponsive.w(8)),

                              // ================= RECEIVER =================
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        AppResponsive.radiusMd,
                                      ),
                                      child: Image.asset(
                                        'assets/transfer/stripe_card.png',
                                        width: double.infinity,
                                        height: AppResponsive.h(140),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    CardDetail(
                                      image:
                                          safeImg != null
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppResponsive.radiusMd,
                                                    ),
                                                child: Image.network(
                                                  safeImg,
                                                  fit: BoxFit.cover,
                                                  width: double.maxFinite,
                                                  height: double.maxFinite,
                                                ),
                                              )
                                              : const Icon(
                                                Icons.person,
                                                size: 40,
                                              ),
                                      imageCardColor: const Color.fromARGB(
                                        255,
                                        113,
                                        34,
                                        249,
                                      ),
                                      name: widget.receiver.name,
                                      titleColor: Colors.black,
                                      subTitle: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: AppResponsive.w(6),
                                              vertical: AppResponsive.h(2),
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.white.withOpacity(
                                                0.4,
                                              ),
                                            ),
                                            child: Text(
                                              'Flowpay',
                                              style: TextStyle(
                                                fontSize: AppResponsive.fs(7),
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: AppResponsive.w(6)),
                                          Flexible(
                                            // ✅ SAFE NOW
                                            child: Text(
                                              widget.receiver.account?.phone ??
                                                  'No Phone',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: AppResponsive.fs(9),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(18)),

                  AppAnimatedItem(
                    index: 2,
                    direction: SlideDirection.left,
                    child: Text(
                      'Transfer Details',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(14)),

                  AppAnimatedItem(
                    index: 3,
                    direction: SlideDirection.right,
                    child: TransferDetails(
                      amountSent: 'Rs. ${widget.amount.toStringAsFixed(2)}',
                      feeTax: 'Free',
                      date: _formattedDate(),
                      transactionId: widget.transactionId,
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(20)),

                  // ── Send button ────────────────────────────────────────
                  AppAnimatedItem(
                    index: 4,
                    direction: SlideDirection.bottom,
                    child: _buildSendButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return ScaleTransition(
      scale: _btnScale,
      child: GestureDetector(
        onTapDown: (_) => _btnCtrl.forward(),
        onTapUp: (_) async {
          await _btnCtrl.reverse();
          if (!_isSending) _showAuthSheet();
        },
        onTapCancel: () => _btnCtrl.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: AppResponsive.h(54),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
            color:
                _isSending
                    ? const Color(0xff1A73E8).withOpacity(0.85)
                    : const Color(0xff1A73E8),
          ),
          child:
              _isSending
                  ? _sendingAnimation()
                  : Center(
                    child: Text(
                      'Send Now',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(16),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _sendingAnimation() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const _BouncingDots(),
      SizedBox(width: AppResponsive.w(10)),
      Text(
        'Sending...',
        style: TextStyle(
          fontSize: AppResponsive.fs(15),
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      SizedBox(width: AppResponsive.w(10)),
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 800),
        builder:
            (_, v, __) => Transform.translate(
              offset: Offset(v * 6, 0),
              child: Opacity(
                opacity: 1 - v * 0.3,
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: AppResponsive.sp(16),
                ),
              ),
            ),
      ),
    ],
  );
}

// Bouncing dots (unchanged logic, sizes responsive)
class _BouncingDots extends StatefulWidget {
  const _BouncingDots();
  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder:
        (_, __) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
            final bounce = (phase < 0.5 ? phase : 1 - phase) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: AppResponsive.sp(6),
              height: AppResponsive.sp(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6 + bounce * 0.4),
                shape: BoxShape.circle,
              ),
              transform: Matrix4.translationValues(0, -bounce * 4, 0),
            );
          }),
        ),
  );
}
