import 'medicine_model.dart';

class PharmacyStoreModel {
  final int id;
  final String pharmacyName;
  final String? pharmacyCode;
  final String? pharmacyType;
  final num deliveryCharge;
  final num minFreeDeliveryAmount;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final int? hospitalId;
  final String? hospitalDomain;
  final HospitalInfo? hospital;

  PharmacyStoreModel({
    required this.id,
    required this.pharmacyName,
    this.pharmacyCode,
    this.pharmacyType,
    this.deliveryCharge = 0,
    this.minFreeDeliveryAmount = 0,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.hospitalId,
    this.hospitalDomain,
    this.hospital,
  });

  factory PharmacyStoreModel.fromJson(Map<String, dynamic> json) {
    HospitalInfo? hosp;
    if (json['hospital'] is Map) {
      hosp = HospitalInfo.fromJson(Map<String, dynamic>.from(json['hospital']));
    }

    num delCharge = 0;
    if (json['delivery_charge'] is num) {
      delCharge = json['delivery_charge'];
    } else if (json['delivery_charge'] != null) {
      delCharge = num.tryParse(json['delivery_charge'].toString()) ?? 0;
    }

    num minFree = 0;
    if (json['min_free_delivery_amount'] is num) {
      minFree = json['min_free_delivery_amount'];
    } else if (json['min_free_delivery_amount'] != null) {
      minFree = num.tryParse(json['min_free_delivery_amount'].toString()) ?? 0;
    }

    return PharmacyStoreModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      pharmacyName: json['pharmacy_name']?.toString() ?? 'Pharmacy Store',
      pharmacyCode: json['pharmacy_code']?.toString(),
      pharmacyType: json['pharmacy_type']?.toString(),
      deliveryCharge: delCharge,
      minFreeDeliveryAmount: minFree,
      contactPerson: json['contact_person']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
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
      'pharmacy_name': pharmacyName,
      'pharmacy_code': pharmacyCode,
      'pharmacy_type': pharmacyType,
      'delivery_charge': deliveryCharge,
      'min_free_delivery_amount': minFreeDeliveryAmount,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'hospital_id': hospitalId,
      'hospital_domain': hospitalDomain,
      'hospital': hospital?.toJson(),
    };
  }
}
