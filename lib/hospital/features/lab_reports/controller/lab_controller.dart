import 'dart:developer';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/services/constants.dart';

import '../data/model/lab_model.dart';
import '../data/repositories/lab_repo.dart';

class LabController extends GetxController implements GetxService {
  final LabRepo labRepo;

  LabController({LabRepo? labRepo})
      : labRepo = labRepo ??
            (Get.isRegistered<LabRepo>()
                ? Get.find<LabRepo>()
                : Get.put(LabRepo()));

  // Observables & States
  final RxBool isLoading = false.obs;
  final RxBool isTestsLoading = false.obs;
  final RxBool isCentersLoading = false.obs;
  final RxBool isCategoriesLoading = false.obs;
  final RxBool isBookingLoading = false.obs;
  final RxBool isVerifyingPaymentLoading = false.obs;

  final RxString errorMessage = ''.obs;
  final RxString selectedCategorySlug = 'all'.obs;

  // Data
  final Rxn<LabStatsModel> stats = Rxn<LabStatsModel>();
  final RxList<LabCategoryModel> categories = <LabCategoryModel>[].obs;
  final RxList<DiagnosticLabModel> diagnosticLabs = <DiagnosticLabModel>[].obs;
  final RxList<LabTestModel> tests = <LabTestModel>[].obs;
  final RxList<PatientLabBookingModel> patientLabBookings =
      <PatientLabBookingModel>[].obs;
  final RxBool isPatientBookingsLoading = false.obs;
  final RxInt totalTestsCount = 0.obs;
  final RxInt hospitalsCount = 0.obs;
  final RxInt totalLabsCount = 0.obs;

  // Selected details
  final Rxn<LabTestModel> selectedTest = Rxn<LabTestModel>();
  final Rxn<LabBookingResponse> lastBooking = Rxn<LabBookingResponse>();
  final Rxn<LabVerifyPaymentResponse> verifiedPayment =
      Rxn<LabVerifyPaymentResponse>();

  List<LabCategoryModel> get displayCategories {
    final list = <LabCategoryModel>[];
    for (var cat in categories) {
      list.add(cat);
    }
    // Dynamically include categories present in the loaded diagnostic labs
    for (var lab in diagnosticLabs) {
      if (lab.category != null && lab.category!.trim().isNotEmpty) {
        final catName = lab.category!.trim();
        final slug = catName.toLowerCase().replaceAll(' ', '_');
        if (!list.any((c) =>
            c.name.toLowerCase() == catName.toLowerCase() || c.slug == slug)) {
          final count = diagnosticLabs
              .where((l) => l.category?.toLowerCase() == catName.toLowerCase())
              .length;
          list.add(LabCategoryModel(
            name: catName,
            slug: slug,
            testsCount: count,
          ));
        }
      }
    }
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    initLabData();
  }

