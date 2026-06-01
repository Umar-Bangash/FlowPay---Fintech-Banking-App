import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/qr/presentation/cubit/qr_cubit.dart';
import 'package:flowpay/features/qr/presentation/cubit/qr_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../../domain/entities/qr_access_token.dart';

class AccessQrDialog extends StatefulWidget {
  final String? ownerUid;
  const AccessQrDialog({super.key, this.ownerUid});
  @override
  State<AccessQrDialog> createState() => _AccessQrDialogState();
}

class _AccessQrDialogState extends State<AccessQrDialog> {
  final _emailCtrl = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 300;
  bool _emailDone = false;
  bool _fetchingUid = false;

  @override
  void initState() {
    super.initState();
    if (widget.ownerUid != null) {
      _emailDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<QRCubit>().generateAccessToken(widget.ownerUid!);
        }
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 300);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        if (mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR expired. Generate a new one.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Future<void> _fetchAndGenerate(String email) async {
    setState(() => _fetchingUid = true);
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
      if (!mounted) return;
      if (snap.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No account found with this email.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _fetchingUid = false);
        return;
      }
      setState(() {
        _emailDone = true;
        _fetchingUid = false;
      });
      if (mounted) {
        context.read<QRCubit>().generateAccessToken(snap.docs.first.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _fetchingUid = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return BlocConsumer<QRCubit, QRStates>(
      listener: (context, state) {
        if (state is QRTokenGenerated) _startCountdown();
      },
      builder: (context, state) {
        final isGenerating = state is QRTokenGenerating || _fetchingUid;
        final isGenerated = state is QRTokenGenerated;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
          ),
          backgroundColor: Colors.white,
          // isScrollControlled so keyboard doesn't clip on small phones
          insetPadding: EdgeInsets.symmetric(
            horizontal: AppResponsive.w(20),
            vertical: AppResponsive.h(40),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppResponsive.w(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Title row ──────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Access QR',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(17),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _timer?.cancel();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),

                SizedBox(height: AppResponsive.h(8)),

                // ── Body ───────────────────────────────────────────────
                if (isGenerating)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppResponsive.h(40),
                    ),
                    child: const CircularProgressIndicator(
                      color: Color(0xff007AFF),
                    ),
                  )
                else if (isGenerated)
                  _QrDisplayView(
                    token: (state).token,
                    secondsLeft: _secondsLeft,
                  )
                else if (!_emailDone)
                  _EmailInputView(
                    controller: _emailCtrl,
                    onSubmit: _fetchAndGenerate,
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppResponsive.h(40),
                    ),
                    child: const CircularProgressIndicator(
                      color: Color(0xff007AFF),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmailInputView extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmit;
  const _EmailInputView({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: AppResponsive.h(8)),
        Icon(
          Icons.lock_open_outlined,
          size: AppResponsive.sp(44),
          color: const Color(0xff007AFF),
        ),
        SizedBox(height: AppResponsive.h(14)),
        Text(
          'Enter your email to generate\na secure access QR code.',
          style: TextStyle(
            fontSize: AppResponsive.fs(13),
            color: const Color(0xff737373),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppResponsive.h(5)),
        Text(
          'Valid for 5 minutes · Single use only',
          style: TextStyle(
            fontSize: AppResponsive.fs(11),
            color: const Color(0xffA3A3A3),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppResponsive.h(18)),
        TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'your@email.com',
            hintStyle: const TextStyle(color: Color(0xffA3A3A3)),
            filled: true,
            fillColor: const Color(0xffF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppResponsive.w(16),
              vertical: AppResponsive.h(13),
            ),
          ),
        ),
        SizedBox(height: AppResponsive.h(18)),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff007AFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
              ),
              padding: EdgeInsets.symmetric(vertical: AppResponsive.h(13)),
            ),
            onPressed: () {
              final e = controller.text.trim();
              if (e.isEmpty) return;
              onSubmit(e);
            },
            child: Text(
              'Generate QR',
              style: TextStyle(
                fontSize: AppResponsive.fs(14),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: AppResponsive.h(8)),
      ],
    );
  }
}

class _QrDisplayView extends StatelessWidget {
  final QrAccessToken token;
  final int secondsLeft;
  const _QrDisplayView({required this.token, required this.secondsLeft});

  @override
  Widget build(BuildContext context) {
    final mm = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final ss = (secondsLeft % 60).toString().padLeft(2, '0');
    final qrD = 'flowpay_access::${token.tokenId}::${token.ownerUid}';
    // QR size responsive
    final qrSize = (AppResponsive.screenWidth * 0.48).clamp(150.0, 200.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: AppResponsive.h(8)),
        Container(
          padding: EdgeInsets.all(AppResponsive.w(12)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
            border: Border.all(color: const Color(0xffE5E5E5)),
          ),
          child: QrImageView(
            data: qrD,
            size: qrSize,
            backgroundColor: Colors.white,
          ),
        ),
        SizedBox(height: AppResponsive.h(14)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timer_outlined,
              size: AppResponsive.sp(15),
              color: secondsLeft < 60 ? Colors.red : const Color(0xff007AFF),
            ),
            SizedBox(width: AppResponsive.w(5)),
            Text(
              'Expires in $mm:$ss',
              style: TextStyle(
                fontSize: AppResponsive.fs(13),
                fontWeight: FontWeight.w500,
                color: secondsLeft < 60 ? Colors.red : const Color(0xff007AFF),
              ),
            ),
          ],
        ),
        SizedBox(height: AppResponsive.h(8)),
        Text(
          'Show this QR to the person\nwho needs access.',
          style: TextStyle(
            fontSize: AppResponsive.fs(11),
            color: const Color(0xffA3A3A3),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppResponsive.h(8)),
      ],
    );
  }
}
