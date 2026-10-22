import 'dart:developer';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/data/models/attendance_model.dart';
import 'package:vlr/data/models/booking_model.dart';
import 'package:vlr/data/models/gym_attendance_model.dart';
import 'package:vlr/data/models/gym_invoice_model.dart';
import 'package:vlr/data/models/gym_review_model.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/data/repositories/attendance_repo.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/file_download_helper.dart';

class AttendanceController extends GetxController implements GetxService {
  final AttendanceRepo attendanceRepo;
  AttendanceController({required this.attendanceRepo});

  bool isLoading = false;
  List<BookingModel> bookingList = [];
  List<AttendanceModel> todayAttendanceList = [];
  List<AttendanceModel> attendanceHistoryList = [];

  // ══════════════════════════════════════════════════════════════════
  // GYM ATTENDANCE & INVOICES STATE
  // ══════════════════════════════════════════════════════════════════
  GymAttendanceStatusData? attendanceStatusData;
  bool isStatusLoading = false;
  bool isPunching = false;

  GymAttendanceHistorySummary? historySummary;
  List<GymAttendanceLogItem> gymLogs = [];
  GymAttendancePagination? historyPagination;
  bool isHistoryLoading = false;

  GymInvoicesData? invoicesData;
  List<GymInvoiceItem> invoicesList = [];
  GymInvoicesSummary? invoicesSummary;
  GymAttendancePagination? invoicesPagination;
  bool isInvoicesLoading = false;
  bool isInvoiceDownloading = false;
  String? downloadingInvoiceId;

  GymInvoiceItem? selectedInvoiceDetail;
  bool isInvoiceDetailLoading = false;

  GymReviewsData? gymReviewsData;
  GymReviewSummary? gymReviewSummary;
  List<GymReviewItem> gymReviewsList = [];
  bool isGymReviewsLoading = false;
  bool isSubmittingReview = false;

  String? currentCustomerPhone;
  String? currentGymId;

  /// Dynamic phone resolver (from status response, auth profile, or controllers)
  String? get resolvedCustomerMobile {
    if (currentCustomerPhone != null && currentCustomerPhone!.trim().isNotEmpty) {
      return currentCustomerPhone!.trim();
    }
    if (attendanceStatusData?.customer?.phone != null &&
        attendanceStatusData!.customer!.phone!.trim().isNotEmpty) {
      return attendanceStatusData!.customer!.phone!.trim();
    }
    try {
      final authCtrl = Get.find<AuthController>();
      if (authCtrl.userModel?.mobile != null &&
          authCtrl.userModel!.mobile!.trim().isNotEmpty) {
        return authCtrl.userModel!.mobile!.trim();
      }
      if (authCtrl.mobileNoController.text.trim().isNotEmpty) {
        return authCtrl.mobileNoController.text.trim();
      }
    } catch (_) {}
    return null;
  }

  /// Dynamic Gym ID resolver
  String? get resolvedGymId {
    if (currentGymId != null && currentGymId!.trim().isNotEmpty) {
      return currentGymId!.trim();
    }
    if (attendanceStatusData?.gym?.id != null &&
        attendanceStatusData!.gym!.id!.trim().isNotEmpty) {
      return attendanceStatusData!.gym!.id!.trim();
    }
    if (bookingList.isNotEmpty) {
      final firstGymId = bookingList.first.listing?.id;
      if (firstGymId != null && firstGymId.trim().isNotEmpty) {
        return firstGymId.trim();
      }
    }
    return null;
  }

  bool isUserLoggedIn() {
    return Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().isLoggedIn();
  }

  void clearGymAttendanceData() {
    bookingList = [];
    todayAttendanceList = [];
    attendanceHistoryList = [];
    attendanceStatusData = null;
    historySummary = null;
    gymLogs = [];
    historyPagination = null;
    invoicesData = null;
    invoicesList = [];
    invoicesSummary = null;
    invoicesPagination = null;
    isStatusLoading = false;
    isHistoryLoading = false;
    isInvoicesLoading = false;
    isLoading = false;
    update();
  }

