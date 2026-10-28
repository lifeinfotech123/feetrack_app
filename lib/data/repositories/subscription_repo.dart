import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class SubscriptionRepo {
  final ApiClient apiClient;

  SubscriptionRepo({required this.apiClient});

  Future<Response> createSubscription({
    required FormData data,
  }) async =>
      await apiClient.postData(
        AppConstants.postCreateBooking,
        "createSubscription",
        data,
      );

  Future<Response> fetchSubscription() async => await apiClient.getData(
        AppConstants.getSubscription,
        "fetchSubscription",
      );

  Future<Response> fetchDuringListingById({
    required String id,
  }) async =>
      await apiClient.getData(
        AppConstants.getProfileDurations(id: id),
        "fetchDuringListingById",
      );

  Future<Response> fetchPlanListingById({
    required String id,
    Map<String, dynamic>? query,
  }) async =>
      await apiClient.getData(
        AppConstants.getProfilePlan(id: id),
        "fetchPlanListingById",
        query: query,
      );

  Future<Response> fetchBillingSummary({
    required Map<String, dynamic> data,
  }) async =>
      await apiClient.getData(
        AppConstants.billingPreview,
        "fetchBillingSummary",
        query: data,
      );

  Future<Response> fetchBookings() async => await apiClient.getData(
        AppConstants.postCreateBooking,
        "fetchBookings",
      );

  Future<Response> fetchBookingById({required String id}) async =>
      await apiClient.getData(
        "${AppConstants.postCreateBooking}/$id",
        "fetchBookingById",
      );

  Future<Response> cancelBooking(String bookingId) async =>
      await apiClient.postData(
        "${AppConstants.postCreateBooking}/$bookingId/cancel",
        "cancelBooking",
        {},
      );

  Future<Response> payBooking(String bookingId) async =>
      await apiClient.postData(
        "${AppConstants.postCreateBooking}/$bookingId/pay",
        "payBooking",
        {},
      );

  Future<Response> fetchSubscriptionsList() async => await apiClient.getData(
        AppConstants.getSubscription,
        "fetchSubscriptionsList",
      );

  Future<Response> fetchSubscriptionDetail({required String id}) async =>
      await apiClient.getData(
        "${AppConstants.getSubscription}/$id",
        "fetchSubscriptionDetail",
      );

  Future<Response> requestCancellation(
          {required String id, required Map<String, dynamic> data}) async =>
      await apiClient.postData(
        "${AppConstants.getSubscription}/$id/request-cancellation",
        "requestCancellation",
        data,
      );

  Future<Response> fetchCancellationHistory() async => await apiClient.getData(
        "${AppConstants.getSubscription}/cancellations/history",
        "fetchCancellationHistory",
      );

  Future<Response> renewSubscription(String subscriptionId) async =>
      await apiClient.postData(
        "${AppConstants.getSubscription}/$subscriptionId/renew",
        "renewSubscription",
        {},
      );

  Future<Response> downloadInvoice(String invoiceId) async {
    return await apiClient.getData(
      AppConstants.downloadReceipt(type: 'invoice', id: invoiceId),
      "downloadInvoice",
    );
  }
}

