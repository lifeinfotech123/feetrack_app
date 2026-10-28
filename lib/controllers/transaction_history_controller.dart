import 'dart:developer';

import 'package:get/get.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/data/models/transaction_history/total_transaction_model.dart';

class TransactionHistoryController extends GetxController {
  final ApiClient apiClient;

  TransactionHistoryController({required this.apiClient});

  bool isLoading = false;
  bool isDetailLoading = false;
  bool isSummaryLoading = false;

  TransactionSummary? summary;
  List<MyTransactionItem> transactions = [];
  Map<String, dynamic> pagination = {};

  MyTransactionItem? selectedTransaction;

  Map<String, dynamic> summaryData = {};

  Future<void> fetchTransactions() async {
    isLoading = true;
    update();
    try {
      final response = await apiClient.getData("v1/my-transactions", "fetchMyTransactions");
      if (response.body != null && response.body['status'] == true) {
        final data = response.body['data'];
        if (data is Map) {
          if (data['summary'] is Map) {
            summary = TransactionSummary.fromJson(Map<String, dynamic>.from(data['summary']));
          }
          if (data['transactions'] is List) {
            transactions = (data['transactions'] as List)
                .where((e) => e is Map)
                .map((e) => MyTransactionItem.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          }
          pagination = data['pagination'] is Map ? Map<String, dynamic>.from(data['pagination']) : {};
        }
      }
    } catch (e) {
      log('ERROR fetchTransactions: $e');
    }
    isLoading = false;
    update();
  }

  Future<void> fetchTransactionDetail(String id) async {
    isDetailLoading = true;
    selectedTransaction = null;
    update();
    try {
      final response = await apiClient.getData("v1/my-transactions/$id", "fetchTransactionDetail");
      if (response.body != null && response.body['status'] == true) {
        final data = response.body['data'];
        if (data is Map) {
          selectedTransaction = MyTransactionItem.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      log('ERROR fetchTransactionDetail: $e');
    }
    isDetailLoading = false;
    update();
  }

  Future<void> fetchTransactionSummary() async {
    isSummaryLoading = true;
    update();
    try {
      final response = await apiClient.getData("v1/my-transactions/summary", "fetchTransactionSummary");
      if (response.body != null && response.body['status'] == true) {
        final data = response.body['data'];
        if (data is Map) {
          summaryData = Map<String, dynamic>.from(data);
        }
      }
    } catch (e) {
      log('ERROR fetchTransactionSummary: $e');
    }
    isSummaryLoading = false;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }
}
