import 'package:get/get.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class TransactionRepo {
  final ApiClient apiClient;

  TransactionRepo({required this.apiClient});

  Future<Response> fetchRecentTransactions({Map<String, dynamic>? filters}) async {
    return await apiClient.getData(
      AppConstants.recentTransactionsUri,
      "fetchRecentTransactions",
      query: filters,
    );
  }

  Future<Response> fetchTransactionDetails(String id) async {
    return await apiClient.getData("${AppConstants.recentTransactionsUri}/$id", "fetchTransactionDetails");
  }
}
