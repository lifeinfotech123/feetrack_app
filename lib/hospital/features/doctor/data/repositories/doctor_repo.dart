import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class DoctorRepo {
  final ApiClient? apiClient;

  DoctorRepo({this.apiClient});

  ApiClient? get _client {
    if (apiClient != null) return apiClient;
    if (Get.isRegistered<ApiClient>()) return Get.find<ApiClient>();
    return null;
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
      if (Get.isRegistered<SharedPreferences>()) {
        final sp = Get.find<SharedPreferences>();
        final t = sp.getString(AppConstants.token) ?? sp.getString('token');
        if (t != null && t.isNotEmpty) return t;
      }
      final sp = await SharedPreferences.getInstance();
      return sp.getString(AppConstants.token) ?? sp.getString('token') ?? '';
    } catch (e) {
      log('Error getting token: $e', name: 'DoctorRepo');
      return '';
    }
  }

  // GET with fallback
  Future<Map<String, dynamic>> _get(String endpoint,
      {Map<String, dynamic>? query}) async {
    final cleaned = _cleanEndpoint(endpoint);
    try {
      final client = _client;
      if (client != null) {
        final Response res = await client.getData(
          cleaned,
          'DoctorRepo_GET_$cleaned',
          query: query,
        );

        if (res.isOk && res.body != null) {
          if (res.body is Map) {
            return Map<String, dynamic>.from(res.body);
          } else if (res.body is String) {
            final decoded = jsonDecode(res.body);
            if (decoded is Map<String, dynamic>) return decoded;
          }
        }
      }
    } catch (e) {
      log('GetX client failed: $e, trying http fallback...', name: 'DoctorRepo');
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
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          return {
            'status': true,
            'data': decoded,
          };
        }
      } else {
        return {
          'status': false,
          'message': 'Server returned ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      log('Direct HTTP failed: $e', name: 'DoctorRepo');
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  // 1. Fetch All Doctors
  Future<Map<String, dynamic>> fetchDoctors() async {
    return _get(AppConstants.hospitalDoctorsUri);
  }

  // 2. Fetch Hospital Services
  Future<Map<String, dynamic>> fetchServices() async {
    return _get(AppConstants.hospitalServicesUri);
  }

  // 3. Fetch Doctor By ID
  Future<Map<String, dynamic>> fetchDoctorById(dynamic id) async {
    return _get('${AppConstants.hospitalDoctorsUri}/$id');
  }
}
