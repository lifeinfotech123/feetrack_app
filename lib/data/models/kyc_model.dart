class KycProfileModel {
  final String? id;
  final String? customerId;
  final String? livePhoto;
  final String? aadhaarFront;
  final String? aadhaarBack;
  final String? panFront;
  final String? panBack;
  final String? bankStatement;
  final String? passportFront;
  final String? passportBack;
  final String? drivingLicenseFront;
  final String? drivingLicenseBack;
  final String? status;
  final String? reviewedAt;
  final String? rejectionReason;
  final String? createdAt;
  final String? updatedAt;

  KycProfileModel({
    this.id,
    this.customerId,
    this.livePhoto,
    this.aadhaarFront,
    this.aadhaarBack,
    this.panFront,
    this.panBack,
    this.bankStatement,
    this.passportFront,
    this.passportBack,
    this.drivingLicenseFront,
    this.drivingLicenseBack,
    this.status,
    this.reviewedAt,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  factory KycProfileModel.fromJson(Map<String, dynamic> json) {
    return KycProfileModel(
      id: json['id'],
      customerId: json['customer_id'],
      livePhoto: json['live_photo'],
      aadhaarFront: json['aadhaar_front'],
      aadhaarBack: json['aadhaar_back'],
      panFront: json['pan_front'],
      panBack: json['pan_back'],
      bankStatement: json['bank_statement'],
      passportFront: json['passport_front'],
      passportBack: json['passport_back'],
      drivingLicenseFront: json['driving_license_front'],
      drivingLicenseBack: json['driving_license_back'],
      status: json['status'],
      reviewedAt: json['reviewed_at'],
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'live_photo': livePhoto,
      'aadhaar_front': aadhaarFront,
      'aadhaar_back': aadhaarBack,
      'pan_front': panFront,
      'pan_back': panBack,
      'bank_statement': bankStatement,
      'passport_front': passportFront,
      'passport_back': passportBack,
      'driving_license_front': drivingLicenseFront,
      'driving_license_back': drivingLicenseBack,
      'status': status,
      'reviewed_at': reviewedAt,
      'rejection_reason': rejectionReason,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
