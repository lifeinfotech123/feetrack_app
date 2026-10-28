import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vlr/data/models/trans_filter_payment_type_model.dart';
import 'package:vlr/data/models/trans_filter_status_model.dart';
import 'package:vlr/data/models/transaction_model.dart';
import 'package:vlr/data/repositories/transaction_repo.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/file_download_helper.dart';
import 'package:vlr/views/screens/transaction_details_screen/transaction_details_screen.dart';

class TransactionController extends GetxController implements GetxService {
  final TransactionRepo transactionRepo;

  TransactionController({required this.transactionRepo});

  //* Transaction filter

  DateTime? fromDate;
  DateTime? toDate;

  TransactionModel? selectedTransaction;
  TransFilterPaymentTypeModel? selectTransFilterPaymentTypeModel;
  TransFilterStatusModel? selectTransFilterStatusModel;

  List<TransactionModel> transactionList = [];

  bool isTransactionLoading = false;
  bool isDetailLoading = false;

  Future<void> fetchRecentTransactions() async {
    isTransactionLoading = true;
    update();
    try {
      final Map<String, dynamic> filters = {};

      if (selectTransFilterStatusModel != null && selectTransFilterStatusModel!.id != 1) {
        filters['status'] = selectTransFilterStatusModel!.TranStatus?.toLowerCase();
      }

      if (selectTransFilterPaymentTypeModel != null) {
        filters['gateway'] = selectTransFilterPaymentTypeModel!.paymentType?.toLowerCase();
      }

      if (fromDate != null) {
        filters['from_date'] = DateFormat('yyyy-MM-dd').format(fromDate!);
      }

      if (toDate != null) {
        filters['to_date'] = DateFormat('yyyy-MM-dd').format(toDate!);
      }

      Response response = await transactionRepo.fetchRecentTransactions(filters: filters);
      if (response.statusCode == 200 &&
          response.body != null &&
          response.body['status'] == 'success') {
        transactionList = [];
        var data = response.body['data'];
        if (data != null && data['transactions'] != null) {
          var transactionsData = data['transactions']['data'];
          if (transactionsData != null && transactionsData is List) {
            for (var v in transactionsData) {
              transactionList.add(TransactionModel.fromJson(v));
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
    }
    isTransactionLoading = false;
    update();
  }

  Future<void> fetchTransactionDetails(String id) async {
    isDetailLoading = true;
    update();
    try {
      Response response = await transactionRepo.fetchTransactionDetails(id);
      if (response.statusCode == 200 &&
          response.body != null &&
          response.body['status'] == 'success') {
        var transactionData = response.body['data']['transaction'];
        if (transactionData != null) {
          selectedTransaction = TransactionModel.fromJson(transactionData);
        }
      }
    } catch (e) {
      debugPrint("Error fetching transaction details: $e");
    }
    isDetailLoading = false;
    update();
  }

  List<TransFilterPaymentTypeModel> transPaymentTypeList = [
    TransFilterPaymentTypeModel(
      id: 1,
      paymentType: "Cash",
    ),
    TransFilterPaymentTypeModel(
      id: 2,
      paymentType: "Razorpay",
    ),
    TransFilterPaymentTypeModel(
      id: 3,
      paymentType: "Tpipay",
    ),
  ];

  List<TransFilterStatusModel> transStatusList = [
    TransFilterStatusModel(
      id: 1,
      TranStatus: "All States",
    ),
    TransFilterStatusModel(
      id: 2,
      TranStatus: "Paid",
    ),
    TransFilterStatusModel(
      id: 3,
      TranStatus: "Failed",
    ),
    TransFilterStatusModel(
      id: 4,
      TranStatus: "Pending",
    ),
  ];

  void resetTransactionFilters() {
    fromDate = null;
    toDate = null;
    selectTransFilterPaymentTypeModel = null;
    selectTransFilterStatusModel =
        transStatusList.isNotEmpty ? transStatusList.first : null;
    update();
  }

  void openTransactionDetails(TransactionModel transaction) {
    selectedTransaction = transaction;
    update();
  }

  void navigateToTransactionDetails({
    required BuildContext context,
    required TransactionModel transaction,
  }) {
    openTransactionDetails(transaction);
    navigate(
      context: context,
      page: TransactionDetailsScreen(transaction: transaction),
    );
  }

  Future<void> copyTransactionId(String transactionId) async {
    await Clipboard.setData(ClipboardData(text: transactionId));
    showToast(
      toastType: ToastType.success,
      message: "Transaction ID copied",
    );
  }

  Future<void> shareTransactionScreenshot({
    required GlobalKey boundaryKey,
    required TransactionModel transaction,
  }) async {
    try {
      final RenderRepaintBoundary? boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        showToast(
          toastType: ToastType.error,
          message: "Unable to capture receipt",
        );
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        showToast(
          toastType: ToastType.error,
          message: "Unable to prepare screenshot",
        );
        return;
      }

      final directory = await getTemporaryDirectory();
      final File file = File(
        '${directory.path}/${transaction.transactionId}_receipt.png',
      );
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: "Transaction receipt for ${transaction.transactionId}",
        ),
      );
    } catch (_) {
      showToast(
        toastType: ToastType.error,
        message: "Unable to share receipt screenshot",
      );
    }
  }

  Future<void> downloadPDF({required String type, required String id, required String fileName}) async {
    final String url = "${AppConstants.baseUrl}${AppConstants.downloadReceipt(type: type, id: id)}";
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${transactionRepo.apiClient.token}',
      'Accept': 'application/pdf',
    };

    await FileDownloadHelper.downloadAndShareFile(
      url,
      "$fileName.pdf",
      headers,
    );
  }
}
