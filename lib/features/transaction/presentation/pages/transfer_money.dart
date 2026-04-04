import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/auth/domain/entities/app_user.dart';
import 'package:flowpay/features/auth/presentation/components/my_textfield.dart';
import 'package:flowpay/features/transaction/presentation/components/fav_plus_money_btn.dart';
import 'package:flowpay/features/transaction/presentation/components/money_flow_form.dart';
import 'package:flowpay/features/transaction/presentation/cubit/amnt_plus_cmnt_cubit.dart';
import 'package:flowpay/features/transaction/presentation/pages/transfer_money_2.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/transaction_cubit.dart';

class TransferMoney extends StatefulWidget {
  final AppUser? receiver;

  const TransferMoney({super.key, this.receiver});

  @override
  State<TransferMoney> createState() => _TransferMoneyState();
}

class _TransferMoneyState extends State<TransferMoney> {
  final recipentController = TextEditingController();
  final amountController = TextEditingController();
  final commentController = TextEditingController();

  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Stream<AppUser?>? receiverStream;
  AppUser? selectedReceiver;

  Timer? _debounce;

  // flag to know if receiver came from QR
  bool _isQrReceiver = false;

  @override
  void initState() {
    super.initState();

    if (widget.receiver != null) {
      // QR Flow: set receiver directly, fill field, skip stream
      _isQrReceiver = true;
      selectedReceiver = widget.receiver;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final phone = widget.receiver!.account?.phone ?? "";

        // remove listener before setting text so _onRecipientChanged
        //    does not fire and reset selectedReceiver to null
        recipentController.removeListener(_onRecipientChanged);
        recipentController.text = phone;

        // re-add listener after setting text
        recipentController.addListener(_onRecipientChanged);

        if (mounted) setState(() {});
      });
    } else {
      // manual flow: attach listener normally
      recipentController.addListener(_onRecipientChanged);
    }
  }

  void _onRecipientChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final account = recipentController.text.trim();

      if (!mounted) return;

      // if user edits the field after QR scan, switch back to manual mode
      if (_isQrReceiver) {
        _isQrReceiver = false;
      }

      setState(() {
        selectedReceiver = null;

        if (account.isEmpty) {
          receiverStream = null;
        } else {
          receiverStream = context
              .read<TransactionCubit>()
              .searchReceiverStream(account);
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    recipentController.dispose();
    amountController.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        actions: const [Icon(Icons.notifications_outlined)],
        backgroundColor: const Color(0xffFFFFFF),
      ),

      body: Padding(
        padding: context.padSymmetricPx(horizontal: 25),
        child: SingleChildScrollView(
          child: Column(
            children: [
              context.spaceHPx(10),

              const Text(
                'send Money via flowPay Wallet',
                style: TextStyle(fontSize: 12),
              ),

              context.spaceHPx(25),

              MoneyFlowForm(),

              context.spaceHPx(20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Transfer Details',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),

              context.spaceHPx(12),

              //  RECEIVER CARD LOGIC:
              // - QR flow   → show _receiverCard directly with widget.receiver
              // - Manual flow → show _receiverStreamCard (handles search stream)
              _isQrReceiver && widget.receiver != null
                  ? _receiverCard(widget.receiver!)
                  : _receiverStreamCard(),

              context.spaceHPx(12),

              /// RECIPIENT FIELD
              textPlusTextField(
                text: 'Recipient',
                textField: MyTextField(
                  controller: recipentController,
                  hintText: 'Enter account no',
                  obscureText: false,
                ),
              ),

              context.spaceHPx(10),

              /// AMOUNT
              textPlusTextField(
                text: 'Amount',
                textField: MyTextField(
                  controller: amountController,
                  hintText: 'Rs. 00 - 30,000.',
                  obscureText: false,
                  onChange: (value) {
                    context.read<AmountCubit>().reflectAmount(value);
                  },
                ),
              ),

              context.spaceHPx(10),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Comment (Optional)'),
              ),

              TextFormField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter Comment',
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

              context.spaceHPx(25),

              /// SEND BUTTON
              FavPlusMoneyBtn(
                onTap: () {
                  // Validate receiver
                  if (selectedReceiver == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid receiver"),
                      ),
                    );
                    return;
                  }

                  // Validate amount field is not empty
                  final amountText = amountController.text.trim();
                  if (amountText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter an amount")),
                    );
                    return;
                  }

                  // Validate amount is a valid number
                  final double? amount = double.tryParse(amountText);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid amount"),
                      ),
                    );
                    return;
                  }

                  final trxId =
                      "FP-TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => TransferMoney2(
                            senderAccountId: currentUserId,
                            receiver: selectedReceiver!,
                            amount: amount,
                            comment: commentController.text.trim(),
                            transactionId: trxId,
                          ),
                    ),
                  );
                },
                buttoncontent: Row(
                  children: [
                    context.spaceWPx(15),
                    const Text(
                      'Send Rs . ',
                      style: TextStyle(color: Colors.white),
                    ),
                    BlocBuilder<AmountCubit, String>(
                      builder: (context, amount) {
                        return Text(
                          amount,
                          style: const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ],
                ),
              ),

              context.spaceHPx(30),
            ],
          ),
        ),
      ),
    );
  }

  // UNIFIED receiver card — used for both QR and stream result
  Widget _receiverCard(AppUser receiver) {
    return Container(
      height: context.hPx(88),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        color: const Color(0xffFBFCFF),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child:
              receiver.profileImageUrl != null &&
                      receiver.profileImageUrl!.isNotEmpty
                  ? Image.network(
                    receiver.profileImageUrl!,
                    height: context.hPx(45),
                    width: context.wPx(45),
                    fit: BoxFit.cover,
                    // Graceful fallback if network image fails
                    errorBuilder:
                        (context, error, stackTrace) =>
                            Image.asset('assets/navigation/profile.png'),
                  )
                  : Image.asset('assets/navigation/profile.png'),
        ),
        title: Text(
          receiver.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        // Phone now correctly shown in both QR and manual flow
        subtitle: Text('Flowpay  ${receiver.account?.phone ?? ""}'),
      ),
    );
  }

  // STREAM CARD — only used during manual search
  Widget _receiverStreamCard() {
    // No stream yet (field is empty) → show nothing
    if (receiverStream == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<AppUser?>(
      stream: receiverStream,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // No result found
        if (!snapshot.hasData || snapshot.data == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "No account found",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final receiver = snapshot.data!;

        // Safely update selectedReceiver after build completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && selectedReceiver?.uid != receiver.uid) {
            setState(() => selectedReceiver = receiver);
          }
        });

        return _receiverCard(receiver);
      },
    );
  }

  Widget textPlusTextField({
    required String text,
    required MyTextField textField,
  }) {
    return Column(
      children: [
        Align(alignment: Alignment.centerLeft, child: Text(text)),
        textField,
      ],
    );
  }
}
