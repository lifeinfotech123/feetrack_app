import 'package:vlr/data/models/category_model/listing_model.dart';

class PgRoomModel {
  final String? id;
  final String? compositeId;
  final String? floorId;
  final String? floorName;
  final String? roomNumber;
  final String? roomType;
  final int? capacity;
  final int? availableBeds;
  final dynamic securityDeposit;
  final dynamic startingPrice;
  final dynamic fullRent;
  final dynamic perBedRent;
  final int? occupiedBeds;
  final bool? isAvailable;
  final int? packagesCount;
  final List<RoomImage>? images;
  final List<RoomPackage>? packages;
  final ListingModel? listing;
  final PartnerModel? partner;
  final Map<String, dynamic>? website;
  bool isSelect;

  PgRoomModel({
    this.id,
    this.compositeId,
    this.floorId,
    this.floorName,
    this.roomNumber,
    this.roomType,
    this.capacity,
    this.availableBeds,
    this.occupiedBeds,
    this.isAvailable,
    this.packagesCount,
    this.securityDeposit,
    this.startingPrice,
    this.fullRent,
    this.perBedRent,
    this.images,
    this.packages,
    this.listing,
    this.partner,
    this.website,
    this.isSelect = false,
  });

  // Keep old field names as getters/aliases for backward compatibility
  String? get roomNo => roomNumber;
  int? get bedLeftNo => availableBeds;
  int? get shareType => capacity;
  String? get listingId => listing?.id;

  factory PgRoomModel.fromJson(Map<String, dynamic> json) {
    String? parsedFloorId;
    String? parsedFloorName;
    if (json['floor'] is Map) {
      parsedFloorId = json['floor']['id']?.toString();
      parsedFloorName = json['floor']['name']?.toString();
    } else {
      parsedFloorId = json['floor_id']?.toString();
    }

    bool? parsedIsAvailable;
    if (json['is_available'] is bool) {
      parsedIsAvailable = json['is_available'] as bool;
    } else if (json['is_available'] != null) {
      final s = json['is_available'].toString().toLowerCase();
      parsedIsAvailable = s == '1' || s == 'true';
    }

    List<RoomImage>? parsedImages;
    if (json['images'] is List) {
      parsedImages = (json['images'] as List)
          .map((i) => RoomImage.fromJson(i))
          .toList();
    } else if (json['images'] is String && (json['images'] as String).isNotEmpty) {
      parsedImages = [RoomImage(url: json['images'])];
    } else if (json['image'] is String && (json['image'] as String).isNotEmpty) {
      parsedImages = [RoomImage(url: json['image'])];
    }

    List<RoomPackage>? parsedPackages;
    if (json['packages'] is List) {
      parsedPackages = (json['packages'] as List)
          .whereType<Map>()
          .map((p) => RoomPackage.fromJson(Map<String, dynamic>.from(p)))
          .toList();
    }

    return PgRoomModel(
      id: json['id']?.toString(),
      compositeId: json['composite_id']?.toString(),
      floorId: parsedFloorId,
      floorName: parsedFloorName,
      roomNumber: json['room_number']?.toString(),
      roomType: json['room_type']?.toString(),
      capacity: json['capacity'] != null
          ? int.tryParse(json['capacity'].toString())
          : null,
      availableBeds: json['available_beds'] != null
          ? int.tryParse(json['available_beds'].toString())
          : null,
      occupiedBeds: json['occupied_beds'] != null
          ? int.tryParse(json['occupied_beds'].toString())
          : null,
      isAvailable: parsedIsAvailable,
      packagesCount: json['packages_count'] != null
          ? int.tryParse(json['packages_count'].toString())
          : null,
      securityDeposit: json['security_deposit'],
      startingPrice:
          json['starting_price'] ?? json['per_bed_rent'] ?? json['full_rent'],
      fullRent: json['full_rent'],
      perBedRent: json['per_bed_rent'],
      images: parsedImages,
      packages: parsedPackages,
      listing: json['listing'] != null && json['listing'] is Map
          ? ListingModel.fromJson(Map<String, dynamic>.from(json['listing']))
          : null,
      partner: json['partner'] != null && json['partner'] is Map
          ? PartnerModel.fromJson(Map<String, dynamic>.from(json['partner']))
          : null,
      website: json['website'] is Map
          ? Map<String, dynamic>.from(json['website'])
          : null,
    );
  }
}

class PartnerModel {
  final String? name;
  final String? mobile;
  final String? profilePhotoUrl;

  PartnerModel({this.name, this.mobile, this.profilePhotoUrl});

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      name: json['name'],
      mobile: json['mobile'],
      profilePhotoUrl: json['profile_photo_url'],
    );
  }
}

class RoomImage {
  final int? id;
  final String? url;

  RoomImage({this.id, this.url});

  factory RoomImage.fromJson(dynamic json) {
    if (json is String) {
      return RoomImage(url: json);
    }
    if (json is Map) {
      return RoomImage(
        id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
        url: json['url']?.toString() ?? json['image']?.toString(),
      );
    }
    return RoomImage();
  }
}

class RoomPackage {
  final String? id;
  final String? name;
  final String? type;
  final String? durationLabel;
  final int? durationDays;
  final dynamic price;
  final List<String>? features;
  final String? occupancyType;
  final MealPlans? mealPlans;
  final String? roomType;
  final String? roomId;

  RoomPackage({
    this.id,
    this.name,
    this.type,
    this.durationLabel,
    this.durationDays,
    this.price,
    this.features,
    this.occupancyType,
    this.mealPlans,
    this.roomType,
    this.roomId,
  });

  factory RoomPackage.fromJson(Map<String, dynamic> json) {
    return RoomPackage(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      type: json['type']?.toString(),
      durationLabel: json['duration_label']?.toString(),
      durationDays: json['duration_days'] != null ? int.tryParse(json['duration_days'].toString()) : null,
      price: json['price'],
      features: (json['features'] is List)
          ? List<String>.from((json['features'] as List).map((e) => e.toString()))
          : null,
      occupancyType: json['occupancy_type']?.toString(),
      mealPlans: (json['meal_plans'] is Map)
          ? MealPlans.fromJson(Map<String, dynamic>.from(json['meal_plans']))
          : null,
      roomType: json['room_type']?.toString(),
      roomId: json['room_id']?.toString(),
    );
  }
}

class MealPlans {
  final bool? hasBreakfast;
  final bool? hasLunch;
  final bool? hasDinner;
  final String? mealType;

  MealPlans({this.hasBreakfast, this.hasLunch, this.hasDinner, this.mealType});

  factory MealPlans.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    return MealPlans(
      hasBreakfast: parseBool(json['has_breakfast']),
      hasLunch: parseBool(json['has_lunch']),
      hasDinner: parseBool(json['has_dinner']),
      mealType: json['meal_type']?.toString(),
    );
  }
}
