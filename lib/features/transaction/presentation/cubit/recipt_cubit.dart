import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/services/receipt_pdf_service.dart';

class ReceiptCubit extends Cubit<void> {
  final ReceiptPdfService pdfService;

  ReceiptCubit(this.pdfService) : super(null);

  Future<File> _createFile(
    String receiverName,
    double amount,
    String transactionId,
  ) async {
    return await pdfService.generateReceipt(
      receiverName: receiverName,
      amount: amount,
      transactionId: transactionId,
    );
  }

  Future<void> shareReceipt({
    required String receiverName,
    required double amount,
    required String transactionId,
  }) async {
    final file = await _createFile(receiverName, amount, transactionId);

    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> downloadReceipt({
    required String receiverName,
    required double amount,
    required String transactionId,
  }) async {
    final file = await pdfService.generateReceipt(
      receiverName: receiverName,
      amount: amount,
      transactionId: transactionId,
    );

    await Printing.layoutPdf(onLayout: (format) async => file.readAsBytes());
  }
}