  // ──────────────────────────────────────────────────────────────────
  // 1. Fetch Today Gym Attendance Status (/api/v1/gym/attendance/status)
  // ──────────────────────────────────────────────────────────────────
  Future<void> fetchGymAttendanceStatus() async {
    if (!isUserLoggedIn()) {
      attendanceStatusData = null;
      isStatusLoading = false;
      update();
      return;
    }

    isStatusLoading = true;
    update();

    try {
      final Response response =
          await attendanceRepo.fetchGymAttendanceStatus();
      log("fetchGymAttendanceStatus status: ${response.statusCode}");

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['status'] == true || body['status'] == 'true') {
          final data = body['data'];
          if (data is Map) {
            attendanceStatusData = GymAttendanceStatusData.fromJson(
              Map<String, dynamic>.from(data),
            );
            if (attendanceStatusData?.customer?.phone != null &&
                attendanceStatusData!.customer!.phone!.isNotEmpty) {
              currentCustomerPhone = attendanceStatusData!.customer!.phone;
            }
            if (attendanceStatusData?.gym?.id != null &&
                attendanceStatusData!.gym!.id!.isNotEmpty) {
              currentGymId = attendanceStatusData!.gym!.id;
            }
          }
        }
      }
    } catch (e) {
      log("ERROR in fetchGymAttendanceStatus: $e");
    } finally {
      isStatusLoading = false;
      update();
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // 2. Punch In Gym Attendance (/api/v1/gym/attendance/punch-in)
  // ──────────────────────────────────────────────────────────────────
  Future<ResponseModel> punchInGym({
    String? gymId,
    String? mobile,
    String? note,
    String? location,
    bool reset = true,
  }) async {
    if (isPunching) {
      return ResponseModel(false, "Punch in request already in progress...");
    }

    isPunching = true;
    update();

    try {
      final finalGymId = gymId ?? resolvedGymId ?? "";
      final finalMobile = mobile ?? resolvedCustomerMobile ?? "";

      final Map<String, dynamic> body = {
        if (finalGymId.isNotEmpty) "gym_id": finalGymId,
        "mobile": finalMobile,
        "note": note ?? "Workout session",
        "reset": reset,
        "location": location ?? "gym",
      };

      log("Punching In Gym: $body");
      final Response response = await attendanceRepo.punchInGym(body);
      log("punchInGym response: ${response.statusCode}, body: ${response.body}");

      if (response.statusCode == 200 && response.body != null) {
        final resBody = response.body;
        final isSuccess = resBody['status'] == true ||
            resBody['status'] == 'true' ||
            resBody['data']?['success'] == true;
        final message = resBody['message']?.toString() ??
            resBody['data']?['message']?.toString() ??
            "Workout session started successfully!";

        // Refresh Attendance Status API after punch in
        await fetchGymAttendanceStatus();

        return ResponseModel(isSuccess, message);
      } else {
        final message = response.body?['message']?.toString() ??
            response.body?['data']?['message']?.toString() ??
            "Failed to Punch In. Please try again.";
        return ResponseModel(false, message);
      }
    } catch (e) {
      log("ERROR in punchInGym: $e");
      return ResponseModel(false, "Punch In error: $e");
    } finally {
      isPunching = false;
      update();
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // 3. Punch Out Gym Attendance (/api/v1/gym/attendance/punch-out)
  // ──────────────────────────────────────────────────────────────────
  Future<ResponseModel> punchOutGym({
    String? mobile,
  }) async {
    if (isPunching) {
      return ResponseModel(false, "Punch out request already in progress...");
    }

    isPunching = true;
    update();

    try {
      final finalMobile = mobile ?? resolvedCustomerMobile ?? "";

      final Map<String, dynamic> body = {
        "mobile": finalMobile,
      };

      log("Punching Out Gym: $body");
      final Response response = await attendanceRepo.punchOutGym(body);
      log("punchOutGym response: ${response.statusCode}, body: ${response.body}");

      if (response.statusCode == 200 && response.body != null) {
        final resBody = response.body;
        final isSuccess = resBody['status'] == true ||
            resBody['status'] == 'true' ||
            resBody['data']?['success'] == true;
        final message = resBody['message']?.toString() ??
            resBody['data']?['message']?.toString() ??
            "Workout completed successfully!";

        // Refresh Attendance Status API after punch out
        await fetchGymAttendanceStatus();

        return ResponseModel(isSuccess, message);
      } else {
        final message = response.body?['message']?.toString() ??
            response.body?['data']?['message']?.toString() ??
            "Failed to Punch Out. Please try again.";
        return ResponseModel(false, message);
      }
    } catch (e) {
      log("ERROR in punchOutGym: $e");
      return ResponseModel(false, "Punch Out error: $e");
    } finally {
      isPunching = false;
      update();
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // 4. Fetch Gym Attendance History (/api/v1/gym/attendance/history)
  // ──────────────────────────────────────────────────────────────────
  Future<void> fetchGymAttendanceHistory({
    String? mobile,
    String? month,
    int? page,
  }) async {
    if (!isUserLoggedIn()) {
      historySummary = null;
      gymLogs = [];
      historyPagination = null;
      isHistoryLoading = false;
      update();
      return;
    }

    isHistoryLoading = true;
    update();

    try {
      final finalMobile = mobile ?? resolvedCustomerMobile ?? "";
      final Response response = await attendanceRepo.fetchGymAttendanceHistory(
        mobile: finalMobile,
        month: month,
        page: page,
      );
      log("fetchGymAttendanceHistory status: ${response.statusCode}");

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['status'] == true || body['status'] == 'true') {
          final data = body['data'];
          if (data is Map) {
            final parsed = GymAttendanceHistoryData.fromJson(
              Map<String, dynamic>.from(data),
            );
            historySummary = parsed.summary;
            gymLogs = parsed.logs;
            historyPagination = parsed.pagination;
          }
        }
      }
    } catch (e) {
      log("ERROR in fetchGymAttendanceHistory: $e");
    } finally {
      isHistoryLoading = false;
      update();
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // 5. Fetch Gym Invoices (/api/v1/gym/invoices)
  // ──────────────────────────────────────────────────────────────────
  Future<void> fetchGymInvoices({int? page}) async {
    if (!isUserLoggedIn()) {
      invoicesData = null;
      invoicesList = [];
      invoicesSummary = null;
      invoicesPagination = null;
      isInvoicesLoading = false;
      update();
      return;
    }

    isInvoicesLoading = true;
    update();

    try {
      final Response response =
          await attendanceRepo.fetchGymInvoices(page: page);
      log("fetchGymInvoices status: ${response.statusCode}");

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['status'] == true || body['status'] == 'true') {
          final data = body['data'];
          if (data is Map) {
            invoicesData = GymInvoicesData.fromJson(
              Map<String, dynamic>.from(data),
            );
            invoicesList = invoicesData?.invoices ?? [];
            invoicesSummary = invoicesData?.summary;
            invoicesPagination = invoicesData?.pagination;
          }
        }
      }
    } catch (e) {
      log("ERROR in fetchGymInvoices: $e");
    } finally {
      isInvoicesLoading = false;
      update();
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // 6. Fetch Single Gym Invoice Detail (/api/v1/gym/invoices/{id})
  // ──────────────────────────────────────────────────────────────────
  Future<ResponseModel> fetchGymInvoiceDetails(String invoiceId) async {
    if (!isUserLoggedIn()) {
      selectedInvoiceDetail = null;
      isInvoiceDetailLoading = false;
      update();
      return ResponseModel(false, "User not logged in");
    }

    isInvoiceDetailLoading = true;
    update();

    try {
      final Response response =
          await attendanceRepo.fetchGymInvoiceDetails(invoiceId);
      log("fetchGymInvoiceDetails status: ${response.statusCode}");

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['status'] == true || body['status'] == 'true') {
          final data = body['data'];
          if (data is Map) {
            selectedInvoiceDetail = GymInvoiceItem.fromJson(
              Map<String, dynamic>.from(data),
            );
            return ResponseModel(
              true,
              body['message'] ?? "Invoice details retrieved.",
              selectedInvoiceDetail,
            );
          }
        }
      }
      return ResponseModel(
        false,
        response.body?['message'] ?? "Failed to fetch invoice details.",
      );
    } catch (e) {
      log("ERROR in fetchGymInvoiceDetails: $e");
      return ResponseModel(false, "Error: $e");
    } finally {
      isInvoiceDetailLoading = false;
      update();
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // 7. Fetch Gym Reviews (/api/v1/gym/reviews?gym_id=...)
  // ──────────────────────────────────────────────────────────────────
  Future<void> fetchGymReviews({String? gymId, int? page}) async {
    isGymReviewsLoading = true;
    update();

    try {
      final targetGymId = gymId ?? resolvedGymId ?? "";
      if (targetGymId.isEmpty) {
        isGymReviewsLoading = false;
        update();
        return;
      }

      final Response response = await attendanceRepo.fetchGymReviews(
        gymId: targetGymId,
        page: page,
      );
      log("fetchGymReviews status: ${response.statusCode}");

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['status'] == true || body['status'] == 'true') {
          final data = body['data'];
          if (data is Map) {
            gymReviewsData = GymReviewsData.fromJson(
              Map<String, dynamic>.from(data),
            );
            gymReviewSummary = gymReviewsData?.summary;
            gymReviewsList = gymReviewsData?.reviews ?? [];
          }
        }
      }
    } catch (e) {
      log("ERROR in fetchGymReviews: $e");
    } finally {
      isGymReviewsLoading = false;
      update();
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // 8. Submit Gym Review & Rating (/api/v1/gym/reviews)
  // ──────────────────────────────────────────────────────────────────
  Future<ResponseModel> submitGymReview({
    required double rating,
    required String comment,
    String? gymId,
    String? mobile,
  }) async {
    if (isSubmittingReview) {
      return ResponseModel(false, "Submitting review in progress...");
    }

    isSubmittingReview = true;
    update();

    try {
      final targetGymId = gymId ?? resolvedGymId ?? "";
      final targetMobile = mobile ?? resolvedCustomerMobile ?? "";

      final Map<String, dynamic> body = {
        "gym_id": targetGymId,
        "rating": rating.toInt(),
        "comment": comment,
        "mobile": targetMobile,
      };

      log("Submitting Gym Review: $body");
      final Response response = await attendanceRepo.submitGymReview(body);
      log("submitGymReview status: ${response.statusCode}, body: ${response.body}");

      if (response.statusCode == 200 && response.body != null) {
        final resBody = response.body;
        final isSuccess = resBody['status'] == true ||
            resBody['status'] == 'true' ||
            resBody['data']?['success'] == true;
        final message = resBody['message']?.toString() ??
            resBody['data']?['message']?.toString() ??
            "Your gym rating & review has been updated successfully!";

        // Refresh reviews after submitting
        if (targetGymId.isNotEmpty) {
          await fetchGymReviews(gymId: targetGymId);
        }

        return ResponseModel(isSuccess, message);
      } else {
        final message = response.body?['message']?.toString() ??
            response.body?['data']?['message']?.toString() ??
            "Failed to submit review. Please try again.";
        return ResponseModel(false, message);
      }
    } catch (e) {
      log("ERROR in submitGymReview: $e");
      return ResponseModel(false, "Review error: $e");
    } finally {
      isSubmittingReview = false;
      update();
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // 9. Download / View Gym Invoice Receipt PDF
  // ──────────────────────────────────────────────────────────────────
  Future<void> downloadOrOpenInvoicePdf(GymInvoiceItem invoice) async {
    final invId = invoice.id ?? invoice.invoiceNumber ?? "invoice";
    final rawUrl = invoice.downloadUrl ?? invoice.receiptUrl;

    if (rawUrl == null || rawUrl.isEmpty) {
      showToast(message: "Invoice receipt link unavailable", toastType: ToastType.error);
      return;
    }

    // Resolve URL if relative or local
    String finalUrl = rawUrl;
    if (finalUrl.startsWith('/')) {
      final baseUrlClean = AppConstants.baseUrl.endsWith('/')
          ? AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1)
          : AppConstants.baseUrl;
      finalUrl = "$baseUrlClean$finalUrl";
    }

    isInvoiceDownloading = true;
    downloadingInvoiceId = invoice.id;
    update();

    try {
      final Map<String, String> headers = {
        'Authorization': 'Bearer ${attendanceRepo.apiClient.token}',
        'Accept': 'application/pdf',
      };

      await FileDownloadHelper.downloadAndShareFile(
        finalUrl,
        "Gym_Invoice_${invoice.invoiceNumber ?? invId}.pdf",
        headers,
      );
    } catch (e) {
      log("Error downloading invoice: $e");
      try {
        final uri = Uri.parse(finalUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}
    } finally {
      isInvoiceDownloading = false;
      downloadingInvoiceId = null;
      update();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // EXISTING BOOKINGS & LEGACY METHODS (PRESERVED)
  // ══════════════════════════════════════════════════════════════════
  Future<void> getBookings() async {
    if (!isUserLoggedIn()) {
      bookingList = [];
      isLoading = false;
      update();
      return;
    }

    isLoading = true;
    update();
    try {
      Response response = await attendanceRepo.getBookings();
      if (response.body != null && response.body['status'] == "success") {
        var data = response.body['data'];
        List items = [];
        if (data is List) {
          items = data;
        } else if (data is Map && data['data'] is List) {
          items = data['data'];
        }

        bookingList = items
            .map((e) => BookingModel.fromJson(e))
            .where((booking) => booking.status?.toLowerCase() == 'completed')
            .toList();
      }
    } catch (e) {
      log("Error fetching bookings: $e");
    }
    isLoading = false;
    update();
  }

  Future<ResponseModel> punchIn(String listingId, double lat, double lng) async {
    isLoading = true;
    update();
    try {
      Response response = await attendanceRepo.punchIn({
        "listing_id": listingId,
        "lat": lat,
        "lng": lng,
      });
      if (response.body != null && response.body['status'] == "success") {
        getTodayAttendance();
        return ResponseModel(
            true, response.body['message'] ?? "Punched in successfully");
      } else {
        return ResponseModel(
            false, response.body?['message'] ?? "Error punching in");
      }
    } catch (e) {
      return ResponseModel(false, "Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<ResponseModel> punchOut(String listingId, double lat, double lng) async {
    isLoading = true;
    update();
    try {
      Response response = await attendanceRepo.punchOut({
        "listing_id": listingId,
        "lat": lat,
        "lng": lng,
      });
      if (response.body != null && response.body['status'] == "success") {
        getTodayAttendance();
        return ResponseModel(
            true, response.body['message'] ?? "Punched out successfully");
      } else {
        return ResponseModel(
            false, response.body?['message'] ?? "Error punching out");
      }
    } catch (e) {
      return ResponseModel(false, "Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getTodayAttendance() async {
    if (!isUserLoggedIn()) {
      todayAttendanceList = [];
      isLoading = false;
      update();
      return;
    }

    isLoading = true;
    update();
    try {
      Response response = await attendanceRepo.getTodayAttendance();
      if (response.body != null && response.body['status'] == "success") {
        var data = response.body['data'];
        List items = [];
        if (data is List) {
          items = data;
        } else if (data is Map && data['data'] is List) {
          items = data['data'];
        }

        todayAttendanceList =
            items.map((e) => AttendanceModel.fromJson(e)).toList();
      }
    } catch (e) {
      log("Error fetching today's attendance: $e");
    }
    isLoading = false;
    update();
  }

  Future<void> getAttendanceHistory({
    String? listingId,
    String? from,
    String? to,
  }) async {
    if (!isUserLoggedIn()) {
      attendanceHistoryList = [];
      isLoading = false;
      update();
      return;
    }

    isLoading = true;
    update();
    try {
      Map<String, dynamic> data = {
        "listing_id": listingId ?? "",
        if (from != null && from.isNotEmpty) "from": from,
        if (to != null && to.isNotEmpty) "to": to,
      };
      Response response = await attendanceRepo.getAttendanceHistory(data);
      if (response.body != null && response.body['status'] == "success") {
        var rawData = response.body['data'];
        List items = [];

        if (rawData is List) {
          items = rawData;
        } else if (rawData is Map && rawData['data'] is List) {
          items = rawData['data'];
        }

        attendanceHistoryList =
            items.map((e) => AttendanceModel.fromJson(e)).toList();
      }
    } catch (e) {
      log("Error fetching attendance history: $e");
    }
    isLoading = false;
    update();
  }
}
