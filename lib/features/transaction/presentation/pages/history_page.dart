import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/transaction/domain/entities/transaction.dart';
import 'package:flowpay/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:flowpay/features/transaction/presentation/cubit/transaction_states.dart';
import 'package:flowpay/features/transaction/presentation/components/trx_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  DateTime? _selectedDate;
  String _filter = 'All';

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final _filters = ['All', 'Credit', 'Debit'];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap =
        await FirebaseFirestore.instance
            .collection('accounts')
            .where('userId', isEqualTo: uid)
            .limit(1)
            .get();
    if (snap.docs.isNotEmpty && mounted) {
      context.read<TransactionCubit>().listenToTransactions(snap.docs.first.id);
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  List<TransactionModel> _applyFilters(List<TransactionModel> all) {
    var f = all;
    if (_selectedDate != null) {
      f =
          f
              .where(
                (t) =>
                    t.dateTime.year == _selectedDate!.year &&
                    t.dateTime.month == _selectedDate!.month &&
                    t.dateTime.day == _selectedDate!.day,
              )
              .toList();
    }
    if (_filter == 'Credit') f = f.where((t) => t.type == 'credit').toList();
    if (_filter == 'Debit') f = f.where((t) => t.type == 'debit').toList();
    if (_selectedDate == null) f = f.take(10).toList();
    return f;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder:
          (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xff007AFF),
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _fmtDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today  ${DateFormat('hh:mm a').format(d)}';
    }
    if (d.year == now.year && d.month == now.month && d.day == now.day - 1) {
      return 'Yesterday  ${DateFormat('hh:mm a').format(d)}';
    }
    return DateFormat('dd MMM yyyy  hh:mm a').format(d);
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
          child: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Transaction History',
          style: TextStyle(
            fontSize: AppResponsive.fs(16),
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // ── Filter row ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
              child: Column(
                children: [
                  SizedBox(height: AppResponsive.h(12)),
                  Row(
                    children: [
                      // Type chips
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                _filters.map((f) {
                                  final sel = _filter == f;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: AppResponsive.w(8),
                                    ),
                                    child: GestureDetector(
                                      onTap: () => setState(() => _filter = f),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppResponsive.w(14),
                                          vertical: AppResponsive.h(7),
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              sel
                                                  ? const Color(0xff007AFF)
                                                  : const Color(0xffF5F5F5),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          f,
                                          style: TextStyle(
                                            fontSize: AppResponsive.fs(13),
                                            fontWeight: FontWeight.w500,
                                            color:
                                                sel
                                                    ? Colors.white
                                                    : const Color(0xff737373),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),

                      // Date picker chip
                      GestureDetector(
                        onTap: _pickDate,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppResponsive.w(10),
                            vertical: AppResponsive.h(7),
                          ),
                          decoration: BoxDecoration(
                            color:
                                _selectedDate != null
                                    ? const Color(0xff007AFF).withOpacity(0.1)
                                    : const Color(0xffF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  _selectedDate != null
                                      ? const Color(0xff007AFF)
                                      : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: AppResponsive.sp(13),
                                color:
                                    _selectedDate != null
                                        ? const Color(0xff007AFF)
                                        : const Color(0xff737373),
                              ),
                              SizedBox(width: AppResponsive.w(5)),
                              Text(
                                _selectedDate != null
                                    ? DateFormat(
                                      'dd MMM',
                                    ).format(_selectedDate!)
                                    : 'Date',
                                style: TextStyle(
                                  fontSize: AppResponsive.fs(12),
                                  fontWeight: FontWeight.w500,
                                  color:
                                      _selectedDate != null
                                          ? const Color(0xff007AFF)
                                          : const Color(0xff737373),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_selectedDate != null) ...[
                        SizedBox(width: AppResponsive.w(5)),
                        GestureDetector(
                          onTap: () => setState(() => _selectedDate = null),
                          child: Container(
                            padding: EdgeInsets.all(AppResponsive.sp(5)),
                            decoration: BoxDecoration(
                              color: const Color(0xffFF3B30).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.close,
                              size: AppResponsive.sp(13),
                              color: const Color(0xffFF3B30),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: AppResponsive.h(14)),

                  if (_selectedDate != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: AppResponsive.fs(12),
                            color: const Color(0xff737373),
                          ),
                          children: [
                            const TextSpan(text: 'Showing results for  '),
                            TextSpan(
                              text: DateFormat(
                                'dd MMM yyyy',
                              ).format(_selectedDate!),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xff007AFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── List ────────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<TransactionCubit, TransactionStates>(
                builder: (context, state) {
                  if (state is TransactionLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xff007AFF),
                      ),
                    );
                  }
                  if (state is TransactionError)
                    return Center(child: Text(state.message));
                  if (state is TransactionLoaded) {
                    final filtered = _applyFilters(state.transactions);
                    if (filtered.isEmpty) return _emptyState();
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppResponsive.w(25),
                        vertical: AppResponsive.h(10),
                      ),
                      itemCount: filtered.length,
                      separatorBuilder:
                          (_, __) => SizedBox(height: AppResponsive.h(12)),
                      itemBuilder: (context, i) {
                        final trx = filtered[i];
                        final isCredit = trx.type == 'credit';
                        return AppAnimatedItem(
                          index: i,
                          direction:
                              i.isEven
                                  ? SlideDirection.left
                                  : SlideDirection.right,
                          child: TrxTile(
                            profileImageUrl: 'assets/home/pocket.png',
                            name: trx.description,
                            datetime: _fmtDate(trx.dateTime),
                            amount:
                                isCredit
                                    ? '+ Rs ${trx.amount.toStringAsFixed(0)}'
                                    : '- Rs ${trx.amount.toStringAsFixed(0)}',
                            amountColor:
                                isCredit
                                    ? const Color(0xff2F80ED)
                                    : const Color(0xffEB5757),
                            onTap: () => _showDetail(context, trx),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: AppResponsive.sp(72),
          width: AppResponsive.sp(72),
          decoration: BoxDecoration(
            color: const Color(0xff007AFF).withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
          ),
          child: Icon(
            Icons.receipt_long_outlined,
            size: AppResponsive.sp(32),
            color: const Color(0xff007AFF),
          ),
        ),
        SizedBox(height: AppResponsive.h(14)),
        Text(
          'No transactions found',
          style: TextStyle(
            fontSize: AppResponsive.fs(15),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppResponsive.h(6)),
        Text(
          _selectedDate != null
              ? 'No transactions on this date'
              : 'Your history will appear here',
          style: TextStyle(
            fontSize: AppResponsive.fs(12),
            color: const Color(0xff737373),
          ),
        ),
      ],
    ),
  );

  void _showDetail(BuildContext context, TransactionModel trx) {
    final isCredit = trx.type == 'credit';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder:
          (_) => SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppResponsive.w(22)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppResponsive.w(36),
                    height: AppResponsive.h(4),
                    decoration: BoxDecoration(
                      color: const Color(0xffE5E5E5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: AppResponsive.h(22)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppResponsive.w(12),
                      vertical: AppResponsive.h(5),
                    ),
                    decoration: BoxDecoration(
                      color:
                          isCredit
                              ? const Color(0xff2F80ED).withOpacity(0.1)
                              : const Color(0xffEB5757).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCredit ? 'Money Received' : 'Money Sent',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(12),
                        fontWeight: FontWeight.w600,
                        color:
                            isCredit
                                ? const Color(0xff2F80ED)
                                : const Color(0xffEB5757),
                      ),
                    ),
                  ),
                  SizedBox(height: AppResponsive.h(14)),
                  Text(
                    '${isCredit ? '+' : '-'} Rs. ${trx.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: AppResponsive.fs(28),
                      fontWeight: FontWeight.bold,
                      color:
                          isCredit
                              ? const Color(0xff2F80ED)
                              : const Color(0xffEB5757),
                    ),
                  ),
                  SizedBox(height: AppResponsive.h(20)),
                  _detailRow('Description', trx.description),
                  const Divider(height: 20, color: Color(0xffF0F0F0)),
                  _detailRow(
                    'Date & Time',
                    DateFormat('dd MMM yyyy  hh:mm a').format(trx.dateTime),
                  ),
                  const Divider(height: 20, color: Color(0xffF0F0F0)),
                  _detailRow('Transaction ID', trx.transactionId),
                  SizedBox(height: AppResponsive.h(20)),
                ],
              ),
            ),
          ),
    );
  }

  Widget _detailRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: AppResponsive.fs(13),
          color: const Color(0xff737373),
        ),
      ),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: AppResponsive.fs(13),
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    ],
  );
}
