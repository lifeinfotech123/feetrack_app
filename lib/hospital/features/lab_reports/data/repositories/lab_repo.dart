import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class LabRepo {
  final ApiClient? apiClient;

  LabRepo({this.apiClient});

  ApiClient get _client {
    if (apiClient != null) return apiClient!;
    if (Get.isRegistered<ApiClient>()) return Get.find<ApiClient>();
    final sp = Get.isRegistered<SharedPreferences>() ? Get.find<SharedPreferences>() : null;
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

  /// Save response to SharedPreferences cache
  Future<void> _saveToCache(String key, Map<String, dynamic> data) async {
    try {
      final sp = Get.isRegistered<SharedPreferences>()
          ? Get.find<SharedPreferences>()
          : await SharedPreferences.getInstance();
      await sp.setString('lab_cache_$key', jsonEncode(data));
      log('Saved $key to SharedPreferences cache', name: 'LabRepo');
    } catch (e) {
      log('Error saving to SharedPreferences: $e', name: 'LabRepo');
    }
  }

  /// Read response from SharedPreferences cache
  Future<Map<String, dynamic>?> _getFromCache(String key) async {
    try {
      final sp = Get.isRegistered<SharedPreferences>()
          ? Get.find<SharedPreferences>()
          : await SharedPreferences.getInstance();
      final str = sp.getString('lab_cache_$key');
      if (str != null && str.isNotEmpty) {
        log('Loaded $key from SharedPreferences cache', name: 'LabRepo');
        return jsonDecode(str) as Map<String, dynamic>;
      }
    } catch (e) {
      log('Error reading from SharedPreferences: $e', name: 'LabRepo');
    }
    return null;
  }

  // Helper GET with fallback & SharedPreferences caching
  Future<Map<String, dynamic>> _get(String endpoint, {Map<String, dynamic>? query}) async {
    final cleaned = _cleanEndpoint(endpoint);
    final cacheKey = query != null && query.isNotEmpty
        ? '${cleaned}_${query.values.join("_")}'
        : cleaned;

    try {
      final Response res = await _client.getData(
        cleaned,
        'LabRepo_GET_$cleaned',
        query: query,
      );

      if (res.isOk && res.body != null) {
        Map<String, dynamic> result;
        if (res.body is Map) {
          result = Map<String, dynamic>.from(res.body);
        } else if (res.body is String) {
          result = jsonDecode(res.body);
        } else {
          result = {'status': true, 'data': res.body};
        }
        if (result['status'] == true) {
          await _saveToCache(cacheKey, result);
        }
        return result;
      }
    } catch (e) {
      log('GetX client failed: $e, trying http fallback...', name: 'LabRepo');
    }

    // Direct HTTP Fallback
    try {
      final base = AppConstants.baseUrl.endsWith('/')
          ? AppConstants.baseUrl
          : '${AppConstants.baseUrl}/';
      var uri = Uri.parse('$base$cleaned');
      if (query != null && query.isNotEmpty) {
        final queryParams = query.map((k, v) => MapEntry(k, v?.toString() ?? ''));
        uri = uri.replace(queryParameters: queryParams);
      }

      final sp = Get.isRegistered<SharedPreferences>() ? Get.find<SharedPreferences>() : null;
      final token = sp?.getString(AppConstants.token) ?? '';

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        if (result['status'] == true) {
          await _saveToCache(cacheKey, result);
        }
        return result;
      } else {
        // Try fallback to cached data if available
        final cached = await _getFromCache(cacheKey);
        if (cached != null) return cached;

        return {
          'status': false,
          'message': 'Server returned ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      log('Direct HTTP failed: $e', name: 'LabRepo');
      // Offline / error fallback to cache
      final cached = await _getFromCache(cacheKey);
      if (cached != null) return cached;

      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  // Helper POST with fallback & SharedPreferences caching
  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> body) async {
    final cleaned = _cleanEndpoint(endpoint);
    final sp = Get.isRegistered<SharedPreferences>() ? Get.find<SharedPreferences>() : null;
    final token = sp?.getString(AppConstants.token) ?? '';

    try {
      final Response res = await _client.postData(
        cleaned,
        'LabRepo_POST_$cleaned',
        body,
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (res.isOk && res.body != null) {
        Map<String, dynamic> result;
        if (res.body is Map) {
          result = Map<String, dynamic>.from(res.body);
        } else if (res.body is String) {
          result = jsonDecode(res.body);
        } else {
          result = {'status': true, 'data': res.body};
        }
        if (result['status'] == true) {
          await _saveToCache('last_post_$cleaned', result);
        }
        return result;
      }
    } catch (e) {
      log('GetX client POST failed: $e, trying http fallback...', name: 'LabRepo');
    }

    // Direct HTTP Fallback for POST
    try {
      final base = AppConstants.baseUrl.endsWith('/')
          ? AppConstants.baseUrl
          : '${AppConstants.baseUrl}/';
      final uri = Uri.parse('$base$cleaned');

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      log('LabRepo Direct HTTP response: ${response.statusCode} ${response.body}', name: 'LabRepo');

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final result = Map<String, dynamic>.from(decoded);
          if (result['status'] == true) {
            await _saveToCache('last_post_$cleaned', result);
          }
          return result;
        }
      } catch (_) {}

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'status': true, 'data': response.body};
      } else {
        return {
          'status': false,
          'message': 'Server returned ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      log('Direct HTTP POST failed: $e', name: 'LabRepo');
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  /// 1. Get all Lab Listing: api/v1/hospital/lab
  Future<Map<String, dynamic>> getLabListing({String? search}) async {
    Map<String, dynamic>? query;
    if (search != null && search.isNotEmpty) {
      query = {'search': search};
    }
    return await _get(AppConstants.hospitalLabListingUri, query: query);
  }

  /// 2. Get Test Lab: /api/v1/hospital/lab/tests
  Future<Map<String, dynamic>> getLabTests({String? search, String? category}) async {
    Map<String, dynamic> query = {};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    if (category != null && category.isNotEmpty && category != 'all') {
      query['category'] = category;
    }
    return await _get(AppConstants.hospitalLabTestsUri, query: query.isNotEmpty ? query : null);
  }

  /// 3. Get Test Lab By Id: /api/v1/hospital/lab/tests/{id}
  Future<Map<String, dynamic>> getTestById(dynamic id) async {
    return await _get(AppConstants.hospitalLabTestByIdUri(id));
  }

  /// 4. Get Lab Centers: /api/v1/hospital/lab/centers
  Future<Map<String, dynamic>> getLabCenters({String? search}) async {
    Map<String, dynamic>? query;
    if (search != null && search.isNotEmpty) {
      query = {'search': search};
    }
    return await _get(AppConstants.hospitalLabCentersUri, query: query);
  }

  /// 5. Get Lab Categories: /api/v1/hospital/lab/categories
  Future<Map<String, dynamic>> getLabCategories({String? search}) async {
    Map<String, dynamic>? query;
    if (search != null && search.isNotEmpty) {
      query = {'search': search};
    }
    return await _get(AppConstants.hospitalLabCategoriesUri, query: query);
  }

  /// 6. Book Lab Test: /api/v1/hospital/lab/book
  Future<Map<String, dynamic>> bookLabTest(Map<String, dynamic> body) async {
    final res = await _post(AppConstants.hospitalLabBookUri, body);
    if (res['status'] == true) {
      await _saveToCache('last_booking', res);
    }
    return res;
  }

  /// 7. Verify Payment: /api/v1/hospital/lab/verify-payment
  Future<Map<String, dynamic>> verifyPayment(Map<String, dynamic> body) async {
    final res = await _post(AppConstants.hospitalLabVerifyPaymentUri, body);
    if (res['status'] == true) {
      await _saveToCache('last_verified_payment', res);
    }
    return res;
  }

  /// 8. Get Patient Lab Bookings: /api/v1/hospital/patient/lab-bookings
  Future<Map<String, dynamic>> getPatientLabBookings() async {
    return await _get(AppConstants.hospitalPatientLabBookingsUri);
  }
}
