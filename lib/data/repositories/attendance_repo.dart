import 'package:get/get_connect/http/src/response/response.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class AttendanceRepo {
  final ApiClient apiClient;

  AttendanceRepo({required this.apiClient});

  Future<Response> punchIn(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.punchInUri, "punchIn", data);
  }

  Future<Response> punchOut(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.punchOutUri, "punchOut", data);
  }

  Future<Response> getTodayAttendance() async {
    return await apiClient.getData(AppConstants.todayAttendanceUri, "getTodayAttendance");
  }

  Future<Response> getAttendanceHistory(Map<String, dynamic> data) async {
    return await apiClient.getData(AppConstants.attendanceHistoryUri, "getAttendanceHistory", query: data);
  }

  Future<Response> getBookings() async {
    return await apiClient.getData("bookings", "getBookings");
  }

  // ── Gym Attendance & Invoices APIs ─────────────────────────────────
  /// 1. Fetch Today Gym Attendance Status (/api/v1/gym/attendance/status)
  Future<Response> fetchGymAttendanceStatus() async {
    return await apiClient.getData(
      AppConstants.gymAttendanceStatus,
      "fetchGymAttendanceStatus",
    );
  }

  /// 2. Punch In Gym Attendance (/api/v1/gym/attendance/punch-in)
  Future<Response> punchInGym(Map<String, dynamic> data) async {
    return await apiClient.postData(
      AppConstants.gymAttendancePunchIn,
      "punchInGym",
      data,
    );
  }

  /// 3. Punch Out Gym Attendance (/api/v1/gym/attendance/punch-out)
  Future<Response> punchOutGym(Map<String, dynamic> data) async {
    return await apiClient.postData(
      AppConstants.gymAttendancePunchOut,
      "punchOutGym",
      data,
    );
  }

  /// 4. Fetch Gym Attendance History (/api/v1/gym/attendance/history?mobile=...)
  Future<Response> fetchGymAttendanceHistory({
    required String mobile,
    int? page,
    String? month,
  }) async {
    String url = "${AppConstants.gymAttendanceHistory}?mobile=$mobile";
    if (page != null) url = "$url&page=$page";
    if (month != null && month.isNotEmpty) url = "$url&month=$month";
    return await apiClient.getData(url, "fetchGymAttendanceHistory");
  }

  /// 5. Fetch Gym Invoices & Billing (/api/v1/gym/invoices)
  Future<Response> fetchGymInvoices({int? page}) async {
    String url = AppConstants.gymInvoices;
    if (page != null) url = "$url?page=$page";
    return await apiClient.getData(url, "fetchGymInvoices");
  }

  /// 6. Fetch Single Gym Invoice Receipt Details (/api/v1/gym/invoices/{id})
  Future<Response> fetchGymInvoiceDetails(String invoiceId) async {
    return await apiClient.getData(
      AppConstants.gymInvoiceDetails(invoiceId),
      "fetchGymInvoiceDetails",
    );
  }

  /// 7. Fetch Gym Reviews & Ratings (/api/v1/gym/reviews?gym_id=...)
  Future<Response> fetchGymReviews({
    required String gymId,
    int? page,
  }) async {
    return await apiClient.getData(
      AppConstants.gymReviewsByGymId(gymId: gymId, page: page),
      "fetchGymReviews",
    );
  }

  /// 8. Submit Gym Review & Rating (/api/v1/gym/reviews)
  Future<Response> submitGymReview(Map<String, dynamic> data) async {
    return await apiClient.postData(
      AppConstants.gymReviews,
      "submitGymReview",
      data,
    );
  }
}
