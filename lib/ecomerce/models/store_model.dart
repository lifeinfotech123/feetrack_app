class StoreModel {
  final int id;
  final int? shopId;
  final String name;
  final String? slug;
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
  final bool isCurrentlyOpen;
  final double? deliveryRadiusKm;
  final double? minDeliveryCharge;
  final double? deliveryChargePerKm;
  final int? avgPackingTimeMin;
  final double? instantMinOrderAmount;
  final bool hasDining;
  final double rating;
  final int reviewsCount;
  final int totalProducts;
  final int? websiteId;

  // Details fields
  final String? email;
  final String? zipCode;
  final StoreSellerModel? seller;
  final StoreStatisticsModel? statistics;

  StoreModel({
    required this.id,
    this.shopId,
    required this.name,
    this.slug,
    this.domain,
    this.logo,
    this.banner,
    this.address,
    this.contact,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.isRestaurant = false,
    this.restaurantType,
    this.openingTime,
    this.closingTime,
    this.isOpen = true,
    this.isCurrentlyOpen = true,
    this.deliveryRadiusKm,
    this.minDeliveryCharge,
    this.deliveryChargePerKm,
    this.avgPackingTimeMin,
    this.instantMinOrderAmount,
    this.hasDining = false,
    this.rating = 5.0,
    this.reviewsCount = 0,
    this.totalProducts = 0,
    this.websiteId,
    this.email,
    this.zipCode,
    this.seller,
    this.statistics,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      shopId: json['shop_id'] is int
          ? json['shop_id']
          : int.tryParse(json['shop_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
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
      isOpen: json['is_open'] == 1 || json['is_open'] == true,
      isCurrentlyOpen: json['is_currently_open'] == true ||
          json['is_currently_open'] == 1 ||
          json['is_open'] == 1,
      deliveryRadiusKm: (json['delivery_radius_km'] as num?)?.toDouble(),
      minDeliveryCharge: (json['min_delivery_charge'] as num?)?.toDouble(),
      deliveryChargePerKm: (json['delivery_charge_per_km'] as num?)?.toDouble(),
      avgPackingTimeMin: (json['avg_packing_time_min'] as num?)?.toInt(),
      instantMinOrderAmount:
          (json['instant_min_order_amount'] as num?)?.toDouble(),
      hasDining: json['has_dining'] == true || json['has_dining'] == 1,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: json['reviews_count'] is int
          ? json['reviews_count']
          : int.tryParse(json['reviews_count']?.toString() ?? '') ?? 0,
      totalProducts: json['total_products'] is int
          ? json['total_products']
          : int.tryParse(json['total_products']?.toString() ?? '') ?? 0,
      websiteId: json['website_id'] is int
          ? json['website_id']
          : int.tryParse(json['website_id']?.toString() ?? ''),
      email: json['email']?.toString(),
      zipCode: json['zip_code']?.toString(),
      seller: json['seller'] is Map<String, dynamic>
          ? StoreSellerModel.fromJson(json['seller'])
          : null,
      statistics: json['statistics'] is Map<String, dynamic>
          ? StoreStatisticsModel.fromJson(json['statistics'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'name': name,
      'slug': slug,
      'domain': domain,
      'logo': logo,
      'banner': banner,
      'address': address,
      'contact': contact,
      'rating': rating,
      'total_products': totalProducts,
    };
  }
}

class StoreSellerModel {
  final String? name;
  final String? phone;
  final String? email;

  StoreSellerModel({this.name, this.phone, this.email});

  factory StoreSellerModel.fromJson(Map<String, dynamic> json) {
    return StoreSellerModel(
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

class StoreStatisticsModel {
  final int totalProducts;
  final int totalCategories;
  final double rating;
  final int reviewsCount;

  StoreStatisticsModel({
    this.totalProducts = 0,
    this.totalCategories = 0,
    this.rating = 0.0,
    this.reviewsCount = 0,
  });

  factory StoreStatisticsModel.fromJson(Map<String, dynamic> json) {
    return StoreStatisticsModel(
      totalProducts: (json['total_products'] as num?)?.toInt() ?? 0,
      totalCategories: (json['total_categories'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
    );
  }
}
