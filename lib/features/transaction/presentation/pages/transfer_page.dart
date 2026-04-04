import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/notification/presentation/pages/notification_page.dart';
import 'package:flowpay/features/stripe_payment/presentation/pages/payment_page.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_states.dart';
import 'package:flowpay/features/transaction/presentation/components/trx_tile.dart';
import 'package:flowpay/features/transaction/presentation/components/activity_button.dart';
import 'package:flowpay/features/transaction/presentation/components/card_detail.dart';
import 'package:flowpay/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:flowpay/features/transaction/presentation/cubit/transaction_states.dart';
import 'package:flowpay/features/transaction/presentation/pages/transfer_money.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../account/presentation/cubit/account_cubit.dart';
import '../../../account/presentation/cubit/account_states.dart';

class TransferPage extends StatelessWidget {
  TransferPage({super.key});

  final searchController = TextEditingController();
  final userId = FirebaseAuth.instance.currentUser!.uid;

  // Timer? _debounce;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: context.padSymmetricPx(horizontal: 25),
                  child: BlocBuilder<ProfileCubit, ProfileStates>(
                    builder: (context, profileState) {
                      final profile =
                          profileState is ProfileLoaded
                              ? profileState.profileUser
                              : null;

                      return BlocBuilder<AccountCubit, AccountStates>(
                        builder: (context, accountState) {
                          final account =
                              accountState is AccountLoaded &&
                                      accountState.accounts.isNotEmpty
                                  ? accountState.accounts.first
                                  : null;

                          return Row(
                            children: [
                              // PROFILE IMAGE
                              Container(
                                height: context.hPx(43),
                                width: context.hPx(43),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  color: const Color.fromARGB(
                                    255,
                                    157,
                                    171,
                                    179,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child:
                                      (profile?.profileImageUrl != null &&
                                              profile!
                                                  .profileImageUrl!
                                                  .isNotEmpty)
                                          ? Image.network(
                                            profile.profileImageUrl!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return const Icon(Icons.person);
                                            },
                                          )
                                          : const Icon(Icons.person),
                                ),
                              ),

                              context.spaceWPx(12),

                              // NAME + PHONE
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hi, ${profile?.name ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        account?.phone ?? 'account number',
                                        style: const TextStyle(
                                          fontSize: 11.57,
                                          color: Color(0xff737373),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      context.spaceWPx(4),
                                      Image.asset(
                                        'assets/home/copy.png',
                                        height: context.hPx(16),
                                        width: context.wPx(16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const Spacer(),

                              // LOGOUT
                              InkWell(
                                onTap: () {
                                  context.read<AuthCubit>().logout();
                                },
                                child: Image.asset(
                                  'assets/home/logout.png',
                                  height: context.hPx(24),
                                  width: context.wPx(24),
                                ),
                              ),

                              context.spaceWPx(8),

                              // NOTIFICATION
                              InkWell(
                                onTap: () {
                                  final userId =
                                      FirebaseAuth.instance.currentUser!.uid;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              NotificationPage(userId: userId),
                                    ),
                                  );
                                },
                                child: Image.asset(
                                  'assets/home/notification.png',
                                  height: context.hPx(24),
                                  width: context.wPx(24),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                context.spaceHPx(20),
                Padding(
                  padding: context.padSymmetricPx(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose transfer type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      context.spaceHPx(5),
                      Text(
                        'Where do you want to send your money?',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                context.spaceHPx(20),
                Padding(
                  padding: context.padSymmetricPx(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransferMoney(),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/transfer/flowpay_card.png',
                                width: context.wPx(180),
                                height: context.hPx(160),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          CardDetail(
                            image: Padding(
                              padding: context.padAllPx(8),
                              child: Image.asset(
                                'assets/images/flowpay_logo.png',
                              ),
                            ),
                            imageCardColor: Color(0xffCFE8FE),
                            name: 'Flow Pay',
                            titleColor: Color(0xffFFFFFF),
                            subTitle: Text(
                              'Instant transfer, no\nfee',
                              style: TextStyle(
                                fontSize: 8.4,
                                color: Color(0xffFFFFFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      context.spaceWPx(20),
                      Stack(
                        children: [
                          Image.asset(
                            'assets/transfer/stripe_card.png',
                            width: context.wPx(180),
                            height: context.hPx(160),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PaymentPage(userId: userId),
                                ),
                              );
                            },
                            child: CardDetail(
                              image: Image.asset(
                                'assets/transfer/stripe_icon.png',
                              ),
                              imageCardColor: const Color.fromARGB(
                                255,
                                113,
                                34,
                                249,
                              ),
                              name: 'Pay with Stripe',
                              titleColor: Color(0xff000000),
                              subTitle: Text(
                                'Small fee may \napply',
                                style: TextStyle(fontSize: 8.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                context.spaceHPx(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '------------------ ',
                      style: TextStyle(color: Color(0xff737373)),
                    ),
                    Text(
                      'or select from',
                      style: TextStyle(fontSize: 12, color: Color(0xff737373)),
                    ),
                    Text(
                      ' ------------------',
                      style: TextStyle(color: Color(0xff737373)),
                    ),
                  ],
                ),
                context.spaceHPx(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ActivityButton(
                      imagePath: 'assets/transfer/history.png',
                      buttonColor: Color(0xff007AFF),
                      buttonName: 'History',
                      textColor: Color(0xffFFFFFF),
                      onTap: () {},
                    ),
                    context.spaceWPx(8),
                    ActivityButton(
                      imagePath: 'assets/transfer/star.png',
                      buttonColor: Color(0xffFFFFFF),
                      buttonName: 'Favourites',
                      textColor: Color(0xff007AFF),
                      onTap: () {},
                    ),
                  ],
                ),
                context.spaceHPx(15),
                Padding(
                  padding: context.padSymmetricPx(horizontal: 40, vertical: 10),
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 25, right: 10),
                        child: Image.asset(
                          'assets/transfer/search.png',
                          height: context.hPx(24),
                          width: context.wPx(24),
                        ),
                      ),
                      hintText: 'Search by account number',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xffA3A3A3),
                      ),
                      enabled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffA3A3A3)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffA3A3A3)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                context.spaceHPx(15),
                Padding(
                  padding: context.padSymmetricPx(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff737373),
                        ),
                      ),
                    ],
                  ),
                ),
                context.spaceHPx(15),
                Padding(
                  padding: context.padSymmetricPx(horizontal: 25),
                  child: BlocBuilder<TransactionCubit, TransactionStates>(
                    builder: (context, transactionState) {
                      if (transactionState is TransactionLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (transactionState is TransactionLoaded) {
                        final transactions = transactionState.transactions;

                        if (transactions.isEmpty) {
                          return const Center(child: Text('No Transaction'));
                        }

                        return Column(
                          children:
                              transactions.take(4).map((trx) {
                                final isCredit = trx.type == "credit";

                                final trxDate =
                                    DateTime.tryParse(
                                      trx.dateTime.toString(),
                                    ) ??
                                    DateTime.now();

                                final now = DateTime.now();

                                String formattedDate;

                                if (trxDate.year == now.year &&
                                    trxDate.month == now.month &&
                                    trxDate.day == now.day) {
                                  formattedDate = "Today";
                                } else if (trxDate.year == now.year &&
                                    trxDate.month == now.month &&
                                    trxDate.day == now.day - 1) {
                                  formattedDate = "Yesterday";
                                } else {
                                  formattedDate =
                                      "${trxDate.day}/${trxDate.month}/${trxDate.year}";
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: TrxTile(
                                    imagePath: 'assets/home/pocket.png',
                                    name: trx.description,
                                    datetime: formattedDate,
                                    amount:
                                        isCredit
                                            ? "+ Rs ${trx.amount.toStringAsFixed(0)}"
                                            : "- Rs ${trx.amount.toStringAsFixed(0)}",
                                    amountColor:
                                        isCredit
                                            ? const Color(0xff2F80ED)
                                            : const Color(0xffEB5757),
                                    onTap: () {},
                                  ),
                                );
                              }).toList(),
                        );
                      }

                      if (transactionState is TransactionError) {
                        return Center(child: Text(transactionState.message));
                      }

                      return const SizedBox();
                    },
                  ),
                ),
                context.spaceHPx(30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
