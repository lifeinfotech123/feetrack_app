import 'booking_model.dart';

class SubscriptionModel {
  final String? id;
  final String? status;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final bool? autoRenew;
  final bool? isActive;
  final SubscriptionListing? listing;
  final SubscriptionPlan? plan;
  final SubscriptionRoom? room;
  final DateTime? createdAt;
  final String? bookingId;
  final List<Invoice>? invoices;
  final List<dynamic>? payments;
  final String? leaveStatus;

  SubscriptionModel({
    this.id,
    this.status,
    this.startsAt,
    this.expiresAt,
    this.autoRenew,
    this.isActive,
    this.listing,
    this.plan,
    this.room,
    this.createdAt,
    this.bookingId,
    this.invoices,
    this.payments,
    this.leaveStatus,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) => SubscriptionModel(
        id: json["id"]?.toString(),
        status: json["status"],
        startsAt: json["starts_at"] == null ? null : DateTime.parse(json["starts_at"]),
        expiresAt: json["expires_at"] == null ? null : DateTime.parse(json["expires_at"]),
        autoRenew: json["auto_renew"] is bool ? json["auto_renew"] : (json["auto_renew"] == 1 || json["auto_renew"] == "1"),
        isActive: json["is_active"] is bool ? json["is_active"] : (json["is_active"] == 1 || json["is_active"] == "1"),
        listing: json["listing"] == null ? null : SubscriptionListing.fromJson(json["listing"]),
        plan: json["plan"] == null ? null : SubscriptionPlan.fromJson(json["plan"]),
        room: json["room"] == null ? null : SubscriptionRoom.fromJson(json["room"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        bookingId: json["booking_id"]?.toString(),
        invoices: json["invoices"] == null
            ? []
            : List<Invoice>.from(json["invoices"]!.map((x) => Invoice.fromJson(x))),
        payments: json["payments"] == null ? [] : List<dynamic>.from(json["payments"]!.map((x) => x)),
        leaveStatus: json["leave_status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "starts_at": startsAt?.toIso8601String(),
        "expires_at": expiresAt?.toIso8601String(),
        "auto_renew": autoRenew,
        "is_active": isActive,
        "listing": listing?.toJson(),
        "plan": plan?.toJson(),
        "room": room?.toJson(),
        "created_at": createdAt?.toIso8601String(),
        "booking_id": bookingId,
        "invoices": invoices == null ? [] : List<dynamic>.from(invoices!.map((x) => x.toJson())),
        "payments": payments == null ? [] : List<dynamic>.from(payments!.map((x) => x)),
        "leave_status": leaveStatus,
      };
}

class SubscriptionListing {
  final String? id;
  final String? title;
  final String? category;
  final String? address;
  final String? image;

  SubscriptionListing({
    this.id,
    this.title,
    this.category,
    this.address,
    this.image,
  });

  factory SubscriptionListing.fromJson(Map<String, dynamic> json) => SubscriptionListing(
        id: json["id"]?.toString(),
        title: json["title"],
        category: json["category"],
        address: json["address"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "category": category,
        "address": address,
        "image": image,
      };
}

class SubscriptionPlan {
  final String? id;
  final String? name;
  final String? duration;

  SubscriptionPlan({
    this.id,
    this.name,
    this.duration,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) => SubscriptionPlan(
        id: json["id"]?.toString(),
        name: json["name"],
        duration: json["duration"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "duration": duration,
      };
}

class SubscriptionRoom {
  final String? roomNumber;
  final String? roomType;

  SubscriptionRoom({
    this.roomNumber,
    this.roomType,
  });

  factory SubscriptionRoom.fromJson(Map<String, dynamic> json) => SubscriptionRoom(
        roomNumber: json["room_number"]?.toString(),
        roomType: json["room_type"],
      );

  Map<String, dynamic> toJson() => {
        "room_number": roomNumber,
        "room_type": roomType,
      };
}
