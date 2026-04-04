import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/bill_payment/presentation/components/bill_categories.dart';
import 'package:flowpay/features/bill_payment/presentation/components/bill_pages_appbar.dart';
import 'package:flowpay/features/bill_payment/presentation/components/bill_tile.dart';
import 'package:flowpay/features/bill_payment/presentation/cubit/bill_cubit.dart';
import 'package:flowpay/features/bill_payment/presentation/pages/electricity_provider_page.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BillCategoriesPage extends StatelessWidget {
  BillCategoriesPage({super.key});

  final billSearchController = TextEditingController();

  /// category: icon mapping (keeps your UI assets)
  final Map<String, String> categoryIcons = {
    "Electricity": "assets/bill/electricity.png",
    "Gas": "assets/bill/gas.png",
    "Water": "assets/bill/water.png",
    "Internet": "assets/bill/wifi.png",
    "Education": "assets/bill/education.png",
    "Telephone": "assets/bill/telephone.png",
    "Insurance": "assets/bill/insurance.png",
    "Government": "assets/bill/more.png",
    "More": "assets/bill/more.png",
  };

  /// tile colors
  final Map<String, Color> categoryColors = {
    "Electricity": Color(0xffFFEDD5),
    "Gas": Color(0xffFEE2E2),
    "Water": Color(0xffE0F2FE),
    "Internet": Color(0xffDBEAFE),
    "Education": Color(0xffEDE9FE),
    "Telephone": Color(0xffDCFCE7),
    "Insurance": Color(0xffFEF3C7),
    "Government": Color(0xffE5E7EB),
    "More": Color(0xffF3F4F6),
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BillCubit>();

    /// replace with your auth user id
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: billAppBar(context, 'Pay Bills'),
      body: SizedBox(
        width: double.maxFinite,
        child: Padding(
          padding: context.padSymmetricPx(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// SEARCH FIELD
              TextFormField(
                controller: billSearchController,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 10),
                    child: Image.asset(
                      'assets/transfer/search.png',
                      height: context.hPx(24),
                      width: context.wPx(24),
                    ),
                  ),
                  hintText: 'Search billers, categoreis...',
                  hintStyle: TextStyle(color: Color(0xff6B7280)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 244, 244, 244),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              context.spaceHPx(10),

              Text(
                'Categories',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              context.spaceHPx(12),

              /// DYNAMIC CATEGORY GRID
              SizedBox(
                height: context.hPx(310),
                child: FutureBuilder(
                  future: cubit.getCategories(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final categories = snapshot.data!;

                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: categories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.3,
                          ),
                      itemBuilder: (context, index) {
                        final category = categories[index];

                        return GestureDetector(
                          onTap: () {
                            /// Example navigation
                            if (category == "Electricity") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ElectricityProviderPage(),
                                ),
                              );
                            }
                          },
                          child: BillCategories(
                            imagePath: categoryIcons[category] ?? "",
                            billName: category,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              context.spaceHPx(16),

              /// RECENT BILLS HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Bills',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff007AFF),
                    ),
                  ),
                ],
              ),

              context.spaceHPx(12),

              /// DYNAMIC RECENT BILLS
              Expanded(
                child: StreamBuilder(
                  stream: cubit.getUserBillsStream(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text("Something went wrong"));
                    }

                    final bills = snapshot.data ?? [];

                    if (bills.isEmpty) {
                      return const Center(child: Text("No recent bills"));
                    }

                    return ListView.builder(
                      itemCount: bills.length,
                      itemBuilder: (context, index) {
                        final bill = bills[index];

                        final color =
                            categoryColors[bill.category] ??
                            const Color(0xffF3F4F6);

                        return BillTile(
                          imagePath: categoryIcons[bill.category] ?? "",
                          color: color,
                          billName: "${bill.providerName} ${bill.category}",
                          billID: "ID: ${bill.consumerId}",
                          useWidget:
                              bill.status == "paid"
                                  ? Image.asset(
                                    'assets/bill/paidtext.png',
                                    height: context.hPx(20),
                                    width: context.wPx(44),
                                  )
                                  : Container(
                                    height: context.hPx(32),
                                    width: context.wPx(83),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color(0xff007AFF),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Pay Now',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xffFFFFFF),
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
      backgroundColor: Color(0xffFFFFFF),
    );
  }
}

// import 'package:flowpay/features/bill_payment/presentation/components/bill_categories.dart';
// import 'package:flowpay/features/bill_payment/presentation/components/bill_pages_appbar.dart';
// import 'package:flowpay/features/bill_payment/presentation/components/bill_tile.dart';
// import 'package:flowpay/features/bill_payment/presentation/pages/electricity_provider_page.dart';
// import 'package:flowpay/helpers/ui_responsive_helper.dart';
// import 'package:flutter/material.dart';

// class BillCategoriesPage extends StatelessWidget {
//   BillCategoriesPage({super.key});

//   final billSearchController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: billAppBar(context, 'Pay Bills'),
//       body: SizedBox(
//         width: double.maxFinite,
//         child: Padding(
//           padding: context.padSymmetricPx(horizontal: 25),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(
//                   prefixIcon: Padding(
//                     padding: const EdgeInsets.only(left: 16, right: 10),
//                     child: Image.asset(
//                       'assets/transfer/search.png',
//                       height: context.hPx(24),
//                       width: context.wPx(24),
//                     ),
//                   ),
//                   hintText: 'Search billers, categoreis...',
//                   hintStyle: TextStyle(color: Color(0xff6B7280)),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: Color.fromARGB(255, 244, 244, 244),
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//               ),
//               context.spaceHPx(10),
//               Text(
//                 'Categories',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//               context.spaceHPx(12),
//               SizedBox(
//                 height: context.hPx(310),
//                 child: GridView.builder(
//                   padding: EdgeInsets.zero,
//                   itemCount: lisofBillCategories.length,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 20,
//                     mainAxisSpacing: 20,
//                     childAspectRatio: 1.3,
//                   ),
//                   itemBuilder: (context, index) {
//                     final billItem = lisofBillCategories[index];
//                     return GestureDetector(
//                       onTap: () {
//                         if (index == 0) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ElectricityProviderPage(),
//                             ),
//                           );
//                         }
//                       },
//                       child: BillCategories(
//                         imagePath: billItem.imagePath,
//                         billName: billItem.billName,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               context.spaceHPx(16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Recent Bills',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                   Text(
//                     'View All',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xff007AFF),
//                     ),
//                   ),
//                 ],
//               ),
//               context.spaceHPx(12),
//               BillTile(
//                 imagePath: 'assets/bill/electricity.png',
//                 color: Color(0xffFFEDD5),
//                 billName: 'LESCO Electricity',
//                 billID: 'ID: 15468200345',
//                 useWidget: Container(
//                   height: context.hPx(32),
//                   width: context.wPx(83),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: Color(0xff007AFF),
//                   ),
//                   child: Center(
//                     child: Text(
//                       'Pay Now',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xffFFFFFF),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               BillTile(
//                 imagePath: 'assets/bill/wifi.png',
//                 color: Color(0xffDBEAFE),
//                 billName: 'StromFiber Internet',
//                 billID: 'ID: 15468200345',
//                 useWidget: Image.asset(
//                   'assets/bill/paidtext.png',
//                   height: context.hPx(20),
//                   width: context.wPx(44),
//                 ),
//               ),
//               BillTile(
//                 imagePath: 'assets/bill/gas.png',
//                 color: Color(0xffFEE2E2),
//                 billName: 'LESCO Electricity',
//                 billID: 'ID: 15468200345',
//                 useWidget: Container(
//                   height: context.hPx(32),
//                   width: context.wPx(83),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: Color(0xff007AFF),
//                   ),
//                   child: Center(
//                     child: Text(
//                       'Pay Now',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xffFFFFFF),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       backgroundColor: Color(0xffFFFFFF),
//     );
//   }
// }
