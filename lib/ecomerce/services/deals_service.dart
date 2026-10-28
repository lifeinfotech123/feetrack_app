import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/deal_model.dart';

class DealsService {
  final http.Client _client;

  DealsService({http.Client? client}) : _client = client ?? http.Client();

  final Map<String, String> _headers = const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Fetch Flash Deals (api/v1/ecommerce/flash-deals)
  Future<List<FlashDealModel>> getFlashDeals({
    int? activeOnly = 1,
    String? domain,
    int? featured,
    String? search,
    int withProducts = 1,
    int productsLimit = 10,
    int page = 1,
    int perPage = 20,
  }) async {
    String url = '$ecomBaseUrl$ecomFlashDealsEndpoint';
    final queryParams = <String, String>{};
    if (activeOnly != null) queryParams['active_only'] = activeOnly.toString();
    if (domain != null && domain.isNotEmpty) queryParams['domain'] = domain;
    if (featured != null) queryParams['featured'] = featured.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    queryParams['with_products'] = withProducts.toString();
    queryParams['products_limit'] = productsLimit.toString();
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
              .map((item) =>
                  FlashDealModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      } else {
        debugPrint(
            'DealsService getFlashDeals Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('DealsService getFlashDeals Exception: $e');
    }
    return [];
  }

  /// Fetch Deal of the Day (api/v1/ecommerce/deal-of-the-day)
  Future<List<DealOfTheDayModel>> getDealOfTheDay({
    String? search,
    String? domain,
    int? categoryId,
    int? brandId,
    double? minPrice,
    double? maxPrice,
  }) async {
    String url = '$ecomBaseUrl$ecomDealOfTheDayEndpoint';
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (domain != null && domain.isNotEmpty) queryParams['domain'] = domain;
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (brandId != null) queryParams['brand_id'] = brandId.toString();
    if (minPrice != null) queryParams['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();

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
                  DealOfTheDayModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      } else {
        debugPrint(
            'DealsService getDealOfTheDay Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('DealsService getDealOfTheDay Exception: $e');
    }
    return [];
  }

  /// Fetch Featured Deals (api/v1/ecommerce/featured_deals)
  Future<List<FlashDealModel>> getFeaturedDeals({
    String? search,
    String? domain,
    int? categoryId,
    int? brandId,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int perPage = 20,
  }) async {
    String url = '$ecomBaseUrl$ecomFeaturedDealsEndpoint';
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (domain != null && domain.isNotEmpty) queryParams['domain'] = domain;
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (brandId != null) queryParams['brand_id'] = brandId.toString();
    if (minPrice != null) queryParams['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
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
                  FlashDealModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      } else {
        debugPrint(
            'DealsService getFeaturedDeals Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('DealsService getFeaturedDeals Exception: $e');
    }
    return [];
  }
}
