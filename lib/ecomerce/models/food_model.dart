import 'product_model.dart';
import 'restaurant_model.dart';

class FoodHeroCmsModel {
  final String badgeText;
  final String titleMain;
  final String titleHighlight;
  final String subtitle;
  final String avgDelivery;
  final String topRated;
  final String liveTracking;

  FoodHeroCmsModel({
    required this.badgeText,
    required this.titleMain,
    required this.titleHighlight,
    required this.subtitle,
    required this.avgDelivery,
    required this.topRated,
    required this.liveTracking,
  });

  factory FoodHeroCmsModel.fromJson(Map<String, dynamic> json) {
    return FoodHeroCmsModel(
      badgeText: json['badge_text']?.toString() ?? "25-35 Mins Instant Food Delivery",
      titleMain: json['title_main']?.toString() ?? "Craving Something",
      titleHighlight: json['title_highlight']?.toString() ?? "Delicious?",
      subtitle: json['subtitle']?.toString() ?? "Order fresh, hot, and hygienic meals.",
      avgDelivery: json['avg_delivery']?.toString() ?? "30-40m",
      topRated: json['top_rated']?.toString() ?? "4.8+",
      liveTracking: json['live_tracking']?.toString() ?? "100%",
    );
  }
}

class CuisineModel {
  final int id;
  final String name;
  final String slug;
  final String? icon;
  final int dishesCount;
  final int? storeId;
  final String? storeSlug;
  final String? storeDomain;

  CuisineModel({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.dishesCount = 0,
    this.storeId,
    this.storeSlug,
    this.storeDomain,
  });

  factory CuisineModel.fromJson(Map<String, dynamic> json) {
    int? storeId;
    String? storeSlug;
    String? storeDomain;

    if (json['store'] is Map<String, dynamic>) {
      storeId = json['store']['id'] is int
          ? json['store']['id']
          : int.tryParse(json['store']['id']?.toString() ?? '');
      storeSlug = json['store']['slug']?.toString();
      storeDomain = json['store']['domain']?.toString();
    }

    return CuisineModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString(),
      dishesCount: json['dishes_count'] is int
          ? json['dishes_count']
          : int.tryParse(json['dishes_count']?.toString() ?? '0') ?? 0,
      storeId: storeId,
      storeSlug: storeSlug,
      storeDomain: storeDomain,
    );
  }
}

class FoodHomeDataModel {
  final FoodHeroCmsModel heroCms;
  final List<CuisineModel> cuisines;
  final List<RestaurantModel> restaurants;
  final int totalRestaurants;
  final int totalCuisines;

  FoodHomeDataModel({
    required this.heroCms,
    required this.cuisines,
    required this.restaurants,
    required this.totalRestaurants,
    required this.totalCuisines,
  });

  factory FoodHomeDataModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    FoodHeroCmsModel hero = FoodHeroCmsModel(
      badgeText: "25-35 Mins Instant Food Delivery",
      titleMain: "Craving Something",
      titleHighlight: "Delicious?",
      subtitle: "Order fresh, hot, and hygienic meals from the finest restaurants.",
      avgDelivery: "30-40m",
      topRated: "4.8+",
      liveTracking: "100%",
    );

    if (data['hero_cms'] is Map<String, dynamic>) {
      hero = FoodHeroCmsModel.fromJson(data['hero_cms']);
    }

    final List<CuisineModel> cuisinesList = [];
    if (data['cuisines'] is List) {
      for (var item in data['cuisines']) {
        if (item is Map<String, dynamic>) {
          cuisinesList.add(CuisineModel.fromJson(item));
        }
      }
    }

    final List<RestaurantModel> restaurantsList = [];
    if (data['restaurants'] is List) {
      for (var item in data['restaurants']) {
        if (item is Map<String, dynamic>) {
          restaurantsList.add(RestaurantModel.fromJson(item));
        }
      }
    }

    return FoodHomeDataModel(
      heroCms: hero,
      cuisines: cuisinesList,
      restaurants: restaurantsList,
      totalRestaurants: json['total_restaurants'] is int
          ? json['total_restaurants']
          : int.tryParse(json['total_restaurants']?.toString() ?? '0') ??
              restaurantsList.length,
      totalCuisines: json['total_cuisines'] is int
          ? json['total_cuisines']
          : int.tryParse(json['total_cuisines']?.toString() ?? '0') ??
              cuisinesList.length,
    );
  }
}

class DishVariantModel {
  final int id;
  final String name;
  final double price;
  final double promotionalPrice;
  final num? weightVolume;
  final String? weightUnit;
  final int? servingSize;
  final int? prepTimeMin;
  final String? sku;

