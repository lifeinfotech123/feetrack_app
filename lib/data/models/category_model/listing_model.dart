import 'package:vlr/data/models/category_model/image_model.dart';
import 'package:vlr/data/models/category_model/package_model.dart';
import 'package:vlr/data/models/rooom/pg_floor_model.dart';
import 'package:vlr/services/constants.dart';

import 'category_model.dart';

class ListingModel {
  final String? id;
  final String? partnerId;
  final String? categoryId;
  final String? title;
  final String? description;
  final String? address;
  final dynamic phone;
  final String? lat;
  final String? lng;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;
  final String? packagesMinPrice;
  final double? distanceKm;
  final int? availableRoomsCount;
  final int? availableBedsCount;
  final bool? fullyBooked;
  final int? startingPrice;
  final List<PackageModel>? packages;
  final CategoryModel? category;
  final String? about;
  final String? image;
  final List<ImageMode>? images;
  final String? landmark;
  final String? openingTime;
  final String? closingTime;
  final Map<String, dynamic>? partner;
  final ListingRating? rating;
  final String? reviewsAvgRating;
  final String? reviewsCount;
  final String? genderType;
  final String? securityDeposit;
  final List<String>? amenities;
  final bool? isVerified;
  final List<String>? bookingPerks;
  final Map<String, dynamic>? links;
  final Map<String, dynamic>? website;
  final List<dynamic>? shifts;
  final List<dynamic>? trainers;
  final String? listingNumber;
  final String? city;
  final String? state;
  final String? pincode;
  final String? fullAddress;
  final List<PgFloorModel>? floors;
  final String? compositeId;
  final String? searchKeywords;
  final int? totalRooms;
  final int? availableBeds;
  final int? totalFloors;

  /// Client-side calculated distance (set via Haversine formula)
  double? calculatedDistanceKm;

  /// Returns API distance_km if available, otherwise returns client-calculated distance
  double? get effectiveDistanceKm => distanceKm ?? calculatedDistanceKm;

