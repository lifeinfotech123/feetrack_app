import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/data/models/category_model/staff_model.dart';
import 'package:vlr/data/models/gym_profile_banner_model.dart';
import 'package:vlr/data/models/gym_shift_model.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/data/repositories/gym_repo.dart';
import 'package:vlr/generated/assets.dart';

class GymController extends GetxController implements GetxService {
  final GymRepo gymRepo;

  GymController({required this.gymRepo});

  bool isLoading = false;

  bool _isResponseSuccess(Response response, dynamic body) {
    if (!response.isOk &&
        response.statusCode != 200 &&
        response.statusCode != 201) {
      return false;
    }
    if (body is Map) {
      final status = body['status'];
      if (status != null) {
        final s = status.toString().trim().toLowerCase();
        if (s == 'true' ||
            s == 'success' ||
            s == '1' ||
            s == '200' ||
            s == '201' ||
            s == 'pending' ||
            s == 'confirmed' ||
            s == 'booked' ||
            s == 'created') {
          return true;
        }
        if (s == 'false' || s == '0' || s == 'failed' || s == 'error') {
          return false;
        }
      }
      final success = body['success'];
      if (success != null) {
        final s = success.toString().trim().toLowerCase();
        if (s == 'true' || s == '1' || s == 'success') {
          return true;
        }
        if (s == 'false' || s == '0' || s == 'failed' || s == 'error') {
          return false;
        }
      }
      if (body['error'] != null && body['error'] != false) {
        return false;
      }
      if (body['errors'] != null) {
        return false;
      }
      return true;
    }
    return response.isOk;
  }

  List<BannerModel> gymProfileImageSliders = [
    BannerModel(
      image: Assets.imagesGymBanner,
    ),
    BannerModel(
      image: Assets.imagesGymBanner,
    ),
    BannerModel(
      image: Assets.imagesGymBanner,
    ),
  ];

  bool isGYMSubscription = false;

  List<StaffModel> gymTrainerModelList = [];
  StaffModel? selectGymTrainerModel;
  Map<String, dynamic>? selectedTrainerDetails;
  bool isTrainerDetailsLoading = false;
  bool isGymTrainersLoading = false;
  String? gymTrainersError;
  String? trainersGymId;

  Map<String, dynamic>? myGymBookingsData;
  List<dynamic> myGymBookingsList = [];
  List<dynamic> myGymMembershipsList = [];
  List<dynamic> myGymVisitsList = [];
  bool isMyGymBookingsLoading = false;
  bool isMyGymVisitsLoading = false;
  bool hasLoadedMyGymBookings = false;
  bool hasLoadedMyGymVisits = false;
  String? myGymBookingsError;

  Map<String, dynamic>? selectedVisitDetails;
  bool isVisitDetailsLoading = false;
  String? visitDetailsError;

  List<GymShiftModel> gymShiftsList = [];
  GymShiftModel? selectedGymShift;
  GymShiftModel? gymShiftDetails;
  bool isGymShiftsLoading = false;
  bool isGymShiftDetailsLoading = false;
  String? shiftsGymId;
  String? gymShiftsError;

