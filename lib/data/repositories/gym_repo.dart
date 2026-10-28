import 'package:get/get.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class GymRepo {
  final ApiClient apiClient;

  GymRepo({required this.apiClient});

  Future<Response> fetchGymTrainers({String? id}) async =>
      await apiClient.getData(
        AppConstants.gymTrainers,
        "fetchGymTrainers",
        query:
            id != null && id.trim().isNotEmpty ? {"gym_id": id.trim()} : null,
      );

  Future<Response> fetchTrainerDetails({required String id}) async =>
      await apiClient.getData(
        AppConstants.gymTrainerDetails(id: id),
        "fetchTrainerDetails",
      );

  Future<Response> fetchMyGymBookings() async => await apiClient.getData(
        AppConstants.myGymBookings,
        "fetchMyGymBookings",
      );

  Future<Response> fetchMyGymVisits() async => await apiClient.getData(
        AppConstants.myGymVisits,
        "fetchMyGymVisits",
      );

  Future<Response> fetchMyGymVisitDetails({required String id}) async =>
      await apiClient.getData(
        AppConstants.myGymVisitDetails(id: id),
        "fetchMyGymVisitDetails",
      );

  Future<Response> bookGymVisit({
    required Map<String, dynamic> data,
  }) async =>
      await apiClient.postData(
        AppConstants.gymBookVisit,
        "bookGymVisit",
        data,
      );

  Future<Response> bookGymMembership({
    required Map<String, dynamic> data,
  }) async =>
      await apiClient.postData(
        AppConstants.gymBookMembership,
        "bookGymMembership",
        data,
      );

  Future<Response> fetchGymCities() async => await apiClient.getData(
        AppConstants.gymCities,
        "fetchGymCities",
      );

  Future<Response> verifyPaymentBooking({
    required Map<String, dynamic> data,
  }) async =>
      await apiClient.postData(
        AppConstants.gymVerifyPayment,
        "verifyPaymentBooking",
        data,
      );

  Future<Response> fetchGymShifts() async => await apiClient.getData(
        AppConstants.gymShifts,
        "fetchGymShifts",
      );

  Future<Response> fetchGymShiftsByGymId({required String gymId}) async =>
      await apiClient.getData(
        AppConstants.gymSpecificShifts(gymId: gymId),
        "fetchGymShiftsByGymId",
      );

  Future<Response> fetchGymShiftDetails({required String id}) async =>
      await apiClient.getData(
        AppConstants.gymShiftDetails(id: id),
        "fetchGymShiftDetails",
      );

  // ── Gym Attendance & Invoices ──────────────────────────────────────
  Future<Response> fetchGymAttendanceStatus() async => await apiClient.getData(
        AppConstants.gymAttendanceStatus,
        "fetchGymAttendanceStatus",
      );

  Future<Response> punchInGym({required Map<String, dynamic> data}) async =>
      await apiClient.postData(
        AppConstants.gymAttendancePunchIn,
        "punchInGym",
        data,
      );

  Future<Response> punchOutGym({required Map<String, dynamic> data}) async =>
      await apiClient.postData(
        AppConstants.gymAttendancePunchOut,
        "punchOutGym",
        data,
      );

  Future<Response> fetchGymAttendanceHistory({
    required String mobile,
    int? page,
    String? month,
  }) async {
    return await apiClient.getData(
      AppConstants.gymAttendanceHistory,
      "fetchGymAttendanceHistory",
      query: {
        "mobile": mobile,
        if (page != null) "page": page,
        if (month != null && month.isNotEmpty) "month": month,
      },
    );
  }

  Future<Response> fetchGymInvoices({int? page}) async {
    String url = AppConstants.gymInvoices;
    if (page != null) url = "$url?page=$page";
    return await apiClient.getData(url, "fetchGymInvoices");
  }

  Future<Response> fetchGymInvoiceDetails(String invoiceId) async =>
      await apiClient.getData(
        AppConstants.gymInvoiceDetails(invoiceId),
        "fetchGymInvoiceDetails",
      );

  Future<Response> fetchGymReviews({
    required String gymId,
    int? page,
  }) async =>
      await apiClient.getData(
        AppConstants.gymReviewsByGymId(gymId: gymId, page: page),
        "fetchGymReviews",
      );

  Future<Response> submitGymReview({
    required Map<String, dynamic> data,
  }) async =>
      await apiClient.postData(
        AppConstants.gymReviews,
        "submitGymReview",
        data,
      );
}
