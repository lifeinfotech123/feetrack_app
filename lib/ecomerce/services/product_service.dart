import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/home_screen_models.dart';
import '../models/product_variant_model.dart';

class ProductService {
  final http.Client _client;

  ProductService({http.Client? client}) : _client = client ?? http.Client();

  final Map<String, String> _headers = const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Fetch Products with rich filters (api/v1/ecommerce/products)
  Future<List<ApiProductModel>> getProducts({
    String? domain,
    String? search,
    String? category,
    int? categoryId,
    int? subCategoryId,
    String? brand,
    int? brandId,
    double? minPrice,
    double? maxPrice,
    int? isFood,
    String? foodType,
    int? isRecommended,
    int? featured,
    int? inStock,
    int? isInstantDelivery,
    double? latitude,
    double? longitude,
    String? sortBy,
    int? storeId,
    int? shopId,
    int page = 1,
    int perPage = 20,
  }) async {
    String url = '$ecomBaseUrl$ecomProductsEndpoint';
    final queryParams = <String, String>{};
    if (domain != null && domain.isNotEmpty) queryParams['domain'] = domain;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (subCategoryId != null) {
      queryParams['sub_category_id'] = subCategoryId.toString();
    }
    if (brand != null && brand.isNotEmpty) queryParams['brand'] = brand;
    if (brandId != null) queryParams['brand_id'] = brandId.toString();
    if (minPrice != null) queryParams['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
    if (isFood != null) queryParams['is_food'] = isFood.toString();
    if (foodType != null && foodType.isNotEmpty) {
      queryParams['food_type'] = foodType;
    }
    if (isRecommended != null) {
      queryParams['is_recommended'] = isRecommended.toString();
    }
    if (featured != null) queryParams['featured'] = featured.toString();
    if (inStock != null) queryParams['in_stock'] = inStock.toString();
    if (isInstantDelivery != null) {
      queryParams['is_instant_delivery'] = isInstantDelivery.toString();
    }
    if (latitude != null) queryParams['latitude'] = latitude.toString();
    if (longitude != null) queryParams['longitude'] = longitude.toString();
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sort_by'] = sortBy;
    if (storeId != null) queryParams['store_id'] = storeId.toString();
    if (shopId != null) queryParams['shop_id'] = shopId.toString();
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
                  ApiProductModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      } else {
        debugPrint(
            'ProductService getProducts Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ProductService getProducts Exception: $e');
    }
    return [];
  }

  /// Fetch Product Variants (api/v1/ecommerce/products/variants?product_id={id})
  Future<ProductVariantDetailsModel?> getProductVariants(
    int productId, {
    String? domain,
  }) async {
    String url =
        '$ecomBaseUrl$ecomProductVariantsEndpoint?product_id=$productId';
    if (domain != null && domain.isNotEmpty) {
      url = '$url&domain=$domain';
    }

    try {
      final response = await _client.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] is Map<String, dynamic>) {
          return ProductVariantDetailsModel.fromJson(data['data']);
        }
      } else {
        debugPrint(
            'ProductService getProductVariants Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('ProductService getProductVariants Exception: $e');
    }
    return null;
  }
}
