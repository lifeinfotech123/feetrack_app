class StaffModel {
  final int? id;
  final String? name;
  final String? specialization;
  final String? experienceYears;
  final String? photoUrl;
  final String? description;

  StaffModel({
    this.id,
    this.name,
    this.specialization,
    this.experienceYears,
    this.photoUrl,
    this.description,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) => StaffModel(
        id: json["id"] is int
            ? json["id"]
            : int.tryParse(json["id"]?.toString() ?? ""),
        name: json["name"],
        specialization: json["specialization"] ?? json["designation"],
        experienceYears: (json["experience_years"] ??
                json["experience_label"] ??
                json["experience"])
            ?.toString(),
        photoUrl: json["photo_url"] ?? json["image_url"] ?? json["photo"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "specialization": specialization,
        "experience_years": experienceYears,
        "photo_url": photoUrl,
        "description": description,
      };
}
