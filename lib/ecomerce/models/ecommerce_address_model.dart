class EcommerceAddressModel {
  final int? id;
  final String name;
  final String phone;
  final String address;
  final String? city;
  final String? state;
  final String? zip;
  final String addressType; // 'home', 'work', 'office', 'other'
  final bool isDefault;
  final String? domain;
  final int? customerId;
  final String? country;

  const EcommerceAddressModel({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.city,
    this.state,
    this.zip,
    this.addressType = 'home',
    this.isDefault = false,
    this.domain,
    this.customerId,
    this.country = 'IN',
  });

  factory EcommerceAddressModel.fromJson(Map<String, dynamic> json) {
    return EcommerceAddressModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      name: json['name']?.toString() ??
          json['contact_person_name']?.toString() ??
          '',
      phone: json['phone']?.toString() ??
          json['contact_person_number']?.toString() ??
          '',
      address: json['address']?.toString() ??
          json['street_address']?.toString() ??
          json['address_line_1']?.toString() ??
          '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      zip: json['zip']?.toString() ?? json['pincode']?.toString() ?? '',
      addressType: (json['address_type']?.toString().toLowerCase()) ?? 'home',
      isDefault: json['is_default'] == true ||
          json['is_default'] == 1 ||
          json['is_default'] == '1',
      domain: json['domain']?.toString() ?? json['store_domain']?.toString(),
      customerId: json['customer_id'] is int
          ? json['customer_id']
          : int.tryParse('${json['customer_id']}'),
      country: json['country']?.toString() ?? 'IN',
    );
  }

  Map<String, dynamic> toJson({String? domain, int? userId}) {
    final effectiveDomain = (domain != null && domain.isNotEmpty)
        ? domain
        : (this.domain != null && this.domain!.isNotEmpty
            ? this.domain!
            : 'e-team-12');

    return {
      if (id != null) 'id': id,
      if (id != null) 'address_id': id,
      'domain': effectiveDomain,
      if (userId != null) 'user_id': userId,
      'address': address,
      'street_address': address,
      if (name.isNotEmpty) 'name': name,
      if (name.isNotEmpty) 'contact_person_name': name,
      if (phone.isNotEmpty) 'phone': phone,
      if (phone.isNotEmpty) 'contact_person_number': phone,
      'address_type': addressType,
      if (city != null && city!.isNotEmpty) 'city': city,
      if (state != null && state!.isNotEmpty) 'state': state,
      if (zip != null && zip!.isNotEmpty) 'zip': zip,
      if (zip != null && zip!.isNotEmpty) 'pincode': zip,
      'country': country ?? 'IN',
      'is_default': isDefault ? 1 : 0,
    };
  }

  String get formattedAddress {
    final parts = [
      address,
      if (city != null && city!.trim().isNotEmpty) city!.trim(),
      if (state != null && state!.trim().isNotEmpty) state!.trim(),
      if (zip != null && zip!.trim().isNotEmpty) zip!.trim(),
    ];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  EcommerceAddressModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? zip,
    String? addressType,
    bool? isDefault,
    String? domain,
    int? customerId,
    String? country,
  }) {
    return EcommerceAddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      addressType: addressType ?? this.addressType,
      isDefault: isDefault ?? this.isDefault,
      domain: domain ?? this.domain,
      customerId: customerId ?? this.customerId,
      country: country ?? this.country,
    );
  }
}

class CustomerProfileModel {
  final int id;
  final String name;
  final String email;
  final String phone;

  const CustomerProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}

class AddressApiResponse {
  final bool status;
  final bool isLoggedIn;
  final String message;
  final List<EcommerceAddressModel> data;
  final CustomerProfileModel? customer;

  AddressApiResponse({
    required this.status,
    required this.isLoggedIn,
    required this.message,
    required this.data,
    this.customer,
  });

  factory AddressApiResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List? ?? [];
    return AddressApiResponse(
      status: json['status'] == true,
      isLoggedIn: json['is_logged_in'] == true,
      message: json['message']?.toString() ?? '',
      data: rawList
          .map((item) =>
              EcommerceAddressModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      customer: json['customer'] != null && json['customer'] is Map
          ? CustomerProfileModel.fromJson(
              Map<String, dynamic>.from(json['customer']))
          : null,
    );
  }
}
