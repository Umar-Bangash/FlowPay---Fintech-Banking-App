import 'package:flowpay/features/transaction/presentation/pages/transfer_money.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../helpers/ui_responsive_helper.dart';

class RequestMoneyCard extends StatelessWidget {
  final String name;
  final int amount;
  final String purpose;
  final DateTime timeLine;
  final String note;
  final String status;
  final bool isMe;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const RequestMoneyCard({
    super.key,
    required this.name,
    required this.amount,
    required this.purpose,
    required this.timeLine,
    required this.note,
    required this.status,
    required this.isMe,
    this.onAccept,
    this.onReject,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xff22C55E);
      case 'rejected':
        return const Color(0xffEF4444);
      default:
        return const Color(0xffF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: AppResponsive.h(10),
          horizontal: AppResponsive.w(16),
        ),
        // Width = 85% of screen, no fixed height
        width: AppResponsive.wp(85),
        padding: EdgeInsets.all(AppResponsive.w(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // ── KEY FIX: mainAxisSize.min so Column never tries to fill ──────
        //    the unbounded height of its ListView parent
        child: Column(
          mainAxisSize: MainAxisSize.min, // ← THE fix
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + title ─────────────────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppResponsive.sp(48),
                    height: AppResponsive.sp(48),
                    decoration: BoxDecoration(
                      color: const Color(0xffE6ECFF),
                      borderRadius: BorderRadius.circular(
                        AppResponsive.radiusMd,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: const Color(0xff6B7280),
                      size: AppResponsive.sp(26),
                    ),
                  ),
                  SizedBox(height: AppResponsive.h(8)),
                  Text(
                    '$name requesting money',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppResponsive.fs(14),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff1F2937),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppResponsive.h(16)),

            // ── Detail rows ────────────────────────────────────────────
            _DetailRow('Request Amount', 'PKR $amount'),
            SizedBox(height: AppResponsive.h(8)),
            _DetailRow('Purpose', purpose),
            SizedBox(height: AppResponsive.h(8)),
            _DetailRow(
              'Return Timeline',
              DateFormat('dd-MM-yyyy').format(timeLine),
            ),

            SizedBox(height: AppResponsive.h(12)),
            const Divider(color: Color(0xffE5E7EB)),
            SizedBox(height: AppResponsive.h(8)),

            // ── Note ───────────────────────────────────────────────────
            Text(
              'Note',
              style: TextStyle(
                fontSize: AppResponsive.fs(11),
                fontWeight: FontWeight.bold,
                color: const Color(0xff9CA3AF),
              ),
            ),
            SizedBox(height: AppResponsive.h(4)),
            Text(
              note.isEmpty ? 'No note provided' : note,
              style: TextStyle(
                fontSize: AppResponsive.fs(13),
                color: const Color(0xff374151),
              ),
            ),

            SizedBox(height: AppResponsive.h(14)),

            // ── Status badge ────────────────────────────────────────────
            _StatusBadge(status: status, color: _statusColor),

            SizedBox(height: AppResponsive.h(10)),

            // ── Action buttons — plain containers, NO Expanded ──────────
            if (!isMe) ...[
              if (status.toLowerCase() == 'pending') ...[
                _ActionBtn(
                  label: 'Accept',
                  bgColor: const Color(0xff007AFF),
                  onTap: () => onAccept?.call(),
                ),
                SizedBox(height: AppResponsive.h(8)),
                _ActionBtn(
                  label: 'Reject',
                  bgColor: const Color(0xffEF4444),
                  onTap: () => onReject?.call(),
                ),
              ] else if (status.toLowerCase() == 'accepted') ...[
                _ActionBtn(
                  label: 'Pay money request',
                  bgColor: const Color(0xff007AFF),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TransferMoney()),
                      ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ── Plain button — width:double.infinity, height fixed ─────────────────────
// Does NOT use Expanded internally so it works inside unbounded-height Column
class _ActionBtn extends StatelessWidget {
  final String label;
  final Color bgColor;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    required this.bgColor,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
    child: Container(
      width: double.infinity,
      height: AppResponsive.h(46),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: AppResponsive.fs(14),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: AppResponsive.w(10),
      vertical: AppResponsive.h(5),
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status.toUpperCase(),
      style: TextStyle(
        color: color,
        fontSize: AppResponsive.fs(11),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
  );
}

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
          color: const Color(0xff9CA3AF),
        ),
      ),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: AppResponsive.fs(12),
            fontWeight: FontWeight.w700,
            color: const Color(0xff1F2937),
          ),
        ),
      ),
    ],
  );
}
