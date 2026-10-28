class GymCityModel {
  final String city;
  final int gymsCount;

  GymCityModel({
    required this.city,
    required this.gymsCount,
  });

  factory GymCityModel.fromJson(Map<String, dynamic> json) {
    return GymCityModel(
      city: json['city']?.toString() ?? '',
      gymsCount: int.tryParse(json['gyms_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'city': city,
        'gyms_count': gymsCount,
      };
}
