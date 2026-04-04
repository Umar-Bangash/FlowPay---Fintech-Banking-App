import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowpay/components/add_pocket_box.dart';
import 'package:flowpay/components/shortcut_tile.dart';
import 'package:flowpay/deposit_money.dart';
import 'package:flowpay/features/account/presentation/cubit/account_cubit.dart';
import 'package:flowpay/features/account/presentation/cubit/account_states.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowpay/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:flowpay/features/notification/presentation/cubit/notification_states.dart';
import 'package:flowpay/features/notification/presentation/pages/notification_page.dart';
import 'package:flowpay/features/pocket/presentation/cubit/goal_cubit.dart';
import 'package:flowpay/features/pocket/presentation/cubit/goal_states.dart';
import 'package:flowpay/features/pocket/presentation/pages/my_pockets.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_states.dart';
import 'package:flowpay/features/qr/presentation/pages/qr_page.dart';
import 'package:flowpay/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:flowpay/features/transaction/presentation/cubit/transaction_states.dart';
import 'package:flowpay/features/transaction/presentation/components/trx_tile.dart';
import 'package:flowpay/features/bill_payment/presentation/pages/bill_categories_page.dart';
import 'package:flowpay/features/request_money/presentation/pages/request_money.dart';
import 'package:flowpay/features/transaction/domain/entities/transaction.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'features/transaction/presentation/pages/transfer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isClick = false;

  void clickToShow() {
    setState(() {
      isClick = !isClick;
    });
  }

  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    context.read<AccountCubit>().listenToAccounts(uid);
    context.read<GoalCubit>().fetchGoals(uid);
    context.read<NotificationCubit>().listenToNotifications(userId);
    context.read<ProfileCubit>().fetchProfileUser(uid);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AccountCubit, AccountStates>(
          listener: (context, state) {
            if (state is AccountLoaded && state.accounts.isNotEmpty) {
              final accountId = state.accounts.first.accountId;
              context.read<TransactionCubit>().listenToTransactions(
                accountId.toString(),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<AuthCubit, AuthStates>(
        builder: (context, authState) {
          final userName =
              authState is Authenticated ? authState.user.name : '';

          return BlocBuilder<AccountCubit, AccountStates>(
            builder: (context, accountState) {
              final accountLoaded =
                  accountState is AccountLoaded &&
                          accountState.accounts.isNotEmpty
                      ? accountState.accounts.first
                      : null;

              return BlocBuilder<ProfileCubit, ProfileStates>(
                builder: (context, profileState) {
                  final profileImage =
                      profileState is ProfileLoaded
                          ? profileState.profileUser.profileImageUrl
                          : null;

                  return BlocBuilder<GoalCubit, GoalState>(
                    builder: (context, goalState) {
                      final totalSavedAmount =
                          goalState is GoalLoaded
                              ? goalState.goals.fold<double>(
                                0,
                                (sum, goal) => sum + goal.savedAmount,
                              )
                              : 0.0;
                      final goalsLength =
                          goalState is GoalLoaded ? goalState.goals.length : 0;

                      return BlocBuilder<NotificationCubit, NotificationStates>(
                        builder: (context, notificationState) {
                          final unreadNotifications =
                              notificationState is NotificationLoaded
                                  ? notificationState.notifications
                                      .where((n) => !n.isRead)
                                      .length
                                  : 0;

                          return BlocBuilder<
                            TransactionCubit,
                            TransactionStates
                          >(
                            builder: (context, transactionState) {
                              final transactions =
                                  transactionState is TransactionLoaded
                                      ? transactionState.transactions
                                      : <TransactionModel>[];

                              return PopScope(
                                canPop: false,
                                child: Scaffold(
                                  backgroundColor: Colors.white,
                                  body: Padding(
                                    padding: context.padSymmetricPx(
                                      horizontal: 24,
                                    ),
                                    child: SafeArea(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // HEADER
                                            Row(
                                              children: [
                                                Container(
                                                  height: context.hPx(43),
                                                  width: context.hPx(43),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          9,
                                                        ),
                                                    color: const Color.fromARGB(
                                                      255,
                                                      157,
                                                      171,
                                                      179,
                                                    ),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          9,
                                                        ),
                                                    child:
                                                        (profileImage != null &&
                                                                profileImage
                                                                    .isNotEmpty)
                                                            ? Image.network(
                                                              profileImage,
                                                              fit: BoxFit.cover,
                                                              width:
                                                                  double
                                                                      .infinity,
                                                              height:
                                                                  double
                                                                      .infinity,
                                                              errorBuilder: (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return const Icon(
                                                                  Icons.person,
                                                                );
                                                              },
                                                            )
                                                            : const Icon(
                                                              Icons.person,
                                                            ),
                                                  ),
                                                ),
                                                context.spaceWPx(12),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Hi, $userName',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          accountLoaded
                                                                  ?.phone ??
                                                              'account number',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 11.57,
                                                                color: Color(
                                                                  0xff737373,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                        context.spaceWPx(4),
                                                        Image.asset(
                                                          'assets/home/copy.png',
                                                          height: context.hPx(
                                                            16,
                                                          ),
                                                          width: context.wPx(
                                                            16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                InkWell(
                                                  onTap:
                                                      () =>
                                                          context
                                                              .read<AuthCubit>()
                                                              .logout(),
                                                  child: Image.asset(
                                                    'assets/home/logout.png',
                                                    height: context.hPx(24),
                                                    width: context.wPx(24),
                                                  ),
                                                ),
                                                context.spaceWPx(8),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (_) =>
                                                                NotificationPage(
                                                                  userId:
                                                                      userId,
                                                                ),
                                                      ),
                                                    );
                                                  },
                                                  child: Stack(
                                                    clipBehavior: Clip.none,
                                                    children: [
                                                      Image.asset(
                                                        'assets/home/notification.png',
                                                        height: context.hPx(24),
                                                        width: context.wPx(24),
                                                      ),
                                                      if (unreadNotifications >
                                                          0)
                                                        Positioned(
                                                          right: -6,
                                                          top: -6,
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  5,
                                                                ),
                                                            decoration:
                                                                const BoxDecoration(
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                ),
                                                            constraints:
                                                                const BoxConstraints(
                                                                  minWidth: 18,
                                                                  minHeight: 18,
                                                                ),
                                                            child: Center(
                                                              child: Text(
                                                                unreadNotifications >
                                                                        99
                                                                    ? '99+'
                                                                    : unreadNotifications
                                                                        .toString(),
                                                                style: const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                context.spaceWPx(6),
                                              ],
                                            ),

                                            context.spaceHPx(16),

                                            // CARD STACK
                                            Stack(
                                              children: [
                                                Image.asset(
                                                  'assets/home/card.png',
                                                  width: double.maxFinite,
                                                  fit: BoxFit.cover,
                                                ),
                                                Padding(
                                                  padding: context
                                                      .padSymmetricPx(
                                                        horizontal: 40,
                                                        vertical: 30,
                                                      ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        'Total Balance',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Color(
                                                            0xffFFFFFF,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      InkWell(
                                                        onTap: clickToShow,
                                                        child:
                                                            isClick
                                                                ? Image.asset(
                                                                  'assets/home/eye.png',
                                                                  height:
                                                                      context
                                                                          .hPx(
                                                                            16,
                                                                          ),
                                                                  width: context
                                                                      .wPx(20),
                                                                )
                                                                : const Icon(
                                                                  Icons
                                                                      .visibility_off,
                                                                  color: Color(
                                                                    0xffFFFFFF,
                                                                  ),
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 80,
                                                  left: 40,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        isClick
                                                            ? 'Rs ${accountLoaded?.balance ?? 0}'
                                                            : 'Rs ******',
                                                        style: const TextStyle(
                                                          fontSize: 31,
                                                          color: Color(
                                                            0xffFFFFFF,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const Text(
                                                        'Tap to hide balance',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Color(
                                                            0xffFFFFFF,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 20,
                                                  left: 20,
                                                  child: Row(
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (_) =>
                                                                      DepositMoney(),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          width: 169,
                                                          height: 56,
                                                          decoration: BoxDecoration(
                                                            color: const Color(
                                                              0xffFFFFFF,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Text(
                                                                  'Add Money',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Color(
                                                                      0xff1E1F20,
                                                                    ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                                context
                                                                    .spaceWPx(
                                                                      10,
                                                                    ),
                                                                Image.asset(
                                                                  'assets/home/arrowup.png',
                                                                  height:
                                                                      context
                                                                          .hPx(
                                                                            24,
                                                                          ),
                                                                  width: context
                                                                      .wPx(24),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      context.spaceWPx(8),
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (_) =>
                                                                      QRPage(),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          height: context.hPx(
                                                            56,
                                                          ),
                                                          width: context.wPx(
                                                            124,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                            border: Border.all(
                                                              color:
                                                                  const Color(
                                                                    0xffFFFFFF,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: const Center(
                                                            child: Text(
                                                              'Show QR',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Color(
                                                                  0xffFFFFFF,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            context.spaceHPx(20),

                                            // TRANSFER & SHORTCUTS
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Stack(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (_) =>
                                                                    TransferPage(),
                                                          ),
                                                        );
                                                      },
                                                      child: Stack(
                                                        children: [
                                                          Container(
                                                            height: context.hPx(
                                                              230,
                                                            ),
                                                            width: context.wPx(
                                                              136,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  const Color(
                                                                    0xff21496A,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20,
                                                                  ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            right: 0,
                                                            child: Image.asset(
                                                              'assets/home/sidecircle.png',
                                                              height: context
                                                                  .hPx(81),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: context
                                                          .padSymmetricPx(
                                                            horizontal: 30,
                                                            vertical: 40,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8,
                                                                ),
                                                            height: context.hPx(
                                                              42,
                                                            ),
                                                            width: context.wPx(
                                                              42,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  const Color(
                                                                    0xffDFE5FF,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                            child: Image.asset(
                                                              'assets/home/arrowup.png',
                                                            ),
                                                          ),
                                                          context.spaceHPx(70),
                                                          const Text(
                                                            'Transfer',
                                                            style: TextStyle(
                                                              color: Color(
                                                                0xffFFFFFF,
                                                              ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          const Text(
                                                            'Send Money',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Color(
                                                                0xffFFFFFF,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                context.spaceWPx(10),
                                                Expanded(
                                                  child: SizedBox(
                                                    height: context.hPx(250),
                                                    child: GridView.builder(
                                                      itemCount:
                                                          listOfShortCuts
                                                              .length,
                                                      gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                            childAspectRatio: 1,
                                                            mainAxisSpacing: 4,
                                                            crossAxisSpacing: 6,
                                                            crossAxisCount: 2,
                                                          ),
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemBuilder: (
                                                        context,
                                                        index,
                                                      ) {
                                                        final item =
                                                            listOfShortCuts[index];
                                                        return InkWell(
                                                          onTap: () {
                                                            if (index == 0) {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (_) =>
                                                                          BillCategoriesPage(),
                                                                ),
                                                              );
                                                            }
                                                            if (index == 2) {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (_) =>
                                                                          const RequestMoney(),
                                                                ),
                                                              );
                                                            }
                                                            if (index == 3) {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (_) =>
                                                                          QRPage(),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: ShortCutTile(
                                                            imagePath:
                                                                item.imagePath,
                                                            buttonName:
                                                                item.buttonName,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            context.spaceHPx(15),

                                            // MY POCKETS
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: const [
                                                Text(
                                                  'My Pockets',
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
                                            context.spaceHPx(15),
                                            Center(
                                              child: AddPocketBox(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (_) => MyPockets(),
                                                    ),
                                                  );
                                                },
                                                totalPockets: goalsLength,
                                                saveAmount: totalSavedAmount,
                                                isHavePocket:
                                                    goalState is GoalLoaded &&
                                                    goalState.goals.isNotEmpty,
                                              ),
                                            ),
                                            context.spaceHPx(15),

                                            // RECENT TRANSACTIONS
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: const [
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
                                            context.spaceHPx(15),

                                            // TRANSACTION LIST
                                            if (transactionState
                                                is TransactionLoading)
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                            else if (transactions.isEmpty)
                                              const Text("No Transactions")
                                            else
                                              Column(
                                                children:
                                                    transactions.take(4).map((
                                                      trx,
                                                    ) {
                                                      final isCredit =
                                                          trx.type == "credit";

                                                      final trxDate =
                                                          DateTime.tryParse(
                                                            trx.dateTime
                                                                .toString(),
                                                          ) ??
                                                          DateTime.now();

                                                      final now =
                                                          DateTime.now();

                                                      String formattedDate;

                                                      if (trxDate.year ==
                                                              now.year &&
                                                          trxDate.month ==
                                                              now.month &&
                                                          trxDate.day ==
                                                              now.day) {
                                                        formattedDate = "Today";
                                                      } else if (trxDate.year ==
                                                              now.year &&
                                                          trxDate.month ==
                                                              now.month &&
                                                          trxDate.day ==
                                                              now.day - 1) {
                                                        formattedDate =
                                                            "Yesterday";
                                                      } else {
                                                        formattedDate =
                                                            "${trxDate.day}/${trxDate.month}/${trxDate.year}";
                                                      }

                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              bottom: 15,
                                                            ),
                                                        child: TrxTile(
                                                          imagePath:
                                                              'assets/home/pocket.png',

                                                          name: trx.description,

                                                          datetime:
                                                              formattedDate,

                                                          amount:
                                                              isCredit
                                                                  ? "+ Rs ${trx.amount.toStringAsFixed(0)}"
                                                                  : "- Rs ${trx.amount.toStringAsFixed(0)}",
                                                          amountColor:
                                                              isCredit
                                                                  ? const Color(
                                                                    0xff2F80ED,
                                                                  ) // Blue
                                                                  : const Color(
                                                                    0xffEB5757,
                                                                  ), // Red

                                                          onTap: () {},
                                                        ),
                                                      );
                                                    }).toList(),
                                              ),

                                            context.spaceHPx(30),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
