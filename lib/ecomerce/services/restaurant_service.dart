import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/food_model.dart';
import '../models/restaurant_model.dart';

class RestaurantService {
  final http.Client _client;

  RestaurantService({http.Client? client}) : _client = client ?? http.Client();

  final Map<String, String> _headers = const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Fetch Restaurants Directory with filters (api/v1/ecommerce/restaurants)
  Future<List<RestaurantModel>> getRestaurants({
    double? latitude,
    double? longitude,
    double? distanceKm,
    String? foodType,
    int? isOpen,
    int? hasDining,
    String? search,
    String? sort,
    String? domain,
    int page = 1,
    int perPage = 20,
  }) async {
    String url = '$ecomBaseUrl$ecomRestaurantsEndpoint';
    final queryParams = <String, String>{};
    if (latitude != null) queryParams['latitude'] = latitude.toString();
    if (longitude != null) queryParams['longitude'] = longitude.toString();
    if (distanceKm != null) queryParams['distance_km'] = distanceKm.toString();
    if (foodType != null && foodType.isNotEmpty) {
      queryParams['food_type'] = foodType;
    }
    if (isOpen != null) queryParams['is_open'] = isOpen.toString();
    if (hasDining != null) queryParams['has_dining'] = hasDining.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;
    if (domain != null && domain.isNotEmpty) queryParams['domain'] = domain;
    if (page > 1) queryParams['page'] = page.toString();
    if (perPage != 20) queryParams['per_page'] = perPage.toString();

    if (queryParams.isNotEmpty) {
      url = '$url?${Uri(queryParameters: queryParams).query}';
    }

    try {
      final response = await _client.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List list = data['data'];
          return list
              .map((item) =>
                  RestaurantModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      } else {
        debugPrint(
            'RestaurantService getRestaurants Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('RestaurantService getRestaurants Exception: $e');
    }
    return [];
  }

  /// Fetch Restaurant Menu & Details (api/v1/ecommerce/restaurant/menu?shop_id=...&domain=...)
  Future<RestaurantDetailModel?> getRestaurantMenu({
    required int shopId,
    required String domain,
  }) async {
    final queryParams = {'shop_id': shopId.toString(), 'domain': domain};
    final url =
        '$ecomBaseUrl$ecomRestaurantMenuEndpoint?${Uri(queryParameters: queryParams).query}';
    try {
      final response = await _client.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return RestaurantDetailModel.fromJson(
              Map<String, dynamic>.from(data['data']));
        }
      } else {
        debugPrint(
            'RestaurantService getRestaurantMenu Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('RestaurantService getRestaurantMenu Exception: $e');
    }
    return null;
  }

  /// Fetch Full Restaurant Menu Data including dishes & categories
  Future<RestaurantMenuData?> getRestaurantMenuData({
    required int shopId,
    required String domain,
    RestaurantModel? initialRestaurant,
  }) async {
    final queryParams = {'shop_id': shopId.toString(), 'domain': domain};
    final url =
        '$ecomBaseUrl$ecomRestaurantMenuEndpoint?${Uri(queryParameters: queryParams).query}';
    try {
      final response = await _client.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return RestaurantMenuData.fromJson(
            Map<String, dynamic>.from(data['data']),
            fallbackRestaurant: initialRestaurant,
          );
        }
      } else {
        debugPrint(
            'RestaurantService getRestaurantMenuData Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('RestaurantService getRestaurantMenuData Exception: $e');
    }
    return null;
  }

  /// Fetch Restaurant Details by ID (fallback / backward compatible)
  Future<RestaurantDetailModel?> getRestaurantDetails(dynamic id) async {
    final uri = Uri.parse('$ecomBaseUrl$ecomRestaurantsEndpoint/$id');
    try {
      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return RestaurantDetailModel.fromJson(
              Map<String, dynamic>.from(data['data']));
        }
      } else {
        debugPrint(
            'RestaurantService getRestaurantDetails Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('RestaurantService getRestaurantDetails Exception: $e');
    }
    return null;
  }
}
