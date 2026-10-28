import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class HospitalProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rxn<Map<String, dynamic>> patient = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> counts = Rxn<Map<String, dynamic>>();

  bool get isLoggedIn =>
      Get.isRegistered<AuthController>() &&
      Get.find<AuthController>().isLoggedIn();

  @override
  void onInit() {
    super.onInit();
    if (isLoggedIn) {
      fetchPatientDashboard();
    } else {
      resetGuestState();
    }
  }

  void resetGuestState() {
    patient.value = null;
    counts.value = null;
    isLoading.value = false;
  }

  String get displayName {
    if (!isLoggedIn) return 'Guest';
    final p = patient.value;
    if (p == null) {
      final authUser = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>().userModel?.name
          : null;
      if (authUser != null && authUser.trim().isNotEmpty) {
        return authUser.trim();
      }
      return isLoading.value ? 'Loading...' : 'Guest';
    }
    final fullName = p['full_name']?.toString() ??
        ('${p['first_name'] ?? ''} ${p['last_name'] ?? ''}').trim();
    if (fullName.isNotEmpty) return fullName;
    final authUser = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>().userModel?.name
        : null;
    return (authUser != null && authUser.trim().isNotEmpty)
        ? authUser.trim()
        : 'Guest';
  }

  String get firstName {
    if (!isLoggedIn) return 'Guest';
    final p = patient.value;
    final fn = p?['first_name']?.toString() ?? '';
    if (fn.isNotEmpty) return fn;
    final full = displayName;
    return full.split(' ').first;
  }

  String get patientId {
    if (!isLoggedIn) return '';
    return patient.value?['patient_id']?.toString() ?? '';
  }

  String get email {
    if (!isLoggedIn) return '';
    return patient.value?['email']?.toString() ??
        (Get.isRegistered<AuthController>()
            ? Get.find<AuthController>().userModel?.email ?? ''
            : '');
  }

  String get phone {
    if (!isLoggedIn) return '';
    return patient.value?['phone']?.toString() ??
        (Get.isRegistered<AuthController>()
            ? Get.find<AuthController>().userModel?.mobile ?? ''
            : '');
  }

  String get gender {
    if (!isLoggedIn) return '';
    return patient.value?['gender']?.toString() ?? '';
  }

  String? get bloodGroup {
    if (!isLoggedIn) return null;
    return patient.value?['blood_group']?.toString();
  }

  Future<void> fetchPatientDashboard() async {
    if (!isLoggedIn) {
      resetGuestState();
      return;
    }

    isLoading.value = true;

    try {
      // 1. Try ApiClient via GetX
      if (Get.isRegistered<ApiClient>()) {
        final client = Get.find<ApiClient>();
        final res = await client.getData(
          'v1/hospital/patient/dashboard',
          'patient_dashboard',
        );
        if (res.isOk && res.body != null) {
          final body = res.body is Map
              ? Map<String, dynamic>.from(res.body)
              : jsonDecode(res.body.toString());
          if (body['status'] == true && body['data'] != null) {
            final data = Map<String, dynamic>.from(body['data']);
            patient.value = data['patient'] != null
                ? Map<String, dynamic>.from(data['patient'])
                : null;
            counts.value = data['counts'] != null
                ? Map<String, dynamic>.from(data['counts'])
                : null;
            isLoading.value = false;
            return;
          }
        }
      }

      // 2. Direct HTTP Fallback
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString(AppConstants.token) ?? '';
      if (token.isEmpty) {
        resetGuestState();
        return;
      }
      final base = AppConstants.baseUrl.endsWith('/')
          ? AppConstants.baseUrl
          : '${AppConstants.baseUrl}/';
      final uri = Uri.parse('${base}v1/hospital/patient/dashboard');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        if (body['status'] == true && body['data'] != null) {
          final data = Map<String, dynamic>.from(body['data']);
          patient.value = data['patient'] != null
              ? Map<String, dynamic>.from(data['patient'])
              : null;
          counts.value = data['counts'] != null
              ? Map<String, dynamic>.from(data['counts'])
              : null;
          isLoading.value = false;
          return;
        }
      }
    } catch (e) {
      log('Error fetching patient dashboard in HospitalProfileController: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
