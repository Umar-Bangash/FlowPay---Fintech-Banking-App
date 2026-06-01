import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/notification/presentation/pages/notification_page.dart';
import 'package:flowpay/features/stripe_payment/presentation/pages/payment_page.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_states.dart';
import 'package:flowpay/features/transaction/presentation/components/trx_tile.dart';
import 'package:flowpay/features/transaction/presentation/components/card_detail.dart';
import 'package:flowpay/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:flowpay/features/transaction/presentation/cubit/transaction_states.dart';
import 'package:flowpay/features/transaction/presentation/pages/favourite_page.dart';
import 'package:flowpay/features/transaction/presentation/pages/history_page.dart';
import 'package:flowpay/features/transaction/presentation/pages/transfer_money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../../../account/presentation/cubit/account_cubit.dart';
import '../../../account/presentation/cubit/account_states.dart';
import '../components/profile_image.dart';

class TransferPage extends StatelessWidget {
  TransferPage({super.key});

  final _userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: AppAnimatedPage(
        direction: SlideDirection.bottom,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppResponsive.h(12)),

                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.w(25),
                  ),
                  child: AppAnimatedItem(
                    index: 0,
                    direction: SlideDirection.left,
                    child: _Header(userId: _userId),
                  ),
                ),

                SizedBox(height: AppResponsive.h(20)),

                // ── Section title ────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.w(25),
                  ),
                  child: AppAnimatedItem(
                    index: 1,
                    direction: SlideDirection.left,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose transfer type',
                          style: TextStyle(
                            fontSize: AppResponsive.fs(16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppResponsive.h(4)),
                        Text(
                          'Where do you want to send your money?',
                          style: TextStyle(
                            fontSize: AppResponsive.fs(12),
                            color: const Color(0xff737373),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(18)),

                // ── Transfer type cards ──────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.w(25),
                  ),
                  child: AppAnimatedItem(
                    index: 2,
                    direction: SlideDirection.bottom,
                    child: _TransferCards(userId: _userId),
                  ),
                ),

                SizedBox(height: AppResponsive.h(20)),

                // ── Or divider ───────────────────────────────────────────
                AppAnimatedItem(
                  index: 3,
                  direction: SlideDirection.bottom,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppResponsive.w(25),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Color(0xffC0C0C0)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppResponsive.w(10),
                          ),
                          child: Text(
                            'or select from',
                            style: TextStyle(
                              fontSize: AppResponsive.fs(12),
                              color: const Color(0xff737373),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Color(0xffC0C0C0)),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(18)),

                // ── History + Favourites ─────────────────────────────────
                // ROOT FIX: Use Row with Expanded children — NEVER fixed widths
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.w(25),
                  ),
                  child: AppAnimatedItem(
                    index: 4,
                    direction: SlideDirection.bottom,
                    child: Row(
                      children: [
                        // History button — takes half the space
                        Expanded(
                          child: _ActionButton(
                            imagePath: 'assets/transfer/history.png',
                            label: 'History',
                            filled: true,
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HistoryPage(),
                                  ),
                                ),
                          ),
                        ),
                        SizedBox(width: AppResponsive.w(10)),
                        // Favourites button — takes other half
                        Expanded(
                          child: _ActionButton(
                            imagePath: 'assets/transfer/star.png',
                            label: 'Favourites',
                            filled: false,
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FavouritesPage(),
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(16)),

                // ── Recent Transactions header ────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.w(25),
                  ),
                  child: AppAnimatedItem(
                    index: 6,
                    direction: SlideDirection.left,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: AppResponsive.fs(15),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'View All',
                          style: TextStyle(
                            fontSize: AppResponsive.fs(13),
                            color: const Color(0xff737373),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(14)),

                // ── Transaction list ──────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.w(25),
                  ),
                  child: BlocBuilder<TransactionCubit, TransactionStates>(
                    builder: (context, state) {
                      if (state is TransactionLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is TransactionError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: TextStyle(fontSize: AppResponsive.fs(13)),
                          ),
                        );
                      }
                      if (state is TransactionLoaded) {
                        if (state.transactions.isEmpty) {
                          return Center(
                            child: Text(
                              'No transactions',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(13),
                                color: const Color(0xff737373),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children:
                              state.transactions.take(4).toList().asMap().entries.map((
                                e,
                              ) {
                                final i = e.key;
                                final trx = e.value;
                                final isCredit = trx.type == 'credit';
                                final d =
                                    DateTime.tryParse(
                                      trx.dateTime.toString(),
                                    ) ??
                                    DateTime.now();
                                final now = DateTime.now();
                                final fmt =
                                    d.year == now.year &&
                                            d.month == now.month &&
                                            d.day == now.day
                                        ? 'Today'
                                        : d.year == now.year &&
                                            d.month == now.month &&
                                            d.day == now.day - 1
                                        ? 'Yesterday'
                                        : '${d.day}/${d.month}/${d.year}';
                                return AppAnimatedItem(
                                  index: i + 7,
                                  direction:
                                      i.isEven
                                          ? SlideDirection.left
                                          : SlideDirection.right,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: AppResponsive.h(14),
                                    ),
                                    child: FutureBuilder<String?>(
                                      future: getProfileImage(trx.receiverId),
                                      builder:
                                          (_, snap) => TrxTile(
                                            profileImageUrl: snap.data,
                                            name: trx.description,
                                            datetime: fmt,
                                            amount:
                                                isCredit
                                                    ? '+ Rs ${trx.amount.toStringAsFixed(0)}'
                                                    : '- Rs ${trx.amount.toStringAsFixed(0)}',
                                            amountColor:
                                                isCredit
                                                    ? const Color(0xff2F80ED)
                                                    : const Color(0xffEB5757),
                                            onTap: () {},
                                          ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),

                SizedBox(height: AppResponsive.h(30)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Reusable action button (History / Favourites) ────────────────────────────
// Uses width: double.infinity so Expanded controls its size — NEVER fixed width
class _ActionButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.imagePath,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
      child: Container(
        width: double.infinity, // fills the Expanded parent
        height: AppResponsive.h(52),
        decoration: BoxDecoration(
          color: filled ? const Color(0xff007AFF) : Colors.white,
          borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
          border: filled ? null : Border.all(color: const Color(0xff007AFF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: AppResponsive.sp(18),
              width: AppResponsive.sp(18),
              color: filled ? Colors.white : const Color(0xff007AFF),
            ),
            SizedBox(width: AppResponsive.w(8)),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppResponsive.fs(14),
                  fontWeight: FontWeight.w600,
                  color: filled ? Colors.white : const Color(0xff007AFF),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String userId;
  const _Header({required this.userId});

  @override
  Widget build(BuildContext context) {
    final av = AppResponsive.sp(43);
    return BlocBuilder<ProfileCubit, ProfileStates>(
      builder: (context, ps) {
        final profile = ps is ProfileLoaded ? ps.profileUser : null;
        return BlocBuilder<AccountCubit, AccountStates>(
          builder: (context, as_) {
            final account =
                as_ is AccountLoaded && as_.accounts.isNotEmpty
                    ? as_.accounts.first
                    : null;
            return Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
                  child: Container(
                    width: av,
                    height: av,
                    color: const Color(0xff9DABB3),
                    child:
                        (profile?.profileImageUrl?.isNotEmpty ?? false)
                            ? Image.network(
                              profile!.profileImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                            )
                            : const Icon(Icons.person, color: Colors.white),
                  ),
                ),
                SizedBox(width: AppResponsive.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${profile?.name ?? ''}',
                        style: TextStyle(
                          fontSize: AppResponsive.fs(15),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              account?.phone ?? 'account number',
                              style: TextStyle(
                                fontSize: AppResponsive.fs(11),
                                color: const Color(0xff737373),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: AppResponsive.w(4)),
                          Image.asset(
                            'assets/home/copy.png',
                            height: AppResponsive.sp(13),
                            width: AppResponsive.sp(13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => context.read<AuthCubit>().logout(),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/home/logout.png',
                      height: AppResponsive.sp(22),
                      width: AppResponsive.sp(22),
                    ),
                  ),
                ),
                SizedBox(width: AppResponsive.w(6)),
                InkWell(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationPage(userId: userId),
                        ),
                      ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/home/notification.png',
                      height: AppResponsive.sp(22),
                      width: AppResponsive.sp(22),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ─── Transfer cards — LayoutBuilder so they NEVER overflow ───────────────────
class _TransferCards extends StatelessWidget {
  final String userId;
  const _TransferCards({required this.userId});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final gap = AppResponsive.w(16);
        final cardW = (c.maxWidth - gap) / 2;
        final cardH = cardW * 0.86;

        return Row(
          children: [
            // FlowPay
            Expanded(
              child: Stack(
                children: [
                  InkWell(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TransferMoney()),
                        ),
                    borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppResponsive.radiusLg,
                      ),
                      child: Image.asset(
                        'assets/transfer/flowpay_card.png',
                        width: cardW,
                        height: cardH,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  CardDetail(
                    image: Padding(
                      padding: EdgeInsets.all(AppResponsive.sp(8)),
                      child: Image.asset('assets/images/flowpay_logo.png'),
                    ),
                    imageCardColor: const Color(0xffCFE8FE),
                    name: 'Flow Pay',
                    titleColor: Colors.white,
                    subTitle: Text(
                      'Instant transfer, no\nfee',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(8),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: gap),

            // Stripe
            Expanded(
              child: Stack(
                children: [
                  Image.asset(
                    'assets/transfer/stripe_card.png',
                    width: cardW,
                    height: cardH,
                  ),
                  InkWell(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentPage(userId: userId),
                          ),
                        ),
                    child: CardDetail(
                      image: Image.asset('assets/transfer/stripe_icon.png'),
                      imageCardColor: const Color.fromARGB(255, 113, 34, 249),
                      name: 'Pay with Stripe',
                      titleColor: Colors.black,
                      subTitle: Text(
                        'Small fee may\napply',
                        style: TextStyle(fontSize: AppResponsive.fs(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
