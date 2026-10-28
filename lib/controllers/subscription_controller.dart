import 'dart:developer';

import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/billing_preview_model.dart';
import 'package:vlr/data/models/booking_model.dart';
import 'package:vlr/data/models/category_model/batch_model.dart';
import 'package:vlr/data/models/category_model/package_model.dart';
import 'package:vlr/data/models/category_model/plan_during_model.dart';
import 'package:vlr/data/models/category_model/plan_model.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/data/repositories/subscription_repo.dart';

import 'package:vlr/data/models/category_model/room_detail_model.dart';

import 'package:vlr/data/models/subscription_model.dart';

import 'package:vlr/services/file_download_helper.dart';

import '../services/constants.dart';

class SubscriptionController extends GetxController implements GetxService {
  final SubscriptionRepo subscriptionRepo;

  SubscriptionController({required this.subscriptionRepo});

  bool isLoading = false;

  PackageModel? selectPackageModel;

  void updateSelectPackageModel({required PackageModel? value}) {
    selectPackageModel = value;
    update();
  }

  Future<ResponseModel> createSubscription({
    required String listingId,
    required String planId,
    String? durationId,
    String? couponCode,
    required String paymentMode,
    dynamic staffId,
    dynamic batchId,
    String? roomId,
    int? bedsBooked,
    String? paymentId,
  }) async {
    log('-----------  createSubscription ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      final Map<String, dynamic> data = {
        "listing_id": listingId,
        "package_id": planId,
        "payment_method": paymentMode,
        "use_wallet": useWallet ? 1 : 0,
      };

      if (durationId != null && durationId.isNotEmpty) {
        data["duration_id"] = durationId;
      }
      if (couponCode != null && couponCode.isNotEmpty) {
        data["coupon_code"] = couponCode;
      }

      // GYM Scenario (Shifts/Trainers)
      if (batchId != null) {
        data["shift_id"] = batchId.toString();
      }
      if (staffId != null) {
        data["trainer_ids[0]"] = staffId.toString();
      }

      // Room Scenario
      if (roomId != null) {
        data["room_id"] = roomId;
      }
      if (bedsBooked != null) {
        data["beds_booked"] = bedsBooked.toString();
      }
      if (paymentId != null && paymentId.isNotEmpty) {
        data["payment_id"] = paymentId;
      }

      print('--- createSubscription API Body ---');
      print('URL: ${AppConstants.baseUrl}${AppConstants.postCreateBooking}');
      print('Body: $data');
      print('-----------------------------------');

      Response response =
          await subscriptionRepo.createSubscription(data: FormData(data));

      final status =
          response.body is Map ? response.body['status']?.toString() : null;
      if (status == "true" || status == "success") {
        responseModel = ResponseModel(
            true,
            response.body['message'] ?? "Booking Created Successfully",
            response.body['data']);
      } else {
        responseModel = ResponseModel(
            false,
            response.body['message'] ?? "Error while creating booking",
            response.body['data']);
      }
    } catch (e) {
      log('ERROR AT createSubscription(): $e');
      responseModel = ResponseModel(false, "Error while creating booking $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchSubscription() async {
    log('-----------  fetchSubscription ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Response response = await subscriptionRepo.fetchSubscription();

      if (response.body['status'] == "success") {
        responseModel = ResponseModel(
            true, response.body['message'] ?? "success fetchSubscription  ");
      } else {
        responseModel = ResponseModel(false,
            response.body['message'] ?? "Error while fetchSubscription  ");
      }
    } catch (e) {
      log('ERROR AT fetchSubscription(): $e');
      responseModel =
          ResponseModel(false, "Error while fetchSubscription   $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  List<PlanDurationModel> planDurationList = [];
  Future<ResponseModel> fetchDuringListingById({required String? id}) async {
    log('-----------  fetchDuringListingById {required String? $id}  ----------');

    ResponseModel responseModel;
    isLoading = true;
    planDurationList = [];
    selectedDuration = null;
    planModelList = [];
    allPlanList = [];
    batchModelList = [];
    roomDetailList = [];
    selectedPlan = null;
    selectedBatch = null;
    selectedRoomDetail = null;
    update();

    try {
      Response response =
          await subscriptionRepo.fetchDuringListingById(id: id ?? "");

      print('API URL (fetchDuringListingById): ${response.request?.url}');
      print('API Response (fetchDuringListingById): ${response.body}');

      if (response.body['status'] == "success") {
        planDurationList = (response.body['data'] as List)
            .map((e) => PlanDurationModel.fromJson(e))
            .toList();
        planDurationList.insert(
          0,
          PlanDurationModel(
            label: "All",
            type: "all",
            durationDays: 0,
            isSelected: false,
          ),
        );

        // Try to find "Monthly" duration and select it, otherwise select the first one
        int monthlyIndex =
            planDurationList.indexWhere((element) => element.type == 'monthly');
        if (monthlyIndex != -1) {
          planDurationList[monthlyIndex].isSelected = true;
          selectedDuration = planDurationList[monthlyIndex];
        } else {
          planDurationList.first.isSelected = true;
          selectedDuration = planDurationList.first;
        }

        responseModel = ResponseModel(true,
            response.body['message'] ?? "success fetchDuringListingById  ");
      } else {
        responseModel = ResponseModel(false,
            response.body['message'] ?? "Error while fetchDuringListingById  ");
      }
    } catch (e) {
      log('ERROR AT fetchDuringListingById(): $e');
      responseModel =
          ResponseModel(false, "Error while fetchDuringListingById   $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  PlanDurationModel? selectedDuration;
  void selectDuration(int index, String listingId) {
    for (final item in planDurationList) {
      item.isSelected = false;
    }

    planDurationList[index].isSelected = true;
    selectedDuration = planDurationList[index];

    final selectedType = selectedDuration?.type;

    final roomController = Get.find<RoomController>();
    final roomId = roomController.selectedRoomDetails?.id;
    final floorId = roomController.selectedRoomDetails?.floorId;

    fetchPlanListingById(
      id: listingId,
      roomId: roomId,
      floorId: floorId,
      paymentMethod: "online", // Default
    );

    update();
  }

  List<PlanModel> allPlanList = [];
  List<PlanModel> planModelList = [];
  List<BatchModel> batchModelList = [];
  List<RoomDetailModel> roomDetailList = [];
  RoomDetailModel? selectedRoomDetail;
  String? selectedRoomId;
  int selectedBedsCount = 1;
  bool useWallet = false;

  void updateUseWallet(bool value) {
    useWallet = value;
    update();
  }

  void updateSelectBedsCount(int value) {
    selectedBedsCount = value;
    update();
  }

  void updateSelectRoomDetail({required RoomDetailModel? value}) {
    selectedRoomDetail = value;
    selectedRoomId = value?.id;
    update();
  }

  void setSelectedRoomId(String? id) {
    selectedRoomId = id;
    if (id != null && selectedRoomDetail?.id != id) {
      selectedRoomDetail = roomDetailList.firstWhereOrNull((e) => e.id == id);
    }
    update();
  }

  bool hasShifts = false;
  bool hasRooms = false;

  Future<ResponseModel> fetchPlanListingById({
    required String? id,
    String? packageId,
    String? roomId,
    String? floorId,
    String? shiftId,
    List<String>? trainerIds,
    String? paymentMethod,
    int? bedsBooked,
    String? couponCode,
  }) async {
    log('----------- fetchPlanListingById ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      final Map<String, dynamic> query = {};

      // If no packageId provided, check if we have a selected duration type
      if (packageId != null) {
        query['package_id'] = packageId;
      } else if (selectedDuration != null && selectedDuration!.type != "all") {
        query['type'] = selectedDuration!.type;
      }

      if (roomId != null) query['room_id'] = roomId;
      if (floorId != null) query['floor_id'] = floorId;
      if (id != null) query['listing_id'] = id;
      if (shiftId != null) query['shift_id'] = shiftId;
      if (trainerIds != null && trainerIds.isNotEmpty) {
        query['trainer_ids'] = trainerIds;
      }
      if (paymentMethod != null) query['payment_method'] = paymentMethod;
      if (bedsBooked != null) query['beds_booked'] = bedsBooked.toString();
      if (couponCode != null) query['coupon_code'] = couponCode;

      Response response = await subscriptionRepo.fetchPlanListingById(
        id: id ?? "",
        query: query.isNotEmpty ? query : null,
      );

      print('API URL (fetchPlanListingById): ${response.request?.url}');
      print('API Response (fetchPlanListingById): ${response.body}');

      final status = response.body is Map ? response.body['status'] : null;
      if (status == true || status == "true" || status == "success") {
        final data = response.body['data'];

        /// Plans
        final List plansJson = data['plans'] ?? [];
        allPlanList = plansJson.map((e) => PlanModel.fromJson(e)).toList();

        planModelList = List.from(allPlanList);

        if (planModelList.isNotEmpty) {
          planModelList.first.isSelected = true;
          selectedPlan = planModelList.first;
        }

        /// Batch Times
        final List batchJson = data['batch_times'] ?? [];
        batchModelList = batchJson.map((e) => BatchModel.fromJson(e)).toList();

        if (batchModelList.isNotEmpty) {
          batchModelList.first.isSelected = true;
          selectedBatch = batchModelList.first;
        }

        /// Rooms
        final List roomsJson = data['rooms'] ?? [];
        roomDetailList =
            roomsJson.map((e) => RoomDetailModel.fromJson(e)).toList();

        hasShifts = data['has_shifts'] ?? false;
        hasRooms = data['has_rooms'] ?? false;

        responseModel = ResponseModel(
          true,
          response.body['message'] ?? "success",
        );
      } else {
        responseModel = ResponseModel(
          false,
          response.body['message'] ?? "Error",
        );
      }

      if (allPlanList.isEmpty) {
        final homeController = Get.find<HomeController>();
        final gymPackages = homeController.selectListingModel?.packages;
        if (gymPackages != null && gymPackages.isNotEmpty) {
          allPlanList = gymPackages
              .map((p) => PlanModel(
                    id: p.id,
                    name: p.name,
                    type: p.type,
                    durationLabel: p.durationLabel ??
                        (p.durationDays != null
                            ? "${p.durationDays} Days"
                            : "1 Month"),
                    durationDays: p.durationDays,
                    price: p.price != null
                        ? (double.tryParse(p.price!)?.toInt() ?? p.price)
                        : null,
                    features: p.features,
                  ))
              .toList();

          planModelList = List.from(allPlanList);
          if (planModelList.isNotEmpty) {
            planModelList.first.isSelected = true;
            selectedPlan = planModelList.first;
          }
          responseModel = ResponseModel(true, "Loaded from gym packages");
        }
      }
    } catch (e) {
      log('ERROR AT fetchPlanListingById(): $e');
      if (allPlanList.isEmpty) {
        final homeController = Get.find<HomeController>();
        final gymPackages = homeController.selectListingModel?.packages;
        if (gymPackages != null && gymPackages.isNotEmpty) {
          allPlanList = gymPackages
              .map((p) => PlanModel(
                    id: p.id,
                    name: p.name,
                    type: p.type,
                    durationLabel: p.durationLabel ??
                        (p.durationDays != null
                            ? "${p.durationDays} Days"
                            : "1 Month"),
                    durationDays: p.durationDays,
                    price: p.price != null
                        ? (double.tryParse(p.price!)?.toInt() ?? p.price)
                        : null,
                    features: p.features,
                  ))
              .toList();

          planModelList = List.from(allPlanList);
          if (planModelList.isNotEmpty) {
            planModelList.first.isSelected = true;
            selectedPlan = planModelList.first;
          }
          responseModel = ResponseModel(true, "Loaded from gym packages");
        } else {
          responseModel = ResponseModel(false, e.toString());
        }
      } else {
        responseModel = ResponseModel(false, e.toString());
      }
    }

    isLoading = false;
    update();
    return responseModel;
  }

  PlanModel? selectedPlan;
  void updateSelectPlan(PlanModel value) {
    selectedPlan = value;
    update();
  }

  void selectPlan(int index) {
    for (final plan in planModelList) {
      plan.isSelected = false;
    }

    planModelList[index].isSelected = true;
    selectedPlan = planModelList[index];

    update();
  }

  BatchModel? selectedBatch;

  void selectBatch(int index) {
    for (final item in batchModelList) {
      item.isSelected = false;
    }

    batchModelList[index].isSelected = true;
    selectedBatch = batchModelList[index];
    update();
  }

  BillingPreviewModel? billingPreviewModel;

  Future<ResponseModel> fetchBillingSummary({
    required String? listingId,
    required String? packageId,
    String? roomId,
    String? shiftId,
    List<String>? trainerIds,
    int? bedsBooked,
    String paymentMethod = "online",
    String? couponCode,
    bool useWallet = false,
  }) async {
    log('-----------  fetchBillingSummary ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      final Map<String, dynamic> data = {
        "listing_id": listingId.toString(),
        "package_id": packageId.toString(),
        "payment_method": paymentMethod.toString(),
        "use_wallet": useWallet ? "1" : "0",
      };

      if (roomId != null) {
        data["room_id"] = roomId.toString();
      }
      if (shiftId != null) {
        data["shift_id"] = shiftId.toString();
      }
      if (trainerIds != null && trainerIds.isNotEmpty) {
        for (int i = 0; i < trainerIds.length; i++) {
          data["trainer_ids[$i]"] = trainerIds[i].toString();
        }
      }
      if (bedsBooked != null) {
        data["beds_booked"] = bedsBooked.toString();
      }
      if (couponCode != null && couponCode.isNotEmpty) {
        data["coupon_code"] = couponCode;
      }

      Response response =
          await subscriptionRepo.fetchBillingSummary(data: data);

      log('API URL (fetchBillingSummary): ${response.request?.url ?? 'URL is NULL (Request failed)'}',
          name: 'BILLING_PREVIEW');
      log('API Status Code: ${response.statusCode}', name: 'BILLING_PREVIEW');
      log('API Status Text: ${response.statusText}', name: 'BILLING_PREVIEW');
      log('API Response Body: ${response.bodyString}', name: 'BILLING_PREVIEW');

      if (response.body != null && response.body['status'] == "success") {
        billingPreviewModel =
            BillingPreviewModel.fromJson(response.body['data']);
        responseModel = ResponseModel(
            true, response.body['message'] ?? "success fetchBillingSummary  ");
      } else {
        responseModel = ResponseModel(false,
            response.body?['message'] ?? "Error while fetchBillingSummary  ");
      }
    } catch (e) {
      log('ERROR AT fetchBillingSummary(): $e');
      responseModel =
          ResponseModel(false, "Error while fetchBillingSummary   $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  List<BookingModel> bookingList = [];
  List<BookingModel> filteredBookingList = [];
  bool isBookingLoading = false;
  String selectedBookingFilter = 'all';

  void setBookingFilter(String filter) {
    selectedBookingFilter = filter;
    _filterBookings();
    update();
  }

  void _filterBookings() {
    if (selectedBookingFilter == 'all') {
      filteredBookingList = List.from(bookingList);
    } else {
      filteredBookingList = bookingList.where((booking) {
        final status =
            (booking.bookingStatus ?? booking.status ?? "").toLowerCase();
        if (selectedBookingFilter == 'pending_otp') {
          return status == 'pending_otp';
        } else if (selectedBookingFilter == 'pending_payment') {
          return status == 'pending_payment';
        } else if (selectedBookingFilter == 'cancelled') {
          return status == 'cancelled';
        } else if (selectedBookingFilter == 'completed') {
          return status == 'completed' || status == 'active';
        }
        return true;
      }).toList();
    }
  }

  Future<ResponseModel> fetchBookings() async {
    log('-----------  fetchBookings ----------');
    ResponseModel responseModel;
    isBookingLoading = true;
    update();

    try {
      Response response = await subscriptionRepo.fetchBookings();

      if (response.body != null && response.body['status'] == "success") {
        var data = response.body['data'];
        if (data is Map && data['data'] is List) {
          bookingList = (data['data'] as List)
              .map((e) => BookingModel.fromJson(e))
              .toList();
        } else if (data is List) {
          bookingList = data.map((e) => BookingModel.fromJson(e)).toList();
        } else {
          bookingList = [];
        }

        _filterBookings();

        responseModel = ResponseModel(
            true, response.body['message'] ?? "success fetchBookings");
      } else {
        bookingList = [];
        filteredBookingList = [];
        responseModel = ResponseModel(
            false, response.body?['message'] ?? "Error while fetchBookings");
      }
    } catch (e) {
      bookingList = [];
      filteredBookingList = [];
      log('ERROR AT fetchBookings(): $e');
      responseModel = ResponseModel(false, "Error while fetchBookings $e");
    }

    isBookingLoading = false;
    update();
    return responseModel;
  }

  BookingModel? selectedBookingDetail;
  bool isBookingDetailLoading = false;

  Future<ResponseModel> fetchBookingById({required String id}) async {
    log('-----------  fetchBookingById ----------');
    log('Booking Detail URL: ${AppConstants.baseUrl}${AppConstants.postCreateBooking}/$id');
    ResponseModel responseModel;
    isBookingDetailLoading = true;
    update();

    try {
      Response response = await subscriptionRepo.fetchBookingById(id: id);

      if (response.body != null && response.body['status'] == "success") {
        selectedBookingDetail = BookingModel.fromJson(response.body['data']);
        responseModel = ResponseModel(
            true, response.body['message'] ?? "success fetchBookingById");
      } else {
        selectedBookingDetail = null;
        responseModel = ResponseModel(
            false, response.body?['message'] ?? "Error while fetchBookingById");
      }
    } catch (e) {
      selectedBookingDetail = null;
      log('ERROR AT fetchBookingById(): $e');
      responseModel = ResponseModel(false, "Error while fetchBookingById $e");
    }

    isBookingDetailLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> cancelBooking(String bookingId) async {
    log('----------- cancelBooking ----------');
    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Response response = await subscriptionRepo.cancelBooking(bookingId);

      if (response.body != null && response.body['status'] == "success") {
        await fetchBookingById(id: bookingId);
        responseModel = ResponseModel(
            true, response.body['message'] ?? "Booking cancelled successfully");
      } else {
        responseModel = ResponseModel(false,
            response.body?['message'] ?? "Error while cancelling booking");
      }
    } catch (e) {
      log('ERROR AT cancelBooking(): $e');
      responseModel =
          ResponseModel(false, "Error while cancelling booking: $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> payBooking(String bookingId) async {
    log('----------- payBooking ----------');
    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Response response = await subscriptionRepo.payBooking(bookingId);

      if (response.statusCode == 200 &&
          response.body is Map &&
          response.body['status'] == "success") {
        responseModel = ResponseModel(
            true, response.body['message'] ?? "success", response.body['data']);
      } else {
        String errorMessage = "Error while generating payment link";
        if (response.body is Map && response.body['message'] != null) {
          errorMessage = response.body['message'];
        } else if (response.statusText != null) {
          errorMessage = response.statusText!;
        }
        responseModel = ResponseModel(false, errorMessage);
      }
    } catch (e) {
      log('ERROR AT payBooking(): $e');
      responseModel = ResponseModel(false, "Error: $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  List<SubscriptionModel> subscriptionsList = [];
  bool isSubscriptionsLoading = false;

  Future<ResponseModel> fetchSubscriptionsList() async {
    log('-----------  fetchSubscriptionsList ----------');
    ResponseModel responseModel;
    isSubscriptionsLoading = true;
    update();

    try {
      Response response = await subscriptionRepo.fetchSubscriptionsList();

      if (response.body != null && response.body['status'] == "success") {
        var data = response.body['data'];
        if (data is Map && data['data'] is List) {
          subscriptionsList = (data['data'] as List)
              .map((e) => SubscriptionModel.fromJson(e))
              .toList();
        } else if (data is List) {
          subscriptionsList =
              data.map((e) => SubscriptionModel.fromJson(e)).toList();
        } else {
          subscriptionsList = [];
        }
        responseModel = ResponseModel(
            true, response.body['message'] ?? "success fetchSubscriptionsList");
      } else {
        subscriptionsList = [];
        responseModel = ResponseModel(false,
            response.body?['message'] ?? "Error while fetchSubscriptionsList");
      }
    } catch (e) {
      subscriptionsList = [];
      log('ERROR AT fetchSubscriptionsList(): $e');
      responseModel =
          ResponseModel(false, "Error while fetchSubscriptionsList $e");
    }

    isSubscriptionsLoading = false;
    update();
    return responseModel;
  }

  SubscriptionModel? selectedSubscriptionDetail;
  bool isSubscriptionDetailLoading = false;

  Future<ResponseModel> fetchSubscriptionDetail({required String id}) async {
    log('-----------  fetchSubscriptionDetail ----------');
    ResponseModel responseModel;
    isSubscriptionDetailLoading = true;
    update();

    try {
      Response response =
          await subscriptionRepo.fetchSubscriptionDetail(id: id);

      if (response.body != null && response.body['status'] == "success") {
        selectedSubscriptionDetail =
            SubscriptionModel.fromJson(response.body['data']);
        responseModel = ResponseModel(true,
            response.body['message'] ?? "success fetchSubscriptionDetail");
      } else {
        selectedSubscriptionDetail = null;
        responseModel = ResponseModel(false,
            response.body?['message'] ?? "Error while fetchSubscriptionDetail");
      }
    } catch (e) {
      selectedSubscriptionDetail = null;
      log('ERROR AT fetchSubscriptionDetail(): $e');
      responseModel =
          ResponseModel(false, "Error while fetchSubscriptionDetail $e");
    }

    isSubscriptionDetailLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> requestCancellation({
    required String id,
    required String reason,
    required String leaveDate,
  }) async {
    log('----------- requestCancellation ----------');
    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      final Map<String, dynamic> data = {
        "reason": reason,
        "leave_date": leaveDate,
      };

      Response response =
          await subscriptionRepo.requestCancellation(id: id, data: data);

      if (response.body != null && response.body['status'] == "success") {
        await fetchSubscriptionDetail(id: id);
        responseModel = ResponseModel(
            true, response.body['message'] ?? "Cancellation request submitted");
      } else {
        responseModel = ResponseModel(false,
            response.body?['message'] ?? "Error requesting cancellation");
      }
    } catch (e) {
      log('ERROR AT requestCancellation(): $e');
      responseModel = ResponseModel(false, "Error requesting cancellation: $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  List<SubscriptionModel> cancellationHistoryList = [];
  bool isCancellationHistoryLoading = false;

  Future<ResponseModel> fetchCancellationHistory() async {
    log('-----------  fetchCancellationHistory ----------');
    ResponseModel responseModel;
    isCancellationHistoryLoading = true;
    update();

    try {
      Response response = await subscriptionRepo.fetchCancellationHistory();

      if (response.body != null && response.body['status'] == "success") {
        var data = response.body['data'];
        if (data is Map && data['data'] is List) {
          cancellationHistoryList = (data['data'] as List)
              .map((e) => SubscriptionModel.fromJson(e))
              .toList();
        } else if (data is List) {
          cancellationHistoryList =
              data.map((e) => SubscriptionModel.fromJson(e)).toList();
        } else {
          cancellationHistoryList = [];
        }
        responseModel = ResponseModel(true,
            response.body['message'] ?? "success fetchCancellationHistory");
      } else {
        cancellationHistoryList = [];
        responseModel = ResponseModel(
            false,
            response.body?['message'] ??
                "Error while fetchCancellationHistory");
      }
    } catch (e) {
      cancellationHistoryList = [];
      log('ERROR AT fetchCancellationHistory(): $e');
      responseModel =
          ResponseModel(false, "Error while fetchCancellationHistory $e");
    }

    isCancellationHistoryLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> renewSubscription(String subscriptionId) async {
    log('----------- renewSubscription ----------');
    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Response response =
          await subscriptionRepo.renewSubscription(subscriptionId);

      if (response.statusCode == 200 &&
          response.body != null &&
          response.body['status'] == "success") {
        responseModel = ResponseModel(
            true, response.body['message'] ?? "success", response.body['data']);
      } else {
        responseModel = ResponseModel(false,
            response.body?['message'] ?? "Error while renewing subscription");
      }
    } catch (e) {
      log('ERROR AT renewSubscription(): $e');
      responseModel =
          ResponseModel(false, "Error while renewing subscription: $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<void> downloadInvoice(String invoiceId, String invoiceNumber) async {
    final String url =
        "${AppConstants.baseUrl}${AppConstants.downloadReceipt(type: 'invoice', id: invoiceId)}";
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${subscriptionRepo.apiClient.token}',
      'Accept': 'application/pdf',
    };

    await FileDownloadHelper.downloadAndShareFile(
      url,
      "Invoice_$invoiceNumber.pdf",
      headers,
    );
  }
}
