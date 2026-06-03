import 'package:flowpay/features/transaction/presentation/components/activity_button.dart';
import 'package:flowpay/features/transaction/presentation/components/payment_recipt.dart';
import 'package:flowpay/features/transaction/presentation/cubit/recipt_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../../../auth/domain/entities/app_user.dart';

class PaymentSuccessPage extends StatefulWidget {
  final double amount;
  final AppUser reciver;
  final String transactionId;

  const PaymentSuccessPage({
    super.key,
    required this.amount,
    required this.reciver,
    required this.transactionId,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with TickerProviderStateMixin {
  // ── Circle pulse (outer ring expanding outward like Easypaisa) ─────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  // ── Success icon scale pop ─────────────
  late AnimationController _iconCtrl;
  late Animation<double> _iconScale;

  // ── Tick draw (stroke fills in) ─────────────
  late AnimationController _tickCtrl;
  late Animation<double> _tickProgress;

  // ── Content slide up ─────────────
  late AnimationController _contentCtrl;
  late Animation<Offset> _contentSlide;
  late Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();

    // Pulse ring
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

    // Icon pop
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _iconCtrl, curve: Curves.elasticOut));

    // Tick draw
    _tickCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _tickProgress = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _tickCtrl, curve: Curves.easeInOut));

    // Content
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

    // Sequence: icon pops first → tick draws → content slides up
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

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: AppResponsive.h(40)),

              // ── Animated success icon ─────────────────────────────────
              _AnimatedSuccessIcon(
                pulseScale: _pulseScale,
                pulseOpacity: _pulseOpacity,
                iconScale: _iconScale,
                tickProgress: _tickProgress,
              ),

              SizedBox(height: AppResponsive.h(24)),

              // ── Title + subtitle ──────────────────────────────────────
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
                      SizedBox(height: AppResponsive.h(6)),
                      Text(
                        'Your payment has been processed',
                        style: TextStyle(
                          fontSize: AppResponsive.fs(13),
                          color: const Color(0xff737373),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppResponsive.h(24)),

              // ── Receipt ───────────────────────────────────────────────
              FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: PaymentRecipt(
                    amount: widget.amount,
                    serviceFee: 0.00,
                    totalAmount: widget.amount,
                    reciverName: widget.reciver.name,
                    dateAndTime: DateTime.now(),
                    paymentMethod: 'FlowPay',
                    transactionID: widget.transactionId,
                  ),
                ),
              ),

              SizedBox(height: AppResponsive.h(24)),

              // ── Action buttons ────────────────────────────────────────
              FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ActivityButton(
                          imagePath: 'assets/transfer/share_with.png',
                          buttonColor: const Color(0xffDFE5FF),
                          buttonName: 'Share receipt',
                          textColor: Colors.black,
                          onTap:
                              () => context.read<ReceiptCubit>().shareReceipt(
                                receiverName: widget.reciver.name,
                                amount: widget.amount,
                                transactionId: widget.transactionId,
                              ),
                        ),
                      ),
                      SizedBox(width: AppResponsive.w(16)),
                      Expanded(
                        child: ActivityButton(
                          imagePath: 'assets/transfer/download.png',
                          buttonColor: const Color(0xff007AFF),
                          buttonName: 'Download',
                          textColor: Colors.white,
                          onTap:
                              () async =>
                                  context.read<ReceiptCubit>().downloadReceipt(
                                    receiverName: widget.reciver.name,
                                    amount: widget.amount,
                                    transactionId: widget.transactionId,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Animated success icon  (Easypaisa-style pulse + tick draw)
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedSuccessIcon extends StatelessWidget {
  final Animation<double> pulseScale;
  final Animation<double> pulseOpacity;
  final Animation<double> iconScale;
  final Animation<double> tickProgress;

  const _AnimatedSuccessIcon({
    required this.pulseScale,
    required this.pulseOpacity,
    required this.iconScale,
    required this.tickProgress,
  });

  @override
  Widget build(BuildContext context) {
    final size = AppResponsive.sp(110).clamp(80.0, 140.0);

    return SizedBox(
      width: size * 1.8,
      height: size * 1.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring
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

          // Middle ring (static, slightly smaller)
          Container(
            width: size * 0.92,
            height: size * 0.92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xff007AFF).withOpacity(0.08),
            ),
          ),

          // Main icon circle — pops in with elastic scale
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

// ─────────────────────────────────────────────────────────────────────────────
//  Tick painter — draws the checkmark progressively
// ─────────────────────────────────────────────────────────────────────────────
class _TickPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  _TickPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = size.width * 0.09
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Tick path: short leg then long leg
    final p1 = Offset(cx - size.width * 0.22, cy + size.height * 0.02);
    final p2 = Offset(cx - size.width * 0.04, cy + size.height * 0.20);
    final p3 = Offset(cx + size.width * 0.26, cy - size.height * 0.18);

    // Total path length (approx)
    final leg1 = (p2 - p1).distance;
    final leg2 = (p3 - p2).distance;
    final total = leg1 + leg2;
    final drawn = progress * total;

    final path = Path();
    if (drawn <= leg1) {
      // Drawing first leg
      final t = drawn / leg1;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t);
    } else {
      // First leg done, drawing second
      final t = (drawn - leg1) / leg2;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      path.lineTo(p2.dx + (p3.dx - p2.dx) * t, p2.dy + (p3.dy - p2.dy) * t);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TickPainter old) => old.progress != progress;
}
