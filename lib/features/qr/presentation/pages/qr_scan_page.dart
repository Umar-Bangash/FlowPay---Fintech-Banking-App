import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../transaction/presentation/cubit/transaction_cubit.dart';
import '../../../transaction/presentation/pages/transfer_money.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),

      appBar: AppBar(
        backgroundColor: const Color(0xffFFFFFF),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: const Text(
          "Scan QR",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),

      body: Column(
        children: [
          context.spaceHPx(30),

          const Text(
            "Scan receiver QR to send money",
            style: TextStyle(fontSize: 16),
          ),

          context.spaceHPx(30),

          Expanded(
            child: MobileScanner(
              onDetect: (barcodeCapture) async {
                if (isScanned) return;

                final barcodes = barcodeCapture.barcodes;

                for (final barcode in barcodes) {
                  final String? scannedUserId = barcode.rawValue;

                  if (scannedUserId != null) {
                    isScanned = true;

                    debugPrint("Scanned UserId: $scannedUserId");

                    try {
                      final receiver = await context
                          .read<TransactionCubit>()
                          .getReceiverById(scannedUserId);

                      if (receiver == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Receiver not found")),
                        );
                        setState(() => isScanned = false);
                        return;
                      }

                      if (!mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransferMoney(receiver: receiver),
                        ),
                      );
                    } catch (e) {
                      debugPrint("Error: $e");

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));

                      setState(() => isScanned = false);
                    }

                    break;
                  }
                }
              },
            ),
          ),

          context.spaceHPx(50),
        ],
      ),
    );
  }
}

// import 'package:flowpay/features/qr/pages/qr_payment_success_page.dart';
// import 'package:flowpay/helpers/ui_responsive_helper.dart';
// import 'package:flowpay/start_pages/components/main_button.dart';
// import 'package:flutter/material.dart';

// class QRScanPage extends StatelessWidget {
//   const QRScanPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: InkWell(
//           onTap: () => Navigator.pop(context),
//           child: Icon(Icons.arrow_back_ios, size: 20),
//         ),
//         centerTitle: true,
//         title: Text(
//           'Scan QR',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//         ),
//         backgroundColor: Color(0xffFFFFFF),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             'The Scan QR functionality will be implemented',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w500,
//               color: Color(0xff000000),
//             ),
//           ),
//           context.spaceHPx(30),
//           Container(
//             height: context.hPx(36),
//             width: context.wPx(122),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(55),
//               color: Color(0xffDADADA),
//             ),
//             child: Center(
//               child: Text(
//                 'Scan Qr Code',
//                 style: TextStyle(fontSize: 13, color: Color(0xff737373)),
//               ),
//             ),
//           ),
//           context.spaceHPx(50),
//           MainButton(
//             buttonName: 'Done',
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const QRPaymentSuccessPage(),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       backgroundColor: Color(0xffFFFFFF),
//     );
//   }
// }
