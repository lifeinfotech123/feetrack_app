import 'dart:developer';

import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
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

  Map<String, dynamic>? myGymBookingsData;
  List<dynamic> myGymBookingsList = [];
  List<dynamic> myGymMembershipsList = [];
  List<dynamic> myGymVisitsList = [];
  bool isMyGymBookingsLoading = false;

  List<GymShiftModel> gymShiftsList = [];
  GymShiftModel? selectedGymShift;
  GymShiftModel? gymShiftDetails;
  bool isGymShiftsLoading = false;
  bool isGymShiftDetailsLoading = false;

  Future<ResponseModel> fetchGymTrainers({String? listingId}) async {
    log('-----------  fetchGymTrainers ----------');
    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Response response = await gymRepo.fetchGymTrainers(id: listingId);
      final body = response.body;

      if (body != null && (body['status'] == true || body['status'] == "success")) {
        var data = body['data'];
        if (data is List) {
          gymTrainerModelList = data
              .map((e) => StaffModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else if (data is Map && data['data'] is List) {
          gymTrainerModelList = (data['data'] as List)
              .map((e) => StaffModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          gymTrainerModelList = [];
        }

        responseModel = ResponseModel(
            true, body['message'] ?? "success fetchGymTrainers");
      } else {
        gymTrainerModelList = [];
        responseModel = ResponseModel(false,
            body?['message'] ?? "Error while fetchGymTrainers");
      }
    } catch (e) {
      gymTrainerModelList = [];
      log('ERROR AT fetchGymTrainers(): $e');
      responseModel = ResponseModel(false, "Error while fetchGymTrainers $e");
    }

    // Fallback: If empty, populate from selectListingModel.trainers if available
    if (gymTrainerModelList.isEmpty) {
      try {
        final homeCtrl = Get.find<HomeController>();
        final rawTrainers = homeCtrl.selectListingModel?.trainers;
        if (rawTrainers != null && rawTrainers.isNotEmpty) {
          gymTrainerModelList = rawTrainers
              .map((e) => StaffModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      } catch (_) {}
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchTrainerDetails({required String trainerId}) async {
    log('----------- fetchTrainerDetails ($trainerId) ----------');
    isTrainerDetailsLoading = true;
    update();

    ResponseModel responseModel;
    try {
      Response response = await gymRepo.fetchTrainerDetails(id: trainerId);
      final body = response.body;
      if (body != null && (body['status'] == true || body['status'] == "success")) {
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
      };

      Response response = await gymRepo.bookGymVisit(data: data);
      final status = response.body?['status'];
      final isSuccess = status == true || status == "success";

      if (isSuccess) {
        responseModel = ResponseModel(
          true,
          response.body['message'] ?? "Gym visit scheduled successfully!",
          response.body['data'],
        );
      } else {
        responseModel = ResponseModel(
          false,
          response.body?['message'] ?? "Failed to schedule gym visit",
          response.body?['data'],
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
          response.body['message'] ??
              "Membership booking placed successfully!",
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
    myGymVisitsList = [];
    isMyGymBookingsLoading = false;
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
          myGymVisitsList = myGymBookingsData!['visits'] is List
              ? myGymBookingsData!['visits']
              : [];
        } else {
          myGymBookingsList = [];
          myGymMembershipsList = [];
          myGymVisitsList = [];
        }
        responseModel = ResponseModel(
          true,
          body['message'] ?? "Customer gym bookings retrieved successfully.",
          myGymBookingsData,
        );
      } else {
        clearMyGymBookings();
        responseModel = ResponseModel(
          false,
          body?['message'] ?? "Failed to retrieve gym bookings.",
        );
      }
    } catch (e) {
      log('ERROR AT fetchMyGymBookings(): $e');
      clearMyGymBookings();
      responseModel = ResponseModel(false, "Error: $e");
    }

    isMyGymBookingsLoading = false;
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
        responseModel = ResponseModel(
          false,
          body?['message'] ?? "Failed to retrieve gym shifts.",
        );
      }
    } catch (e) {
      log('ERROR AT fetchGymShifts(): $e');
      gymShiftsList = [];
      selectedGymShift = null;
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
      final Response response =
          await gymRepo.fetchGymShiftDetails(id: shiftId);
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
