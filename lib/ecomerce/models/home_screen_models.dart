import 'brand_model.dart';
import 'category_model.dart';
import 'product_model.dart';
import 'store_model.dart';

class ApiProductModel {
  final int id;
  final int? shopId;
  final String name;
  final String? slug;
  final String? thumbnail;
  final double unitPrice;
  final double? discount;
  final String? discountType;
  final double? discountPercent;
  final double? discountedPrice;
  final double? finalPrice;
  final String? formattedOriginalPrice;
  final String? formattedDiscountedPrice;
  final double? rating;
  final int? reviewsCount;
  final int? currentStock;
  final BrandModel? brand;
  final StoreModel? store;
  final bool? isInstantDelivery;
  final String? badge;
  final CategoryModel? category;
  final String? variant;
  final String? color;
  final Map<String, dynamic>? choices;
  final double? tax;
  final String? taxType;

  ApiProductModel({
    required this.id,
    this.shopId,
    required this.name,
    this.slug,
    this.thumbnail,
    required this.unitPrice,
    this.discount,
    this.discountType,
    this.discountPercent,
    this.discountedPrice,
    this.finalPrice,
    this.formattedOriginalPrice,
    this.formattedDiscountedPrice,
    this.rating,
    this.reviewsCount,
    this.currentStock,
    this.brand,
    this.store,
    this.isInstantDelivery,
    this.badge,
    this.category,
    this.variant,
    this.color,
    this.choices,
    this.tax,
    this.taxType,
  });