  Future<ResponseModel> fetchGymTrainers({String? listingId}) async {
    log('-----------  fetchGymTrainers (listingId: $listingId) ----------');
    ResponseModel responseModel;
    isGymTrainersLoading = true;
    gymTrainersError = null;
    trainersGymId = listingId;
    final previousSelectedId = selectGymTrainerModel?.id;
    gymTrainerModelList = [];
    update();

    try {
      Response response = await gymRepo.fetchGymTrainers(id: listingId);
      final body = response.body;

      if (body != null &&
          (body['status'] == true || body['status'] == "success")) {
        var data = body['data'];
        List<StaffModel> allTrainers = [];
        if (data is List) {
          allTrainers = data
              .map((e) => StaffModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else if (data is Map && data['data'] is List) {
          allTrainers = (data['data'] as List)
              .map((e) => StaffModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          allTrainers = [];
        }

        // Filter trainers specifically for this gym
        if (listingId != null && listingId.trim().isNotEmpty) {
          final targetGymId = listingId.trim().toLowerCase();
          final filtered = allTrainers.where((t) {
            final tGymId = t.gymId?.trim().toLowerCase();
            return tGymId == targetGymId;
          }).toList();

          final anyHasGymId = allTrainers
              .any((t) => t.gymId != null && t.gymId!.trim().isNotEmpty);
          if (anyHasGymId) {
            gymTrainerModelList = filtered;
          } else {
            gymTrainerModelList = allTrainers;
          }
        } else {
          gymTrainerModelList = allTrainers;
        }

        // Preserve previously selected trainer if it belongs to this gym
        if (previousSelectedId != null) {
          selectGymTrainerModel = gymTrainerModelList.firstWhereOrNull(
            (t) => t.id == previousSelectedId,
          );
        } else {
          selectGymTrainerModel = null;
        }

        responseModel =
            ResponseModel(true, body['message'] ?? "success fetchGymTrainers");
      } else {
        gymTrainerModelList = [];
        selectGymTrainerModel = null;
        gymTrainersError =
            body?['message']?.toString() ?? "Failed to load gym trainers.";
        responseModel = ResponseModel(false, gymTrainersError!);
      }
    } catch (e) {
      gymTrainerModelList = [];
      selectGymTrainerModel = null;
      gymTrainersError = "Unable to load gym trainers. Please try again.";
      log('ERROR AT fetchGymTrainers(): $e');
      responseModel = ResponseModel(false, "Error while fetchGymTrainers $e");
    }

    isGymTrainersLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchTrainerDetails({required String trainerId}) async {
    log('----------- fetchTrainerDetails ($trainerId) ----------');
    isTrainerDetailsLoading = true;
    selectedTrainerDetails = null;
    update();

    ResponseModel responseModel;
    try {
      Response response = await gymRepo.fetchTrainerDetails(id: trainerId);
      final body = response.body;
      if (body != null &&
          (body['status'] == true || body['status'] == "success")) {
        selectedTrainerDetails = body['data'] is Map
            ? Map<String, dynamic>.from(body['data'])
            : null;
        responseModel = ResponseModel(
          true,
          body['message'] ?? "Trainer details retrieved successfully.",
          selectedTrainerDetails,
        );
      } else {
        selectedTrainerDetails = null;
        responseModel = ResponseModel(
          false,
          body?['message'] ?? "Failed to retrieve trainer details.",
        );
      }
    } catch (e) {
      log('ERROR AT fetchTrainerDetails(): $e');
      selectedTrainerDetails = null;
      responseModel = ResponseModel(false, "Error: $e");
    }

    isTrainerDetailsLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> bookGymVisit({
    required String listingId,
    required String visitDate,
    required String preferredTime,
    String? note,
    int? appUserId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerAddress,
  }) async {
    log('----------- bookGymVisit ----------');
    isLoading = true;
    update();

    ResponseModel responseModel;
    try {
      final Map<String, dynamic> data = {
        "listing_id": listingId,
        "visit_date": visitDate,
        "preferred_time": preferredTime,
        if (note != null && note.isNotEmpty) "note": note,
        if (appUserId != null) "app_user_id": appUserId,
        if (customerName != null && customerName.isNotEmpty)
          "customer_name": customerName,
        if (customerPhone != null && customerPhone.isNotEmpty)
          "customer_phone": customerPhone,
        if (customerEmail != null && customerEmail.isNotEmpty)
          "customer_email": customerEmail,
        if (customerAddress != null && customerAddress.isNotEmpty)
          "customer_address": customerAddress,
      };

      Response response = await gymRepo.bookGymVisit(data: data);

      dynamic body = response.body;
      if (body is String) {
        try {
          body = jsonDecode(body);
        } catch (_) {}
      }

      final isSuccess = _isResponseSuccess(response, body);
      final dynamic responseData = body is Map ? (body['data'] ?? body) : null;
      final String responseMessage = (body is Map &&
              body['message'] != null &&
              body['message'].toString().trim().isNotEmpty)
          ? body['message'].toString()
          : (isSuccess
              ? "Gym visit scheduled successfully!"
              : (response.statusText ?? "Failed to schedule gym visit"));

      if (isSuccess) {
        responseModel = ResponseModel(
          true,
          responseMessage,
          responseData,
        );
        fetchMyGymVisits();
      } else {
        responseModel = ResponseModel(
          false,
          responseMessage,
          responseData,
        );
      }
    } catch (e) {
      log('ERROR AT bookGymVisit(): $e');
      responseModel = ResponseModel(false, "Error: $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> bookGymMembership({
    required String packageId,
    required String listingId,
    required String visitDate,
    required String preferredTime,
    String? note,
    int? appUserId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String paymentMethod = "cash",
    String? paymentId,
    String? trainerId,
    String? shiftId,
  }) async {
    log('----------- bookGymMembership ----------');
    isLoading = true;
    update();

    ResponseModel responseModel;
    try {
      final Map<String, dynamic> data = {
        "package_id": packageId,
        "listing_id": listingId,
        "visit_date": visitDate,
        "preferred_time": preferredTime,
        "payment_method": paymentMethod,
        if (paymentId != null && paymentId.isNotEmpty) "payment_id": paymentId,
        if (trainerId != null && trainerId.isNotEmpty) "trainer_id": trainerId,
        if (shiftId != null && shiftId.isNotEmpty) "shift_id": shiftId,
        if (note != null && note.isNotEmpty) "note": note,
        if (appUserId != null) "app_user_id": appUserId,
        if (customerName != null && customerName.isNotEmpty)
          "customer_name": customerName,
        if (customerPhone != null && customerPhone.isNotEmpty)
          "customer_phone": customerPhone,
        if (customerEmail != null && customerEmail.isNotEmpty)
          "customer_email": customerEmail,
      };

      Response response = await gymRepo.bookGymMembership(data: data);
      final status = response.body?['status'];
      final isSuccess = status == true || status == "success";

      if (isSuccess) {
        responseModel = ResponseModel(
          true,
          response.body['message'] ?? "Membership booking placed successfully!",
          response.body['data'],
        );
      } else {
        responseModel = ResponseModel(
          false,
          response.body?['message'] ?? "Failed to book membership",
          response.body?['data'],
        );
      }
    } catch (e) {
      log('ERROR AT bookGymMembership(): $e');
      responseModel = ResponseModel(false, "Error: $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  void clearMyGymBookings() {
    myGymBookingsData = null;
    myGymBookingsList = [];
    myGymMembershipsList = [];
    isMyGymBookingsLoading = false;
    hasLoadedMyGymBookings = false;
    myGymBookingsError = null;
    update();
  }

  void clearMyGymVisits() {
    myGymVisitsList = [];
    isMyGymVisitsLoading = false;
    hasLoadedMyGymVisits = false;
    update();
  }

  Future<ResponseModel> fetchMyGymBookings() async {
    log('----------- fetchMyGymBookings (v1/gym/my-bookings) ----------');
    if (Get.isRegistered<AuthController>() &&
        !Get.find<AuthController>().isLoggedIn()) {
      clearMyGymBookings();
      return ResponseModel(false, "User not logged in");
    }

    isMyGymBookingsLoading = true;
    myGymBookingsError = null;
    update();

    ResponseModel responseModel;
    try {
      Response response = await gymRepo.fetchMyGymBookings();
      final body = response.body;
      if (body != null &&
          (body['status'] == true || body['status'] == "success")) {
        myGymBookingsData = body['data'] is Map
            ? Map<String, dynamic>.from(body['data'])
            : null;
        if (myGymBookingsData != null) {
          myGymBookingsList = myGymBookingsData!['bookings'] is List
              ? myGymBookingsData!['bookings']
              : [];
          myGymMembershipsList = myGymBookingsData!['memberships'] is List
              ? myGymBookingsData!['memberships']
              : [];
        } else {
          myGymBookingsList = [];
          myGymMembershipsList = [];
        }
        responseModel = ResponseModel(
          true,
          body['message'] ?? "Customer gym bookings retrieved successfully.",
          myGymBookingsData,
        );
      } else {
        clearMyGymBookings();
        myGymBookingsError =
            body?['message']?.toString() ?? "Failed to retrieve gym bookings.";
        responseModel = ResponseModel(
          false,
          myGymBookingsError!,
        );
      }
    } catch (e) {
      log('ERROR AT fetchMyGymBookings(): $e');
      clearMyGymBookings();
      myGymBookingsError = "Unable to load memberships. Please try again.";
      responseModel = ResponseModel(false, "Error: $e");
    }

    isMyGymBookingsLoading = false;
    hasLoadedMyGymBookings = true;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchMyGymVisits() async {
    log('----------- fetchMyGymVisits (v1/gym/my-visits) ----------');
    if (Get.isRegistered<AuthController>() &&
        !Get.find<AuthController>().isLoggedIn()) {
      myGymVisitsList = [];
      isMyGymVisitsLoading = false;
      hasLoadedMyGymVisits = false;
      update();
      return ResponseModel(false, "User not logged in");
    }

    isMyGymVisitsLoading = true;
    update();

    ResponseModel responseModel;
    try {
      final Response response = await gymRepo.fetchMyGymVisits();
      final body = response.body;
      final data = body is Map ? body['data'] : null;

      if (body is Map &&
          (body['status'] == true || body['status'] == "success")) {
        final List<dynamic> visits;
        if (data is List) {
          visits = data;
        } else if (data is Map && data['visits'] is List) {
          visits = data['visits'];
        } else if (data is Map && data['data'] is List) {
          visits = data['data'];
        } else {
          visits = [];
        }
        myGymVisitsList = visits
            .whereType<Map>()
            .map((visit) => Map<String, dynamic>.from(visit))
            .toList();
        responseModel = ResponseModel(
          true,
          body['message'] ?? "Gym visits retrieved successfully.",
          myGymVisitsList,
        );
      } else {
        myGymVisitsList = [];
        responseModel = ResponseModel(
          false,
          body is Map
              ? body['message'] ?? "Failed to retrieve gym visits."
              : "Failed to retrieve gym visits.",
        );
      }
    } catch (e) {
      log('ERROR AT fetchMyGymVisits(): $e');
      myGymVisitsList = [];
      responseModel = ResponseModel(false, "Error fetching gym visits: $e");
    }

    isMyGymVisitsLoading = false;
    hasLoadedMyGymVisits = true;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchMyGymVisitDetails(
      {required String visitId}) async {
    log('----------- fetchMyGymVisitDetails ($visitId) ----------');
    isVisitDetailsLoading = true;
    selectedVisitDetails = null;
    visitDetailsError = null;
    update();

    ResponseModel responseModel;
    try {
      final Response response =
          await gymRepo.fetchMyGymVisitDetails(id: visitId);
      final body = response.body;
      if (body != null &&
          (body['status'] == true || body['status'] == "success")) {
        selectedVisitDetails = body['data'] is Map
            ? Map<String, dynamic>.from(body['data'])
            : null;
        responseModel = ResponseModel(
          true,
          body['message'] ?? "Visit detail retrieved successfully.",
          selectedVisitDetails,
        );
      } else {
        selectedVisitDetails = null;
        visitDetailsError =
            body?['message'] ?? "Failed to retrieve visit details.";
        responseModel = ResponseModel(false, visitDetailsError!);
      }
    } catch (e) {
      log('ERROR AT fetchMyGymVisitDetails(): $e');
      selectedVisitDetails = null;
      visitDetailsError = "Error: $e";
      responseModel = ResponseModel(false, "Error: $e");
    }

    isVisitDetailsLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> verifyPaymentBooking({
    required String bookingId,
    required String invoiceId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    log('----------- verifyPaymentBooking ----------');
    isLoading = true;
    update();

    ResponseModel responseModel;
    try {
      final Map<String, dynamic> data = {
        "booking_id": bookingId,
        "invoice_id": invoiceId,
        "razorpay_order_id": razorpayOrderId,
        "razorpay_payment_id": razorpayPaymentId,
        "razorpay_signature": razorpaySignature,
      };

      Response response = await gymRepo.verifyPaymentBooking(data: data);
      final body = response.body;
      final status = body?['status'];
      final isSuccess = status == true || status == "success";

      responseModel = ResponseModel(
        isSuccess,
        body?['message'] ??
            (isSuccess
                ? "Payment verified successfully!"
                : "Payment verification failed."),
        body?['data'],
      );
    } catch (e) {
      log('ERROR AT verifyPaymentBooking(): $e');
      responseModel = ResponseModel(false, "Payment verification error: $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchGymShifts({String? gymId}) async {
    log('----------- fetchGymShifts (gymId: $gymId) ----------');
    isGymShiftsLoading = true;
    gymShiftsError = null;
    shiftsGymId = gymId;
    gymShiftsList = [];
    selectedGymShift = null;
    update();

    ResponseModel responseModel;
    try {
      final Response response = (gymId != null && gymId.isNotEmpty)
          ? await gymRepo.fetchGymShiftsByGymId(gymId: gymId)
          : await gymRepo.fetchGymShifts();

      final body = response.body;
      if (body != null &&
          (body['status'] == true || body['status'] == "success")) {
        final dynamic rawData = body['data'];
        List items = [];
        if (rawData is List) {
          items = rawData;
        } else if (rawData is Map && rawData['data'] is List) {
          items = rawData['data'];
        }

        gymShiftsList = items
            .map((e) => GymShiftModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        if (gymShiftsList.isNotEmpty) {
          if (selectedGymShift != null) {
            final match = gymShiftsList
                .firstWhereOrNull((s) => s.id == selectedGymShift!.id);
            if (match != null) {
              match.isSelected = true;
              selectedGymShift = match;
            } else {
              gymShiftsList.first.isSelected = true;
              selectedGymShift = gymShiftsList.first;
            }
          } else {
            gymShiftsList.first.isSelected = true;
            selectedGymShift = gymShiftsList.first;
          }
        } else {
          selectedGymShift = null;
        }

        responseModel = ResponseModel(
          true,
          body['message'] ?? "Gym shifts retrieved successfully.",
          gymShiftsList,
        );
      } else {
        gymShiftsList = [];
        selectedGymShift = null;
        gymShiftsError =
            body?['message']?.toString() ?? "Failed to load gym shifts.";
        responseModel = ResponseModel(
          false,
          gymShiftsError!,
        );
      }
    } catch (e) {
      log('ERROR AT fetchGymShifts(): $e');
      gymShiftsList = [];
      selectedGymShift = null;
      gymShiftsError = "Unable to load gym shifts. Please try again.";
      responseModel = ResponseModel(false, "Error: $e");
    }

    isGymShiftsLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchGymShiftDetails({required String shiftId}) async {
    log('----------- fetchGymShiftDetails ($shiftId) ----------');
    isGymShiftDetailsLoading = true;
    update();

    ResponseModel responseModel;
    try {
      final Response response = await gymRepo.fetchGymShiftDetails(id: shiftId);
      final body = response.body;
      if (body != null &&
          (body['status'] == true || body['status'] == "success")) {
        final data = body['data'];
        if (data is Map) {
          gymShiftDetails =
              GymShiftModel.fromJson(Map<String, dynamic>.from(data));
        } else {
          gymShiftDetails = null;
        }
        responseModel = ResponseModel(
          true,
          body['message'] ?? "Gym shift details retrieved successfully.",
          gymShiftDetails,
        );
      } else {
        gymShiftDetails = null;
        responseModel = ResponseModel(
          false,
          body?['message'] ?? "Failed to retrieve gym shift details.",
        );
      }
    } catch (e) {
      log('ERROR AT fetchGymShiftDetails(): $e');
      gymShiftDetails = null;
      responseModel = ResponseModel(false, "Error: $e");
    }

    isGymShiftDetailsLoading = false;
    update();
    return responseModel;
  }

  void selectGymShift(GymShiftModel shift) {
    for (var s in gymShiftsList) {
      s.isSelected = (s.id == shift.id);
    }
    selectedGymShift = shift;
    update();
  }
}
