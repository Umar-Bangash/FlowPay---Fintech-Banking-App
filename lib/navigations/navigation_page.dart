import 'package:flowpay/features/chat/presentation/pages/chat_contact_page.dart';
import 'package:flowpay/features/profile_and_setting/presentation/pages/profile_setting_page.dart';
import 'package:flowpay/features/qr/presentation/pages/qr_page.dart';
import 'package:flowpay/features/transaction/presentation/pages/transfer_page.dart';
import 'package:flowpay/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../helpers/ui_responsive_helper.dart';
import 'navigation_cubit.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    // Nav bar height: responsive, clamped so it never clips on short screens
    final navH = AppResponsive.h(72).clamp(64.0, 84.0);
    // QR fab size
    final fabSz = AppResponsive.sp(72).clamp(60.0, 84.0);
    // Icon container size
    final iconSz = AppResponsive.sp(40).clamp(34.0, 48.0);
    // Bottom offset so QR sits centred vertically on the nav bar
    final fabBottom = (navH - fabSz) / 2 + AppResponsive.bottomBarHeight;

    return BlocBuilder<NavigationCubit, int>(
      builder: (context, selectedIndex) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              body: IndexedStack(
                index: selectedIndex,
                children: [
                  HomePage(),
                  TransferPage(),
                  const QRPage(),
                  const ChatContactPage(),
                  const ProfileSettingPage(),
                ],
              ),

              bottomNavigationBar: Container(
                height: navH,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.35),
                      blurRadius: 7,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                // Use Row with equal Expanded slots so items NEVER overflow
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Home
                    Expanded(
                      child: _NavIcon(
                        asset: 'assets/navigation/home.png',
                        selected: selectedIndex == 0,
                        size: iconSz,
                        onTap:
                            () => context.read<NavigationCubit>().selectPage(0),
                      ),
                    ),

                    // Transfer
                    Expanded(
                      child: _NavIcon(
                        asset: 'assets/navigation/transfer.png',
                        selected: selectedIndex == 1,
                        size: iconSz,
                        onTap:
                            () => context.read<NavigationCubit>().selectPage(1),
                      ),
                    ),

                    // Centre gap — where the QR FAB sits
                    SizedBox(width: fabSz + AppResponsive.w(8)),

                    // Chat
                    Expanded(
                      child: _NavIcon(
                        asset: 'assets/navigation/chat.png',
                        selected: selectedIndex == 3,
                        size: iconSz,
                        onTap:
                            () => context.read<NavigationCubit>().selectPage(3),
                      ),
                    ),

                    // Profile
                    Expanded(
                      child: _NavIcon(
                        asset: 'assets/navigation/profile.png',
                        selected: selectedIndex == 4,
                        size: iconSz,
                        onTap:
                            () => context.read<NavigationCubit>().selectPage(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── QR FAB — always horizontally centred, never hardcoded ────────
            Positioned(
              bottom: fabBottom,
              left: (AppResponsive.screenWidth - fabSz) / 2,
              child: GestureDetector(
                onTap: () => context.read<NavigationCubit>().selectPage(2),
                child: Container(
                  height: fabSz,
                  width: fabSz,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(AppResponsive.sp(8)),
                  child: Image.asset('assets/navigation/qr.png'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Reusable nav icon — fills its Expanded slot, never overflows ─────────────
class _NavIcon extends StatelessWidget {
  final String asset;
  final bool selected;
  final double size;
  final VoidCallback onTap;

  const _NavIcon({
    required this.asset,
    required this.selected,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: size,
        width: size,
        padding: EdgeInsets.all(AppResponsive.sp(8)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
          color: selected ? const Color(0xffE8EDFF) : Colors.transparent,
        ),
        child: Image.asset(
          asset,
          height: AppResponsive.sp(22),
          width: AppResponsive.sp(22),
        ),
      ),
    ),
  );
}