  factory ApiProductModel.fromJson(Map<String, dynamic> json) {
    final double unit = (json['unit_price'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        0.0;
    final double? disc = (json['discount'] as num?)?.toDouble() ??
        (json['discount_amount'] as num?)?.toDouble();
    final double? fPrice = (json['final_price'] as num?)?.toDouble() ??
        (json['discounted_price'] as num?)?.toDouble();

    CategoryModel? catModel;
    if (json['category'] != null && json['category'] is Map) {
      catModel = CategoryModel.fromJson(
          Map<String, dynamic>.from(json['category'] as Map));
    } else if (json['categories'] is List && (json['categories'] as List).isNotEmpty) {
      final first = (json['categories'] as List).first;
      if (first is Map) {
        catModel = CategoryModel.fromJson(Map<String, dynamic>.from(first));
      }
    } else if (json['category_ids'] is List && (json['category_ids'] as List).isNotEmpty) {
      final first = (json['category_ids'] as List).first;
      if (first is Map) {
        final cId = int.tryParse(first['id']?.toString() ?? '') ?? 0;
        if (cId > 0) {
          catModel = CategoryModel(
            id: cId,
            name: first['name']?.toString() ?? 'Category',
            slug: first['slug']?.toString() ?? '',
          );
        }
      }
    }

    if (catModel == null &&
        (json['category_id'] != null || json['category_name'] != null)) {
      final cId = json['category_id'] is int
          ? json['category_id'] as int
          : int.tryParse(json['category_id']?.toString() ?? '');
      if (cId != null && cId > 0) {
        catModel = CategoryModel(
          id: cId,
          name: json['category_name']?.toString() ?? 'Category',
          slug: json['category_slug']?.toString() ?? '',
          categoryType: json['category_type']?.toString(),
        );
      }
    }

    return ApiProductModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      shopId: json['shop_id'] is int
          ? json['shop_id']
          : int.tryParse(json['shop_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      unitPrice: unit,
      discount: disc,
      discountType: json['discount_type']?.toString(),
      discountPercent: (json['discount_percent'] as num?)?.toDouble(),
      discountedPrice: fPrice ?? (disc != null && disc > 0 ? (unit - disc) : null),
      finalPrice: fPrice,
      formattedOriginalPrice: json['formatted_original_price']?.toString(),
      formattedDiscountedPrice: json['formatted_discounted_price']?.toString(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewsCount: json['reviews_count'] is int
          ? json['reviews_count']
          : int.tryParse(json['reviews_count']?.toString() ?? ''),
      currentStock: json['current_stock'] is int
          ? json['current_stock']
          : int.tryParse(json['current_stock']?.toString() ?? ''),
      brand: json['brand'] is Map<String, dynamic>
          ? BrandModel.fromJson(json['brand'])
          : null,
      store: json['store'] is Map<String, dynamic>
          ? StoreModel.fromJson(json['store'])
          : null,
      isInstantDelivery: json['is_instant_delivery'] == 1 ||
          json['is_instant_delivery'] == true,
      badge: json['badge']?.toString(),
      category: catModel,
      variant: json['variant']?.toString() ?? json['variation']?.toString(),
      color: json['color']?.toString(),
      choices: json['choices'] is Map
          ? Map<String, dynamic>.from(json['choices'])
          : null,
      tax: (json['tax'] as num?)?.toDouble() ?? 18.0,
      taxType: json['tax_type']?.toString() ?? 'percent',
    );
  }

  bool get isFood {
    if (category != null && category!.isFood) return true;
    final catType = (category?.categoryType ?? '').toLowerCase();
    if (catType == 'food') return true;
    final catName = (category?.name ?? '').toLowerCase();
    final catSlug = (category?.slug ?? '').toLowerCase();
    if (catName.contains('food') ||
        catName.contains('restaurant') ||
        catName.contains('dining') ||
        catName.contains('grocery') ||
        catSlug.contains('food') ||
        catSlug.contains('restaurant') ||
        catSlug.contains('grocery')) {
      return true;
    }
    final nameLower = name.toLowerCase();
    const foodKeywords = [
      'paneer', 'pizza', 'burger', 'sandwich', 'biryani', 'masala',
      'dal ', 'roti', 'naan', 'curry', 'chicken butter', 'thali',
      'noodles', 'fried rice', 'dosa', 'idli', 'samosa', 'momo',
      'beverage', 'shake', 'juice', 'coffee', 'tea'
    ];
    for (final kw in foodKeywords) {
      if (nameLower.contains(kw)) return true;
    }
    return false;
  }

  ProductModel toProductModel({String? overrideDomain}) {
    final double? effectiveDiscountedPrice = finalPrice ?? discountedPrice;
    final bool hasDiscount =
        (effectiveDiscountedPrice != null && effectiveDiscountedPrice < unitPrice) ||
            (discount != null && discount! > 0) ||
            (discountPercent != null && discountPercent! > 0);

    final double? calculatedDiscountAmount = (discount != null && discount! > 0)
        ? discount
        : (hasDiscount && effectiveDiscountedPrice != null)
            ? (unitPrice - effectiveDiscountedPrice)
            : null;

    final int? calculatedPercent = discountPercent?.round() ??
        (discountType == 'percent'
            ? discount?.round()
            : (unitPrice > 0 && calculatedDiscountAmount != null
                ? ((calculatedDiscountAmount / unitPrice) * 100).round()
                : null));

    return ProductModel(
      id: id,
      image: (thumbnail != null &&
              thumbnail!.isNotEmpty &&
              !thumbnail!.contains('imgur.com'))
          ? thumbnail!
          : '',
      brandName: brand?.name ?? (store?.name ?? 'Official Brand'),
      title: name,
      price: unitPrice,
      priceAfetDiscount: hasDiscount ? effectiveDiscountedPrice : null,
      dicountpercent: calculatedPercent,
      discountAmount: calculatedDiscountAmount,
      storeName: store?.name,
      storeDomain: (overrideDomain != null && overrideDomain.trim().isNotEmpty)
          ? overrideDomain.trim()
          : ((store?.domain != null && store!.domain!.trim().isNotEmpty)
              ? store!.domain!.trim()
              : 'e-team-12'),
      shopId: shopId ?? store?.shopId ?? 1,
      storeId: store?.id,
      storeSlug: store?.slug,
      variant: variant,
      color: color,
      choices: choices,
      categoryId: category?.id,
      categoryName: category?.name,
      categorySlug: category?.slug,
      categoryType: category?.categoryType,
      tax: tax ?? 18.0,
      taxType: taxType ?? 'percent',
    );
  }
}

class FlashDealCountdown {
  final String? targetTime;
  final int remainingSeconds;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final bool isExpired;

  FlashDealCountdown({
    this.targetTime,
    this.remainingSeconds = 0,
    this.days = 0,
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
    this.isExpired = false,
  });

  factory FlashDealCountdown.fromJson(Map<String, dynamic> json) {
    return FlashDealCountdown(
      targetTime: json['target_time']?.toString(),
      remainingSeconds: (json['remaining_seconds'] as num?)?.toInt() ?? 0,
      days: (json['days'] as num?)?.toInt() ?? 0,
      hours: (json['hours'] as num?)?.toInt() ?? 0,
      minutes: (json['minutes'] as num?)?.toInt() ?? 0,
      seconds: (json['seconds'] as num?)?.toInt() ?? 0,
      isExpired: json['is_expired'] as bool? ?? false,
    );
  }
}

class FlashDealModel {
  final int id;
  final String? title;
  final String? slug;
  final String? banner;
  final String? startDate;
  final String? endDate;
  final FlashDealCountdown? countdown;
  final int? productsCount;

  FlashDealModel({
    required this.id,
    this.title,
    this.slug,
    this.banner,
    this.startDate,
    this.endDate,
    this.countdown,
    this.productsCount,
  });

  factory FlashDealModel.fromJson(Map<String, dynamic> json) {
    return FlashDealModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString(),
      slug: json['slug']?.toString(),
      banner: json['banner']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      countdown: json['countdown'] is Map<String, dynamic>
          ? FlashDealCountdown.fromJson(json['countdown'])
          : null,
      productsCount: json['products_count'] is int
          ? json['products_count']
          : int.tryParse(json['products_count']?.toString() ?? ''),
    );
  }
}

class TopSellerModel {
  final int id;
  final int? sellerId;
  final String name;
  final String? slug;
  final String? banner;
  final String? logo;
  final double? rating;
  final String? ratingFormatted;
  final int? reviewsCount;
  final int? productsCount;
  final int? ordersCount;
  final bool? isInhouse;

  TopSellerModel({
    required this.id,
    this.sellerId,
    required this.name,
    this.slug,
    this.banner,
    this.logo,
    this.rating,
    this.ratingFormatted,
    this.reviewsCount,
    this.productsCount,
    this.ordersCount,
    this.isInhouse,
  });

  factory TopSellerModel.fromJson(Map<String, dynamic> json) {
    return TopSellerModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      sellerId: json['seller_id'] is int
          ? json['seller_id']
          : int.tryParse(json['seller_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      banner: json['banner']?.toString(),
      logo: json['logo']?.toString(),
      rating: (json['rating'] as num?)?.toDouble(),
      ratingFormatted: json['rating_formatted']?.toString(),
      reviewsCount: json['reviews_count'] is int
          ? json['reviews_count']
          : int.tryParse(json['reviews_count']?.toString() ?? ''),
      productsCount: json['products_count'] is int
          ? json['products_count']
          : int.tryParse(json['products_count']?.toString() ?? ''),
      ordersCount: json['orders_count'] is int
          ? json['orders_count']
          : int.tryParse(json['orders_count']?.toString() ?? ''),
      isInhouse: json['is_inhouse'] as bool?,
    );
  }
}
