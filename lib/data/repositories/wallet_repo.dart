import 'package:get/get_connect/http/src/response/response.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class WalletRepo {
  final ApiClient apiClient;

  WalletRepo({required this.apiClient});

  Future<Response> fetchGymCustomerWallet() async => await apiClient.getData(
        AppConstants.getGymCustomerWallet,
        "fetchGymCustomerWallet",
      );

  Future<Response> fetchGymCustomerWalletTransactions(
          {Map<String, dynamic>? query}) async =>
      await apiClient.getData(
        AppConstants.getGymCustomerWalletTransactions,
        "fetchGymCustomerWalletTransactions",
      );

  Future<Response> initiateGymWalletRecharge(Map<String, dynamic> body) async =>
      await apiClient.postData(
        AppConstants.postGymCustomerWalletRecharge,
        "initiateGymWalletRecharge",
        body,
      );

  Future<Response> verifyGymWalletRecharge(Map<String, dynamic> body) async =>
      await apiClient.postData(
        AppConstants.postGymCustomerWalletVerifyRecharge,
        "verifyGymWalletRecharge",
        body,
      );

  Future<Response> fetchPaymentHistory() async => await apiClient.getData(
        AppConstants.getPaymentHistory,
        "fetchPaymentHistory",
      );

  Future<Response> fetchMyWalletBalance() async => await apiClient.getData(
        AppConstants.getMyWalletBalance,
        "fetchMyWalletBalance",
      );

  Future<Response> fetchMyTransactions() async => await apiClient.getData(
        AppConstants.getMyTransactions,
        "fetchMyTransactions",
      );

  Future<Response> rechargeMyWallet(Map<String, dynamic> body) async =>
      await apiClient.postData(
        AppConstants.postMyWalletRecharge,
        "rechargeMyWallet",
        body,
      );

  Future<Response> fetchWalletSummary() async => await apiClient.getData(
        AppConstants.getWalletSummary,
        "fetchWalletSummary",
      );

  Future<Response> fetchReserveHistory() async => await apiClient.getData(
        AppConstants.getReserveHistory,
        "fetchReserveHistory",
      );

  Future<Response> fetchRechargeHistory() async => await apiClient.getData(
        AppConstants.getRechargeHistory,
        "fetchRechargeHistory",
      );

  Future<Response> fetchWithdrawalHistory() async => await apiClient.getData(
        AppConstants.getWithdrawalHistory,
        "fetchWithdrawalHistory",
      );

  Future<Response> fetchWalletHistory() async => await apiClient.getData(
        AppConstants.getWalletHistory,
        "fetchWalletHistory",
      );

  Future<Response> rechargeWallet(Map<String, dynamic> body) async =>
      await apiClient.postData(
        AppConstants.postWalletRecharge,
        "rechargeWallet",
        body,
      );

  Future<Response> rechargeWalletInitiate(Map<String, dynamic> body) async =>
      await apiClient.postData(
        AppConstants.postWalletRechargeInitiate,
        "rechargeWalletInitiate",
        body,
      );

  Future<Response> getRechargeConfig(double amount) async =>
      await apiClient.postData(
        "${AppConstants.getRechargeConfig}?amount=$amount",
        "getRechargeConfig",
        {"amount": amount},
      );

  Future<Response> requestWithdrawal(Map<String, dynamic> body) async =>
      await apiClient.postData(
        AppConstants.postWalletWithdrawal,
        "requestWithdrawal",
        body,
      );

  Future<Response> rechargeGymCustomerWallet(Map<String, dynamic> body) async =>
      await apiClient.postData(
        AppConstants.postGymCustomerWalletRecharge,
        "rechargeGymCustomerWallet",
        body,
      );

  Future<Response> verifyGymCustomerWalletRecharge(
          Map<String, dynamic> body) async =>
      await apiClient.postData(
        AppConstants.postGymCustomerWalletVerifyRecharge,
        "verifyGymCustomerWalletRecharge",
        body,
      );
}
