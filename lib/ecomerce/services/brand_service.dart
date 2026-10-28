import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';

class BrandService {
  final http.Client _client;

  BrandService({http.Client? client}) : _client = client ?? http.Client();

  final Map<String, String> _headers = const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Fetch all brands from live API (api/v1/ecommerce/brands)
  Future<List<BrandModel>> getBrands({
    String? domain,
    String? search,
    int? hasProducts,
    String? sortBy,
    String? order,
    int page = 1,
    int perPage = 20,
  }) async {
    String url = '$ecomBaseUrl$ecomBrandsEndpoint';
    final queryParams = <String, String>{};
    if (domain != null && domain.isNotEmpty) queryParams['domain'] = domain;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (hasProducts != null) {
      queryParams['has_products'] = hasProducts.toString();
    }
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sort_by'] = sortBy;
    if (order != null && order.isNotEmpty) queryParams['order'] = order;
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
          final liveList = list
              .map((item) => BrandModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          if (liveList.isNotEmpty) {
            return liveList;
          }
        }
      } else {
        debugPrint('BrandService getBrands Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('BrandService getBrands Exception: $e');
    }
    return _fallbackBrands;
  }

  static List<BrandModel> get _fallbackBrands => [
      BrandModel(
        id: 1,
        name: "Nike",
        slug: "nike",
        image: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=85",
        productsCount: 48,
      ),
      BrandModel(
        id: 2,
        name: "Zara",
        slug: "zara",
        image: "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=800&q=85",
        productsCount: 65,
      ),
      BrandModel(
        id: 3,
        name: "Adidas",
        slug: "adidas",
        image: "https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?auto=format&fit=crop&w=800&q=85",
        productsCount: 52,
      ),
      BrandModel(
        id: 4,
        name: "Levi's",
        slug: "levis",
        image: "https://images.unsplash.com/photo-1582552938357-32b906df40cb?auto=format&fit=crop&w=800&q=85",
        productsCount: 38,
      ),
      BrandModel(
        id: 5,
        name: "H&M",
        slug: "hm",
        image: "https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?auto=format&fit=crop&w=800&q=85",
        productsCount: 74,
      ),
      BrandModel(
        id: 6,
        name: "Puma",
        slug: "puma",
        image: "https://images.unsplash.com/photo-1608231387042-66d1773070a5?auto=format&fit=crop&w=800&q=85",
        productsCount: 42,
      ),
    ];

  /// Fetch brand details (brand info, categories, products) by slug
  Future<BrandDetailModel?> getBrandDetails(String slug) async {
    final allBrands = await getBrands();
    BrandModel brand;
    try {
      brand = allBrands.firstWhere(
        (b) =>
            b.slug == slug ||
            b.name.toLowerCase() == slug.toLowerCase(),
      );
    } catch (_) {
      brand = allBrands.first;
    }

    final categories = [
      CategoryModel(id: 0, name: "All", slug: "all"),
      CategoryModel(id: 1, name: "Footwear", slug: "footwear"),
      CategoryModel(id: 2, name: "Apparel", slug: "apparel"),
      CategoryModel(id: 3, name: "Accessories", slug: "accessories"),
    ];

    final products = [
      BrandProductModel(
        id: 101,
        name: "${brand.name} Pro Sport Edition",
        slug: "${brand.slug}-pro-sport",
        thumbnail: "https://i.imgur.com/CGCyp1d.png",
        unitPrice: 540.0,
        discount: 120.0,
        discountType: "amount",
        rating: 4.8,
        reviewsCount: 120,
        currentStock: 25,
        categoryId: 1,
      ),
      BrandProductModel(
        id: 102,
        name: "${brand.name} Classic Streetwear",
        slug: "${brand.slug}-classic-streetwear",
        thumbnail: "https://i.imgur.com/q9oF9Yq.png",
        unitPrice: 800.0,
        rating: 4.5,
        reviewsCount: 95,
        currentStock: 18,
        categoryId: 2,
      ),
      BrandProductModel(
        id: 103,
        name: "${brand.name} Air Flow Performance",
        slug: "${brand.slug}-air-flow",
        thumbnail: "https://i.imgur.com/MsppAcx.png",
        unitPrice: 650.62,
        discount: 40.0,
        discountType: "percent",
        rating: 4.9,
        reviewsCount: 230,
        currentStock: 40,
        categoryId: 1,
      ),
      BrandProductModel(
        id: 104,
        name: "${brand.name} Urban Casual Fit",
        slug: "${brand.slug}-urban-casual",
        thumbnail: "https://i.imgur.com/JfyZlnO.png",
        unitPrice: 1264.0,
        discount: 5.0,
        discountType: "percent",
        rating: 4.6,
        reviewsCount: 65,
        currentStock: 12,
        categoryId: 2,
      ),
      BrandProductModel(
        id: 105,
        name: "${brand.name} Essential Cap & Gear",
        slug: "${brand.slug}-essential-gear",
        thumbnail: "https://i.imgur.com/tXyOMMG.png",
        unitPrice: 350.0,
        discount: 15.0,
        discountType: "percent",
        rating: 4.7,
        reviewsCount: 88,
        currentStock: 50,
        categoryId: 3,
      ),
    ];

    return BrandDetailModel(
      brand: brand,
      categories: categories,
      products: products,
    );
  }
}
