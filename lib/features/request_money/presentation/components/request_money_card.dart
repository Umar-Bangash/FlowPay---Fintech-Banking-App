import 'package:flowpay/features/transaction/presentation/pages/transfer_money.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  Color _statusColor() {
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
    // Always centered in chat — not aligned left/right like text bubbles
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + Title ──
            Center(
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xffE6ECFF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xff6B7280),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$name requesting money',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff1F2937),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── Detail Rows ──
            _detailRow('Request Amount', 'PKR $amount'),
            const SizedBox(height: 10),
            _detailRow('Purpose', purpose),
            const SizedBox(height: 10),
            _detailRow(
              'Return Timeline',
              DateFormat('dd-MM-yyyy').format(timeLine),
            ),

            const SizedBox(height: 14),
            const Divider(color: Color(0xffE5E7EB)),
            const SizedBox(height: 10),

            // ── Note ──
            const Text(
              'Note',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xff9CA3AF),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              note.isEmpty ? 'No note provided' : note,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xff374151),
              ),
            ),

            const SizedBox(height: 18),

            // ── Status badge always shown first ──
            _buildStatusBadge(),

            const SizedBox(height: 12),

            // ── Action area ──
            if (isMe) ...[
              // Sender: only badge (already shown above), nothing else
            ] else ...[
              if (status.toLowerCase() == 'pending') ...[
                // Receiver + pending → Accept / Reject buttons
                Row(
                  children: [
                    Expanded(
                      child: MainButton(
                        buttonName: 'Accept',
                        onTap: () => onAccept?.call(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MainButton(
                        buttonName: 'Reject',
                        onTap: () => onReject?.call(),
                      ),
                    ),
                  ],
                ),
              ] else if (status.toLowerCase() == 'accepted') ...[
                // Receiver + accepted → Pay button
                MainButton(
                  buttonName: 'Pay money request',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TransferMoney()),
                    );
                  },
                ),
              ],
              // rejected → only badge shown above, no button
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor().withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _statusColor(),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xff9CA3AF)),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xff1F2937),
            ),
          ),
        ),
      ],
    );
  }
}
