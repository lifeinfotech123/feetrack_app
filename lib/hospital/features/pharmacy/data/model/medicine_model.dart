class AvailableBatch {
  final int? id;
  final String? batchNo;
  final String? expiryDate;
  final num? salePrice;
  final num? mrp;
  final int? quantity;
  final int? pharmacyId;
  final String? pharmacyName;

  AvailableBatch({
    this.id,
    this.batchNo,
    this.expiryDate,
    this.salePrice,
    this.mrp,
    this.quantity,
    this.pharmacyId,
    this.pharmacyName,
  });

  factory AvailableBatch.fromJson(Map<String, dynamic> json) {
    return AvailableBatch(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      batchNo: json['batch_no']?.toString(),
      expiryDate: json['expiry_date']?.toString(),
      salePrice: json['sale_price'] is num
          ? json['sale_price']
          : num.tryParse(json['sale_price']?.toString() ?? '0'),
      mrp: json['mrp'] is num
          ? json['mrp']
          : num.tryParse(json['mrp']?.toString() ?? '0'),
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity']?.toString() ?? '0'),
      pharmacyId: json['pharmacy_id'] is int
          ? json['pharmacy_id']
          : int.tryParse(json['pharmacy_id']?.toString() ?? ''),
      pharmacyName: json['pharmacy_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_no': batchNo,
      'expiry_date': expiryDate,
      'sale_price': salePrice,
      'mrp': mrp,
      'quantity': quantity,
      'pharmacy_id': pharmacyId,
      'pharmacy_name': pharmacyName,
    };
  }
}

class HospitalInfo {
  final int? id;
  final String? name;
  final String? domain;
  final String? portalUrl;
  final String? logo;

  HospitalInfo({
    this.id,
    this.name,
    this.domain,
    this.portalUrl,
    this.logo,
  });

  factory HospitalInfo.fromJson(Map<String, dynamic> json) {
    return HospitalInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      domain: json['domain']?.toString(),
      portalUrl: json['portal_url']?.toString(),
      logo: json['logo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'domain': domain,
      'portal_url': portalUrl,
      'logo': logo,
    };
  }
}

class MedicineModel {
  final int id;
  final String name;
  final int? categoryId;
  final String? categoryName;
  final String? medicineCompany;
  final String? medicineComposition;
  final String? medicineGroup;
  final String? unit;
  final String? unitPacking;
  final num? tax;
  final String? note;
  final String? photo;
  final num salePrice;
  final num mrp;
  final num discountPercentage;
  final bool inStock;
  final int stockQuantity;
  final List<AvailableBatch> availableBatches;
  final List<MedicineModel> relatedMedicines;
  final HospitalInfo? hospital;

  MedicineModel({
    required this.id,
    required this.name,
    this.categoryId,
    this.categoryName,
    this.medicineCompany,
    this.medicineComposition,
    this.medicineGroup,
    this.unit,
    this.unitPacking,
    this.tax,
    this.note,
    this.photo,
    required this.salePrice,
    required this.mrp,
    this.discountPercentage = 0,
    this.inStock = true,
    this.stockQuantity = 0,
    this.availableBatches = const [],
    this.relatedMedicines = const [],
    this.hospital,
  });

  String get cartKey {
    final hospKey = hospital?.domain ?? hospital?.id?.toString() ?? 'gen';
    return '${hospKey}_$id';
  }

  String get displayPhoto {
    if (photo != null && photo!.isNotEmpty) {
      return photo!;
    }
    final cat = (categoryName ?? '').toLowerCase();
    if (cat.contains('syrup') || cat.contains('liquid')) {
      return 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?q=80&w=400&auto=format&fit=crop';
    } else if (cat.contains('inject')) {
      return 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?q=80&w=400&auto=format&fit=crop';
    } else if (cat.contains('cream') || cat.contains('ointment')) {
      return 'https://images.unsplash.com/photo-1556228720-195a672e8a03?q=80&w=400&auto=format&fit=crop';
    }
    return 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=400&auto=format&fit=crop';
  }

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    List<AvailableBatch> batches = [];
    if (json['available_batches'] is List) {
      batches = (json['available_batches'] as List)
          .map((item) =>
              AvailableBatch.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    List<MedicineModel> related = [];
    if (json['related_medicines'] is List) {
      related = (json['related_medicines'] as List)
          .map(
              (item) => MedicineModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    HospitalInfo? hosp;
    if (json['hospital'] is Map) {
      hosp = HospitalInfo.fromJson(Map<String, dynamic>.from(json['hospital']));
    }

    num sPrice = 0;
    if (json['sale_price'] is num) {
      sPrice = json['sale_price'];
    } else if (json['sale_price'] != null) {
      sPrice = num.tryParse(json['sale_price'].toString()) ?? 0;
    }

    num mPrice = sPrice;
    if (json['mrp'] is num) {
      mPrice = json['mrp'];
    } else if (json['mrp'] != null) {
      mPrice = num.tryParse(json['mrp'].toString()) ?? sPrice;
    }

    num disc = 0;
    if (json['discount_percentage'] is num) {
      disc = json['discount_percentage'];
    } else if (json['discount_percentage'] != null) {
      disc = num.tryParse(json['discount_percentage'].toString()) ?? 0;
    }

    num taxVal = 0;
    if (json['tax'] is num) {
      taxVal = json['tax'];
    } else if (json['tax'] != null) {
      taxVal = num.tryParse(json['tax'].toString()) ?? 0;
    }

    int stockQty = 0;
    if (json['stock_quantity'] is int) {
      stockQty = json['stock_quantity'];
    } else if (json['stock_quantity'] != null) {
      stockQty = int.tryParse(json['stock_quantity'].toString()) ?? 0;
    }

    return MedicineModel(
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: json['name']?.toString() ?? 'Unnamed Medicine',
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id']?.toString() ?? ''),
      categoryName: json['category_name']?.toString(),
      medicineCompany: json['medicine_company']?.toString(),
      medicineComposition: json['medicine_composition']?.toString(),
      medicineGroup: json['medicine_group']?.toString(),
      unit: json['unit']?.toString(),
      unitPacking: json['unit_packing']?.toString(),
      tax: taxVal,
      note: json['note']?.toString(),
      photo: () {
        String? p = (json['photo'] ??
                json['photo_url'] ??
                json['image'] ??
                json['image_url'])
            ?.toString();
        if (p != null && p.isNotEmpty && !p.startsWith('http')) {
          final portal = hosp?.portalUrl ?? 'https://aksah.orderknow.com';
          p = p.startsWith('/') ? '$portal$p' : '$portal/$p';
        }
        return p;
      }(),
      salePrice: sPrice,
      mrp: mPrice,
      discountPercentage: disc,
      inStock: json['in_stock'] == true ||
          json['in_stock'] == 1 ||
          json['in_stock'] == '1',
      stockQuantity: stockQty,
      availableBatches: batches,
      relatedMedicines: related,
      hospital: hosp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'category_name': categoryName,
      'medicine_company': medicineCompany,
      'medicine_composition': medicineComposition,
      'medicine_group': medicineGroup,
      'unit': unit,
      'unit_packing': unitPacking,
      'tax': tax,
      'note': note,
      'photo': photo,
      'sale_price': salePrice,
      'mrp': mrp,
      'discount_percentage': discountPercentage,
      'in_stock': inStock,
      'stock_quantity': stockQuantity,
      'available_batches': availableBatches.map((e) => e.toJson()).toList(),
      'related_medicines': relatedMedicines.map((e) => e.toJson()).toList(),
      'hospital': hospital?.toJson(),
    };
  }
}
