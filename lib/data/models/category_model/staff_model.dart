class StaffModel {
  final int? id;
  final String? stringId;
  final String? name;
  final String? specialization;
  final String? experienceYears;
  final String? photoUrl;
  final String? description;
  final String? gymId;
  final String? gymTitle;
  final Map<String, dynamic>? gym;
  final Map<String, dynamic>? website;
  final List<dynamic>? shifts;

  StaffModel({
    this.id,
    this.stringId,
    this.name,
    this.specialization,
    this.experienceYears,
    this.photoUrl,
    this.description,
    this.gymId,
    this.gymTitle,
    this.gym,
    this.website,
    this.shifts,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    String? gymId;
    String? gymTitle;
    if (json["gym"] is Map) {
      gymId = json["gym"]["id"]?.toString();
      gymTitle = json["gym"]["title"]?.toString();
    } else if (json["gym_id"] != null) {
      gymId = json["gym_id"]?.toString();
    }

    final parsedId = json["id"] is int
        ? json["id"] as int
        : int.tryParse(json["id"]?.toString() ?? "");

    return StaffModel(
      id: parsedId,
      stringId: json["id"]?.toString(),
      name: json["name"]?.toString(),
      specialization:
          (json["specialization"] ?? json["designation"])?.toString(),
      experienceYears: (json["experience_label"] ??
              json["experience_years"] ??
              json["experience"])
          ?.toString(),
      photoUrl: (json["photo"] ?? json["photo_url"] ?? json["image_url"])
          ?.toString(),
      description: json["description"]?.toString(),
      gymId: gymId,
      gymTitle: gymTitle,
      gym: json["gym"] is Map ? Map<String, dynamic>.from(json["gym"]) : null,
      website: json["website"] is Map
          ? Map<String, dynamic>.from(json["website"])
          : null,
      shifts: json["shifts"] is List ? (json["shifts"] as List) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id ?? stringId,
        "name": name,
        "specialization": specialization,
        "experience_years": experienceYears,
        "photo_url": photoUrl,
        "description": description,
        "gym_id": gymId,
        if (gym != null) "gym": gym,
        if (website != null) "website": website,
        if (shifts != null) "shifts": shifts,
      };
}

