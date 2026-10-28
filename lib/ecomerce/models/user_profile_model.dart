class UserProfileModel {
  final int id;
  final String name;
  final String? firstName;
  final String? lastName;
  final String email;
  final String phone;
  final String? countryCode;
  final String? gender;
  final String? avatar;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;
  final String status;
  final double walletAmount;

  UserProfileModel({
    required this.id,
    required this.name,
    this.firstName,
    this.lastName,
    required this.email,
    required this.phone,
    this.countryCode,
    this.gender,
    this.avatar,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.country,
    required this.status,
    required this.walletAmount,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user = json['user'] is Map<String, dynamic>
        ? json['user']
        : (json['data'] is Map<String, dynamic> &&
                json['data']['user'] is Map<String, dynamic>
            ? json['data']['user']
            : json);

    // Wallet amount can be root level in json or under user object
    final num? rootWallet = (json['walletAmount'] as num?) ??
        (json['wallet'] is Map ? json['wallet']['balance'] as num? : null);
    final num? userWallet = (user['walletAmount'] as num?) ??
        (user['wallet'] is Map ? user['wallet']['balance'] as num? : null);
    final double finalWallet = (rootWallet ?? userWallet ?? 0.0).toDouble();

    return UserProfileModel(
      id: user['id'] is int
          ? user['id']
          : int.tryParse(user['id']?.toString() ?? '0') ?? 0,
      name: user['name']?.toString() ?? 'User',
      firstName: user['first_name']?.toString(),
      lastName: user['last_name']?.toString(),
      email: user['email']?.toString() ?? '',
      phone: user['phone']?.toString() ?? '',
      countryCode: user['country_code']?.toString(),
      gender: user['gender']?.toString(),
      avatar: user['avatar']?.toString(),
      address: user['address']?.toString(),
      city: user['city']?.toString(),
      state: user['state']?.toString(),
      pincode: user['pincode']?.toString(),
      country: user['country']?.toString(),
      status: user['status']?.toString() ?? 'active',
      walletAmount: finalWallet,
    );
  }
}
