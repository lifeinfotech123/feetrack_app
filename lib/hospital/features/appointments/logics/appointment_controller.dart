import 'dart:developer';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import '../data/model/appointment_model.dart';
import '../data/repositories/appointment_repo.dart';

class AppointmentController extends GetxController implements GetxService {
  final AppointmentRepo appointmentRepo;

  AppointmentController({AppointmentRepo? appointmentRepo})
      : appointmentRepo = appointmentRepo ??
            (Get.isRegistered<AppointmentRepo>()
                ? Get.find<AppointmentRepo>()
                : Get.put(AppointmentRepo()));

  // Observables & States
  final RxBool isLoadingAppointments = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxBool isBookingLoading = false.obs;
  final RxBool isLoadingGateways = false.obs;
  final RxBool isVerifyingPayment = false.obs;

  final RxString selectedFilter = 'All'.obs;
  final RxString selectedMethod = 'Razorpay'.obs;
  final RxString errorMessage = ''.obs;

  // Data
  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final Rxn<AppointmentModel> selectedAppointmentDetail = Rxn<AppointmentModel>();
  final RxList<PaymentGatewayModel> gateways = <PaymentGatewayModel>[].obs;
  final Rxn<PaymentGatewayModel> razorpayGateway = Rxn<PaymentGatewayModel>();
  final Rxn<AppointmentBookingResponse> currentBooking =
      Rxn<AppointmentBookingResponse>();

  bool get isLoggedIn =>
      Get.isRegistered<AuthController>() &&
      Get.find<AuthController>().isLoggedIn();

  @override
  void onInit() {
    super.onInit();
    fetchGateways();
    if (isLoggedIn) {
      fetchAppointments();
    } else {
      appointments.clear();
    }
  }

  // 1. Fetch User Appointments (my-appointments)
  Future<void> fetchAppointments() async {
    if (!isLoggedIn) {
      appointments.clear();
      isLoadingAppointments.value = false;
      return;
    }
    try {
      isLoadingAppointments.value = true;
      errorMessage.value = '';

      final res = await appointmentRepo.getUserAppointments();
      if (res['status'] == true && res['data'] != null) {
        final data = res['data'];
        List rawList = [];
        if (data is Map && data['appointments'] is List) {
          rawList = data['appointments'];
        } else if (data is List) {
          rawList = data;
        }
        final list = rawList
            .map((item) =>
                AppointmentModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        appointments.assignAll(list);
      }
    } catch (e) {
      log('Error fetching appointments: $e', name: 'AppointmentController');
      errorMessage.value = e.toString();
    } finally {
      isLoadingAppointments.value = false;
    }
  }

  // 1.1 Fetch Single Appointment Detail (my-appointments/:id)
  Future<AppointmentModel?> fetchAppointmentDetail(dynamic id) async {
    try {
      isLoadingDetail.value = true;
      final res = await appointmentRepo.getMyAppointmentDetail(id);
      if (res['status'] == true && res['data'] != null) {
        final model =
            AppointmentModel.fromJson(Map<String, dynamic>.from(res['data']));
        selectedAppointmentDetail.value = model;
        return model;
      }
    } catch (e) {
      log('Error fetching appointment detail: $e',
          name: 'AppointmentController');
    } finally {
      isLoadingDetail.value = false;
    }
    return null;
  }

  // 2. Fetch Payment Gateways
  Future<void> fetchGateways() async {
    try {
      isLoadingGateways.value = true;
      final res = await appointmentRepo.fetchPaymentGateways();

      if (res['status'] == true && res['data'] != null) {
        final data = res['data'];
        final list = (data['gateways'] is List) ? (data['gateways'] as List) : [];
        final parsed = list
            .map((g) =>
                PaymentGatewayModel.fromJson(Map<String, dynamic>.from(g)))
            .toList();
        gateways.assignAll(parsed);

        PaymentGatewayModel? rzp;
        for (var g in parsed) {
          if (g.slug.toLowerCase() == 'razorpay') {
            rzp = g;
            break;
          }
        }
        razorpayGateway.value = rzp;

        if (rzp != null && rzp.active) {
          selectedMethod.value = 'Razorpay';
        } else {
          selectedMethod.value = 'Cash';
        }
      }
    } catch (e) {
      log('Error fetching gateways: $e', name: 'AppointmentController');
    } finally {
      isLoadingGateways.value = false;
    }
  }

  // 3. Create Appointment Booking
  Future<AppointmentBookingResponse> createAppointment(
      Map<String, dynamic> payload) async {
    try {
      isBookingLoading.value = true;
      final res = await appointmentRepo.createAppointment(payload);
      final response = AppointmentBookingResponse.fromJson(res);
      currentBooking.value = response;
      return response;
    } catch (e) {
      log('Error creating appointment: $e', name: 'AppointmentController');
      return AppointmentBookingResponse(
        status: false,
        message: e.toString(),
      );
    } finally {
      isBookingLoading.value = false;
    }
  }

  // 4. Verify Payment
  Future<VerifyPaymentResponse> verifyPayment({
    required String appointmentId,
    required String hospitalDomain,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      isVerifyingPayment.value = true;
      final res = await appointmentRepo.verifyPayment(
        appointmentId: appointmentId,
        hospitalDomain: hospitalDomain,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );
      return VerifyPaymentResponse.fromJson(res);
    } catch (e) {
      log('Error verifying payment: $e', name: 'AppointmentController');
      return VerifyPaymentResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      isVerifyingPayment.value = false;
    }
  }
}
