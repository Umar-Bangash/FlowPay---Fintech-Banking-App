import 'package:flowpay/features/stripe_payment/data/service/payment_service.dart';
import 'package:flowpay/features/stripe_payment/domain/entities/payment.dart';
import 'package:flowpay/features/stripe_payment/presentation/cubit/payment_cubit.dart';
import 'package:flowpay/features/stripe_payment/presentation/cubit/payment_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../helpers/ui_responsive_helper.dart';

class PaymentPage extends StatefulWidget {
  final String userId;
  const PaymentPage({super.key, required this.userId});
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with SingleTickerProviderStateMixin {
  final _amountCtrl = TextEditingController();
  bool _processing = false;

  // Existing entry animation — KEPT INTACT
  late AnimationController _animCtrl;
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
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay(BuildContext context) async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      _snack(context, 'Please enter a valid amount', err: true);
      return;
    }
    setState(() => _processing = true);
    try {
      await StripeService.instance.makePaymentAndDeposit(amount: amount);
      if (!mounted) return;
      context.read<PaymentCubit>().createPayment(
        Payment(
          paymentId: 'FP-PAY-${DateTime.now().millisecondsSinceEpoch}',
          userId: widget.userId,
          amount: amount,
          method: 'Stripe',
          status: 'Completed',
          dateTime: DateTime.now(),
        ),
      );
      if (!mounted) return;
      _showSuccessSheet(context, amount);
      _amountCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      final err = e.toString();
      if (err.contains('cancel') ||
          err.contains('Cancel') ||
          err.contains('Cancelled')) {
        return;
      }
      _snack(context, err.replaceAll('Exception: ', ''), err: true);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _snack(BuildContext context, String msg, {bool err = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              err ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: AppResponsive.sp(16),
            ),
            SizedBox(width: AppResponsive.w(10)),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(fontSize: AppResponsive.fs(13)),
              ),
            ),
          ],
        ),
        backgroundColor: err ? const Color(0xFFE53935) : _success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
        ),
        margin: EdgeInsets.all(AppResponsive.w(16)),
      ),
    );
  }

  void _showSuccessSheet(BuildContext context, double amount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      isScrollControlled: true,
      builder:
          (_) => Container(
            decoration: const BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.all(AppResponsive.w(26)),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppResponsive.sp(68),
                    height: AppResponsive.sp(68),
                    decoration: BoxDecoration(
                      color: _success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: _success,
                      size: AppResponsive.sp(42),
                    ),
                  ),
                  SizedBox(height: AppResponsive.h(14)),
                  Text(
                    'Deposit Successful!',
                    style: TextStyle(
                      fontSize: AppResponsive.fs(19),
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  SizedBox(height: AppResponsive.h(7)),
                  Text(
                    'Rs. ${amount.toStringAsFixed(0)} has been deducted\n'
                    'from your FlowPay wallet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppResponsive.fs(13),
                      color: _textMid,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: AppResponsive.h(24)),
                  SizedBox(
                    width: double.infinity,
                    height: AppResponsive.h(52),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppResponsive.radiusMd,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: AppResponsive.fs(15),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppResponsive.h(6)),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
          child: Icon(
            Icons.arrow_back_ios,
            size: AppResponsive.sp(16),
            color: _textDark,
          ),
        ),
        title: Text(
          'Deposit',
          style: TextStyle(
            fontSize: AppResponsive.fs(15),
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: AppResponsive.w(16)),
            child: Icon(
              Icons.notifications_outlined,
              color: _textDark,
              size: AppResponsive.sp(22),
            ),
          ),
        ],
      ),
      body: BlocConsumer<PaymentCubit, PaymentStates>(
        listener: (context, state) {
          if (state is PaymentError) {
            _snack(context, state.message, err: true);
          }
        },
        builder: (context, state) {
          // ── Entry animation is KEPT exactly as original ──────────────
          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppResponsive.h(18)),
                    _infoCard(),
                    SizedBox(height: AppResponsive.h(24)),
                    Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(14),
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    SizedBox(height: AppResponsive.h(14)),
                    _label('Amount'),
                    SizedBox(height: AppResponsive.h(8)),
                    _amountField(),
                    SizedBox(height: AppResponsive.h(14)),
                    _cardNote(),
                    SizedBox(height: AppResponsive.h(28)),
                    _payBtn(context, state),
                    SizedBox(height: AppResponsive.h(20)),
                    _poweredBy(),
                    SizedBox(height: AppResponsive.h(30)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard() => Container(
    width: double.infinity,
    padding: EdgeInsets.all(AppResponsive.w(18)),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1A6BFF), Color(0xFF4D8FFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
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
              padding: EdgeInsets.all(AppResponsive.sp(7)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
              ),
              child: Icon(
                Icons.credit_card_rounded,
                color: Colors.white,
                size: AppResponsive.sp(20),
              ),
            ),
            SizedBox(width: AppResponsive.w(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stripe Secure Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: AppResponsive.fs(14),
                    ),
                  ),
                  Text(
                    'Bank-grade encryption',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: AppResponsive.fs(11),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppResponsive.w(8),
                vertical: AppResponsive.h(3),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Sandbox',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppResponsive.fs(10),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppResponsive.h(16)),
        const Divider(color: Colors.white24, height: 1),
        SizedBox(height: AppResponsive.h(14)),
        Row(
          children: const [
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

  Widget _label(String t) => Text(
    t,
    style: TextStyle(
      fontSize: AppResponsive.fs(12),
      fontWeight: FontWeight.w500,
      color: _textDark,
    ),
  );

  Widget _amountField() => Container(
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
      border: Border.all(color: _border),
    ),
    child: TextField(
      controller: _amountCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: TextStyle(
        fontSize: AppResponsive.fs(15),
        fontWeight: FontWeight.w600,
        color: _textDark,
      ),
      decoration: InputDecoration(
        hintText: '0.00',
        hintStyle: TextStyle(
          color: _textMid.withOpacity(0.5),
          fontWeight: FontWeight.w400,
          fontSize: AppResponsive.fs(15),
        ),
        prefixIcon: Container(
          margin: EdgeInsets.only(
            left: AppResponsive.w(12),
            right: AppResponsive.w(8),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppResponsive.w(8),
            vertical: AppResponsive.h(5),
          ),
          decoration: BoxDecoration(
            color: _primaryLight,
            borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
          ),
          child: Text(
            'Rs.',
            style: TextStyle(
              color: _primary,
              fontWeight: FontWeight.w700,
              fontSize: AppResponsive.fs(12),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppResponsive.w(14),
          vertical: AppResponsive.h(15),
        ),
      ),
      onChanged: (_) => setState(() {}),
    ),
  );

  Widget _cardNote() => Container(
    padding: EdgeInsets.all(AppResponsive.w(13)),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E7),
      borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
      border: Border.all(color: const Color(0xFFFFE0A3)),
    ),
    child: Row(
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: AppResponsive.sp(16),
          color: const Color(0xFFE6A817),
        ),
        SizedBox(width: AppResponsive.w(8)),
        Expanded(
          child: Text(
            "Your card details will be securely entered in the next step "
            "via Stripe's payment sheet.",
            style: TextStyle(
              fontSize: AppResponsive.fs(11),
              color: const Color(0xFF7A5500),
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _payBtn(BuildContext context, PaymentStates state) {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final isReady = amount > 0 && !_processing;
    return SizedBox(
      width: double.infinity,
      height: AppResponsive.h(54),
      child: ElevatedButton(
        onPressed: isReady ? () => _pay(context) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: _border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
          ),
          elevation: isReady ? 4 : 0,
          shadowColor: _primary.withOpacity(0.3),
        ),
        child:
            _processing || state is PaymentLoading
                ? SizedBox(
                  width: AppResponsive.sp(20),
                  height: AppResponsive.sp(20),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: AppResponsive.sp(16),
                    ),
                    SizedBox(width: AppResponsive.w(7)),
                    Text(
                      amount > 0
                          ? 'Deposit Rs. ${amount.toStringAsFixed(0)}'
                          : 'Pay with Stripe',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: AppResponsive.fs(15),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _poweredBy() => Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.security_rounded,
          size: AppResponsive.sp(13),
          color: _textMid,
        ),
        SizedBox(width: AppResponsive.w(5)),
        Text(
          'Secured & Powered by Stripe',
          style: TextStyle(
            fontSize: AppResponsive.fs(11),
            color: _textMid.withOpacity(0.7),
          ),
        ),
      ],
    ),
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: AppResponsive.sp(12), color: Colors.white70),
      SizedBox(width: AppResponsive.w(3)),
      // Flexible + overflow:ellipsis so text shrinks instead of overflowing
      Flexible(
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white70,
            fontSize: AppResponsive.fs(10),
          ),
        ),
      ),
    ],
  );
}
