import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/store_model.dart';

class StoreService {
  final http.Client _client;

  StoreService({http.Client? client}) : _client = client ?? http.Client();

  final Map<String, String> _headers = const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Fetch Stores / Vendors Directory with filters
  Future<List<StoreModel>> getStores({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? search,
    int? isRestaurant,
    String? restaurantType,
    int? isOpen,
    int? hasDining,
    String? sortBy,
    int page = 1,
    int perPage = 20,
  }) async {
    String url = '$ecomBaseUrl$ecomStoresEndpoint';
    final queryParams = <String, String>{};
    if (latitude != null) queryParams['latitude'] = latitude.toString();
    if (longitude != null) queryParams['longitude'] = longitude.toString();
    if (radiusKm != null) queryParams['radius_km'] = radiusKm.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (isRestaurant != null) {
      queryParams['is_restaurant'] = isRestaurant.toString();
    }
    if (restaurantType != null && restaurantType.isNotEmpty) {
      queryParams['restaurant_type'] = restaurantType;
    }
    if (isOpen != null) queryParams['is_open'] = isOpen.toString();
    if (hasDining != null) queryParams['has_dining'] = hasDining.toString();
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sort_by'] = sortBy;
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
              .map((item) => StoreModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      } else {
        debugPrint('StoreService getStores Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('StoreService getStores Exception: $e');
    }
    return [];
  }

  /// Fetch Store Details by id or slug or domain
  Future<StoreModel?> getStoreDetails(dynamic idOrSlug) async {
    final uri = Uri.parse('$ecomBaseUrl$ecomStoresEndpoint/$idOrSlug');
    try {
      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return StoreModel.fromJson(Map<String, dynamic>.from(data['data']));
        }
      } else {
        debugPrint(
            'StoreService getStoreDetails Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('StoreService getStoreDetails Exception: $e');
    }
    return null;
  }
}
