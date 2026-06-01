import 'package:flowpay/features/bill_payment/presentation/components/bill_pages_appbar.dart';
import 'package:flowpay/features/bill_payment/presentation/components/electricity_provider_tile.dart';
import 'package:flowpay/features/bill_payment/presentation/pages/bill_detail_page.dart';
import 'package:flowpay/features/bill_payment/presentation/cubit/bill_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class ElectricityProviderPage extends StatelessWidget {
  const ElectricityProviderPage({super.key});

  static const Map<String, String> _icons = {
    'K-Electric': 'assets/bill/kelectric.png',
    'LESCO': 'assets/bill/LESCO.png',
    'IESCO': 'assets/bill/IESCO.png',
    'PESCO': 'assets/bill/PESCO.png',
    'FESCO': 'assets/bill/FESCO.png',
    'GEPCO': 'assets/bill/kelectric.png',
  };

  static const Map<String, String> _desc = {
    'K-Electric': 'Karachi, Sindh',
    'LESCO': 'Lahore Electric Supply Company',
    'IESCO': 'Islamabad Electric Supply',
    'PESCO': 'Peshawar Electric Supply',
    'FESCO': 'Faisalabad Electric Supply',
    'GEPCO': 'Gujranwala Electric Supply',
  };

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final cubit = context.read<BillCubit>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: billAppBar(context, 'Select Provider'),
      body: AppAnimatedPage(
        direction: SlideDirection.bottom,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
          child: Column(
            children: [
              SizedBox(height: AppResponsive.h(8)),

              // ── Search ──────────────────────────────────────────────────
              AppAnimatedItem(
                index: 0,
                direction: SlideDirection.left,
                child: TextFormField(
                  style: TextStyle(fontSize: AppResponsive.fs(14)),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppResponsive.w(14),
                      ),
                      child: Image.asset(
                        'assets/transfer/search.png',
                        height: AppResponsive.sp(20),
                        width: AppResponsive.sp(20),
                      ),
                    ),
                    hintText: 'Search provider...',
                    hintStyle: TextStyle(
                      color: const Color(0xff6B7280),
                      fontSize: AppResponsive.fs(13),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 244, 244, 244),
                      ),
                      borderRadius: BorderRadius.circular(
                        AppResponsive.radiusMd,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppResponsive.h(24)),

              // ── Header ─────────────────────────────────────────────────
              AppAnimatedItem(
                index: 1,
                direction: SlideDirection.left,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/bill/chargeicon.png',
                      height: AppResponsive.sp(28),
                      width: AppResponsive.sp(28),
                    ),
                    SizedBox(width: AppResponsive.w(10)),
                    Text(
                      'ELECTRICITY PROVIDERS',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(14),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff64748B),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppResponsive.h(16)),

              // ── Provider list ───────────────────────────────────────────
              FutureBuilder(
                future: cubit.getProviders('Electricity'),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final providers = snap.data!;
                  return Column(
                    children:
                        providers.asMap().entries.map((e) {
                          final i = e.key;
                          final provider = e.value;
                          return AppAnimatedItem(
                            index: i + 2,
                            direction:
                                i.isEven
                                    ? SlideDirection.left
                                    : SlideDirection.right,
                            child: InkWell(
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => BillDetailPage(
                                            providerName: provider,
                                            category: 'Electricity',
                                          ),
                                    ),
                                  ),
                              child: ElectricTile(
                                imagePath: _icons[provider] ?? '',
                                providerName: provider,
                                provideFor: _desc[provider] ?? '',
                              ),
                            ),
                          );
                        }).toList(),
                  );
                },
              ),

              SizedBox(height: AppResponsive.h(12)),

              Text(
                'Can\'t find your provider?',
                style: TextStyle(
                  fontSize: AppResponsive.fs(12),
                  color: const Color(0xff94A3B8),
                ),
              ),

              SizedBox(height: AppResponsive.h(8)),

              Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: AppResponsive.fs(13),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff007AFF),
                ),
              ),

              SizedBox(height: AppResponsive.h(24)),
            ],
          ),
        ),
      ),
    );
  }
}
