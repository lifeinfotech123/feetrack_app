import 'medicine_model.dart';

class PharmacyCategoryModel {
  final int id;
  final String name;
  final int medicinesCount;
  final int? hospitalId;
  final String? hospitalDomain;
  final HospitalInfo? hospital;

  PharmacyCategoryModel({
    required this.id,
    required this.name,
    this.medicinesCount = 0,
    this.hospitalId,
    this.hospitalDomain,
    this.hospital,
  });

  factory PharmacyCategoryModel.fromJson(Map<String, dynamic> json) {
    HospitalInfo? hosp;
    if (json['hospital'] is Map) {
      hosp = HospitalInfo.fromJson(Map<String, dynamic>.from(json['hospital']));
    }

    int count = 0;
    if (json['medicines_count'] is int) {
      count = json['medicines_count'];
    } else if (json['medicines_count'] != null) {
      count = int.tryParse(json['medicines_count'].toString()) ?? 0;
    }

    return PharmacyCategoryModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: json['name']?.toString() ?? '',
      medicinesCount: count,
      hospitalId: json['hospital_id'] is int
          ? json['hospital_id']
          : int.tryParse(json['hospital_id']?.toString() ?? ''),
      hospitalDomain: json['hospital_domain']?.toString(),
      hospital: hosp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'medicines_count': medicinesCount,
      'hospital_id': hospitalId,
      'hospital_domain': hospitalDomain,
      'hospital': hospital?.toJson(),
    };
  }
}
