import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class ReceiptPdfService {
  Future<File> generateReceipt({
    required String receiverName,
    required double amount,
    required String transactionId,
  }) async {
    final pdf = pw.Document();

    final formattedDate =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "FlowPay",
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      "RECEIPT",
                      style: pw.TextStyle(fontSize: 20, color: PdfColors.grey),
                    ),
                  ],
                ),
                pw.SizedBox(height: 40),

                _buildRow("Receiver", receiverName),
                _buildRow("Amount", "\$${amount.toStringAsFixed(2)}"),
                _buildRow("Transaction ID", transactionId),
                _buildRow("Date", formattedDate),
                _buildRow("Payment Method", "FlowPay"),

                pw.Divider(height: 40),

                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    "Thank you for using FlowPay!",
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/receipt_$transactionId.pdf");

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  pw.Widget _buildRow(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
