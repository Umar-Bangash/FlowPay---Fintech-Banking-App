import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/qr/presentation/pages/qr_scan_page.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRPage extends StatelessWidget {
  const QRPage({super.key});

  @override
  Widget build(BuildContext context) {
    /// Get current user id
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    /// Debug print to confirm
    debugPrint("QRPage -> Current UserId inside QR : $userId");

    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),

      appBar: AppBar(
        backgroundColor: const Color(0xffFFFFFF),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QRScanPage()),
              );
            },
            child: Image.asset(
              'assets/transfer/qr_icon.png',
              height: context.hPx(24),
              width: context.wPx(24),
            ),
          ),
          context.spaceWPx(10),
          Image.asset(
            'assets/home/notification.png',
            height: context.hPx(24),
            width: context.wPx(24),
          ),
          context.spaceWPx(20),
        ],
      ),

      body: Padding(
        padding: context.padSymmetricPx(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Titles
            const Text(
              'Quick Pay',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),

            const Text(
              'Flow pay',
              style: TextStyle(fontSize: 16, color: Color(0xff737373)),
            ),

            context.spaceHPx(20),

            /// QR Card
            Container(
              height: context.hPx(381),
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xffFFFFFF),
                border: Border.all(color: const Color(0xffE5E5E5)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// FlowPay Logo
                  Image.asset(
                    'assets/images/flowpay.png',
                    height: context.hPx(28),
                    width: context.wPx(157),
                  ),

                  context.spaceHPx(30),

                  /// REAL QR CODE
                  Container(
                    height: context.hPx(170),
                    width: context.wPx(170),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: QrImageView(
                      data: userId,
                      size: 170,
                      backgroundColor: Colors.white,
                    ),
                  ),

                  context.spaceHPx(25),

                  /// User Name
                  const Text(
                    'Umar Bangash',
                    style: TextStyle(
                      fontSize: 17.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  context.spaceHPx(10),

                  /// Account Number
                  const Text(
                    'Account No : 03269114017',
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// Done Button
            Center(child: MainButton(buttonName: 'Done', onTap: () {})),

            context.spaceHPx(100),
          ],
        ),
      ),
    );
  }
}

// import 'package:flowpay/features/qr/pages/qr_scan_page.dart';
// import 'package:flowpay/helpers/ui_responsive_helper.dart';
// import 'package:flowpay/start_pages/components/main_button.dart';
// import 'package:flutter/material.dart';

// class QRPage extends StatelessWidget {
//   const QRPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: InkWell(
//           onTap: () => Navigator.pop(context),
//           child: Icon(Icons.arrow_back_ios, size: 20),
//         ),
//         actions: [
//           InkWell(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const QRScanPage()),
//               );
//             },
//             child: Image.asset(
//               'assets/transfer/qr_icon.png',
//               height: context.hPx(24),
//               width: context.wPx(24),
//             ),
//           ),
//           context.spaceWPx(10),
//           Image.asset(
//             'assets/home/notification.png',
//             height: context.hPx(24),
//             width: context.wPx(24),
//           ),
//           context.spaceWPx(20),
//         ],
//         backgroundColor: Color(0xffFFFFFF),
//       ),
//       body: Padding(
//         padding: context.padSymmetricPx(horizontal: 25),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Quick Pay',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
//             ),
//             Text(
//               'Flow pay',
//               style: TextStyle(fontSize: 16, color: Color(0xff737373)),
//             ),
//             context.spaceHPx(20),
//             Container(
//               height: context.hPx(381.59),
//               width: double.maxFinite,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 color: Color(0xffFFFFFF),
//                 border: Border.all(color: Color(0xffE5E5E5)),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     'assets/images/flowpay.png',
//                     height: context.hPx(27.95),
//                     width: context.wPx(157),
//                   ),
//                   context.spaceHPx(20),
//                   Image.asset(
//                     'assets/transfer/qrcode.png',
//                     height: context.hPx(170),
//                     width: context.wPx(170),
//                   ),
//                   context.spaceHPx(20),
//                   Text(
//                     'Umar Bangash',
//                     style: TextStyle(
//                       fontSize: 17.68,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   context.spaceHPx(16),
//                   Text(
//                     'Account No : 03269114017',
//                     style: TextStyle(fontSize: 17.68),
//                   ),
//                 ],
//               ),
//             ),
//             Spacer(),
//             Center(child: MainButton(buttonName: 'Done', onTap: () {})),
//             context.spaceHPx(100),
//           ],
//         ),
//       ),
//       backgroundColor: Color(0xffFFFFFF),
//     );
//   }
// }
