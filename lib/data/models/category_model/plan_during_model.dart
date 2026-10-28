class PlanDurationModel {
  final String? type;
  final String? label;
  final int? durationDays;
  bool isSelected;

  PlanDurationModel({
    this.type,
    this.label,
    this.durationDays,
    this.isSelected = false,
  });

  factory PlanDurationModel.fromJson(Map<String, dynamic> json) =>
      PlanDurationModel(
        type: json["type"],
        label: json["label"],
        durationDays: json["duration_days"] != null 
            ? int.tryParse(json["duration_days"].toString()) 
            : null,
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "label": label,
        "duration_days": durationDays,
      };
}
