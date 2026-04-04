import 'package:flowpay/features/bill_payment/presentation/components/bill_pages_appbar.dart';
import 'package:flowpay/features/bill_payment/presentation/components/electricity_provider_tile.dart';
import 'package:flowpay/features/bill_payment/presentation/pages/bill_detail_page.dart';
import 'package:flowpay/features/bill_payment/presentation/cubit/bill_cubit.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ElectricityProviderPage extends StatelessWidget {
  const ElectricityProviderPage({super.key});

  /// provider → icon mapping (keeps UI assets same)
  static final Map<String, String> providerIcons = {
    "K-Electric": "assets/bill/kelectric.png",
    "LESCO": "assets/bill/LESCO.png",
    "IESCO": "assets/bill/IESCO.png",
    "PESCO": "assets/bill/PESCO.png",
    "FESCO": "assets/bill/FESCO.png",
    "GEPCO": "assets/bill/kelectric.png",
  };

  /// provider → description mapping (same text as your UI)
  static final Map<String, String> providerDescriptions = {
    "K-Electric": "Karachi, Sindh",
    "LESCO": "Lahore Electric Supply Company",
    "IESCO": "Islamabad Electric Supply",
    "PESCO": "Peshawar Electric Supply",
    "FESCO": "Faisalabad Electric Supply",
    "GEPCO": "Gujranwala Electric Supply",
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BillCubit>();

    return Scaffold(
      appBar: billAppBar(context, 'Select Provider'),
      body: Padding(
        padding: context.padSymmetricPx(horizontal: 25),
        child: Column(
          children: [
            /// SEARCH
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 10),
                  child: Image.asset(
                    'assets/transfer/search.png',
                    height: context.hPx(24),
                    width: context.wPx(24),
                  ),
                ),
                hintText: 'Search provider...',
                hintStyle: TextStyle(color: Color(0xff6B7280)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 244, 244, 244),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            context.spaceHPx(30),

            /// HEADER
            Row(
              children: [
                Image.asset(
                  'assets/bill/chargeicon.png',
                  height: context.hPx(32),
                  width: context.wPx(32),
                ),
                context.spaceWPx(12),
                Text(
                  'ELECTRICITY PROVIDERS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff64748B),
                  ),
                ),
              ],
            ),

            context.spaceHPx(20),

            /// DYNAMIC PROVIDERS
            FutureBuilder(
              future: cubit.getProviders("Electricity"),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final providers = snapshot.data!;

                return Column(
                  children:
                      providers.map((provider) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => BillDetailPage(
                                      providerName: provider,
                                      category: "Electricity",
                                    ),
                              ),
                            );
                          },
                          child: ElectricTile(
                            imagePath: providerIcons[provider] ?? "",
                            providerName: provider,
                            provideFor: providerDescriptions[provider] ?? "",
                          ),
                        );
                      }).toList(),
                );
              },
            ),

            context.spaceHPx(10),

            /// SUPPORT TEXT
            Text(
              'Can\'t find your provider?',
              style: TextStyle(fontSize: 12, color: Color(0xff94A3B8)),
            ),

            context.spaceHPx(10),

            Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff007AFF),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xffFFFFFF),
    );
  }
}

// import 'package:flowpay/features/bill_payment/presentation/components/bill_pages_appbar.dart';
// import 'package:flowpay/features/bill_payment/presentation/components/electricity_provider_tile.dart';
// import 'package:flowpay/features/bill_payment/presentation/pages/bill_detail_page.dart';
// import 'package:flowpay/helpers/ui_responsive_helper.dart';
// import 'package:flutter/material.dart';

// class ElectricityProviderPage extends StatelessWidget {
//   const ElectricityProviderPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: billAppBar(context, 'Select Provider'),
//       body: Padding(
//         padding: context.padSymmetricPx(horizontal: 25),
//         child: Column(
//           children: [
//             TextFormField(
//               decoration: InputDecoration(
//                 prefixIcon: Padding(
//                   padding: const EdgeInsets.only(left: 16, right: 10),
//                   child: Image.asset(
//                     'assets/transfer/search.png',
//                     height: context.hPx(24),
//                     width: context.wPx(24),
//                   ),
//                 ),
//                 hintText: 'Search provider...',
//                 hintStyle: TextStyle(color: Color(0xff6B7280)),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Color.fromARGB(255, 244, 244, 244),
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//             ),
//             context.spaceHPx(30),
//             Row(
//               children: [
//                 Image.asset(
//                   'assets/bill/chargeicon.png',
//                   height: context.hPx(32),
//                   width: context.wPx(32),
//                 ),
//                 context.spaceWPx(12),
//                 Text(
//                   'ELECTRICITY PROVIDERS',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xff64748B),
//                   ),
//                 ),
//               ],
//             ),
//             context.spaceHPx(20),
//             InkWell(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => BillDetailPage()),
//                 );
//               },
//               child: ElectricTile(
//                 imagePath: 'assets/bill/kelectric.png',
//                 providerName: 'K-Electric (KE)',
//                 provideFor: 'Karachi, Sindh',
//               ),
//             ),
//             ElectricTile(
//               imagePath: 'assets/bill/LESCO.png',
//               providerName: 'LESCO',
//               provideFor: 'Lahor Electric Supply Compnay',
//             ),
//             ElectricTile(
//               imagePath: 'assets/bill/IESCO.png',
//               providerName: 'IESCO',
//               provideFor: 'Islamabad Electric Supply',
//             ),
//             ElectricTile(
//               imagePath: 'assets/bill/PESCO.png',
//               providerName: 'PESCO',
//               provideFor: 'Peshawar Electric Supply',
//             ),
//             ElectricTile(
//               imagePath: 'assets/bill/FESCO.png',
//               providerName: 'FESCO',
//               provideFor: 'Faisalabad Electric Supply',
//             ),
//             ElectricTile(
//               imagePath: 'assets/bill/kelectric.png',
//               providerName: 'GESCO',
//               provideFor: 'Gujarnawala Electric Supply',
//             ),
//             context.spaceHPx(10),
//             Text(
//               'Can\'t find your provider?',
//               style: TextStyle(fontSize: 12, color: Color(0xff94A3B8)),
//             ),
//             context.spaceHPx(10),
//             Text(
//               'Contact Support',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xff007AFF),
//               ),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: Color(0xffFFFFFF),
//     );
//   }
// }
