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
  final num? costPrice;
  final String? weightVolume;
  final String? weightUnit;
  final String? servingSize;
  final int? prepTimeMin;
  final String? sku;

  DishVariantModel({
    required this.id,
    required this.name,
    required this.price,
    required this.promotionalPrice,
    this.costPrice,
    this.weightVolume,
    this.weightUnit,
    this.servingSize,
    this.prepTimeMin,
    this.sku,
  });

  double get effectivePrice =>
      promotionalPrice > 0 ? promotionalPrice : price;

  bool get hasDiscount =>
      price > promotionalPrice && promotionalPrice > 0;

  factory DishVariantModel.fromJson(Map<String, dynamic> json) {
    final pr = (json['price'] as num?)?.toDouble() ??
        (json['unit_price'] as num?)?.toDouble() ??
        0.0;
    final promPr = (json['promotional_price'] as num?)?.toDouble() ??
        (json['discounted_price'] as num?)?.toDouble() ??
        pr;

    return DishVariantModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      price: pr,
      promotionalPrice: promPr,
      costPrice: json['cost_price'] as num?,
      weightVolume: json['weight_volume']?.toString(),
      weightUnit: json['weight_unit']?.toString(),
      servingSize: json['serving_size']?.toString(),
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
  final String? unit;
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
  final int? isSpicy;
  final int? isHalal;
  final int? isRecommended;
  final String? calories;
  final int? preparationTimeMin;
  final int? isInstantDelivery;
  final String? instantDeliveryTime;
  final int? categoryId;
  final String? categoryName;
  final String? categorySlug;
  final String? categoryIcon;
  final bool hasVariants;
  final int variantsCount;
  final List<DishVariantModel> variants;
  final int? shopId;
  final String? domain;
  final String? storeName;
  final String? storeLogo;
  final String? storeAddress;
  final double rating;

  DishModel({
    required this.id,
    required this.name,
    required this.slug,
    this.code,
    this.unit,
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
    this.isSpicy,
    this.isHalal,
    this.isRecommended,
    this.calories,
    this.preparationTimeMin,
    this.isInstantDelivery,
    this.instantDeliveryTime,
    this.categoryId,
    this.categoryName,
    this.categorySlug,
    this.categoryIcon,
    this.hasVariants = false,
    this.variantsCount = 0,
    this.variants = const [],
    this.shopId,
    this.domain,
    this.storeName,
    this.storeLogo,
    this.storeAddress,
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
    final origPrice = (json['base_price'] as num?)?.toDouble() ??
        (json['original_price'] as num?)?.toDouble() ??
        (json['unit_price'] as num?)?.toDouble() ??
        (json['base_unit_price'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        0.0;
    final dlPrice = (json['deal_price'] as num?)?.toDouble() ??
        (json['promotional_price'] as num?)?.toDouble() ??
        (json['final_price'] as num?)?.toDouble() ??
        (json['discounted_price'] as num?)?.toDouble() ??
        (json['price_after_discount'] as num?)?.toDouble() ??
        origPrice;

    int? catId;
    String? catName;
    String? catSlug;
    String? catIcon;
    if (json['category'] is Map<String, dynamic>) {
      catId = json['category']['id'] is int
          ? json['category']['id']
          : int.tryParse(json['category']['id']?.toString() ?? '');
      catName = json['category']['name']?.toString();
      catSlug = json['category']['slug']?.toString();
      catIcon = json['category']['icon']?.toString();
    } else {
      catId = json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id']?.toString() ?? '');
      catName = json['category_name']?.toString();
      catSlug = json['category_slug']?.toString();
      catIcon = json['category_icon']?.toString();
    }

    String? itemDomain = defaultDomain;
    int? itemShopId = defaultShopId;
    String? itemStoreName = defaultStoreName;
    String? itemStoreLogo;
    String? itemStoreAddress;

    if (json['restaurant'] is Map<String, dynamic>) {
      final r = json['restaurant'];
      itemDomain ??= r['domain']?.toString();
      itemShopId ??= r['shop_id'] is int
          ? r['shop_id']
          : int.tryParse(r['shop_id']?.toString() ?? '');
      itemStoreName ??= r['name']?.toString();
      itemStoreLogo = r['logo']?.toString();
      itemStoreAddress = r['address']?.toString();
    } else if (json['store'] is Map<String, dynamic>) {
      final s = json['store'];
      itemDomain ??= s['domain']?.toString();
      itemShopId ??= s['shop_id'] is int
          ? s['shop_id']
          : int.tryParse(s['shop_id']?.toString() ?? '');
      itemStoreName ??= s['name']?.toString();
      itemStoreLogo = s['logo']?.toString();
      itemStoreAddress = s['address']?.toString();
    }

    itemShopId ??= json['shop_id'] is int
        ? json['shop_id']
        : int.tryParse(json['shop_id']?.toString() ?? '');
    itemDomain ??= json['domain']?.toString();

    final List<DishVariantModel> variantList = [];
    final rawVariants = json['food_variants'] ?? json['variants'];
    if (rawVariants is List) {
      for (var v in rawVariants) {
        if (v is Map<String, dynamic>) {
          variantList.add(DishVariantModel.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }

    final bool hasVars = json['has_variants'] == true ||
        json['has_variants'] == 1 ||
        variantList.isNotEmpty;
    final int varCount = json['variants_count'] is int
        ? json['variants_count']
        : (int.tryParse(json['variants_count']?.toString() ?? '') ?? variantList.length);

    return DishModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      code: json['code']?.toString(),
      unit: json['unit']?.toString(),
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
      isFood: json['is_food'] == 1 || json['is_food'] == true || true,
      foodType: json['food_type']?.toString().toLowerCase() ?? 'veg',
      isSpicy: json['is_spicy'] is int ? json['is_spicy'] : int.tryParse(json['is_spicy']?.toString() ?? ''),
      isHalal: json['is_halal'] is int ? json['is_halal'] : int.tryParse(json['is_halal']?.toString() ?? ''),
      isRecommended: json['is_recommended'] is int ? json['is_recommended'] : int.tryParse(json['is_recommended']?.toString() ?? ''),
      calories: json['calories']?.toString(),
      preparationTimeMin: json['preparation_time_min'] is int
          ? json['preparation_time_min']
          : int.tryParse(json['preparation_time_min']?.toString() ?? ''),
      isInstantDelivery: json['is_instant_delivery'] is int
          ? json['is_instant_delivery']
          : int.tryParse(json['is_instant_delivery']?.toString() ?? ''),
      instantDeliveryTime: json['instant_delivery_time']?.toString(),
      categoryId: catId,
      categoryName: catName,
      categorySlug: catSlug,
      categoryIcon: catIcon,
      hasVariants: hasVars,
      variantsCount: varCount,
      variants: variantList,
      shopId: itemShopId,
      domain: itemDomain,
      storeName: itemStoreName,
      storeLogo: itemStoreLogo,
      storeAddress: itemStoreAddress,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
    );
  }

  ProductModel toProductModel({
    String? storeDomain,
    int? shopId,
    String? restaurantName,
    DishVariantModel? selectedVariant,
  }) {
    final effectiveDomain = storeDomain ?? domain ?? '21-ecomm';
    final effectiveShopId = shopId ?? this.shopId ?? 1;
    final effectiveStoreName = restaurantName ?? storeName ?? 'Restaurant';

    double effectivePrice = originalPrice;
    double effectiveDealPrice = dealPrice;
    double effectiveDiscountAmount = discountAmount;

    if (selectedVariant != null) {
      effectivePrice = selectedVariant.price > 0 ? selectedVariant.price : selectedVariant.promotionalPrice;
      effectiveDealPrice = selectedVariant.promotionalPrice > 0 ? selectedVariant.promotionalPrice : effectivePrice;
      effectiveDiscountAmount = (effectivePrice > effectiveDealPrice) ? (effectivePrice - effectiveDealPrice) : 0.0;
    }

    int discountPercent = 0;
    if (effectivePrice > effectiveDealPrice && effectivePrice > 0) {
      discountPercent =
          (((effectivePrice - effectiveDealPrice) / effectivePrice) * 100).round();
    }

    return ProductModel(
      id: id,
      title: name,
      price: effectivePrice,
      priceAfetDiscount: effectiveDealPrice,
      discountAmount: effectiveDiscountAmount > 0
          ? effectiveDiscountAmount
          : (effectivePrice - effectiveDealPrice > 0 ? (effectivePrice - effectiveDealPrice) : 0),
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

