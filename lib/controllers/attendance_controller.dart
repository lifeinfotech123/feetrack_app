import 'dart:developer';
import 'package:get/get.dart';
import 'package:vlr/data/models/attendance_model.dart';
import 'package:vlr/data/models/booking_model.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/data/repositories/attendance_repo.dart';

class AttendanceController extends GetxController implements GetxService {
  final AttendanceRepo attendanceRepo;
  AttendanceController({required this.attendanceRepo});

  bool isLoading = false;
  List<BookingModel> bookingList = [];
  List<AttendanceModel> todayAttendanceList = [];
  List<AttendanceModel> attendanceHistoryList = [];

  Future<void> getBookings() async {
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
      if (response.body['status'] == "success") {
        getTodayAttendance();
        return ResponseModel(true, response.body['message'] ?? "Punched in successfully");
      } else {
        return ResponseModel(false, response.body['message'] ?? "Error punching in");
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
      if (response.body['status'] == "success") {
        getTodayAttendance();
        return ResponseModel(true, response.body['message'] ?? "Punched out successfully");
      } else {
        return ResponseModel(false, response.body['message'] ?? "Error punching out");
      }
    } catch (e) {
      return ResponseModel(false, "Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getTodayAttendance() async {
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
        
        todayAttendanceList = items.map((e) => AttendanceModel.fromJson(e)).toList();
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
        
        attendanceHistoryList = items.map((e) => AttendanceModel.fromJson(e)).toList();
      }
    } catch (e) {
      log("Error fetching attendance history: $e");
    }
    isLoading = false;
    update();
  }
}
