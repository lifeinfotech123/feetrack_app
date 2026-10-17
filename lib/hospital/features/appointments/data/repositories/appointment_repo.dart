import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/data/repositories/auth_repo.dart';
import 'package:vlr/services/constants.dart';

class AppointmentRepo {
  final ApiClient? apiClient;

  AppointmentRepo({this.apiClient});

  ApiClient get _client {
    if (apiClient != null) return apiClient!;
    if (Get.isRegistered<ApiClient>()) return Get.find<ApiClient>();
    final sp = Get.isRegistered<SharedPreferences>()
        ? Get.find<SharedPreferences>()
        : null;
    return ApiClient(
      appBaseUrl: AppConstants.baseUrl,
      sharedPreferences: sp ?? Get.put(sp!),
    );
  }

  String _cleanEndpoint(String endpoint) {
    if (endpoint.startsWith('/api/')) {
      return endpoint.replaceFirst('/api/', '');
    } else if (endpoint.startsWith('api/')) {
      return endpoint.replaceFirst('api/', '');
    } else if (endpoint.startsWith('/')) {
      return endpoint.substring(1);
    }
    return endpoint;
  }

  Future<String> _getToken() async {
    try {
      if (Get.isRegistered<AuthRepo>()) {
        final t = Get.find<AuthRepo>().getUserToken();
        if (t.isNotEmpty) return t;
      }
      if (Get.isRegistered<AuthController>()) {
        final t = Get.find<AuthController>().getUserToken();
        if (t.isNotEmpty) return t;
      }
      final sp = await SharedPreferences.getInstance();
      return sp.getString(AppConstants.token) ?? sp.getString('token') ?? '';
    } catch (e) {
      log('Error getting token: $e', name: 'AppointmentRepo');
      return '';
    }
  }

  // GET with fallback
  Future<Map<String, dynamic>> _get(String endpoint,
      {Map<String, dynamic>? query}) async {
    final cleaned = _cleanEndpoint(endpoint);
    try {
      final Response res = await _client.getData(
        cleaned,
        'AppointmentRepo_GET_$cleaned',
        query: query,
      );

      if (res.isOk && res.body != null) {
        if (res.body is Map) {
          return Map<String, dynamic>.from(res.body);
        } else if (res.body is String) {
          return jsonDecode(res.body);
        }
      }
    } catch (e) {
      log('GetX client failed: $e, trying http fallback...',
          name: 'AppointmentRepo');
    }

    try {
      final base = AppConstants.baseUrl.endsWith('/')
          ? AppConstants.baseUrl
          : '${AppConstants.baseUrl}/';
      var uri = Uri.parse('$base$cleaned');
      if (query != null && query.isNotEmpty) {
        final queryParams =
            query.map((k, v) => MapEntry(k, v?.toString() ?? ''));
        uri = uri.replace(queryParameters: queryParams);
      }

      final token = await _getToken();
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': false,
          'message': 'Server returned ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      log('Direct HTTP failed: $e', name: 'AppointmentRepo');
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  // POST with fallback
  Future<Map<String, dynamic>> _post(
      String endpoint, Map<String, dynamic> body) async {
    final cleaned = _cleanEndpoint(endpoint);
    try {
      final Response res = await _client.postData(
        cleaned,
        'AppointmentRepo_POST_$cleaned',
        body,
      );

      if (res.isOk && res.body != null) {
        if (res.body is Map) {
          return Map<String, dynamic>.from(res.body);
        } else if (res.body is String) {
          return jsonDecode(res.body);
        }
      }
    } catch (e) {
      log('GetX client post failed: $e, trying http fallback...',
          name: 'AppointmentRepo');
    }

    try {
      final base = AppConstants.baseUrl.endsWith('/')
          ? AppConstants.baseUrl
          : '${AppConstants.baseUrl}/';
      final uri = Uri.parse('$base$cleaned');

      final token = await _getToken();
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return {
            'status': false,
            'message':
                'Server returned ${response.statusCode}: ${response.body}',
          };
        }
      }
    } catch (e) {
      log('Direct HTTP post failed: $e', name: 'AppointmentRepo');
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  // 1. Create Appointment
  Future<Map<String, dynamic>> createAppointment(
      Map<String, dynamic> payload) async {
    return _post(AppConstants.hospitalAppointmentsUri, payload);
  }

  // 2. Fetch Payment Gateways
  Future<Map<String, dynamic>> fetchPaymentGateways() async {
    return _get(AppConstants.hospitalPaymentGatewaysUri);
  }

  // 3. Verify Payment
  Future<Map<String, dynamic>> verifyPayment({
    required String appointmentId,
    required String hospitalDomain,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final endpoint =
        AppConstants.hospitalAppointmentVerifyPaymentUri(appointmentId);
    final payload = {
      "hospital": hospitalDomain,
      "razorpay_order_id": razorpayOrderId,
      "razorpay_payment_id": razorpayPaymentId,
      "razorpay_signature": razorpaySignature,
    };
    return _post(endpoint, payload);
  }

  // 4. Fetch User Appointments (my-appointments)
  Future<Map<String, dynamic>> getUserAppointments() async {
    return _get(AppConstants.hospitalMyAppointmentsUri);
  }

  // 5. Fetch Single Appointment Details (my-appointments/:id)
  Future<Map<String, dynamic>> getMyAppointmentDetail(dynamic appointmentId) async {
    return _get(AppConstants.hospitalMyAppointmentDetailUri(appointmentId));
  }

  // 6. Cancel Appointment (unpaid or user cancelled)
  Future<Map<String, dynamic>> cancelAppointment(dynamic appointmentId) async {
    try {
      final token = await _getToken();
      final base = AppConstants.baseUrl.endsWith('/')
          ? AppConstants.baseUrl
          : '${AppConstants.baseUrl}/';

      // 1. Try REST cancel endpoint
      try {
        final res = await _post('v1/hospital/appointments/$appointmentId/cancel', {
          'appointment_id': appointmentId,
          'status': 'Cancelled',
        });
        if (res['status'] == true) return res;
      } catch (_) {}

      // 2. Legacy PHP endpoint
      final uri = Uri.parse(
          '$base${_cleanEndpoint(AppConstants.hospitalCancelAppointmentPhp)}');
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'appointment_id': appointmentId}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }
      return {'status': false, 'message': 'Cancellation failed'};
    } catch (e) {
      log('Cancel appointment failed: $e', name: 'AppointmentRepo');
      return {'status': false, 'message': e.toString()};
    }
  }
}
