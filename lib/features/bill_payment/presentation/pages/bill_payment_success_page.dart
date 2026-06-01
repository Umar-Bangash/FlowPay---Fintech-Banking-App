import 'package:flowpay/features/bill_payment/presentation/components/bill_pages_appbar.dart';
import 'package:flowpay/features/bill_payment/presentation/cubit/bill_cubit.dart';
import 'package:flowpay/features/bill_payment/presentation/cubit/bill_states.dart';
import 'package:flowpay/features/bill_payment/presentation/components/categories_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../helpers/ui_responsive_helper.dart';

class BillPaymentSuccessPage extends StatefulWidget {
  const BillPaymentSuccessPage({super.key});
  @override
  State<BillPaymentSuccessPage> createState() => _BillPaymentSuccessPageState();
}

class _BillPaymentSuccessPageState extends State<BillPaymentSuccessPage>
    with TickerProviderStateMixin {
  // Same 3-stage Easypaisa animation
  late AnimationController _pulseCtrl, _iconCtrl, _tickCtrl, _contentCtrl;
  late Animation<double> _pulseScale,
      _pulseOpacity,
      _iconScale,
      _tickProgress,
      _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _pulseScale = Tween<double>(
      begin: 0.85,
      end: 1.6,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));
    _pulseOpacity = Tween<double>(
      begin: 0.55,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));

    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _iconCtrl, curve: Curves.elasticOut));

    _tickCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _tickProgress = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _tickCtrl, curve: Curves.easeInOut));

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
    );
    _contentFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeIn));

    _iconCtrl.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      _tickCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _iconCtrl.dispose();
    _tickCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  String _fmtDT(DateTime dt) =>
      DateFormat("MMM d, yyyy 'at' h:mm a").format(dt);

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: billAppBar(context, ''),
      body: BlocBuilder<BillCubit, BillState>(
        builder: (context, state) {
          if (state is BillLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BillSuccess) {
            final bill = state.bill;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: AppResponsive.h(28)),

                  // ── Animated success icon ────────────────────────────
                  _AnimatedSuccessIcon(
                    pulseScale: _pulseScale,
                    pulseOpacity: _pulseOpacity,
                    iconScale: _iconScale,
                    tickProgress: _tickProgress,
                  ),

                  SizedBox(height: AppResponsive.h(20)),

                  // ── Title ────────────────────────────────────────────
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        children: [
                          Text(
                            'Payment Successful!',
                            style: TextStyle(
                              fontSize: AppResponsive.fs(22),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppResponsive.h(5)),
                          Text(
                            'Your bill has been paid successfully',
                            style: TextStyle(
                              fontSize: AppResponsive.fs(13),
                              color: const Color(0xff737373),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(18)),

                  // ── Amount card ──────────────────────────────────────
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppResponsive.w(24),
                          vertical: AppResponsive.h(18),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffE5E5E5)),
                          borderRadius: BorderRadius.circular(
                            AppResponsive.radiusLg,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Amount Paid',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(13),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: AppResponsive.h(5)),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Rs ${bill.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: AppResponsive.fs(36, max: 44),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff21496A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(18)),

                  // ── Detail card ──────────────────────────────────────
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppResponsive.w(18)),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffE5E5E5)),
                          borderRadius: BorderRadius.circular(
                            AppResponsive.radiusLg,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Bill info row
                            Container(
                              padding: EdgeInsets.all(AppResponsive.w(12)),
                              decoration: BoxDecoration(
                                color: const Color(0xffFAFAFA),
                                borderRadius: BorderRadius.circular(
                                  AppResponsive.radiusMd,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: AppResponsive.sp(38),
                                    width: AppResponsive.sp(38),
                                    padding: EdgeInsets.all(
                                      AppResponsive.sp(8),
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffEFF6FF),
                                      borderRadius: BorderRadius.circular(
                                        AppResponsive.radiusSm,
                                      ),
                                    ),
                                    child: Image.asset(
                                      BillCategoryIcon.getIcon(bill.category),
                                    ),
                                  ),
                                  SizedBox(width: AppResponsive.w(12)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${bill.providerName} ${bill.category}',
                                          style: TextStyle(
                                            fontSize: AppResponsive.fs(13),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'ID: ${bill.consumerId}',
                                          style: TextStyle(
                                            fontSize: AppResponsive.fs(11),
                                            color: const Color(0xff737373),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: AppResponsive.h(12)),
                            _DetailRow('Transaction ID', bill.transactionId),
                            Divider(
                              height: AppResponsive.h(18),
                              color: const Color(0xffF0F0F0),
                            ),
                            _DetailRow(
                              'Date & Time',
                              _fmtDT(bill.transactionDateTime),
                            ),
                            Divider(
                              height: AppResponsive.h(18),
                              color: const Color(0xffF0F0F0),
                            ),
                            _DetailRow('Payment Method', 'Digital Wallet'),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(22)),

                  // ── Share / Download — Expanded, no overflow ──────────
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Row(
                        children: [
                          Expanded(
                            child: _ActionBtn(
                              imagePath: 'assets/transfer/share_with.png',
                              label: 'Share receipt',
                              bgColor: const Color(0xffDFE5FF),
                              textColor: Colors.black,
                              onTap: () {},
                            ),
                          ),
                          SizedBox(width: AppResponsive.w(14)),
                          Expanded(
                            child: _ActionBtn(
                              imagePath: 'assets/transfer/download.png',
                              label: 'Download',
                              bgColor: const Color(0xff007AFF),
                              textColor: Colors.white,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(30)),
                ],
              ),
            );
          }

          if (state is BillError) return Center(child: Text(state.message));
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: AppResponsive.fs(12),
          color: const Color(0xff737373),
        ),
      ),
      Flexible(
        child: Text(
          value,
          style: TextStyle(
            fontSize: AppResponsive.fs(12),
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

class _ActionBtn extends StatelessWidget {
  final String imagePath, label;
  final Color bgColor, textColor;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.imagePath,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
    child: Container(
      width: double.infinity,
      height: AppResponsive.h(50),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: AppResponsive.sp(17),
            width: AppResponsive.sp(17),
          ),
          SizedBox(width: AppResponsive.w(7)),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppResponsive.fs(13),
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

// Animated success icon (same as PaymentSuccessPage)
class _AnimatedSuccessIcon extends StatelessWidget {
  final Animation<double> pulseScale, pulseOpacity, iconScale, tickProgress;
  const _AnimatedSuccessIcon({
    required this.pulseScale,
    required this.pulseOpacity,
    required this.iconScale,
    required this.tickProgress,
  });
  @override
  Widget build(BuildContext context) {
    final size = AppResponsive.sp(100).clamp(80.0, 130.0);
    return SizedBox(
      width: size * 1.8,
      height: size * 1.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: pulseScale,
            builder:
                (_, __) => Transform.scale(
                  scale: pulseScale.value,
                  child: Opacity(
                    opacity: pulseOpacity.value,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xff007AFF).withOpacity(0.18),
                      ),
                    ),
                  ),
                ),
          ),
          Container(
            width: size * 0.92,
            height: size * 0.92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xff007AFF).withOpacity(0.08),
            ),
          ),
          ScaleTransition(
            scale: iconScale,
            child: Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xff007AFF),
              ),
              child: AnimatedBuilder(
                animation: tickProgress,
                builder:
                    (_, __) => CustomPaint(
                      painter: _TickPainter(progress: tickProgress.value),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TickPainter extends CustomPainter {
  final double progress;
  _TickPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final p =
        Paint()
          ..color = Colors.white
          ..strokeWidth = size.width * 0.09
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final p1 = Offset(cx - size.width * 0.22, cy + size.height * 0.02);
    final p2 = Offset(cx - size.width * 0.04, cy + size.height * 0.20);
    final p3 = Offset(cx + size.width * 0.26, cy - size.height * 0.18);
    final l1 = (p2 - p1).distance;
    final l2 = (p3 - p2).distance;
    final drawn = progress * (l1 + l2);
    final path = Path();
    if (drawn <= l1) {
      final t = drawn / l1;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t);
    } else {
      final t = (drawn - l1) / l2;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      path.lineTo(p2.dx + (p3.dx - p2.dx) * t, p2.dy + (p3.dy - p2.dy) * t);
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_TickPainter o) => o.progress != progress;
}
