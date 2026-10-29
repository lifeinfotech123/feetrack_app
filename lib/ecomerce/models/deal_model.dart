import '../constants.dart';
import 'product_model.dart';


class DealStoreModel {
  final int id;
  final String name;
  final String slug;
  final String domain;

  DealStoreModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.domain,
  });

  factory DealStoreModel.fromJson(Map<String, dynamic> json) {
    return DealStoreModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      domain: json['domain']?.toString() ?? '',
    );
  }
}

class DealProductModel {
  final int id;
  final String name;
  final String slug;
  final String? code;
  final double originalPrice;
  final double dealPrice;
  final double discount;
  final String discountType;
  final double discountAmount;
  final int currentStock;
  final bool inStock;
  final String? thumbnail;
  final String? categoryName;
  final String? brandName;
  final int isFood;
  final String? foodType;
  final String? storeName;
  final String? storeDomain;

  DealProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.code,
    required this.originalPrice,
    required this.dealPrice,
    required this.discount,
    required this.discountType,
    required this.discountAmount,
    required this.currentStock,
    required this.inStock,
    this.thumbnail,
    this.categoryName,
    this.brandName,
    this.isFood = 0,
    this.foodType,
    this.storeName,
    this.storeDomain,
  });

  factory DealProductModel.fromJson(Map<String, dynamic> json,
      {String? storeName, String? storeDomain}) {
    return DealProductModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      code: json['code']?.toString(),
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0.0,
      dealPrice: (json['deal_price'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discount_type']?.toString() ?? 'flat',
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      currentStock: json['current_stock'] is int
          ? json['current_stock']
          : int.tryParse(json['current_stock']?.toString() ?? '0') ?? 0,
      inStock: json['in_stock'] == true || json['in_stock'] == 1,
      thumbnail: json['thumbnail']?.toString(),
      categoryName: json['category_name']?.toString(),
      brandName: json['brand_name']?.toString(),
      isFood: json['is_food'] is int
          ? json['is_food']
          : int.tryParse(json['is_food']?.toString() ?? '0') ?? 0,
      foodType: json['food_type']?.toString(),
      storeName: storeName,
      storeDomain: storeDomain,
    );
  }

  ProductModel toProductModel() {
    final int percent = originalPrice > 0
        ? (((originalPrice - dealPrice) / originalPrice) * 100).round()
        : 0;

    return ProductModel(
      id: id,
      image: (thumbnail != null &&
              thumbnail!.isNotEmpty &&
              !thumbnail!.contains('imgur.com'))
          ? thumbnail!
          : '',
      brandName: brandName ?? storeName ?? "Special Deal",
      title: name,
      price: originalPrice > 0 ? originalPrice : dealPrice,
      priceAfetDiscount: dealPrice,
      dicountpercent: percent > 0 ? percent : null,
      discountAmount: discountAmount,
      storeName: storeName,
      storeDomain: storeDomain ?? 'e-team-12',
      shopId: 1,
    );
  }
}

class FlashDealModel {
  final int id;
  final String title;
  final String slug;
  final String? startDate;
  final String? endDate;
  final bool isActive;
  final int secondsRemaining;
  final int featured;
  final String? backgroundColor;
  final String? textColor;
  final String? banner;
  final String? dealType;
  final int totalProducts;
  final List<DealProductModel> products;
  final DealStoreModel? store;

  FlashDealModel({
    required this.id,
    required this.title,
    required this.slug,
    this.startDate,
    this.endDate,
    required this.isActive,
    required this.secondsRemaining,
    required this.featured,
    this.backgroundColor,
    this.textColor,
    this.banner,
    this.dealType,
    required this.totalProducts,
    required this.products,
    this.store,
  });

  factory FlashDealModel.fromJson(Map<String, dynamic> json) {
    DealStoreModel? storeModel;
    if (json['store'] is Map<String, dynamic>) {
      storeModel = DealStoreModel.fromJson(json['store']);
    }

    final storeName = storeModel?.name;
    final storeDomain = storeModel?.domain;
    final List<DealProductModel> productList = [];
    if (json['products'] is List) {
      for (var item in json['products']) {
        if (item is Map<String, dynamic>) {
          productList.add(DealProductModel.fromJson(item,
              storeName: storeName, storeDomain: storeDomain));
        }
      }
    }

    return FlashDealModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'Flash Deal',
      slug: json['slug']?.toString() ?? '',
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      secondsRemaining: json['seconds_remaining'] is int
          ? json['seconds_remaining']
          : int.tryParse(json['seconds_remaining']?.toString() ?? '0') ?? 0,
      featured: json['featured'] is int
          ? json['featured']
          : int.tryParse(json['featured']?.toString() ?? '0') ?? 0,
      backgroundColor: json['background_color']?.toString(),
      textColor: json['text_color']?.toString(),
      banner: json['banner']?.toString(),
      dealType: json['deal_type']?.toString(),
      totalProducts: json['total_products'] is int
          ? json['total_products']
          : int.tryParse(json['total_products']?.toString() ?? '0') ?? productList.length,
      products: productList,
      store: storeModel,
    );
  }
}

class DealOfTheDayModel {
  final int id;
  final String title;
  final String dealType;
  final double dealPrice;
  final double discount;
  final String discountType;
  final double discountAmount;
  final DealProductModel? product;
  final DealStoreModel? store;

  DealOfTheDayModel({
    required this.id,
    required this.title,
    required this.dealType,
    required this.dealPrice,
    required this.discount,
    required this.discountType,
    required this.discountAmount,
    this.product,
    this.store,
  });

  factory DealOfTheDayModel.fromJson(Map<String, dynamic> json) {
    DealStoreModel? storeModel;
    if (json['store'] is Map<String, dynamic>) {
      storeModel = DealStoreModel.fromJson(json['store']);
    }

    DealProductModel? productModel;
    if (json['product'] is Map<String, dynamic>) {
      productModel = DealProductModel.fromJson(
        json['product'],
        storeName: storeModel?.name,
        storeDomain: storeModel?.domain,
      );
    }

    return DealOfTheDayModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'Deal of the Day',
      dealType: json['deal_type']?.toString() ?? 'deal_of_the_day',
      dealPrice: (json['deal_price'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discount_type']?.toString() ?? 'flat',
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      product: productModel,
      store: storeModel,
    );
  }
}