  ListingModel({
    this.id,
    this.partnerId,
    this.categoryId,
    this.title,
    this.description,
    this.address,
    this.phone,
    this.lat,
    this.lng,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.packagesMinPrice,
    this.distanceKm,
    this.availableRoomsCount,
    this.availableBedsCount,
    this.fullyBooked,
    this.startingPrice,
    this.packages,
    this.category,
    this.about,
    this.image,
    this.images,
    this.landmark,
    this.openingTime,
    this.closingTime,
    this.partner,
    this.rating,
    this.reviewsAvgRating,
    this.reviewsCount,
    this.genderType,
    this.securityDeposit,
    this.amenities,
    this.isVerified,
    this.bookingPerks,
    this.links,
    this.website,
    this.shifts,
    this.trainers,
    this.listingNumber,
    this.city,
    this.state,
    this.pincode,
    this.fullAddress,
    this.floors,
    this.compositeId,
    this.searchKeywords,
    this.totalRooms,
    this.availableBeds,
    this.totalFloors,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    // print("ListingModel.fromJson: parsing data for ID: ${json["id"]}");
    return ListingModel(
        id: json["id"]?.toString(),
        partnerId: json["partner_id"]?.toString(),
        compositeId: json["composite_id"]?.toString(),
        searchKeywords: json["search_keywords"]?.toString(),
        categoryId: (json["category_id"] ?? json["category"]?["id"])?.toString(),
        title: json["title"]?.toString(),
        description: json["description"]?.toString(),
        address: (json["full_address"] ?? json["address"])?.toString(),
        phone: json["phone"],
        lat: (json["location"]?["lat"] ?? json["lat"] ?? json["latitude"])?.toString(),
        lng: (json["location"]?["lng"] ?? json["lng"] ?? json["longitude"])?.toString(),
        status: json["status"]?.toString(),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"].toString()),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.tryParse(json["updated_at"].toString()),
        deletedAt: json["deleted_at"],
        city: json["city"]?.toString(),
        state: json["state"]?.toString(),
        pincode: json["pincode"]?.toString(),
        fullAddress: (json["full_address"] ?? json["address"])?.toString(),
        packagesMinPrice: (json["packages_min_price"] ??
                json["pricing"]?["formatted_min"] ??
                json["pricing"]?["min_price"])
            ?.toString(),
        distanceKm: json["distance_km"] == null
            ? (json["location"]?["distance_km"] == null
                ? null
                : double.tryParse(json["location"]["distance_km"].toString()))
            : double.tryParse(json["distance_km"].toString()),
        availableRoomsCount: json["available_rooms_count"] == null
            ? (json["total_rooms"] == null ? null : int.tryParse(json["total_rooms"].toString()))
            : double.tryParse(json["available_rooms_count"].toString())?.toInt(),
        availableBedsCount: json["available_beds_count"] == null
            ? (json["available_beds"] == null ? null : int.tryParse(json["available_beds"].toString()))
            : double.tryParse(json["available_beds_count"].toString())?.toInt(),
        totalRooms: json["total_rooms"] != null ? int.tryParse(json["total_rooms"].toString()) : null,
        availableBeds: json["available_beds"] != null ? int.tryParse(json["available_beds"].toString()) : null,
        totalFloors: json["total_floors"] != null ? int.tryParse(json["total_floors"].toString()) : null,
        floors: json["floors"] == null
            ? null
            : List<PgFloorModel>.from(
                (json["floors"] as List).map((x) => PgFloorModel.fromJson(Map<String, dynamic>.from(x)))),
        fullyBooked: json["fully_booked"] is bool ? json["fully_booked"] : (json["fully_booked"] == 1 || json["fully_booked"] == "1"),
        startingPrice: json["starting_price"] != null
            ? double.tryParse(json["starting_price"].toString())?.toInt()
            : (json["pricing"]?["min_price"] != null
                ? double.tryParse(json["pricing"]["min_price"].toString())?.toInt()
                : null),
        packages: json["packages"] == null
            ? []
            : List<PackageModel>.from(
                (json["packages"] as List).map((x) => PackageModel.fromJson(Map<String, dynamic>.from(x)))),
        category: json["category"] == null
            ? null
            : CategoryModel.fromJson(json["category"]),
        about: (json["about"] ?? json["description"])?.toString(),
        image: (json["cover_image"] ??
                json["image"] ??
                json["image_url"] ??
                json["image_path"])
            ?.toString(),
        images: json["images"] == null
            ? []
            : List<ImageMode>.from(
                (json["images"] as List).map((x) => ImageMode.fromJson(Map<String, dynamic>.from(x)))),
        landmark: json["landmark"]?.toString(),
        openingTime: (json["timings"]?["opening_time"] ?? json["opening_time"])?.toString(),
        closingTime: (json["timings"]?["closing_time"] ?? json["closing_time"])?.toString(),
        partner: json["partner"],
        rating: json["rating"] == null
            ? (json["reviews"] == null
                ? null
                : ListingRating.fromJson(json["reviews"] is Map ? Map<String, dynamic>.from(json["reviews"]) : {}))
            : ListingRating.fromJson(json["rating"] is Map ? Map<String, dynamic>.from(json["rating"]) : {}),
        reviewsAvgRating: (json["reviews_avg_rating"] ?? json["reviews"]?["average_rating"])?.toString(),
        reviewsCount: (json["reviews_count"] ?? json["reviews"]?["total_reviews"])?.toString(),
        genderType: (json["gender_label"] ?? json["gender_type"])?.toString(),
        securityDeposit: json["security_deposit"]?.toString(),
        amenities: json["amenities"] == null
            ? []
            : List<String>.from(json["amenities"].map((x) => x.toString())),
        isVerified: json["is_verified"] is bool
            ? json["is_verified"]
            : (json["is_verified"] == 1 || json["is_verified"] == "1"),
        bookingPerks: json["booking_perks"] == null
            ? []
            : List<String>.from(json["booking_perks"].map((x) => x.toString())),
        links: json["links"] is Map ? Map<String, dynamic>.from(json["links"]) : null,
        website: json["website"] is Map ? Map<String, dynamic>.from(json["website"]) : null,
        shifts: json["shifts"] is List ? json["shifts"] : [],
        trainers: json["trainers"] is List ? json["trainers"] : [],
        listingNumber: json["listing_number"]?.toString(),
      );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "partner_id": partnerId,
        "category_id": categoryId,
        "title": title,
        "description": description,
        "address": address,
        "phone": phone,
        "lat": lat,
        "lng": lng,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
        "packages_min_price": packagesMinPrice,
        "distance_km": distanceKm,
        "available_rooms_count": availableRoomsCount,
        "available_beds_count": availableBedsCount,
        "fully_booked": fullyBooked,
        "starting_price": startingPrice,
        "packages": packages == null
            ? []
            : List<dynamic>.from(packages!.map((x) => x.toJson())),
        "category": category?.toJson(),
        "about": about,
        "image": image,
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toJson())),
        "landmark": landmark,
        "opening_time": openingTime,
        "closing_time": closingTime,
        "partner": partner,
        "rating": rating?.toJson(),
        "reviews_avg_rating": reviewsAvgRating,
        "reviews_count": reviewsCount,
        "gender_type": genderType,
        "security_deposit": securityDeposit,
        "amenities": amenities,
        "is_verified": isVerified,
        "booking_perks": bookingPerks,
        "links": links,
        "website": website,
        "shifts": shifts,
        "trainers": trainers,
        "listing_number": listingNumber,
      };

  String get priceFormat =>
      PriceConverter.convertToNumberFormat(startingPrice ?? 0.0);
}

class ListingRating {
  final double? average;
  final int? count;

  ListingRating({this.average, this.count});

  factory ListingRating.fromJson(Map<String, dynamic> json) => ListingRating(
        average: json["average"] == null
            ? (json["average_rating"] == null
                ? null
                : double.tryParse(json["average_rating"].toString()))
            : double.tryParse(json["average"].toString()),
        count: json["count"] is int
            ? json["count"]
            : (json["total_reviews"] is int
                ? json["total_reviews"]
                : int.tryParse(json["count"]?.toString() ?? json["total_reviews"]?.toString() ?? "")),
      );

  Map<String, dynamic> toJson() => {
        "average": average,
        "count": count,
      };
}
