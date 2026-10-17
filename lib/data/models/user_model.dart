class UserModel {
  final String? id;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobile;
  final String? countryCode;
  final String? gender;
  final String? dateOfBirth;
  final String? bloodGroup;
  final String? role;
  final String? image;
  final String? status;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;
  final String? walletBalance;
  final bool? emailVerifiedAt;
  final bool? mobileVerifiedAt;
  final dynamic fcmToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;

  UserModel({
    this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.countryCode,
    this.gender,
    this.dateOfBirth,
    this.bloodGroup,
    this.role,
    this.image,
    this.status,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.country,
    this.walletBalance,
    this.emailVerifiedAt,
    this.mobileVerifiedAt,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"]?.toString(),
        name: json["name"] ??
            ("${json["first_name"] ?? ''} ${json["last_name"] ?? ''}").trim(),
        firstName: json["first_name"]?.toString(),
        lastName: json["last_name"]?.toString(),
        email: json["email"]?.toString(),
        mobile: json["phone"]?.toString() ?? json["mobile"]?.toString(),
        countryCode: json["country_code"]?.toString() ?? "+91",
        gender: json["gender"]?.toString(),
        dateOfBirth:
            json["date_of_birth"]?.toString() ?? json["dob"]?.toString(),
        bloodGroup: json["blood_group"]?.toString(),
        role: json["role"]?.toString(),
        image: json["avatar"] ??
            json["profile_image"] ??
            json["image"] ??
            json["photo"],
        status: json["status"]?.toString(),
        address: json["address"]?.toString(),
        city: json["city"]?.toString(),
        state: json["state"]?.toString(),
        pincode: json["pincode"]?.toString(),
        country: json["country"]?.toString() ?? "India",
        walletBalance: json["wallet_balance"]?.toString(),
        emailVerifiedAt: json["email_verified_at"] is bool
            ? json["email_verified_at"]
            : json["email_verified_at"] != null,
        mobileVerifiedAt: json["phone_verified_at"] != null ||
            json["mobile_verified_at"] != null,
        fcmToken: json["fcm_token"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"]?.toString() ?? ""),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.tryParse(json["updated_at"]?.toString() ?? ""),
        deletedAt: json["deleted_at"],
      );

  Object? get phone => null;

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "mobile": mobile,
        "country_code": countryCode,
        "gender": gender,
        "date_of_birth": dateOfBirth,
        "blood_group": bloodGroup,
        "role": role,
        "image": image,
        "status": status,
        "address": address,
        "city": city,
        "state": state,
        "pincode": pincode,
        "country": country,
        "wallet_balance": walletBalance,
        "email_verified_at": emailVerifiedAt,
        "mobile_verified_at": mobileVerifiedAt,
        "fcm_token": fcmToken,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
      };
}
