class RestaurantModel {
  final int id;
  final int? shopId;
  final String name;
  final String slug;
  final String? domain;
  final String? logo;
  final String? banner;
  final String? address;
  final String? contact;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final bool isRestaurant;
  final String? restaurantType;
  final String? openingTime;
  final String? closingTime;
  final bool isOpenNow;
  final int deliveryRadiusKm;
  final double minDeliveryCharge;
  final double estimatedDeliveryFee;
  final String? estimatedDeliveryTime;
  final int avgPackingTimeMin;
  final bool hasDining;
  final double rating;
  final int reviewsCount;
  final int totalDishes;
  final int? websiteId;

  RestaurantModel({
    required this.id,
    this.shopId,
    required this.name,
    required this.slug,
    this.domain,
    this.logo,
    this.banner,
    this.address,
    this.contact,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.isRestaurant = true,
    this.restaurantType,
    this.openingTime,
    this.closingTime,
    this.isOpenNow = true,
    this.deliveryRadiusKm = 5,
    this.minDeliveryCharge = 0.0,
    this.estimatedDeliveryFee = 0.0,
    this.estimatedDeliveryTime,
    this.avgPackingTimeMin = 15,
    this.hasDining = false,
    this.rating = 4.8,
    this.reviewsCount = 0,
    this.totalDishes = 0,
    this.websiteId,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      shopId: json['shop_id'] is int
          ? json['shop_id']
          : int.tryParse(json['shop_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      domain: json['domain']?.toString(),
      logo: json['logo']?.toString(),
      banner: json['banner']?.toString(),
      address: json['address']?.toString(),
      contact: json['contact']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      isRestaurant: json['is_restaurant'] == 1 || json['is_restaurant'] == true,
      restaurantType: json['restaurant_type']?.toString(),
      openingTime: json['opening_time']?.toString(),
      closingTime: json['closing_time']?.toString(),
      isOpenNow: json['is_open_now'] == true ||
          json['is_open'] == 1 ||
          json['is_open'] == true,
      deliveryRadiusKm: json['delivery_radius_km'] is int
          ? json['delivery_radius_km']
          : int.tryParse(json['delivery_radius_km']?.toString() ?? '5') ?? 5,
      minDeliveryCharge: (json['min_delivery_charge'] as num?)?.toDouble() ??
          (json['delivery_fee'] as num?)?.toDouble() ??
          20.0,
      estimatedDeliveryFee: (json['estimated_delivery_fee'] as num?)?.toDouble() ??
          (json['min_delivery_charge'] as num?)?.toDouble() ??
          20.0,
      estimatedDeliveryTime: json['estimated_delivery_time']?.toString() ?? "15-25 mins",
      avgPackingTimeMin: json['avg_packing_time_min'] is int
          ? json['avg_packing_time_min']
          : int.tryParse(json['avg_packing_time_min']?.toString() ?? '10') ?? 10,
      hasDining: json['has_dining'] == true || json['dining_enabled'] == true,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewsCount: json['reviews_count'] is int
          ? json['reviews_count']
          : int.tryParse(json['reviews_count']?.toString() ?? '0') ?? 0,
      totalDishes: json['total_dishes'] is int
          ? json['total_dishes']
          : int.tryParse(json['total_dishes']?.toString() ?? '0') ?? 0,
      websiteId: json['website_id'] is int
          ? json['website_id']
          : int.tryParse(json['website_id']?.toString() ?? ''),
    );
  }
}

class RestaurantDetailModel {
  final int id;
  final int? shopId;
  final String name;
  final String slug;
  final String? domain;
  final String? logo;
  final String? banner;
  final String? address;
  final String? contact;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final bool isRestaurant;
  final String? restaurantType;
  final String? openingTime;
  final String? closingTime;
  final bool isOpen;
  final int deliveryRadiusKm;
  final double minDeliveryCharge;
  final double deliveryChargePerKm;
  final int avgPackingTimeMin;
  final double instantMinOrderAmount;
  final bool diningEnabled;
  final List<dynamic> schedules;
  final String? storeName;

  RestaurantDetailModel({
    required this.id,
    this.shopId,
    required this.name,
    required this.slug,
    this.domain,
    this.logo,
    this.banner,
    this.address,
    this.contact,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.isRestaurant = true,
    this.restaurantType,
    this.openingTime,
    this.closingTime,
    this.isOpen = true,
    this.deliveryRadiusKm = 5,
    this.minDeliveryCharge = 20.0,
    this.deliveryChargePerKm = 10.0,
    this.avgPackingTimeMin = 5,
    this.instantMinOrderAmount = 0.0,
    this.diningEnabled = false,
    this.schedules = const [],
    this.storeName,
  });

  factory RestaurantDetailModel.fromJson(Map<String, dynamic> rawJson) {
    final json = (rawJson['restaurant'] is Map<String, dynamic>)
        ? rawJson['restaurant'] as Map<String, dynamic>
        : rawJson;

    String? storeName;
    if (json['store'] is Map<String, dynamic>) {
      storeName = json['store']['name']?.toString();
    } else if (rawJson['store'] is Map<String, dynamic>) {
      storeName = rawJson['store']['name']?.toString();
    }

    return RestaurantDetailModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      shopId: json['shop_id'] is int
          ? json['shop_id']
          : int.tryParse(json['shop_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      domain: json['domain']?.toString(),
      logo: json['logo']?.toString(),
      banner: json['banner']?.toString(),
      address: json['address']?.toString(),
      contact: json['contact']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      isRestaurant: json['is_restaurant'] == 1 || json['is_restaurant'] == true,
      restaurantType: json['restaurant_type']?.toString(),
      openingTime: json['opening_time']?.toString(),
      closingTime: json['closing_time']?.toString(),
      isOpen: json['is_open'] == 1 || json['is_open'] == true || json['is_open_now'] == true,
      deliveryRadiusKm: json['delivery_radius_km'] is int
          ? json['delivery_radius_km']
          : int.tryParse(json['delivery_radius_km']?.toString() ?? '5') ?? 5,
      minDeliveryCharge: (json['min_delivery_charge'] as num?)?.toDouble() ?? 20.0,
      deliveryChargePerKm: (json['delivery_charge_per_km'] as num?)?.toDouble() ?? 10.0,
      avgPackingTimeMin: json['avg_packing_time_min'] is int
          ? json['avg_packing_time_min']
          : int.tryParse(json['avg_packing_time_min']?.toString() ?? '5') ?? 5,
      instantMinOrderAmount: (json['instant_min_order_amount'] as num?)?.toDouble() ?? 0.0,
      diningEnabled: json['dining_enabled'] == true,
      schedules: json['schedules'] is List ? json['schedules'] : [],
      storeName: storeName,
    );
  }
}
