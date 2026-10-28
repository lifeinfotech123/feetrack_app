import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/category_model.dart';

class CategoryService {
  final http.Client _client;

  CategoryService({http.Client? client}) : _client = client ?? http.Client();

  final Map<String, String> _headers = const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Fetch all categories from live API (api/v1/ecommerce/categories)
  Future<List<CategoryModel>> getCategories({
    String? store,
    String? domain,
    String? categoryType,
  }) async {
    String url = '$ecomBaseUrl$ecomCategoriesEndpoint';
    final queryParams = <String, String>{};
    if (store != null && store.isNotEmpty) queryParams['store'] = store;
    if (domain != null && domain.isNotEmpty) queryParams['domain'] = domain;
    if (queryParams.isNotEmpty) {
      url = '$url?${Uri(queryParameters: queryParams).query}';
    }

    try {
      final response = await _client.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List list = data['data'];
          List<CategoryModel> liveList = list
              .map((item) =>
                  CategoryModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();

          if (categoryType != null && categoryType.isNotEmpty && categoryType.toLowerCase() != 'all') {
            final typeLower = categoryType.toLowerCase();
            liveList = liveList.where((cat) {
              final catType = (cat.categoryType ?? '').toLowerCase();
              return catType == typeLower;
            }).toList();
          }

          if (liveList.isNotEmpty) {
            return liveList;
          }
        }
      } else {
        debugPrint('CategoryService getCategories Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('CategoryService getCategories Exception: $e');
    }
    return _filterFallback(categoryType);
  }

  /// Get deduplicated categories by slug/name for clean presentation
  Future<List<CategoryModel>> getUniqueCategories({
    String? store,
    String? domain,
    String? categoryType,
  }) async {
    final list = await getCategories(
      store: store,
      domain: domain,
      categoryType: categoryType,
    );
    final seen = <String>{};
    final unique = <CategoryModel>[];
    for (final cat in list) {
      final key = (cat.slug ?? cat.name).toLowerCase().trim();
      if (!seen.contains(key)) {
        seen.add(key);
        unique.add(cat);
      }
    }
    return unique;
  }

  static List<CategoryModel> _filterFallback(String? categoryType) {
    if (categoryType == null || categoryType.isEmpty || categoryType.toLowerCase() == 'all') {
      return _fallbackCategories;
    }
    final typeLower = categoryType.toLowerCase();
    return _fallbackCategories
        .where((cat) => (cat.categoryType ?? '').toLowerCase() == typeLower)
        .toList();
  }

  static List<CategoryModel> get _fallbackCategories => [
      CategoryModel(
        id: 1,
        name: "On sale",
        slug: "on-sale",
        svgSrc: "assets/icons/Sale.svg",
        subCategories: [
          CategoryModel(
            id: 11,
            name: "All Clothing",
            slug: "all-clothing",
            subCategories: [
              CategoryModel(id: 111, name: "T-Shirts", slug: "t-shirts"),
              CategoryModel(id: 112, name: "Shirts", slug: "shirts"),
              CategoryModel(id: 113, name: "Pants", slug: "pants"),
            ],
          ),
          CategoryModel(
            id: 12,
            name: "New In",
            slug: "new-in",
            subCategories: [
              CategoryModel(
                id: 121,
                name: "Summer Collection",
                slug: "summer-collection",
              ),
              CategoryModel(
                id: 122,
                name: "Winter Wear",
                slug: "winter-wear",
              ),
            ],
          ),
          CategoryModel(id: 13, name: "Coats & Jackets", slug: "coats-jackets"),
          CategoryModel(id: 14, name: "Dresses", slug: "dresses"),
          CategoryModel(id: 15, name: "Jeans", slug: "jeans"),
        ],
      ),
      CategoryModel(
        id: 2,
        name: "Man's & Woman's",
        slug: "mans-womans",
        svgSrc: "assets/icons/Man&Woman.svg",
        subCategories: [
          CategoryModel(
            id: 21,
            name: "All Clothing",
            slug: "all-clothing-mw",
            subCategories: [
              CategoryModel(id: 211, name: "Men's Tops", slug: "mens-tops"),
              CategoryModel(id: 212, name: "Women's Tops", slug: "womens-tops"),
            ],
          ),
          CategoryModel(id: 22, name: "New In", slug: "new-in-mw"),
          CategoryModel(id: 23, name: "Coats & Jackets", slug: "coats-jackets-mw"),
        ],
      ),
      CategoryModel(
        id: 3,
        name: "Kids",
        slug: "kids",
        svgSrc: "assets/icons/Child.svg",
        subCategories: [
          CategoryModel(
            id: 31,
            name: "All Clothing",
            slug: "all-clothing-kids",
            subCategories: [
              CategoryModel(id: 311, name: "Boys", slug: "boys-clothing"),
              CategoryModel(id: 312, name: "Girls", slug: "girls-clothing"),
            ],
          ),
          CategoryModel(id: 32, name: "New In", slug: "new-in-kids"),
          CategoryModel(id: 33, name: "Coats & Jackets", slug: "coats-jackets-kids"),
        ],
      ),
      CategoryModel(
        id: 4,
        name: "Accessories",
        slug: "accessories",
        svgSrc: "assets/icons/Accessories.svg",
        subCategories: [
          CategoryModel(
            id: 41,
            name: "Bags & Wallets",
            slug: "bags-wallets",
            subCategories: [
              CategoryModel(id: 411, name: "Backpacks", slug: "backpacks"),
              CategoryModel(id: 412, name: "Handbags", slug: "handbags"),
            ],
          ),
          CategoryModel(
            id: 42,
            name: "Watches & Jewelry",
            slug: "watches-jewelry",
          ),
          CategoryModel(id: 43, name: "Belts & Hats", slug: "belts-hats"),
        ],
      ),
    ];

  /// Fetch single category details including subcategories & sub-sub-categories by slug
  Future<CategoryModel?> getCategoryDetails(String slug) async {
    final list = await getCategories();
    try {
      return list.firstWhere(
        (cat) =>
            cat.slug == slug ||
            cat.name.toLowerCase() == slug.toLowerCase(),
      );
    } catch (_) {
      return list.isNotEmpty ? list.first : null;
    }
  }
}
