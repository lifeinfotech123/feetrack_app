import 'package:vlr/services/constants.dart';

class PackageListingInfo {
  final String? id;
  final String? title;
  final String? address;
  final String? city;
  final dynamic securityDeposit;

  PackageListingInfo({
    this.id,
    this.title,
    this.address,
    this.city,
    this.securityDeposit,
  });

  factory PackageListingInfo.fromJson(Map<String, dynamic> json) =>
      PackageListingInfo(
        id: json["id"]?.toString(),
        title: json["title"]?.toString(),
        address: json["address"]?.toString(),
        city: json["city"]?.toString(),
        securityDeposit: json["security_deposit"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "address": address,
        "city": city,
        "security_deposit": securityDeposit,
      };
}

class PackageModel {
  final String? id;
  final String? compositeId;
  final String? listingId;
  final dynamic roomId;
  final String? name;
  final String? occupancyType;
  final String? durationDays;
  final String? durationLabel;
  final String? price;
  final String? formattedPrice;
  final String? type;
  final String? packageType;
  final List<String>? features;
  final List<dynamic>? mealPlans;
  final PackageListingInfo? listing;
  final Map<String, dynamic>? website;
  final String? enrollUrl;
  final String? visitPassUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;
  final dynamic room;

  PackageModel({
    this.id,
    this.compositeId,
    this.listingId,
    this.roomId,
    this.name,
    this.occupancyType,
    this.durationDays,
    this.durationLabel,
    this.price,
    this.formattedPrice,
    this.type,
    this.packageType,
    this.features,
    this.mealPlans,
    this.listing,
    this.website,
    this.enrollUrl,
    this.visitPassUrl,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.room,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
        id: json["id"]?.toString(),
        compositeId: json["composite_id"]?.toString(),
        listingId: (json["listing_id"] ?? json["listing"]?["id"])?.toString(),
        roomId: (json["room_id"] ?? json["room"]?["id"])?.toString(),
        name: json["name"]?.toString(),
        occupancyType: json["occupancy_type"]?.toString(),
        durationDays: json["duration_days"]?.toString(),
        durationLabel: json["duration_label"]?.toString(),
        price: json["price"]?.toString(),
        formattedPrice: json["formatted_price"]?.toString(),
        type: (json["package_type"] ?? json["type"])?.toString(),
        packageType: (json["package_type"] ?? json["type"])?.toString(),
        features: json["features"] == null
            ? []
            : List<String>.from(json["features"]!.map((x) => x.toString())),
        mealPlans: json["meal_plans"] is List ? json["meal_plans"] : null,
        listing: json["listing"] is Map<String, dynamic>
            ? PackageListingInfo.fromJson(
                Map<String, dynamic>.from(json["listing"]))
            : null,
        website: json["website"] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json["website"])
            : null,
        enrollUrl: json["enroll_url"]?.toString(),
        visitPassUrl: json["visit_pass_url"]?.toString(),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"].toString()),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.tryParse(json["updated_at"].toString()),
        deletedAt: json["deleted_at"],
        room: json["room"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "composite_id": compositeId,
        "listing_id": listingId,
        "room_id": roomId,
        "name": name,
        "occupancy_type": occupancyType,
        "duration_days": durationDays,
        "price": price,
        "type": type,
        "features":
            features == null ? [] : List<dynamic>.from(features!.map((x) => x)),
        "meal_plans": mealPlans,
        "listing": listing?.toJson(),
        "website": website,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
        "room": room,
      };

  String get priceFormat =>
      PriceConverter.convertToNumberFormat(double.tryParse(price ?? "") ?? 0.0);
}
