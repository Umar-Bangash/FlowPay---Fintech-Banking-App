import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../../../transaction/presentation/cubit/transaction_cubit.dart';
import '../../../transaction/presentation/pages/transfer_money.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});
  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage>
    with SingleTickerProviderStateMixin {
  bool _scanned = false;

  // Animated scan line
  late AnimationController _scanCtrl;
  late Animation<double> _scanAnim;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanAnim = CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Scan QR',
          style: TextStyle(
            fontSize: AppResponsive.fs(17),
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: AppAnimatedPage(
        direction: SlideDirection.bottom,
        child: Column(
          children: [
            SizedBox(height: AppResponsive.h(24)),

            AppAnimatedItem(
              index: 0,
              direction: SlideDirection.bottom,
              child: Text(
                'Scan receiver QR to send money',
                style: TextStyle(
                  fontSize: AppResponsive.fs(15),
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: AppResponsive.h(24)),

            // ── Scanner with overlay frame ────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(20)),
                child: LayoutBuilder(
                  builder: (context, c) {
                    // Frame is square, 80% of available width
                    final frameSize = (c.maxWidth * 0.80).clamp(200.0, 320.0);

                    return Stack(
                      children: [
                        // Camera
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppResponsive.radiusLg,
                          ),
                          child: MobileScanner(
                            onDetect: (capture) async {
                              if (_scanned) return;
                              for (final barcode in capture.barcodes) {
                                final uid = barcode.rawValue;
                                if (uid == null) continue;
                                _scanned = true;
                                try {
                                  final receiver = await context
                                      .read<TransactionCubit>()
                                      .getReceiverById(uid);
                                  if (receiver == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Receiver not found'),
                                      ),
                                    );
                                    setState(() => _scanned = false);
                                    return;
                                  }
                                  if (!mounted) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              TransferMoney(receiver: receiver),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                  setState(() => _scanned = false);
                                }
                                break;
                              }
                            },
                          ),
                        ),

                        // Corner bracket overlay, centered in camera view
                        Center(
                          child: SizedBox(
                            width: frameSize,
                            height: frameSize,
                            child: Stack(
                              children: [
                                // Animated scan line
                                AnimatedBuilder(
                                  animation: _scanAnim,
                                  builder:
                                      (_, __) => Positioned(
                                        top: _scanAnim.value * (frameSize - 2),
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: AppResponsive.h(2),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                const Color(
                                                  0xff007AFF,
                                                ).withOpacity(0.9),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                ),

                                // Corner brackets
                                ..._corners(frameSize, const Color(0xff007AFF)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: AppResponsive.h(40)),

            // Hint text
            AppAnimatedItem(
              index: 1,
              direction: SlideDirection.bottom,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(40)),
                child: Text(
                  'Align the QR code within the frame to scan',
                  style: TextStyle(
                    fontSize: AppResponsive.fs(13),
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            SizedBox(height: AppResponsive.h(40)),
          ],
        ),
      ),
    );
  }

  List<Widget> _corners(double size, Color color) {
    const len = 28.0;
    const thick = 3.0;
    return [
      Positioned(
        top: 0,
        left: 0,
        child: _bracket(len, thick, color, true, true),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: _bracket(len, thick, color, true, false),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: _bracket(len, thick, color, false, true),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: _bracket(len, thick, color, false, false),
      ),
    ];
  }

  Widget _bracket(double len, double thick, Color color, bool top, bool left) =>
      SizedBox(
        width: len,
        height: len,
        child: CustomPaint(
          painter: _BracketPainter(
            color: color,
            thick: thick,
            top: top,
            left: left,
          ),
        ),
      );
}

class _BracketPainter extends CustomPainter {
  final Color color;
  final double thick;
  final bool top, left;
  _BracketPainter({
    required this.color,
    required this.thick,
    required this.top,
    required this.left,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final p =
        Paint()
          ..color = color
          ..strokeWidth = thick
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    final dx = left ? size.width : -size.width;
    final dy = top ? size.height : -size.height;
    canvas.drawLine(Offset(x, y), Offset(x + dx, y), p);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), p);
  }

  @override
  bool shouldRepaint(_BracketPainter o) => o.color != color;
}
