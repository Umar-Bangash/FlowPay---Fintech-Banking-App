import 'package:flowpay/features/chat/presentation/pages/chat_contact_page.dart';
import 'package:flowpay/features/profile_and_setting/presentation/pages/profile_setting_page.dart';
import 'package:flowpay/features/qr/presentation/pages/qr_page.dart';
import 'package:flowpay/features/transaction/presentation/pages/transfer_page.dart';
import 'package:flowpay/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_cubit.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, selectedIndex) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white70,

              body: IndexedStack(
                index: selectedIndex,
                children: [
                  HomePage(),
                  TransferPage(),
                  QRPage(),
                  ChatContactPage(),
                  ProfileSettingPage(),
                ],
              ),

              bottomNavigationBar: Container(
                height: context.hPx(78),
                width: double.maxFinite,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      blurRadius: 7,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    context.spaceWPx(45),

                    // HOME ICON
                    GestureDetector(
                      onTap:
                          () => context.read<NavigationCubit>().selectPage(0),
                      child: Container(
                        height: context.hPx(42),
                        width: context.wPx(42),
                        padding: context.padAllPx(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: selectedIndex == 0 ? Color(0xffE8EDFF) : null,
                        ),
                        child: Image.asset(
                          'assets/navigation/home.png',
                          height: context.hPx(26),
                          width: context.wPx(26),
                        ),
                      ),
                    ),

                    context.spaceWPx(45),

                    // TRANSFER ICON
                    GestureDetector(
                      onTap:
                          () => context.read<NavigationCubit>().selectPage(1),
                      child: Container(
                        height: context.hPx(42),
                        width: context.wPx(42),
                        padding: context.padAllPx(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: selectedIndex == 1 ? Color(0xffE8EDFF) : null,
                        ),
                        child: Image.asset(
                          'assets/navigation/transfer.png',
                          height: context.hPx(26),
                          width: context.wPx(26),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // CHAT
                    GestureDetector(
                      onTap:
                          () => context.read<NavigationCubit>().selectPage(3),
                      child: Container(
                        height: context.hPx(42),
                        width: context.wPx(42),
                        padding: context.padAllPx(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: selectedIndex == 3 ? Color(0xffE8EDFF) : null,
                        ),
                        child: Image.asset(
                          'assets/navigation/chat.png',
                          height: context.hPx(26),
                          width: context.wPx(26),
                        ),
                      ),
                    ),

                    context.spaceWPx(45),

                    // PROFILE
                    GestureDetector(
                      onTap:
                          () => context.read<NavigationCubit>().selectPage(4),
                      child: Container(
                        height: context.hPx(42),
                        width: context.wPx(42),
                        padding: context.padAllPx(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: selectedIndex == 4 ? Color(0xffE8EDFF) : null,
                        ),
                        child: Image.asset(
                          'assets/navigation/profile.png',
                          height: context.hPx(26),
                          width: context.wPx(26),
                        ),
                      ),
                    ),

                    context.spaceWPx(45),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 180,
              bottom: 18,
              child: GestureDetector(
                onTap: () => context.read<NavigationCubit>().selectPage(2),
                child: Container(
                  height: 80,
                  width: 80,
                  padding: context.padAllPx(8),
                  decoration: const BoxDecoration(
                    color: Color(0xffFFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/navigation/qr.png',
                    height: context.hPx(72),
                    width: context.wPx(72),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
