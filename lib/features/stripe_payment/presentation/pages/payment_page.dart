import 'package:flowpay/features/stripe_payment/data/service/payment_service.dart';
import 'package:flowpay/features/stripe_payment/domain/entities/payment.dart';
import 'package:flowpay/features/stripe_payment/presentation/cubit/payment_cubit.dart';
import 'package:flowpay/features/stripe_payment/presentation/cubit/payment_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentPage extends StatefulWidget {
  final String userId;

  const PaymentPage({super.key, required this.userId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color _primary = Color(0xFF1A6BFF);
  static const Color _primaryLight = Color(0xFFEEF3FF);
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _surface = Color(0xFFF7F9FF);
  static const Color _border = Color(0xFFE5EAFF);
  static const Color _textDark = Color(0xFF0D1B3E);
  static const Color _textMid = Color(0xFF6B7A99);
  static const Color _success = Color(0xFF00C48C);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _makePayment(BuildContext context) async {
    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      _showSnack(context, "Please enter a valid amount", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Single call — Stripe sheet opens, balance updated, records saved,
      // notification fired — all handled inside StripeService
      await StripeService.instance.makePaymentAndDeposit(amount: amount);

      // Save to PaymentCubit to keep app state in sync
      if (!mounted) return;
      final payment = Payment(
        paymentId: "FP-PAY-${DateTime.now().millisecondsSinceEpoch}",
        userId: widget.userId,
        amount: amount,
        method: "Stripe",
        status: "Completed",
        dateTime: DateTime.now(),
      );
      context.read<PaymentCubit>().createPayment(payment);

      if (!mounted) return;
      _showSuccessSheet(context, amount);
      _amountController.clear();
    } catch (e) {
      if (!mounted) return;

      final err = e.toString();
      // Ignore user-cancelled Stripe sheet
      if (err.contains('cancel') ||
          err.contains('Cancel') ||
          err.contains('Cancelled'))
        return;

      _showSnack(context, err.replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSnack(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFE53935) : _success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSheet(BuildContext context, double amount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder:
          (_) => Container(
            decoration: const BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: _success,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Deposit Successful!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rs. ${amount.toStringAsFixed(0)} has been deducted\nfrom your FlowPay wallet',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _textMid,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(12),
          child: const Icon(Icons.arrow_back_ios, size: 18, color: _textDark),
        ),
        title: const Text(
          'Deposit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_outlined, color: _textDark),
          ),
        ],
      ),
      body: BlocConsumer<PaymentCubit, PaymentStates>(
        listener: (context, state) {
          if (state is PaymentError) {
            _showSnack(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _stripeInfoCard(),
                    const SizedBox(height: 28),
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Amount'),
                    const SizedBox(height: 8),
                    _amountField(),
                    const SizedBox(height: 16),
                    _cardEntryNote(),
                    const SizedBox(height: 32),
                    _payButton(context, state),
                    const SizedBox(height: 24),
                    _poweredByStripe(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _stripeInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A6BFF), Color(0xFF4D8FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.credit_card_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stripe Secure Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Bank-grade encryption',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Sandbox',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          const Row(
            children: [
              _InfoChip(icon: Icons.lock_outline, label: 'SSL Secured'),
              SizedBox(width: 12),
              _InfoChip(icon: Icons.verified_outlined, label: 'PCI Compliant'),
              SizedBox(width: 12),
              _InfoChip(icon: Icons.flash_on_outlined, label: 'Instant'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: _textDark,
      ),
    );
  }

  Widget _amountField() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _textDark,
        ),
        decoration: InputDecoration(
          hintText: '0.00',
          hintStyle: TextStyle(
            color: _textMid.withOpacity(0.5),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 14, right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Rs.',
              style: TextStyle(
                color: _primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _cardEntryNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0A3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFE6A817)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Your card details will be securely entered in the next step via Stripe's payment sheet.",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7A5500),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _payButton(BuildContext context, PaymentStates state) {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final isReady = amount > 0 && !_isProcessing;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isReady ? () => _makePayment(context) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: _border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isReady ? 4 : 0,
          shadowColor: _primary.withOpacity(0.3),
        ),
        child:
            _isProcessing || state is PaymentLoading
                ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      amount > 0
                          ? 'Deposit Rs. ${amount.toStringAsFixed(0)}'
                          : 'Pay with Stripe',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _poweredByStripe() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.security_rounded, size: 14, color: _textMid),
          const SizedBox(width: 6),
          Text(
            'Secured & Powered by Stripe',
            style: TextStyle(fontSize: 12, color: _textMid.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
