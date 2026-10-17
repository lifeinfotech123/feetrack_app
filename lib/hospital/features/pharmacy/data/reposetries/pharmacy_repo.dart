import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class PharmacyRepo {
  final ApiClient? apiClient;

  PharmacyRepo({this.apiClient});

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

  // Helper method to execute GET request with fallback
  Future<Map<String, dynamic>> _get(String endpoint, {Map<String, dynamic>? query}) async {
    final cleaned = _cleanEndpoint(endpoint);
    try {
      final Response res = await _client.getData(
        cleaned,
        'PharmacyRepo_GET_$cleaned',
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
      log('GetX client failed: $e, trying http fallback...', name: 'PharmacyRepo');
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
        return jsonDecode(response.body);
      } else {
        return {
          'status': false,
          'message': 'Server returned ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      log('Direct HTTP failed: $e', name: 'PharmacyRepo');
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  // Helper method to execute POST request with fallback
  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> body) async {
    final cleaned = _cleanEndpoint(endpoint);
    try {
      final sp = Get.isRegistered<SharedPreferences>() ? Get.find<SharedPreferences>() : null;
      final token = sp?.getString(AppConstants.token) ?? _client.token ?? '';

      final Response res = await _client.postData(
        cleaned,
        'PharmacyRepo_POST_$cleaned',
        body,
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (res.body != null) {
        if (res.body is Map) {
          final map = Map<String, dynamic>.from(res.body);
          if (res.isOk && (map['status'] == true || map['success'] == true)) {
            return map;
          }
        } else if (res.body is String) {
          try {
            final decoded = jsonDecode(res.body);
            if (decoded is Map<String, dynamic> &&
                res.isOk &&
                (decoded['status'] == true || decoded['success'] == true)) {
              return decoded;
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      log('GetX client POST failed: $e, trying http fallback...', name: 'PharmacyRepo');
    }

    // Direct HTTP Fallback
    try {
      final base = AppConstants.baseUrl.endsWith('/')
          ? AppConstants.baseUrl
          : '${AppConstants.baseUrl}/';
      final uri = Uri.parse('$base$cleaned');

      final sp = Get.isRegistered<SharedPreferences>() ? Get.find<SharedPreferences>() : null;
      final token = sp?.getString(AppConstants.token) ?? '';

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {}

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'status': true, 'message': 'Success'};
      } else {
        return {
          'status': false,
          'message': 'Server returned ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      log('Direct HTTP POST failed: $e', name: 'PharmacyRepo');
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  /// 1. Get all Medicine Listing / Catalog: api/v1/hospital/pharmacy
  Future<Map<String, dynamic>> getPharmacyCatalog({String? search}) async {
    Map<String, dynamic>? query;
    if (search != null && search.isNotEmpty) {
      query = {'search': search};
    }
    return await _get(AppConstants.hospitalPharmacyCatalogUri, query: query);
  }

  /// 2. Get Pharmacy Medicines: /api/v1/hospital/pharmacy/medicines
  Future<Map<String, dynamic>> getPharmacyMedicines({String? search, int? categoryId}) async {
    Map<String, dynamic> query = {};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    if (categoryId != null) {
      query['category_id'] = categoryId.toString();
    }
    return await _get(AppConstants.hospitalPharmacyMedicinesUri, query: query.isNotEmpty ? query : null);
  }

  /// 3. Get Pharmacy Medicines By Id: /api/v1/hospital/pharmacy/medicines/{id}
  Future<Map<String, dynamic>> getMedicineById(dynamic id) async {
    return await _get(AppConstants.hospitalPharmacyMedicineByIdUri(id));
  }

  /// 4. Get Pharmacy Category: /api/v1/hospital/pharmacy/categories
  Future<Map<String, dynamic>> getPharmacyCategories({String? search}) async {
    Map<String, dynamic>? query;
    if (search != null && search.isNotEmpty) {
      query = {'search': search};
    }
    return await _get(AppConstants.hospitalPharmacyCategoriesUri, query: query);
  }

  /// 5. Get Pharmacy Store: /api/v1/hospital/pharmacy/stores
  Future<Map<String, dynamic>> getPharmacyStores({String? search}) async {
    Map<String, dynamic>? query;
    if (search != null && search.isNotEmpty) {
      query = {'search': search};
    }
    return await _get(AppConstants.hospitalPharmacyStoresUri, query: query);
  }

  /// 6. Get Pharmacy Place Order: /api/v1/hospital/pharmacy/place-order
  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> body) async {
    return await _post(AppConstants.hospitalPharmacyPlaceOrderUri, body);
  }

  /// 7. Get Payment Verified: /api/v1/hospital/pharmacy/verify-payment
  Future<Map<String, dynamic>> verifyPayment(Map<String, dynamic> body) async {
    return await _post(AppConstants.hospitalPharmacyVerifyPaymentUri, body);
  }

  /// 8. Get Pharmacy Invoice by id: /api/v1/hospital/pharmacy/invoice/{bill_id}
  Future<Map<String, dynamic>> getInvoiceById(dynamic billId) async {
    return await _get(AppConstants.hospitalPharmacyInvoiceUri(billId));
  }

  /// 9. Get Patient Medicine Orders: /api/v1/hospital/patient/medicine-orders
  Future<Map<String, dynamic>> getPatientMedicineOrders() async {
    return await _get(AppConstants.hospitalPatientMedicineOrdersUri);
  }
}
