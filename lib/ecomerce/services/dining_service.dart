import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/restaurant_model.dart';

class DiningService {
  final http.Client _client;

  DiningService({http.Client? client}) : _client = client ?? http.Client();

  final Map<String, String> _headers = const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('token') ??
            prefs.getString('user_app_token') ??
            prefs.getString('auth_token') ??
            '')
        .trim();
  }

  /// Fetch restaurants with dining enabled
  Future<List<RestaurantModel>> getDiningRestaurants({
    String domain = 'e-team-12',
    int page = 1,
    int perPage = 20,
  }) async {
    String url = '$ecomBaseUrl$ecomRestaurantsEndpoint';
    final queryParams = <String, String>{
      'domain': domain,
      'has_dining': '1',
    };
    if (page > 1) queryParams['page'] = page.toString();
    if (perPage != 20) queryParams['per_page'] = perPage.toString();
    url = '$url?${Uri(queryParameters: queryParams).query}';

    try {
      final response = await _client.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List list = data['data'];
          return list
              .map((item) => RestaurantModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('DiningService getDiningRestaurants Exception: $e');
    }
    return [];
  }

  /// Get dining slots
  Future<Map<String, dynamic>?> getDiningSlots({
    required String domain,
    String? date,
    int? guests,
  }) async {
    final queryParams = <String, String>{'domain': domain};
    if (date != null && date.isNotEmpty) queryParams['date'] = date;
    if (guests != null) queryParams['guests'] = guests.toString();

    final uri = Uri.parse('https://orderknow.com/api/v1/ecommerce/dining/slots').replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true) return data;
      }
    } catch (e) {
      debugPrint('DiningService getDiningSlots Exception: $e');
    }
    return null;
  }

  /// Get available tables
  Future<Map<String, dynamic>?> getAvailableTables({
    required String domain,
    required int shopId,
    required String date,
    required String timeSlot,
    int? guests,
  }) async {
    final queryParams = <String, String>{
      'domain': domain,
      'shop_id': shopId.toString(),
      'date': date,
      'time_slot': timeSlot,
    };
    if (guests != null) queryParams['guests_count'] = guests.toString();

    final uri = Uri.parse('https://orderknow.com/api/v1/ecommerce/dining/tables').replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true) return data;
      }
    } catch (e) {
      debugPrint('DiningService getAvailableTables Exception: $e');
    }
    return null;
  }

  /// Get dining menu for preorder
  Future<Map<String, dynamic>?> getDiningMenu({
    required String domain,
    required int shopId,
  }) async {
    final queryParams = <String, String>{
      'domain': domain,
      'shop_id': shopId.toString(),
    };
    final uri = Uri.parse('https://orderknow.com/api/v1/ecommerce/dining/menu').replace(queryParameters: queryParams);
    final token = await _getToken();
    final headers = {..._headers};
    if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

    try {
      final response = await _client.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true) return data;
      }
    } catch (e) {
      debugPrint('DiningService getDiningMenu Exception: $e');
    }
    return null;
  }

  /// Book table
  Future<Map<String, dynamic>?> bookTable({
    required String domain,
    required int shopId,
    required String bookingDate,
    required String bookingTimeSlot,
    required String mealType,
    required int guestsCount,
    int? tableId,
    String? specialRequest,
    List<Map<String, dynamic>>? preorderItems,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
  }) async {
    final token = await _getToken();
    final headers = {..._headers};
    if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

    final uri = Uri.parse('https://orderknow.com/api/v1/ecommerce/dining/book');
    final body = <String, dynamic>{
      'domain': domain,
      'shop_id': shopId,
      'booking_date': bookingDate,
      'booking_time_slot': bookingTimeSlot,
      'meal_type': mealType,
      'guests_count': guestsCount,
      if (tableId != null) 'table_id': tableId,
      if (customerName != null && customerName.trim().isNotEmpty) ...{
        'customer_name': customerName.trim(),
        'name': customerName.trim(),
      },
      if (customerPhone != null && customerPhone.trim().isNotEmpty) ...{
        'customer_phone': customerPhone.trim(),
        'phone': customerPhone.trim(),
        'mobile': customerPhone.trim(),
      },
      if (customerEmail != null && customerEmail.trim().isNotEmpty) ...{
        'customer_email': customerEmail.trim(),
        'email': customerEmail.trim(),
      },
      if (specialRequest != null && specialRequest.isNotEmpty)
        'special_request': specialRequest,
      if (preorderItems != null && preorderItems.isNotEmpty) ...{
        'preorder_items': preorderItems,
        'items': preorderItems,
        'menu_items': preorderItems,
      },
    };

    try {
      debugPrint('BOOK TABLE REQUEST: $body');
      final response = await _client.post(uri, headers: headers, body: jsonEncode(body));
      debugPrint('BOOK TABLE RESPONSE: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      }
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return {'status': false, 'message': response.body};
      }
    } catch (e) {
      debugPrint('DiningService bookTable Exception: $e');
    }
    return {'status': false, 'message': 'Network error'};
  }



  /// Get my bookings
  Future<Map<String, dynamic>?> getMyBookings({
    required String domain,
  }) async {
    final token = await _getToken();
    final headers = {..._headers};
    if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

    final queryParams = <String, String>{'domain': domain};
    final uri = Uri.parse('https://orderknow.com/api/v1/ecommerce/dining/bookings').replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true) return data;
      }
    } catch (e) {
      debugPrint('DiningService getMyBookings Exception: $e');
    }
    return null;
  }

  /// Cancel booking
  Future<Map<String, dynamic>?> cancelBooking({
    required String domain,
    required int bookingId,
    required String reason,
  }) async {
    final token = await _getToken();
    final headers = {..._headers};
    if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

    final uri = Uri.parse('https://orderknow.com/api/v1/ecommerce/dining/bookings/cancel');
    final body = {
      'domain': domain,
      'booking_id': bookingId,
      'reason': reason,
    };

    try {
      final response = await _client.post(uri, headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      }
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('DiningService cancelBooking Exception: $e');
    }
    return null;
  }
}
