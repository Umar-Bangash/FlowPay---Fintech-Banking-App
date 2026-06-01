import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/bill_payment/presentation/components/bill_categories.dart';
import 'package:flowpay/features/bill_payment/presentation/components/bill_pages_appbar.dart';
import 'package:flowpay/features/bill_payment/presentation/components/bill_tile.dart';
import 'package:flowpay/features/bill_payment/presentation/cubit/bill_cubit.dart';
import 'package:flowpay/features/bill_payment/presentation/pages/electricity_provider_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';
import '../../domain/entity/bill.dart';

class BillCategoriesPage extends StatefulWidget {
  const BillCategoriesPage({super.key});
  @override
  State<BillCategoriesPage> createState() => _BillCategoriesPageState();
}

class _BillCategoriesPageState extends State<BillCategoriesPage> {
  final _searchCtrl = TextEditingController();

  late Future<List<String>> _categoriesFuture;
  late Stream<List<Bill>> _billsStream;

  static const Map<String, String> _icons = {
    'Electricity': 'assets/bill/electricity.png',
    'Gas': 'assets/bill/gas.png',
    'Water': 'assets/bill/water.png',
    'Internet': 'assets/bill/wifi.png',
    'Education': 'assets/bill/education.png',
    'Telephone': 'assets/bill/telephone.png',
    'Insurance': 'assets/bill/insurance.png',
    'Government': 'assets/bill/more.png',
    'More': 'assets/bill/more.png',
  };

  static const Map<String, Color> _colors = {
    'Electricity': Color(0xffFFEDD5),
    'Gas': Color(0xffFEE2E2),
    'Water': Color(0xffE0F2FE),
    'Internet': Color(0xffDBEAFE),
    'Education': Color(0xffEDE9FE),
    'Telephone': Color(0xffDCFCE7),
    'Insurance': Color(0xffFEF3C7),
    'Government': Color(0xffE5E7EB),
    'More': Color(0xffF3F4F6),
  };

  @override
  void initState() {
    super.initState();
    final cubit = context.read<BillCubit>();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    _categoriesFuture = cubit.getCategories();
    _billsStream = cubit.getUserBillsStream(userId);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: billAppBar(context, 'Pay Bills'),
      body: AppAnimatedPage(
        direction: SlideDirection.bottom,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppResponsive.h(8)),

              // ── Search ────────────────────────────────────────────────
              AppAnimatedItem(
                index: 0,
                direction: SlideDirection.left,
                child: TextFormField(
                  controller: _searchCtrl,
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
                    hintText: 'Search billers, categories...',
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

              SizedBox(height: AppResponsive.h(12)),

              AppAnimatedItem(
                index: 1,
                direction: SlideDirection.left,
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: AppResponsive.fs(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: AppResponsive.h(10)),

              // ── Category grid — LayoutBuilder so height is always exact ──
              AppAnimatedItem(
                index: 2,
                direction: SlideDirection.bottom,
                child: FutureBuilder<List<String>>(
                  future: _categoriesFuture,
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final cats = snap.data!;
                    // Grid height = rows × tileH + spacing
                    // 3 columns, childAspectRatio 1.3
                    return LayoutBuilder(
                      builder: (context, c) {
                        final tileW = (c.maxWidth - 40) / 3; // 2 gaps of 20
                        final tileH = tileW / 1.3;
                        final rows = (cats.length / 3).ceil();
                        final gridH = rows * tileH + (rows - 1) * 20.0;

                        return SizedBox(
                          height: gridH,
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cats.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: 1.3,
                                ),
                            itemBuilder: (context, i) {
                              final cat = cats[i];
                              return GestureDetector(
                                onTap: () {
                                  if (cat == 'Electricity') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ElectricityProviderPage(),
                                      ),
                                    );
                                  }
                                },
                                child: BillCategories(
                                  imagePath: _icons[cat] ?? '',
                                  billName: cat,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: AppResponsive.h(14)),

              // ── Recent bills header ───────────────────────────────────
              AppAnimatedItem(
                index: 3,
                direction: SlideDirection.right,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Bills',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(15),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(13),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff007AFF),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppResponsive.h(10)),

              // ── Bills list ────────────────────────────────────────────
              Expanded(
                child: StreamBuilder<List<Bill>>(
                  stream: _billsStream,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(child: Text('Error: ${snap.error}'));
                    }
                    final bills = snap.data ?? [];
                    if (bills.isEmpty) {
                      return Center(
                        child: Text(
                          'No recent bills',
                          style: TextStyle(
                            fontSize: AppResponsive.fs(13),
                            color: const Color(0xff737373),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: bills.length,
                      itemBuilder: (context, i) {
                        final bill = bills[i];
                        final color =
                            _colors[bill.category] ?? const Color(0xffF3F4F6);
                        return AppAnimatedItem(
                          index: i + 4,
                          direction:
                              i.isEven
                                  ? SlideDirection.left
                                  : SlideDirection.right,
                          child: BillTile(
                            imagePath: _icons[bill.category] ?? '',
                            color: color,
                            billName: '${bill.providerName} ${bill.category}',
                            billID: 'ID: ${bill.consumerId}',
                            useWidget:
                                bill.status == 'paid'
                                    ? Image.asset(
                                      'assets/bill/paidtext.png',
                                      height: AppResponsive.h(20),
                                      width: AppResponsive.w(44),
                                    )
                                    : Container(
                                      height: AppResponsive.h(32),
                                      width: AppResponsive.w(80),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: const Color(0xff007AFF),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Pay Now',
                                          style: TextStyle(
                                            fontSize: AppResponsive.fs(11),
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