  DishVariantModel({
    required this.id,
    required this.name,
    required this.price,
    required this.promotionalPrice,
    this.weightVolume,
    this.weightUnit,
    this.servingSize,
    this.prepTimeMin,
    this.sku,
  });

  factory DishVariantModel.fromJson(Map<String, dynamic> json) {
    return DishVariantModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      promotionalPrice: (json['promotional_price'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          0.0,
      weightVolume: json['weight_volume'] as num?,
      weightUnit: json['weight_unit']?.toString(),
      servingSize: json['serving_size'] is int
          ? json['serving_size']
          : int.tryParse(json['serving_size']?.toString() ?? ''),
      prepTimeMin: json['prep_time_min'] is int
          ? json['prep_time_min']
          : int.tryParse(json['prep_time_min']?.toString() ?? ''),
      sku: json['sku']?.toString(),
    );
  }
}

class DishModel {
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
  final bool isFood;
  final String foodType; // 'veg', 'non_veg'
  final int? categoryId;
  final String? categoryName;
  final String? categorySlug;
  final List<DishVariantModel> variants;
  final int? shopId;
  final String? domain;
  final String? storeName;
  final double rating;

  DishModel({
    required this.id,
    required this.name,
    required this.slug,
    this.code,
    required this.originalPrice,
    required this.dealPrice,
    this.discount = 0.0,
    this.discountType = 'flat',
    this.discountAmount = 0.0,
    this.currentStock = 100,
    this.inStock = true,
    this.thumbnail,
    this.isFood = true,
    this.foodType = 'veg',
    this.categoryId,
    this.categoryName,
    this.categorySlug,
    this.variants = const [],
    this.shopId,
    this.domain,
    this.storeName,
    this.rating = 4.8,
  });

  bool get isVeg =>
      foodType.toLowerCase() == 'veg' ||
      foodType.toLowerCase() == 'pure_veg' ||
      foodType.toLowerCase() == 'vegetarian';

  factory DishModel.fromJson(
    Map<String, dynamic> json, {
    String? defaultDomain,
    int? defaultShopId,
    String? defaultStoreName,
  }) {
    final origPrice = (json['original_price'] as num?)?.toDouble() ??
        (json['unit_price'] as num?)?.toDouble() ??
        (json['base_unit_price'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        0.0;
    final dlPrice = (json['deal_price'] as num?)?.toDouble() ??
        (json['final_price'] as num?)?.toDouble() ??
        (json['discounted_price'] as num?)?.toDouble() ??
        (json['price_after_discount'] as num?)?.toDouble() ??
        origPrice;

    int? catId;
    String? catName;
    String? catSlug;
    if (json['category'] is Map<String, dynamic>) {
      catId = json['category']['id'] is int
          ? json['category']['id']
          : int.tryParse(json['category']['id']?.toString() ?? '');
      catName = json['category']['name']?.toString();
      catSlug = json['category']['slug']?.toString();
    } else {
      catId = json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id']?.toString() ?? '');
      catName = json['category_name']?.toString();
      catSlug = json['category_slug']?.toString();
    }

    String? itemDomain = defaultDomain;
    int? itemShopId = defaultShopId;
    String? itemStoreName = defaultStoreName;

    if (json['store'] is Map<String, dynamic>) {
      itemDomain ??= json['store']['domain']?.toString();
      itemShopId ??= json['store']['shop_id'] is int
          ? json['store']['shop_id']
          : int.tryParse(json['store']['shop_id']?.toString() ?? '');
      itemStoreName ??= json['store']['name']?.toString();
    }
    itemShopId ??= json['shop_id'] is int
        ? json['shop_id']
        : int.tryParse(json['shop_id']?.toString() ?? '');
    itemDomain ??= json['domain']?.toString();

    final List<DishVariantModel> variantList = [];
    if (json['variants'] is List) {
      for (var v in json['variants']) {
        if (v is Map<String, dynamic>) {
          variantList.add(DishVariantModel.fromJson(v));
        }
      }
    }

    return DishModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      code: json['code']?.toString(),
      originalPrice: origPrice,
      dealPrice: dlPrice > 0 ? dlPrice : origPrice,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discount_type']?.toString() ?? 'flat',
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      currentStock: json['current_stock'] is int
          ? json['current_stock']
          : int.tryParse(json['current_stock']?.toString() ?? '100') ?? 100,
      inStock: json['in_stock'] == true ||
          json['in_stock'] == 1 ||
          (json['current_stock'] != 0),
      thumbnail: json['thumbnail']?.toString() ?? json['image']?.toString(),
      isFood: json['is_food'] == 1 || json['is_food'] == true,
      foodType: json['food_type']?.toString().toLowerCase() ?? 'veg',
      categoryId: catId,
      categoryName: catName,
      categorySlug: catSlug,
      variants: variantList,
      shopId: itemShopId,
      domain: itemDomain,
      storeName: itemStoreName,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
    );
  }

  ProductModel toProductModel({
    String? storeDomain,
    int? shopId,
    String? restaurantName,
  }) {
    final effectiveDomain = storeDomain ?? domain ?? 'e-team-12';
    final effectiveShopId = shopId ?? this.shopId ?? 2;
    final effectiveStoreName = restaurantName ?? storeName ?? 'Restaurant';

    int discountPercent = 0;
    if (originalPrice > dealPrice && originalPrice > 0) {
      discountPercent =
          (((originalPrice - dealPrice) / originalPrice) * 100).round();
    }

    return ProductModel(
      id: id,
      title: name,
      price: originalPrice,
      priceAfetDiscount: dealPrice,
      discountAmount: discountAmount > 0
          ? discountAmount
          : (originalPrice - dealPrice > 0 ? (originalPrice - dealPrice) : 0),
      dicountpercent: discountPercent,
      image: thumbnail ?? '',
      brandName: effectiveStoreName,
      storeName: effectiveStoreName,
      storeDomain: effectiveDomain,
      shopId: effectiveShopId,
      categoryId: categoryId,
      categoryName: categoryName,
      categorySlug: categorySlug,
      categoryType: 'food',
    );
  }
}

class CategoryMenuModel {
  final String categoryName;
  final int categoryId;
  final int dishesCount;
  final List<DishModel> items;

