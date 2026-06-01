import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/auth/domain/entities/app_user.dart';
import 'package:flowpay/features/auth/presentation/components/my_textfield.dart';
import 'package:flowpay/features/transaction/presentation/components/fav_plus_money_btn.dart';
import 'package:flowpay/features/transaction/presentation/components/money_flow_form.dart';
import 'package:flowpay/features/transaction/presentation/cubit/amnt_plus_cmnt_cubit.dart';
import 'package:flowpay/features/transaction/presentation/pages/transfer_money_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../cubit/transaction_cubit.dart';

class TransferMoney extends StatefulWidget {
  final AppUser? receiver;
  const TransferMoney({super.key, this.receiver});
  @override
  State<TransferMoney> createState() => _TransferMoneyState();
}

class _TransferMoneyState extends State<TransferMoney> {
  final _recipientCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  final _currentUid = FirebaseAuth.instance.currentUser!.uid;

  Stream<AppUser?>? _receiverStream;
  AppUser? _selectedReceiver;
  Timer? _debounce;
  bool _isQrReceiver = false;

  @override
  void initState() {
    super.initState();
    if (widget.receiver != null) {
      _isQrReceiver = true;
      _selectedReceiver = widget.receiver;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final phone = widget.receiver!.account?.phone ?? '';
        _recipientCtrl.removeListener(_onRecipientChanged);
        _recipientCtrl.text = phone;
        _recipientCtrl.addListener(_onRecipientChanged);
        if (mounted) setState(() {});
      });
    } else {
      _recipientCtrl.addListener(_onRecipientChanged);
    }
  }

  void _onRecipientChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final account = _recipientCtrl.text.trim();
      if (!mounted) return;
      if (_isQrReceiver) _isQrReceiver = false;
      setState(() {
        _selectedReceiver = null;
        _receiverStream =
            account.isEmpty
                ? null
                : context.read<TransactionCubit>().searchReceiverStream(
                  account,
                );
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _recipientCtrl.dispose();
    _amountCtrl.dispose();
    _commentCtrl.dispose();
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
          'Transfer',
          style: TextStyle(
            fontSize: AppResponsive.fs(16),
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Icon(Icons.notifications_outlined, size: AppResponsive.sp(22)),
          SizedBox(width: AppResponsive.w(12)),
        ],
      ),
      body: AppAnimatedPage(
        direction: SlideDirection.bottom,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: AppResponsive.h(10)),

                // ── Subtitle ──────────────────────────────────────────────
                AppAnimatedItem(
                  index: 0,
                  direction: SlideDirection.left,
                  child: Text(
                    'send Money via flowPay Wallet',
                    style: TextStyle(
                      fontSize: AppResponsive.fs(12),
                      color: const Color(0xff737373),
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(22)),

                // ── Money flow form ───────────────────────────────────────
                AppAnimatedItem(
                  index: 1,
                  direction: SlideDirection.bottom,
                  child: MoneyFlowForm(),
                ),

                SizedBox(height: AppResponsive.h(20)),

                // ── Transfer details title ────────────────────────────────
                AppAnimatedItem(
                  index: 2,
                  direction: SlideDirection.left,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Transfer Details',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(15),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(12)),

                // ── Receiver card ─────────────────────────────────────────
                AppAnimatedItem(
                  index: 3,
                  direction: SlideDirection.right,
                  child:
                      _isQrReceiver && widget.receiver != null
                          ? _receiverCard(widget.receiver!)
                          : _receiverStreamCard(),
                ),

                SizedBox(height: AppResponsive.h(12)),

                // ── Recipient field ───────────────────────────────────────
                AppAnimatedItem(
                  index: 4,
                  direction: SlideDirection.left,
                  child: _labeledField(
                    label: 'Recipient',
                    field: MyTextField(
                      controller: _recipientCtrl,
                      hintText: 'Enter account no',
                      obscureText: false,
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(10)),

                // ── Amount field ──────────────────────────────────────────
                AppAnimatedItem(
                  index: 5,
                  direction: SlideDirection.right,
                  child: _labeledField(
                    label: 'Amount',
                    field: MyTextField(
                      controller: _amountCtrl,
                      hintText: 'Rs. 00 - 30,000.',
                      obscureText: false,
                      onChange:
                          (v) => context.read<AmountCubit>().reflectAmount(v),
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(10)),

                // ── Comment ───────────────────────────────────────────────
                AppAnimatedItem(
                  index: 6,
                  direction: SlideDirection.left,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Comment (Optional)',
                          style: TextStyle(fontSize: AppResponsive.fs(13)),
                        ),
                      ),
                      SizedBox(height: AppResponsive.h(6)),
                      TextFormField(
                        controller: _commentCtrl,
                        maxLines: 3,
                        style: TextStyle(fontSize: AppResponsive.fs(14)),
                        decoration: InputDecoration(
                          hintText: 'Enter Comment',
                          hintStyle: TextStyle(
                            fontSize: AppResponsive.fs(13),
                            color: const Color(0xffA3A3A3),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xffE5E5E5),
                            ),
                            borderRadius: BorderRadius.circular(
                              AppResponsive.radiusMd,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xff007AFF),
                            ),
                            borderRadius: BorderRadius.circular(
                              AppResponsive.radiusMd,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppResponsive.h(25)),

                // ── Send button ───────────────────────────────────────────
                AppAnimatedItem(
                  index: 7,
                  direction: SlideDirection.bottom,
                  child: FavPlusMoneyBtn(
                    receiver: _selectedReceiver,
                    onTap: () {
                      if (_selectedReceiver == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid receiver'),
                          ),
                        );
                        return;
                      }
                      final amountText = _amountCtrl.text.trim();
                      if (amountText.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter an amount'),
                          ),
                        );
                        return;
                      }
                      final amount = double.tryParse(amountText);
                      if (amount == null || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid amount'),
                          ),
                        );
                        return;
                      }
                      final trxId =
                          'FP-TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => TransferMoney2(
                                senderAccountId: _currentUid,
                                receiver: _selectedReceiver!,
                                amount: amount,
                                comment: _commentCtrl.text.trim(),
                                transactionId: trxId,
                              ),
                        ),
                      );
                    },
                    buttoncontent: Row(
                      children: [
                        SizedBox(width: AppResponsive.w(12)),
                        Text(
                          'Send Rs . ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppResponsive.fs(14),
                          ),
                        ),
                        BlocBuilder<AmountCubit, String>(
                          builder:
                              (_, amount) => Text(
                                amount,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppResponsive.fs(14),
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(30)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiverCard(AppUser receiver) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
        color: const Color(0xffFBFCFF),
        border: Border.all(color: const Color(0xffF0F0F0)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppResponsive.w(14),
          vertical: AppResponsive.h(6),
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
          child: SizedBox(
            width: AppResponsive.sp(44),
            height: AppResponsive.sp(44),
            child:
                (receiver.profileImageUrl?.isNotEmpty ?? false)
                    ? Image.network(
                      receiver.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              Image.asset('assets/navigation/profile.png'),
                    )
                    : Image.asset('assets/navigation/profile.png'),
          ),
        ),
        title: Text(
          receiver.name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: AppResponsive.fs(14),
          ),
        ),
        subtitle: Text(
          'Flowpay  ${receiver.account?.phone ?? ''}',
          style: TextStyle(
            fontSize: AppResponsive.fs(12),
            color: const Color(0xff737373),
          ),
        ),
      ),
    );
  }

  Widget _receiverStreamCard() {
    if (_receiverStream == null) return const SizedBox.shrink();
    return StreamBuilder<AppUser?>(
      stream: _receiverStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppResponsive.h(8)),
            child: Text(
              'No account found',
              style: TextStyle(
                color: Colors.grey,
                fontSize: AppResponsive.fs(13),
              ),
            ),
          );
        }
        final receiver = snapshot.data!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedReceiver?.uid != receiver.uid) {
            setState(() => _selectedReceiver = receiver);
          }
        });
        return _receiverCard(receiver);
      },
    );
  }

  Widget _labeledField({required String label, required Widget field}) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(label, style: TextStyle(fontSize: AppResponsive.fs(13))),
        ),
        field,
      ],
    );
  }
}
