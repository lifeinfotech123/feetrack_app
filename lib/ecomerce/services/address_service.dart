import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/ecommerce_address_model.dart';

class AddressService {
  final http.Client _client;

  AddressService({http.Client? client}) : _client = client ?? http.Client();

  String _getToken(SharedPreferences prefs) {
    final token = prefs.getString('token') ??
        prefs.getString('user_app_token') ??
        prefs.getString('auth_token') ??
        '';
    return token.trim();
  }

  int _getUserId(SharedPreferences prefs, int? userId) {
    if (userId != null && userId > 0) return userId;
    final storedId = prefs.get('user_app_id') ?? prefs.get('userId');
    if (storedId is int && storedId > 0) return storedId;
    if (storedId is String) {
      final parsed = int.tryParse(storedId);
      if (parsed != null && parsed > 0) return parsed;
    }
    return 3;
  }

  /// 1. Get Customer Delivery Addresses (GET api/v1/ecommerce/addresses?domain=...&user_id=...)
  Future<AddressApiResponse> getCustomerAddresses({
    String? domain,
    int? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = _getToken(prefs);
    final effectiveUserId = _getUserId(prefs, userId);

    final queryParams = <String, String>{
      'domain': (domain != null && domain.isNotEmpty) ? domain : 'e-team-12',
      'user_id': effectiveUserId.toString(),
    };

    final uri = Uri.parse(
        '$ecomBaseUrl$ecomAddressesEndpoint?${Uri(queryParameters: queryParams).query}');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    debugPrint('=========================================');
    debugPrint('[ECOMMERCE GET ADDRESSES API]');
    debugPrint('URL: $uri');
    debugPrint('Headers: $headers');
    debugPrint('=========================================');

    try {
      final response = await _client.get(uri, headers: headers);
      debugPrint(
          'AddressService getCustomerAddresses Response: ${response.statusCode} - ${response.body}');
      if (response.body.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AddressApiResponse.fromJson(data);
      }
    } catch (e) {
      debugPrint('AddressService getCustomerAddresses Exception: $e');
    }
    return AddressApiResponse(
      status: false,
      isLoggedIn: false,
      message: 'Failed to connect to address service.',
      data: [],
    );
  }

  /// 2. Save Customer Delivery Address (POST api/v1/ecommerce/addresses)
  Future<Map<String, dynamic>> saveCustomerAddress({
    required EcommerceAddressModel address,
    String? domain,
    int? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = _getToken(prefs);
    final effectiveUserId = _getUserId(prefs, userId);

    final uri = Uri.parse('$ecomBaseUrl$ecomAddressesEndpoint');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final body = address.toJson(
      domain: (domain != null && domain.isNotEmpty) ? domain : 'e-team-12',
      userId: effectiveUserId,
    );

    debugPrint('=========================================');
    debugPrint('[ECOMMERCE SAVE ADDRESS API]');
    debugPrint('URL: $uri');
    debugPrint('Headers: $headers');
    debugPrint('Body: ${jsonEncode(body)}');
    debugPrint('=========================================');

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      debugPrint(
          'AddressService saveCustomerAddress Response: ${response.statusCode} - ${response.body}');
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('AddressService saveCustomerAddress Exception: $e');
    }
    return {
      'status': false,
      'message': 'Failed to save address.',
    };
  }

  /// 3. Update Customer Delivery Address (POST api/v1/ecommerce/addresses/update)
  Future<Map<String, dynamic>> updateCustomerAddress({
    required EcommerceAddressModel address,
    String? domain,
    int? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = _getToken(prefs);
    final effectiveUserId = _getUserId(prefs, userId);

    final uri = Uri.parse('$ecomBaseUrl$ecomAddressUpdateEndpoint');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final effectiveDomain = (domain != null && domain.isNotEmpty)
        ? domain
        : (address.domain != null && address.domain!.isNotEmpty
            ? address.domain!
            : 'e-team-12');

    final body = {
      'domain': effectiveDomain,
      'address_id': address.id,
      'address': address.address,
      ...address.toJson(
        domain: effectiveDomain,
        userId: effectiveUserId,
      ),
    };

    debugPrint('=========================================');
    debugPrint('[ECOMMERCE UPDATE ADDRESS API]');
    debugPrint('URL: $uri');
    debugPrint('Headers: $headers');
    debugPrint('Body: ${jsonEncode(body)}');
    debugPrint('=========================================');

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      debugPrint(
          'AddressService updateCustomerAddress Response: ${response.statusCode} - ${response.body}');
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('AddressService updateCustomerAddress Exception: $e');
    }
    return {
      'status': false,
      'message': 'Failed to update address.',
    };
  }

  /// 4. Delete Customer Delivery Address (DELETE api/v1/ecommerce/addresses/delete)
  Future<Map<String, dynamic>> deleteCustomerAddress({
    required int addressId,
    String? domain,
    int? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = _getToken(prefs);

    final effectiveDomain = (domain != null && domain.isNotEmpty) ? domain : 'e-team-12';

    final uri = Uri.parse('$ecomBaseUrl$ecomAddressDeleteEndpoint');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final body = {
      'domain': effectiveDomain,
      'address_id': addressId,
      'id': addressId,
    };

    debugPrint('=========================================');
    debugPrint('[ECOMMERCE DELETE ADDRESS API]');
    debugPrint('URL: $uri');
    debugPrint('Method: DELETE');
    debugPrint('Headers: $headers');
    debugPrint('Body: ${jsonEncode(body)}');
    debugPrint('=========================================');

    try {
      var response = await _client.delete(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      // If server doesn't support DELETE with body (405 Method Not Allowed), retry with POST
      if (response.statusCode == 405) {
        debugPrint('AddressService deleteCustomerAddress 405 -> retrying with POST');
        response = await _client.post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
      }

      debugPrint(
          'AddressService deleteCustomerAddress Response: ${response.statusCode} - ${response.body}');
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('AddressService deleteCustomerAddress Exception: $e');
    }
    return {
      'status': false,
      'message': 'Failed to delete address.',
    };
  }
}
