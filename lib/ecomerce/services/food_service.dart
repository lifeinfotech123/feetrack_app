import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/food_model.dart';

class FoodService {
  final http.Client _client;

  FoodService({http.Client? client}) : _client = client ?? http.Client();

  final Map<String, String> _headers = const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Fetch Food Delivery Homepage Data (api/v1/ecommerce/food)
  Future<FoodHomeDataModel?> getFoodData({
    double? latitude,
    double? longitude,
    String? domain,
  }) async {
    String url = '$ecomBaseUrl$ecomFoodEndpoint';
    final queryParams = <String, String>{};
    if (latitude != null) queryParams['latitude'] = latitude.toString();
    if (longitude != null) queryParams['longitude'] = longitude.toString();
    if (domain != null && domain.isNotEmpty) queryParams['domain'] = domain;

    if (queryParams.isNotEmpty) {
      url = '$url?${Uri(queryParameters: queryParams).query}';
    }

    try {
      final response = await _client.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true) {
          return FoodHomeDataModel.fromJson(data);
        }
      } else {
        debugPrint(
            'FoodService getFoodData Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('FoodService getFoodData Exception: $e');
    }
    return null;
  }

  /// Fetch Popular Food Cuisines (api/v1/ecommerce/food/cuisines or stores/{domain}/food/cuisines)
  Future<List<CuisineModel>> getFoodCuisines({String? domain}) async {
    String url = domain != null && domain.isNotEmpty
        ? '$ecomBaseUrl$ecomStoresEndpoint/$domain/food/cuisines'
        : '$ecomBaseUrl$ecomFoodCuisinesEndpoint';
    try {
      final response = await _client.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List list = data['data'];
          return list
              .map((item) =>
                  CuisineModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      } else {
        debugPrint(
            'FoodService getFoodCuisines Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('FoodService getFoodCuisines Exception: $e');
    }
    return [];
  }

  /// Fetch Global Food Dishes and Items (api/v1/ecommerce/food/dishes?domain=...)
  Future<List<DishModel>> getFoodDishes({String? domain, int? shopId}) async {
    String url = '$ecomBaseUrl$ecomFoodDishesEndpoint';
    final queryParams = <String, String>{};
    if (domain != null && domain.isNotEmpty) queryParams['domain'] = domain;
    if (shopId != null) queryParams['shop_id'] = shopId.toString();

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
              .map((item) => DishModel.fromJson(
                    Map<String, dynamic>.from(item),
                    defaultDomain: domain,
                    defaultShopId: shopId,
                  ))
              .toList();
        }
      } else {
        debugPrint('FoodService getFoodDishes Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('FoodService getFoodDishes Exception: $e');
    }
    return [];
  }
}
