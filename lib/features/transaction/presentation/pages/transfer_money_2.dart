import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/account/presentation/cubit/account_cubit.dart';
import 'package:flowpay/features/account/presentation/cubit/account_states.dart';
import 'package:flowpay/features/auth/domain/entities/app_user.dart';
import 'package:flowpay/features/notification/data/repo/notification_repo_impl.dart';
import 'package:flowpay/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_states.dart';
import 'package:flowpay/features/transaction/presentation/components/card_detail.dart';
import 'package:flowpay/features/transaction/presentation/components/transfer_details.dart';
import 'package:flowpay/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:flowpay/features/transaction/presentation/cubit/transaction_states.dart';
import 'package:flowpay/features/transaction/presentation/pages/payment_success_page.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final notificationRepo = NotificationRepoImpl();
  bool _isSending = false;

  late AnimationController _btnController;
  late Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    context.read<ProfileCubit>().fetchProfileUser(uid);

    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _btnScale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _btnController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _btnController.dispose();
    super.dispose();
  }

  String getFormattedDate() {
    final now = DateTime.now();
    final months = [
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
    return "${now.year} - ${months[now.month - 1]} - ${now.day}";
  }

  // ─────────────────────────────────────────────
  // SHOW AUTH BOTTOM SHEET
  // ─────────────────────────────────────────────
  Future<void> _showAuthSheet() async {
    if (_isSending) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      isDismissible: true,
      builder:
          (_) => AuthBottomSheet(
            uid: uid,
            onVerified: () {
              // sheet already closed by AuthBottomSheet internally
              _executeTransaction();
            },
          ),
    );
  }

  // ─────────────────────────────────────────────
  // EXECUTE TRANSACTION
  // ─────────────────────────────────────────────
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
    final formattedDate = getFormattedDate();

    final safeReceiverImage =
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
        backgroundColor: const Color(0xffFFFFFF),
        appBar: AppBar(
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, size: 20),
          ),
          centerTitle: true,
          title: const Text(
            'Transfer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          actions: [
            const Icon(Icons.notifications_outlined),
            context.spaceWPx(15),
          ],
          backgroundColor: const Color(0xffFFFFFF),
        ),
        body: Padding(
          padding: context.padSymmetricPx(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              context.spaceHPx(20),

              const Text(
                'Confirm Transfer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              context.spaceHPx(4),
              const Text(
                'Please review all details carefully before sending.',
                style: TextStyle(fontSize: 12),
              ),
              context.spaceHPx(20),

              // ── Sender + Receiver Cards ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sender card
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/transfer/flowpay_card.png',
                          width: context.wPx(170),
                          height: context.hPx(160),
                          fit: BoxFit.cover,
                        ),
                      ),
                      BlocBuilder<ProfileCubit, ProfileStates>(
                        builder: (context, state) {
                          String senderName = 'No user found';
                          String? senderImage;
                          if (state is ProfileLoaded) {
                            senderName = state.profileUser.name;
                            senderImage = state.profileUser.profileImageUrl;
                          }

                          final accountState =
                              context.read<AccountCubit>().state;
                          final senderPhone =
                              (accountState is AccountLoaded &&
                                      accountState.accounts.isNotEmpty)
                                  ? accountState.accounts.first.phone
                                  : 'No Phone';

                          return CardDetail(
                            image: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child:
                                  (senderImage != null &&
                                          senderImage.isNotEmpty &&
                                          senderImage != 'null')
                                      ? Image.network(
                                        senderImage,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (c, e, s) => const Icon(
                                              Icons.person,
                                              size: 40,
                                            ),
                                      )
                                      : const Icon(Icons.person, size: 40),
                            ),
                            imageCardColor: const Color(0xffCFE8FE),
                            name: senderName,
                            titleColor: const Color(0xffFFFFFF),
                            subTitle: Row(
                              children: [
                                Container(
                                  height: context.hPx(20),
                                  width: context.wPx(50),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.4),
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Flowpay',
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                context.spaceWPx(10),
                                Text(
                                  senderPhone,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  Image.asset(
                    'assets/transfer/arrow.png',
                    height: context.hPx(24),
                    width: context.wPx(24),
                  ),

                  // Receiver card
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/transfer/stripe_card.png',
                          width: context.wPx(170),
                          height: context.hPx(160),
                          fit: BoxFit.cover,
                        ),
                      ),
                      CardDetail(
                        image:
                            safeReceiverImage != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.network(
                                    safeReceiverImage,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (c, e, s) =>
                                            const Icon(Icons.person, size: 40),
                                  ),
                                )
                                : const Icon(Icons.person, size: 40),
                        imageCardColor: const Color.fromARGB(255, 113, 34, 249),
                        name: widget.receiver.name,
                        titleColor: const Color(0xff000000),
                        subTitle: Row(
                          children: [
                            Container(
                              height: context.hPx(20),
                              width: context.wPx(50),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.4),
                                color: Colors.white.withOpacity(0.4),
                              ),
                              child: const Center(
                                child: Text(
                                  'Flowpay',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            context.spaceWPx(10),
                            Text(
                              widget.receiver.account?.phone ?? 'No Phone',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              context.spaceHPx(20),

              const Text(
                'Transfer Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              context.spaceHPx(15),

              TransferDetails(
                amountSent: 'Rs. ${widget.amount.toStringAsFixed(2)}',
                feeTax: 'Free',
                date: formattedDate,
                transactionId: widget.transactionId,
              ),

              context.spaceHPx(20),

              // ── Animated Send Button ──
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ANIMATED SEND BUTTON
  // ─────────────────────────────────────────────
  Widget _buildSendButton() {
    return ScaleTransition(
      scale: _btnScale,
      child: GestureDetector(
        onTapDown: (_) => _btnController.forward(),
        onTapUp: (_) async {
          await _btnController.reverse();
          if (!_isSending) _showAuthSheet();
        },
        onTapCancel: () => _btnController.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color:
                _isSending
                    ? const Color(0xff1A73E8).withOpacity(0.85)
                    : const Color(0xff1A73E8),
          ),
          child:
              _isSending
                  ? _buildSendingAnimation()
                  : const Center(
                    child: Text(
                      'Send Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SENDING ANIMATION
  // ─────────────────────────────────────────────
  Widget _buildSendingAnimation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _BouncingDots(),
        const SizedBox(width: 12),
        const Text(
          'Sending...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(value * 6, 0),
              child: Opacity(
                opacity: 1 - (value * 0.3),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// BOUNCING DOTS
// ─────────────────────────────────────────────
class _BouncingDots extends StatefulWidget {
  const _BouncingDots();

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = ((_controller.value * 3) - i).clamp(0.0, 1.0);
            final bounce = (phase < 0.5 ? phase : 1 - phase) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6 + bounce * 0.4),
                shape: BoxShape.circle,
              ),
              transform: Matrix4.translationValues(0, -bounce * 4, 0),
            );
          }),
        );
      },
    );
  }
}



// the down commented code is very important !**********!

// showModalBottomSheet(
                //   context: context,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.vertical(
                //       top: Radius.circular(24),
                //     ),
                //   ),
                //   backgroundColor: Colors.white,
                //   isScrollControlled:
                //       true, // allows full height bottom sheet if needed
                //   builder: (context) {
                //     String? selected;

                //     return StatefulBuilder(
                //       builder: (context, setModalState) {
                //         return Padding(
                //           padding: EdgeInsets.only(
                //             bottom: MediaQuery.of(context).viewInsets.bottom,
                //           ),
                //           child: Container(
                //             padding: const EdgeInsets.all(15),
                //             height: context.hPx(429),
                //             child: SizedBox(
                //               width: double.maxFinite,
                //               child: Column(
                //                 crossAxisAlignment: CrossAxisAlignment.center,
                //                 children: [
                //                   InkWell(
                //                     onTap: () => Navigator.pop(context),
                //                     child: Align(
                //                       alignment: Alignment.centerRight,
                //                       child: Image.asset(
                //                         'assets/transfer/cancel.png',
                //                         height: context.hPx(24),
                //                         width: context.wPx(24),
                //                       ),
                //                     ),
                //                   ),
                //                   Text(
                //                     'Authorize Payment',
                //                     style: TextStyle(
                //                       fontSize: 24,
                //                       fontWeight: FontWeight.bold,
                //                     ),
                //                   ),
                //                   SizedBox(height: 10),
                //                   Text(
                //                     'Authenicate with your fingeprint / Face \nID to authorize this transfer.',
                //                     style: TextStyle(
                //                       fontSize: 16,
                //                       color: Color(0xff737373),
                //                     ),
                //                   ),
                //                   context.spaceHPx(20),

                //                   Center(
                //                     child: Row(
                //                       mainAxisAlignment:
                //                           MainAxisAlignment.center,
                //                       children: [
                //                         // ignore: unnecessary_null_comparison
                //                         if (selected == null ||
                //                             selected == 'face')
                //                           BiometricCircle(
                //                             biometricImagePath:
                //                                 'assets/images/face.png',
                //                             biometricName: 'Face ID',
                //                             onTap: () {
                //                               setModalState(() {
                //                                 selected = 'face';
                //                               });
                //                             },
                //                           ),

                //                         if (selected == null)
                //                           context.spaceWPx(25),

                //                         if (selected == null ||
                //                             selected == 'finger')
                //                           BiometricCircle(
                //                             biometricImagePath:
                //                                 'assets/images/fingerprint.png',
                //                             biometricName: 'Fingerprint',
                //                             onTap: () {
                //                               setModalState(() {
                //                                 selected = 'finger';
                //                               });
                //                             },
                //                           ),
                //                       ],
                //                     ),
                //                   ),
                //                   context.spaceHPx(30),
                //                   Text(
                //                     '------------------ or Verify from ------------------',
                //                     style: TextStyle(
                //                       fontSize: 12,
                //                       color: Color(0xffA3A3A3),
                //                     ),
                //                   ),
                //                   context.spaceHPx(30),
                //                   MainButton(
                //                     buttonName: 'Verify through Biometric',
                //                     onTap: () {
                //                       Navigator.push(
                //                         context,
                //                         MaterialPageRoute(
                //                           builder:
                //                               (context) => PaymentSuccessPage(
                //                                 amount: amount,
                //                                 reciver: reciver,
                //                                 transactionId:
                //                                     DateTime.now()
                //                                         .microsecondsSinceEpoch
                //                                         .toString(),
                //                               ),
                //                         ),
                //                       );
                //                     },
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ),
                //         );
                //       },
                //     );
                //   },
                // );