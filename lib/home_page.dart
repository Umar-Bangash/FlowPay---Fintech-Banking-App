import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/transaction/presentation/components/profile_image.dart';
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
import 'features/transaction/presentation/pages/transfer_page.dart';
import 'helpers/app_animation.dart';
import 'helpers/ui_responsive_helper.dart';

class _HomeData {
  final String userName;
  final String? profileImage;
  final dynamic account;
  final double totalSaved;
  final int goalsCount;
  final bool hasGoals;
  final int unread;
  final List<TransactionModel> transactions;
  final bool txLoading;

  const _HomeData({
    required this.userName,
    required this.profileImage,
    required this.account,
    required this.totalSaved,
    required this.goalsCount,
    required this.hasGoals,
    required this.unread,
    required this.transactions,
    required this.txLoading,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _balanceVisible = false;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    context.read<AccountCubit>().listenToAccounts(_uid);
    context.read<GoalCubit>().fetchGoals(_uid);
    context.read<NotificationCubit>().listenToNotifications(_uid);
    context.read<ProfileCubit>().fetchProfileUser(_uid);
  }

  _HomeData _data(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final acct = context.watch<AccountCubit>().state;
    final prof = context.watch<ProfileCubit>().state;
    final goal = context.watch<GoalCubit>().state;
    final notif = context.watch<NotificationCubit>().state;
    final tx = context.watch<TransactionCubit>().state;

    final account =
        acct is AccountLoaded && acct.accounts.isNotEmpty
            ? acct.accounts.first
            : null;

    if (account != null) {
      context.read<TransactionCubit>().listenToTransactions(
        account.accountId.toString(),
      );
    }

    return _HomeData(
      userName: auth is Authenticated ? auth.user.name : '',
      profileImage:
          prof is ProfileLoaded ? prof.profileUser.profileImageUrl : null,
      account: account,
      totalSaved:
          goal is GoalLoaded
              ? goal.goals.fold(0.0, (s, g) => s + g.savedAmount)
              : 0.0,
      goalsCount: goal is GoalLoaded ? goal.goals.length : 0,
      hasGoals: goal is GoalLoaded && goal.goals.isNotEmpty,
      unread:
          notif is NotificationLoaded
              ? notif.notifications.where((n) => !n.isRead).length
              : 0,
      transactions: tx is TransactionLoaded ? tx.transactions : [],
      txLoading: tx is TransactionLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final d = _data(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: AppAnimatedPage(
          direction: SlideDirection.bottom,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: AppResponsive.w(24),
                vertical: AppResponsive.h(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAnimatedItem(
                    index: 0,
                    direction: SlideDirection.left,
                    child: _Header(
                      userName: d.userName,
                      profileImage: d.profileImage,
                      phone: d.account?.phone,
                      unread: d.unread,
                      uid: _uid,
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(16)),

                  AppAnimatedItem(
                    index: 1,
                    direction: SlideDirection.right,
                    child: _BalanceCard(
                      balance: d.account?.balance ?? 0,
                      visible: _balanceVisible,
                      onToggle:
                          () => setState(
                            () => _balanceVisible = !_balanceVisible,
                          ),
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(20)),

                  // ── KEY FIX: LayoutBuilder-driven section ──────────────
                  AppAnimatedItem(
                    index: 2,
                    direction: SlideDirection.left,
                    child: const _TransferShortcuts(),
                  ),

                  SizedBox(height: AppResponsive.h(15)),

                  AppAnimatedItem(
                    index: 3,
                    direction: SlideDirection.right,
                    child: const _SectionRow(
                      title: 'My Pockets',
                      action: 'View All',
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(12)),

                  AppAnimatedItem(
                    index: 4,
                    direction: SlideDirection.bottom,
                    child: Center(
                      child: AddPocketBox(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MyPockets()),
                            ),
                        totalPockets: d.goalsCount,
                        saveAmount: d.totalSaved,
                        isHavePocket: d.hasGoals,
                      ),
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(15)),

                  AppAnimatedItem(
                    index: 5,
                    direction: SlideDirection.left,
                    child: const _SectionRow(
                      title: 'Recent Transactions',
                      action: 'View All',
                    ),
                  ),

                  SizedBox(height: AppResponsive.h(12)),

                  _TxList(loading: d.txLoading, transactions: d.transactions),

                  SizedBox(height: AppResponsive.h(30)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// header
class _Header extends StatelessWidget {
  final String userName;
  final String? profileImage;
  final String? phone;
  final int unread;
  final String uid;

  const _Header({
    required this.userName,
    required this.profileImage,
    required this.phone,
    required this.unread,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final av = AppResponsive.sp(43);
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
          child: Container(
            height: av,
            width: av,
            color: const Color(0xff9DABB3),
            child:
                (profileImage?.isNotEmpty ?? false)
                    ? Image.network(
                      profileImage!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              const Icon(Icons.person, color: Colors.white),
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
                'Hi, $userName',
                style: TextStyle(
                  fontSize: AppResponsive.fs(16),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      phone ?? 'account number',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(11.5),
                        color: const Color(0xff737373),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: AppResponsive.w(4)),
                  Image.asset(
                    'assets/home/copy.png',
                    height: AppResponsive.sp(14),
                    width: AppResponsive.sp(14),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Logout
        _IconBtn(
          onTap: () => context.read<AuthCubit>().logout(),
          child: Image.asset(
            'assets/home/logout.png',
            height: AppResponsive.sp(22),
            width: AppResponsive.sp(22),
          ),
        ),
        SizedBox(width: AppResponsive.w(8)),
        // Bell
        _IconBtn(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationPage(userId: uid),
                ),
              ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                'assets/home/notification.png',
                height: AppResponsive.sp(22),
                width: AppResponsive.sp(22),
              ),
              if (unread > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: AppResponsive.sp(15),
                      minHeight: AppResponsive.sp(15),
                    ),
                    child: Center(
                      child: Text(
                        unread > 99 ? '99+' : '$unread',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppResponsive.fs(8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _IconBtn({required this.child, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(padding: const EdgeInsets.all(4), child: child),
  );
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  final bool visible;
  final VoidCallback onToggle;
  const _BalanceCard({
    required this.balance,
    required this.visible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxWidth * 0.46; // aspect-ratio driven, safe on all screens
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
              child: Image.asset(
                'assets/home/card.png',
                width: double.infinity,
                height: h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: h,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppResponsive.w(20),
                  vertical: AppResponsive.h(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Total Balance',
                          style: TextStyle(
                            fontSize: AppResponsive.fs(14),
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: onToggle,
                          child: Icon(
                            visible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                            size: AppResponsive.sp(20),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppResponsive.h(6)),
                    Text(
                      visible
                          ? 'Rs ${balance.toStringAsFixed(0)}'
                          : 'Rs ••••••',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(26, max: 34),
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Tap to hide balance',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(11),
                        color: Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    // Buttons — Expanded + flex ratio, no fixed widths
                    Row(
                      children: [
                        Expanded(
                          flex: 55,
                          child: _CardBtn(
                            label: 'Add Money',
                            iconAsset: 'assets/home/arrowup.png',
                            filled: true,
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DepositMoney(),
                                  ),
                                ),
                          ),
                        ),
                        SizedBox(width: AppResponsive.w(8)),
                        Expanded(
                          flex: 45,
                          child: _CardBtn(
                            label: 'Show QR',
                            filled: false,
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => QRPage()),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CardBtn extends StatelessWidget {
  final String label;
  final String? iconAsset;
  final bool filled;
  final VoidCallback onTap;

  const _CardBtn({
    required this.label,
    required this.filled,
    required this.onTap,
    this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
      child: Container(
        // Height responsive — clamp prevents it being too tall on tablets
        // or too short on SE
        height: AppResponsive.h(46).clamp(38.0, 54.0),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
          border: filled ? null : Border.all(color: Colors.white),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconAsset != null) ...[
              Image.asset(
                iconAsset!,
                height: AppResponsive.sp(15),
                width: AppResponsive.sp(15),
              ),
              SizedBox(width: AppResponsive.w(5)),
            ],
            // FittedBox ensures text scales DOWN rather than overflowing
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: AppResponsive.fs(13),
                    fontWeight: FontWeight.w500,
                    color: filled ? const Color(0xff1E1F20) : Colors.white,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferShortcuts extends StatelessWidget {
  const _TransferShortcuts();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalW = constraints.maxWidth;
        final gap = AppResponsive.w(10);
        final transferW = totalW * 0.34; // 34% for transfer card
        final gridW = totalW - transferW - gap; // rest for grid

        // Tile size = half gridW minus half the crossAxisSpacing
        final tileSize = (gridW - 6) / 2;

        // Grid height = 2 rows × tileSize + mainAxisSpacing between rows
        final gridH = tileSize * 2 + 4;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TransferCard(width: transferW, height: gridH),

            SizedBox(width: gap),

            SizedBox(
              width: gridW,
              height: gridH,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listOfShortCuts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  final item = listOfShortCuts[index];
                  return InkWell(
                    onTap: () {
                      switch (index) {
                        case 0:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BillCategoriesPage(),
                            ),
                          );
                          break;
                        case 2:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RequestMoney(),
                            ),
                          );
                          break;
                        case 3:
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => QRPage()),
                          );
                          break;
                      }
                    },
                    borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
                    child: ShortCutTile(
                      imagePath: item.imagePath,
                      buttonName: item.buttonName,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TransferCard extends StatelessWidget {
  final double width;
  final double height;
  const _TransferCard({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TransferPage()),
          ),
      borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xff21496A),
          borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(AppResponsive.radiusLg),
                ),
                child: Image.asset(
                  'assets/home/sidecircle.png',
                  height: height * 0.36,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(AppResponsive.w(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppResponsive.sp(7)),
                    height: AppResponsive.sp(34),
                    width: AppResponsive.sp(34),
                    decoration: BoxDecoration(
                      color: const Color(0xffDFE5FF),
                      borderRadius: BorderRadius.circular(
                        AppResponsive.radiusSm,
                      ),
                    ),
                    child: Image.asset('assets/home/arrowup.png'),
                  ),
                  const Spacer(),
                  Text(
                    'Transfer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: AppResponsive.fs(13),
                    ),
                  ),
                  SizedBox(height: AppResponsive.h(2)),
                  Text(
                    'Send Money',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: AppResponsive.fs(10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  final String title;
  final String action;
  const _SectionRow({required this.title, required this.action});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: AppResponsive.fs(15),
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        action,
        style: TextStyle(
          fontSize: AppResponsive.fs(13),
          color: const Color(0xff737373),
        ),
      ),
    ],
  );
}

// transaction tile

class _TxList extends StatelessWidget {
  final bool loading;
  final List<TransactionModel> transactions;
  const _TxList({required this.loading, required this.transactions});

  String _fmt(dynamic dt) {
    final d = DateTime.tryParse(dt.toString()) ?? DateTime.now();
    final n = DateTime.now();
    if (d.year == n.year && d.month == n.month && d.day == n.day) {
      return 'Today';
    }
    if (d.year == n.year && d.month == n.month && d.day == n.day - 1) {
      return 'Yesterday';
    }
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppResponsive.h(20)),
          child: Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: AppResponsive.fs(14),
              color: const Color(0xff737373),
            ),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(transactions.take(4).length, (i) {
        final trx = transactions[i];
        final isCredit = trx.type == 'credit';
        return AppAnimatedItem(
          index: i + 6,
          direction: i.isEven ? SlideDirection.left : SlideDirection.right,
          child: Padding(
            padding: EdgeInsets.only(bottom: AppResponsive.h(14)),
            child: FutureBuilder<String?>(
              future: getProfileImage(trx.receiverId),
              builder:
                  (context, snap) => TrxTile(
                    profileImageUrl: snap.data,
                    name: trx.description,
                    datetime: _fmt(trx.dateTime),
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
      }),
    );
  }
}
