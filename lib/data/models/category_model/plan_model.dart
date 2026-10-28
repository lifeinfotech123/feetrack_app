class PlanModel {
  final String? id;
  final String? name;
  final String? type;
  final String? durationLabel;
  final String? durationDays;
  final dynamic price;
  final List<String>? features;
  final String? roomType;
  final String? roomId;
  final String? occupancyType;
  final MealPlanModel? mealPlans;
  final dynamic room;
  final int? securityDeposit;

  bool isSelected;

  PlanModel({
    this.id,
    this.name,
    this.type,
    this.durationLabel,
    this.durationDays,
    this.price,
    this.features,
    this.roomType,
    this.roomId,
    this.occupancyType,
    this.mealPlans,
    this.room,
    this.securityDeposit,
    this.isSelected = false,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
        id: json["id"]?.toString(),
        name: json["name"]?.toString(),
        type: json["type"]?.toString(),
        durationLabel: json["duration_label"]?.toString(),
        durationDays: json["duration_days"]?.toString(),
        price: json["price"],
        features: json["features"] == null
            ? []
            : List<String>.from(json["features"].map((x) => x.toString())),
        roomType: json["room_type"]?.toString(),
        roomId: json["room_id"]?.toString(),
        occupancyType: json["occupancy_type"]?.toString(),
        mealPlans: json["meal_plans"] != null
            ? MealPlanModel.fromJson(json["meal_plans"])
            : null,
        room: json["room"],
        securityDeposit: json["security_deposit"] is int
            ? json["security_deposit"]
            : int.tryParse(json["security_deposit"]?.toString() ?? ''),
      );
}

class MealPlanModel {
  final bool? hasBreakfast;
  final bool? hasLunch;
  final bool? hasDinner;
  final String? mealType;

  MealPlanModel({
    this.hasBreakfast,
    this.hasLunch,
    this.hasDinner,
    this.mealType,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    return MealPlanModel(
      hasBreakfast: parseBool(json['has_breakfast']),
      hasLunch: parseBool(json['has_lunch']),
      hasDinner: parseBool(json['has_dinner']),
      mealType: json['meal_type']?.toString(),
    );
  }
}
