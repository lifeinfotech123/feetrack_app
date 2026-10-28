num? _safeNum(dynamic val) {
  if (val == null) return null;
  if (val is num) return val;
  return num.tryParse(val.toString());
}

class SpecialistModel {
  final dynamic id;
  final String name;

  SpecialistModel({this.id, required this.name});

  factory SpecialistModel.fromJson(Map<String, dynamic> json) {
    return SpecialistModel(
      id: json['id'],
      name: json['specialist_name']?.toString() ??
          json['name']?.toString() ??
          'General',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class DoctorHospitalModel {
  final dynamic id;
  final String name;
  final String? domain;
  final String? address;
  final num? distanceKm;

  DoctorHospitalModel({
    this.id,
    required this.name,
    this.domain,
    this.address,
    this.distanceKm,
  });

  factory DoctorHospitalModel.fromJson(Map<String, dynamic> json) {
    return DoctorHospitalModel(
      id: json['id'],
      name: json['name']?.toString() ?? 'Hospital',
      domain: json['domain']?.toString(),
      address: json['address']?.toString(),
      distanceKm: _safeNum(json['distance_km']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'domain': domain,
        'address': address,
        'distance_km': distanceKm,
      };
}

class DoctorServiceModel {
  final dynamic id;
  final String name;
  final String? hospitalName;
  final String? description;
  final dynamic fees;
  final String? image;
  final Map<String, dynamic> rawJson;

  DoctorServiceModel({
    this.id,
    required this.name,
    this.hospitalName,
    this.description,
    this.fees,
    this.image,
    this.rawJson = const {},
  });

  factory DoctorServiceModel.fromJson(Map<String, dynamic> json) {
    return DoctorServiceModel(
      id: json['id'],
      name: json['name']?.toString() ?? json['service_name']?.toString() ?? '',
      hospitalName: json['hospital_name']?.toString() ??
          json['hospital']?['name']?.toString(),
      description: json['description']?.toString(),
      fees: json['fees'] ?? json['price'] ?? json['amount'],
      image: json['image']?.toString() ?? json['image_url']?.toString(),
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'hospital_name': hospitalName,
        'description': description,
        'fees': fees,
        'image': image,
      };
}

class DoctorModel {
  final dynamic id;
  final String name;
  final SpecialistModel? specialist;
  final DoctorHospitalModel? hospital;
  final String? qualification;
  final dynamic consultationFees;
  final String? workExperience;
  final String? photo;
  final String? gender;
  final String? phone;
  final String? email;
  final String? staffId;
  final String? doctorType;
  final List<dynamic>? inhouseDays;
  final List<dynamic>? visitingDays;
  final String? inhouseHours;
  final String? visitingHours;
  final List<dynamic>? services;
  final num? distanceKm;
  final dynamic rating;
  final dynamic reviewsCount;
  final Map<String, dynamic> rawJson;

  DoctorModel({
    this.id,
    required this.name,
    this.specialist,
    this.hospital,
    this.qualification,
    this.consultationFees,
    this.workExperience,
    this.photo,
    this.gender,
    this.phone,
    this.email,
    this.staffId,
    this.doctorType,
    this.inhouseDays,
    this.visitingDays,
    this.inhouseHours,
    this.visitingHours,
    this.services,
    this.distanceKm,
    this.rating,
    this.reviewsCount,
    this.rawJson = const {},
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    SpecialistModel? spec;
    if (json['specialist'] != null && json['specialist'] is Map) {
      spec = SpecialistModel.fromJson(
          Map<String, dynamic>.from(json['specialist']));
    }

    DoctorHospitalModel? hosp;
    if (json['hospital'] != null && json['hospital'] is Map) {
      hosp = DoctorHospitalModel.fromJson(
          Map<String, dynamic>.from(json['hospital']));
    }

    final num? dist = _safeNum(json['distance_km']) ?? hosp?.distanceKm;

    return DoctorModel(
      id: json['id'],
      name: json['name']?.toString() ?? 'Dr. Unknown',
      specialist: spec,
      hospital: hosp,
      qualification: json['qualification']?.toString(),
      consultationFees: json['consultation_fees'] ?? json['fee'] ?? json['fees'],
      workExperience: json['work_experience']?.toString(),
      photo: json['photo']?.toString() ??
          json['image']?.toString() ??
          json['profile_photo']?.toString() ??
          json['avatar']?.toString() ??
          json['photo_url']?.toString(),
      gender: json['gender']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      staffId: json['staff_id']?.toString(),
      doctorType: json['doctor_type']?.toString(),
      inhouseDays: json['inhouse_days'] is List ? json['inhouse_days'] : null,
      visitingDays: json['visiting_days'] is List ? json['visiting_days'] : null,
      inhouseHours: json['inhouse_hours']?.toString(),
      visitingHours: json['visiting_hours']?.toString(),
      services: json['services'] is List ? json['services'] : null,
      distanceKm: dist,
      rating: json['rating'],
      reviewsCount: json['reviews_count'],
      rawJson: json,
    );
  }

  String get specialtyName => specialist?.name ?? 'General Specialist';
  String get hospitalName => hospital?.name ?? 'Hospital';

  String get displayPhoto => resolveDoctorPhoto(
        photo: photo,
        domain: hospital?.domain,
        gender: gender,
      );

  static String resolveDoctorPhoto({
    dynamic photo,
    String? domain,
    String? gender,
  }) {
    if (photo != null) {
      final p = photo.toString().trim();
      if (p.isNotEmpty && p != 'null') {
        if (p.startsWith('http://') || p.startsWith('https://')) {
          return p;
        }
        if (p.startsWith('//')) {
          return 'https:$p';
        }
        final cleanPath = p.startsWith('/') ? p.substring(1) : p;
        if (domain != null && domain.isNotEmpty && domain != 'null') {
          return 'https://$domain.orderknow.com/$cleanPath';
        }
        return 'https://orderknow.com/$cleanPath';
      }
    }
    if (gender?.toLowerCase() == 'female') {
      return 'https://images.unsplash.com/photo-1594824813637-27b5e43a53c9?w=400&auto=format&fit=crop&q=80';
    }
    return 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&auto=format&fit=crop&q=80';
  }

  String get displayFee =>
      consultationFees != null ? "₹$consultationFees" : "₹500";
  String get displayExperience =>
      (workExperience != null && workExperience!.isNotEmpty)
          ? workExperience!
          : "10+ Years";

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'specialist': specialist?.toJson(),
        'hospital': hospital?.toJson(),
        'qualification': qualification,
        'consultation_fees': consultationFees,
        'work_experience': workExperience,
        'photo': photo,
        'gender': gender,
        'phone': phone,
        'email': email,
        'staff_id': staffId,
        'doctor_type': doctorType,
        'inhouse_days': inhouseDays,
        'visiting_days': visitingDays,
        'inhouse_hours': inhouseHours,
        'visiting_hours': visitingHours,
        'services': services,
        'distance_km': distanceKm,
        'rating': rating,
        'reviews_count': reviewsCount,
      };
}