  Future<void> initLabData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchLabListing(),
        fetchTests(),
        fetchCategories(),
        fetchCenters(),
        fetchPatientLabBookings(),
      ]);
    } catch (e) {
      log('Error during initLabData: $e', name: 'LabController');
    } finally {
      isLoading.value = false;
    }
  }

  // 1. Fetch Lab Listing
  Future<void> fetchLabListing({String? search}) async {
    try {
      isLoading.value = true;
      final response = await labRepo.getLabListing(search: search);

      if (response['status'] == true && response['data'] is Map) {
        final data = Map<String, dynamic>.from(response['data']);

        if (data['stats'] is Map) {
          stats.value =
              LabStatsModel.fromJson(Map<String, dynamic>.from(data['stats']));
        }
        if (data['hospitals_count'] != null) {
          hospitalsCount.value =
              int.tryParse(data['hospitals_count'].toString()) ?? 0;
        }

        if (data['categories'] is List) {
          final catList = data['categories'] as List;
          categories.assignAll(
            catList
                .map((e) =>
                    LabCategoryModel.fromJson(Map<String, dynamic>.from(e)))
                .toList(),
          );
        }

        if (data['diagnostic_labs'] is List) {
          final labList = data['diagnostic_labs'] as List;
          diagnosticLabs.assignAll(
            labList
                .map((e) =>
                    DiagnosticLabModel.fromJson(Map<String, dynamic>.from(e)))
                .toList(),
          );
        }

        if (data['tests'] is List) {
          final testList = data['tests'] as List;
          tests.assignAll(
            testList
                .map((e) => LabTestModel.fromJson(Map<String, dynamic>.from(e)))
                .toList(),
          );
        }
      }
    } catch (e) {
      log('Error fetching lab listing: $e', name: 'LabController');
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Fetch Tests
  Future<void> fetchTests({String? search, String? category}) async {
    try {
      isTestsLoading.value = true;
      if (category != null) {
        selectedCategorySlug.value = category;
      }

      final response = await labRepo.getLabTests(
        search: search,
        category: category ?? selectedCategorySlug.value,
      );

      if (response['status'] == true && response['data'] is Map) {
        final data = Map<String, dynamic>.from(response['data']);

        if (data['stats'] is Map) {
          stats.value =
              LabStatsModel.fromJson(Map<String, dynamic>.from(data['stats']));
        }
        if (data['total_tests'] != null) {
          totalTestsCount.value =
              int.tryParse(data['total_tests'].toString()) ?? 0;
        }
        if (data['total_labs'] != null) {
          totalLabsCount.value =
              int.tryParse(data['total_labs'].toString()) ?? 0;
        }
        if (data['hospitals_count'] != null) {
          hospitalsCount.value =
              int.tryParse(data['hospitals_count'].toString()) ?? 0;
        }

        if (data['tests'] is List) {
          final testList = data['tests'] as List;
          tests.assignAll(
            testList
                .map((e) => LabTestModel.fromJson(Map<String, dynamic>.from(e)))
                .toList(),
          );
        }

        if (data['categories'] is List &&
            (categories.isEmpty || categories.length <= 1)) {
          final catList = data['categories'] as List;
          categories.assignAll(
            catList
                .map((e) =>
                    LabCategoryModel.fromJson(Map<String, dynamic>.from(e)))
                .toList(),
          );
        }

        if (data['diagnostic_labs'] is List &&
            (data['diagnostic_labs'] as List).isNotEmpty) {
          final labList = data['diagnostic_labs'] as List;
          diagnosticLabs.assignAll(
            labList
                .map((e) =>
                    DiagnosticLabModel.fromJson(Map<String, dynamic>.from(e)))
                .toList(),
          );
        }
      }
    } catch (e) {
      log('Error fetching lab tests: $e', name: 'LabController');
    } finally {
      isTestsLoading.value = false;
    }
  }

  // 3. Fetch Test Details By ID
  Future<LabTestModel?> fetchTestDetails(dynamic id) async {
    try {
      isLoading.value = true;
      final response = await labRepo.getTestById(id);

      if (response['status'] == true && response['data'] is Map) {
        final model =
            LabTestModel.fromJson(Map<String, dynamic>.from(response['data']));
        selectedTest.value = model;
        return model;
      }
    } catch (e) {
      log('Error fetching test details: $e', name: 'LabController');
    } finally {
      isLoading.value = false;
    }
    return null;
  }

  // 4. Fetch Centers
  Future<void> fetchCenters({String? search}) async {
    try {
      isCentersLoading.value = true;
      final response = await labRepo.getLabCenters(search: search);

      if (response['status'] == true && response['data'] is Map) {
        final data = Map<String, dynamic>.from(response['data']);
        if (data['stats'] is Map) {
          stats.value =
              LabStatsModel.fromJson(Map<String, dynamic>.from(data['stats']));
        }
        if (data['hospitals_count'] != null) {
          hospitalsCount.value =
              int.tryParse(data['hospitals_count'].toString()) ?? 0;
        }
        if (data['diagnostic_labs'] is List) {
          final labList = data['diagnostic_labs'] as List;
          diagnosticLabs.assignAll(
            labList
                .map((e) =>
                    DiagnosticLabModel.fromJson(Map<String, dynamic>.from(e)))
                .toList(),
          );
        }
      }
    } catch (e) {
      log('Error fetching lab centers: $e', name: 'LabController');
    } finally {
      isCentersLoading.value = false;
    }
  }

  // 5. Fetch Categories
  Future<void> fetchCategories({String? search}) async {
    try {
      isCategoriesLoading.value = true;
      final response = await labRepo.getLabCategories(search: search);

      if (response['status'] == true && response['data'] is List) {
        final catList = response['data'] as List;
        categories.assignAll(
          catList
              .map((e) =>
                  LabCategoryModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
      }
    } catch (e) {
      log('Error fetching categories: $e', name: 'LabController');
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  // 6. Book Test
  Future<LabBookingResponse?> bookTest({
    required String patientName,
    required String patientPhone,
    required String address,
    required String testName,
    String collectionType = 'Home',
    String? bookingDate,
    String paymentMode = 'Razorpay',
    String? hospital,
    int? labId,
  }) async {
    try {
      isBookingLoading.value = true;

      final formattedDate =
          bookingDate ?? DateTime.now().toString().split(' ')[0];

      final pName =
          patientName.trim().isNotEmpty ? patientName.trim() : 'Patient';
      final pPhone =
          patientPhone.trim().isNotEmpty ? patientPhone.trim() : '9876543210';
      final pAddress = address.trim().isNotEmpty
          ? address.trim()
          : 'Hospital Lab Center Collection';
      final pTest =
          testName.trim().isNotEmpty ? testName.trim() : 'Diagnostic Test';

      final effectiveHospital = (hospital != null && hospital.trim().isNotEmpty)
          ? hospital.trim()
          : (diagnosticLabs.isNotEmpty
              ? (diagnosticLabs.first.hospital?.domain ?? 'usha')
              : 'usha');

      final effectiveLabId =
          labId ?? (diagnosticLabs.isNotEmpty ? diagnosticLabs.first.id : null);

      final req = LabBookingRequest(
        patientName: pName,
        patientPhone: pPhone,
        address: pAddress,
        collectionType: collectionType,
        bookingDate: formattedDate,
        testName: pTest,
        paymentMode: paymentMode,
        hospital: effectiveHospital,
        labId: effectiveLabId,
      );

      final response = await labRepo.bookLabTest(req.toJson());

      if ((response['status'] == true || response['success'] == true) &&
          response['data'] is Map) {
        final bookingRes = LabBookingResponse.fromJson(
          Map<String, dynamic>.from(response['data']),
          msg: response['message']?.toString(),
          isSuccess: true,
        );
        lastBooking.value = bookingRes;
        return bookingRes;
      } else {
        String errorMsg = response['message']?.toString() ??
            'Failed to submit lab test booking';
        if (response['errors'] is Map) {
          final errMap = response['errors'] as Map;
          final errorList = <String>[];
          errMap.forEach((k, v) {
            if (v is List && v.isNotEmpty) {
              errorList.add(v.first.toString());
            } else if (v != null) {
              errorList.add(v.toString());
            }
          });
          if (errorList.isNotEmpty) {
            errorMsg = errorList.join(', ');
          }
        }
        showToast(
          message: errorMsg,
          toastType: ToastType.error,
        );
      }
    } catch (e) {
      log('Error booking lab test: $e', name: 'LabController');
      showToast(message: 'Error: $e', toastType: ToastType.error);
    } finally {
      isBookingLoading.value = false;
    }
    return null;
  }

  // 7. Verify Payment
  Future<LabVerifyPaymentResponse?> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int bookingId,
    String? groupOrderNo,
    String? hospital,
  }) async {
    try {
      isVerifyingPaymentLoading.value = true;

      final effectiveHosp = (hospital != null && hospital.isNotEmpty)
          ? hospital
          : (lastBooking.value?.hospital?.domain ??
              (diagnosticLabs.isNotEmpty
                  ? (diagnosticLabs.first.hospital?.domain ?? 'usha')
                  : 'usha'));

      final body = {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
        'booking_id': bookingId,
        if (groupOrderNo != null) 'group_order_no': groupOrderNo,
        'hospital': effectiveHosp,
      };

      final response = await labRepo.verifyPayment(body);

      if (response['success'] == true || response['status'] == true) {
        final verifyRes = LabVerifyPaymentResponse.fromJson(
          Map<String, dynamic>.from(response),
        );
        verifiedPayment.value = verifyRes;
        return verifyRes;
      } else {
        showToast(
          message:
              response['message']?.toString() ?? 'Payment verification failed',
          toastType: ToastType.error,
        );
      }
    } catch (e) {
      log('Error verifying lab payment: $e', name: 'LabController');
      showToast(message: 'Verification Error: $e', toastType: ToastType.error);
    } finally {
      isVerifyingPaymentLoading.value = false;
    }
    return null;
  }

  // 8. Fetch Patient Lab Bookings (/api/v1/hospital/patient/lab-bookings)
  Future<void> fetchPatientLabBookings() async {
    final isLoggedIn = Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().isLoggedIn();
    if (!isLoggedIn) {
      patientLabBookings.clear();
      isPatientBookingsLoading.value = false;
      return;
    }
    try {
      isPatientBookingsLoading.value = true;
      final res = await labRepo.getPatientLabBookings();
      if (res['status'] == true && res['data'] is List) {
        final list = (res['data'] as List)
            .map((e) => PatientLabBookingModel.fromJson(
                Map<String, dynamic>.from(e)))
            .toList();
        patientLabBookings.assignAll(list);
      }
    } catch (e) {
      log('Error fetching patient lab bookings: $e', name: 'LabController');
    } finally {
      isPatientBookingsLoading.value = false;
    }
  }
}