  CategoryMenuModel({
    required this.categoryName,
    required this.categoryId,
    required this.dishesCount,
    required this.items,
  });

  factory CategoryMenuModel.fromJson(
    Map<String, dynamic> json, {
    String? defaultDomain,
    int? defaultShopId,
    String? defaultStoreName,
  }) {
    final List<DishModel> dishes = [];
    if (json['items'] is List) {
      for (var item in json['items']) {
        if (item is Map<String, dynamic>) {
          dishes.add(DishModel.fromJson(
            item,
            defaultDomain: defaultDomain,
            defaultShopId: defaultShopId,
            defaultStoreName: defaultStoreName,
          ));
        }
      }
    }

    return CategoryMenuModel(
      categoryName: json['category_name']?.toString() ?? '',
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      dishesCount: json['dishes_count'] is int
          ? json['dishes_count']
          : int.tryParse(json['dishes_count']?.toString() ?? '0') ??
              dishes.length,
      items: dishes,
    );
  }
}

class RestaurantMenuData {
  final RestaurantModel? restaurant;
  final List<CategoryMenuModel> categoriesMenu;
  final List<DishModel> allDishes;
  final int totalDishes;

  RestaurantMenuData({
    this.restaurant,
    required this.categoriesMenu,
    required this.allDishes,
    required this.totalDishes,
  });

  factory RestaurantMenuData.fromJson(
    Map<String, dynamic> json, {
    RestaurantModel? fallbackRestaurant,
  }) {
    RestaurantModel? rest = fallbackRestaurant;
    if (json['restaurant'] is Map<String, dynamic>) {
      rest = RestaurantModel.fromJson(json['restaurant']);
    }

    final String? domain = rest?.domain;
    final int? shopId = rest?.shopId;
    final String? storeName = rest?.name;

    final List<CategoryMenuModel> catMenuList = [];
    if (json['categories_menu'] is List) {
      for (var item in json['categories_menu']) {
        if (item is Map<String, dynamic>) {
          catMenuList.add(CategoryMenuModel.fromJson(
            item,
            defaultDomain: domain,
            defaultShopId: shopId,
            defaultStoreName: storeName,
          ));
        }
      }
    }

    final List<DishModel> dishesList = [];
    if (json['all_dishes'] is List) {
      for (var item in json['all_dishes']) {
        if (item is Map<String, dynamic>) {
          dishesList.add(DishModel.fromJson(
            item,
            defaultDomain: domain,
            defaultShopId: shopId,
            defaultStoreName: storeName,
          ));
        }
      }
    } else {
      for (var cat in catMenuList) {
        dishesList.addAll(cat.items);
      }
    }

    return RestaurantMenuData(
      restaurant: rest,
      categoriesMenu: catMenuList,
      allDishes: dishesList,
      totalDishes: json['total_dishes'] is int
          ? json['total_dishes']
          : int.tryParse(json['total_dishes']?.toString() ?? '0') ??
              dishesList.length,
    );
  }
}

