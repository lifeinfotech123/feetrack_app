import 'category_model.dart';

class BrandStoreModel {
  final int id;
  final String name;
  final String? domain;
  final int productsCount;

  BrandStoreModel({
    required this.id,
    required this.name,
    this.domain,
    this.productsCount = 0,
  });

  factory BrandStoreModel.fromJson(Map<String, dynamic> json) {
    return BrandStoreModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      domain: json['domain']?.toString(),
      productsCount: (json['products_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class BrandModel {
  final int? id;
  final String name;
  final String? slug;
  final String? image;
  final int? productsCount;
  final int? storesCount;
  final List<BrandStoreModel>? availableInStores;

  BrandModel({
    this.id,
    required this.name,
    this.slug,
    this.image,
    this.productsCount,
    this.storesCount,
    this.availableInStores,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    final storesJson = json['available_in_stores'];
    List<BrandStoreModel>? stores;
    if (storesJson is List) {
      stores = storesJson
          .map((e) => BrandStoreModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return BrandModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      image: json['image']?.toString() ?? json['logo_image']?.toString(),
      productsCount: json['products_count'] is int
          ? json['products_count']
          : (json['total_products'] is int
              ? json['total_products']
              : int.tryParse(json['products_count']?.toString() ??
                  json['total_products']?.toString() ??
                  '')),
      storesCount: json['stores_count'] is int
          ? json['stores_count']
          : int.tryParse(json['stores_count']?.toString() ?? ''),
      availableInStores: stores,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'image': image,
      'products_count': productsCount,
      'stores_count': storesCount,
    };
  }

  /// Merges two brand entries sharing the same brand name, preserving valid image,
  /// combined products count, and the cleaner slug.
  BrandModel mergeWith(BrandModel other) {
    final bool thisHasImg = image != null && image!.trim().isNotEmpty;
    final bool otherHasImg =
        other.image != null && other.image!.trim().isNotEmpty;
    final String? bestImg =
        thisHasImg ? image : (otherHasImg ? other.image : null);

    final int c1 = productsCount ?? 0;
    final int c2 = other.productsCount ?? 0;
    final int? totalCount =
        (c1 + c2 > 0) ? (c1 + c2) : (productsCount ?? other.productsCount);

    final int s1 = storesCount ?? 0;
    final int s2 = other.storesCount ?? 0;
    final int? totalStores =
        (s1 + s2 > 0) ? (s1 + s2) : (storesCount ?? other.storesCount);

    final String? bestSlug =
        (slug != null && slug!.trim().isNotEmpty && !slug!.contains('-'))
            ? slug
            : (other.slug != null && other.slug!.trim().isNotEmpty
                ? other.slug
                : slug);

    return BrandModel(
      id: id ?? other.id,
      name: name.isNotEmpty ? name : other.name,
      slug: bestSlug,
      image: bestImg,
      productsCount: totalCount,
      storesCount: totalStores,
      availableInStores: [
        if (availableInStores != null) ...availableInStores!,
        if (other.availableInStores != null) ...other.availableInStores!,
      ],
    );
  }

  /// Deduplicates a collection of brands by normalized brand name.
  static List<BrandModel> deduplicate(Iterable<BrandModel> list) {
    final Map<String, BrandModel> map = {};
    for (final b in list) {
      final key = b.name.trim().toLowerCase();
      if (key.isEmpty) continue;
      if (map.containsKey(key)) {
        map[key] = map[key]!.mergeWith(b);
      } else {
        map[key] = b;
      }
    }
    return map.values.toList();
  }
}

class BrandProductModel {
  final int? id;
  final String name;
  final String? slug;
  final String? thumbnail;
  final double unitPrice;
  final double? purchasePrice;
  final double? discount;
  final String? discountType;
  final int? currentStock;
  final double? rating;
  final int? reviewsCount;
  final int? categoryId;

  BrandProductModel({
    this.id,
    required this.name,
    this.slug,
    this.thumbnail,
    required this.unitPrice,
    this.purchasePrice,
    this.discount,
    this.discountType,
    this.currentStock,
    this.rating,
    this.reviewsCount,
    this.categoryId,
  });

  factory BrandProductModel.fromJson(Map<String, dynamic> json) {
    return BrandProductModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      thumbnail: json['thumbnail']?.toString() ?? json['image']?.toString(),
      unitPrice: (json['unit_price'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          0.0,
      purchasePrice: (json['purchase_price'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      discountType: json['discount_type']?.toString(),
      currentStock: json['current_stock'] is int
          ? json['current_stock']
          : int.tryParse(json['current_stock']?.toString() ?? ''),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewsCount: json['reviews_count'] is int
          ? json['reviews_count']
          : int.tryParse(json['reviews_count']?.toString() ?? ''),
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id']?.toString() ?? ''),
    );
  }

  double get priceAfterDiscount {
    if (discount == null || discount! <= 0) return unitPrice;
    if (discountType == 'percent') {
      return unitPrice - (unitPrice * discount! / 100);
    } else {
      return (unitPrice - discount!).clamp(0, double.infinity);
    }
  }

  int? get discountPercent {
    if (discount == null || discount! <= 0) return null;
    if (discountType == 'percent') {
      return discount!.round();
    } else if (unitPrice > 0) {
      return ((discount! / unitPrice) * 100).round();
    }
    return null;
  }
}

class BrandDetailModel {
  final BrandModel brand;
  final List<CategoryModel> categories;
  final List<BrandProductModel> products;

  BrandDetailModel({
    required this.brand,
    required this.categories,
    required this.products,
  });

  factory BrandDetailModel.fromJson(Map<String, dynamic> json) {
    final brandJson = json['brand'] as Map<String, dynamic>? ?? {};
    final categoriesJson = json['categories'] as List? ?? [];
    final productsJson = json['products'] as List? ?? [];

    return BrandDetailModel(
      brand: BrandModel.fromJson(brandJson),
      categories: categoriesJson
          .map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      products: productsJson
          .map((p) => BrandProductModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
