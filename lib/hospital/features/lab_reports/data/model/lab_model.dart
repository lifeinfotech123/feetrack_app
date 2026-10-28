import '../../../pharmacy/data/model/medicine_model.dart';
import '../../../pharmacy/data/model/order_model.dart';

class LabStatsModel {
  final int totalDiagnosticLabs;
  final int inHouseHospitalLabs;
  final int partnerLabsSaas;
  final int activeSubscribedPlans;

  LabStatsModel({
    this.totalDiagnosticLabs = 0,
    this.inHouseHospitalLabs = 0,
    this.partnerLabsSaas = 0,
    this.activeSubscribedPlans = 0,
  });

  factory LabStatsModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return LabStatsModel(
      totalDiagnosticLabs: parseInt(json['total_diagnostic_labs']),
      inHouseHospitalLabs: parseInt(json['in_house_hospital_labs']),
      partnerLabsSaas: parseInt(json['partner_labs_saas']),
      activeSubscribedPlans: parseInt(json['active_subscribed_plans']),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_diagnostic_labs': totalDiagnosticLabs,
        'in_house_hospital_labs': inHouseHospitalLabs,
        'partner_labs_saas': partnerLabsSaas,
        'active_subscribed_plans': activeSubscribedPlans,
      };
}

class LabCategoryModel {
  final String name;
  final String slug;
  final int testsCount;

  LabCategoryModel({
    required this.name,
    required this.slug,
    this.testsCount = 0,
  });

  factory LabCategoryModel.fromJson(Map<String, dynamic> json) {
    int count = 0;
    if (json['tests_count'] is int) {
      count = json['tests_count'];
    } else if (json['tests_count'] != null) {
      count = int.tryParse(json['tests_count'].toString()) ?? 0;
    }

    return LabCategoryModel(
      name: json['name']?.toString() ?? 'Category',
      slug: json['slug']?.toString() ?? 'all',
      testsCount: count,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'slug': slug,
        'tests_count': testsCount,
      };
}

class DiagnosticLabModel {
  final int id;
  final int? labId;
  final String labName;
  final String? labCode;
  final String? labType;
  final String? labClassification;
  final String? category;
  final String? inchargeName;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? location;
  final bool nablAccredited;
  final bool homeCollectionAvailable;
  final num homeCollectionCharges;
  final String? timing;
  final String? timeFrom;
  final String? timeTo;
  final num rating;
  final bool isActive;
  final String status;
  final String? saasPlan;
  final String? platformSplit;
  final num commissionRate;
  final HospitalInfo? hospital;

  DiagnosticLabModel({
    required this.id,
    this.labId,
    required this.labName,
    this.labCode,
    this.labType,
    this.labClassification,
    this.category,
    this.inchargeName,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.location,
    this.nablAccredited = false,
    this.homeCollectionAvailable = false,
    this.homeCollectionCharges = 0,
    this.timing,
    this.timeFrom,
    this.timeTo,
    this.rating = 4.5,
    this.isActive = true,
    this.status = 'Active',
    this.saasPlan,
    this.platformSplit,
    this.commissionRate = 0,
    this.hospital,
  });

  factory DiagnosticLabModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v != null) return int.tryParse(v.toString()) ?? 0;
      return 0;
    }

    num parseNum(dynamic v) {
      if (v is num) return v;
      if (v != null) return num.tryParse(v.toString()) ?? 0;
      return 0;
    }

    HospitalInfo? hosp;
    if (json['hospital'] is Map) {
      hosp = HospitalInfo.fromJson(Map<String, dynamic>.from(json['hospital']));
    }

    return DiagnosticLabModel(
      id: parseInt(json['id'] ?? json['lab_id']),
      labId: json['lab_id'] != null ? parseInt(json['lab_id']) : null,
      labName: json['lab_name']?.toString() ?? 'Diagnostic Lab',
      labCode: json['lab_code']?.toString(),
      labType: json['lab_type']?.toString(),
      labClassification: json['lab_classification']?.toString(),
      category: json['category']?.toString(),
      inchargeName: json['incharge_name']?.toString() ?? json['incharge']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      location: json['location']?.toString(),
      nablAccredited: json['nabl_accredited'] == true || json['nabl_accredited'] == 1,
      homeCollectionAvailable: json['home_collection_available'] == true ||
          json['home_collection'] == true ||
          json['home_collection'] == 1,
      homeCollectionCharges: parseNum(json['home_collection_charges']),
      timing: json['timing']?.toString(),
      timeFrom: json['time_from']?.toString(),
      timeTo: json['time_to']?.toString(),
      rating: parseNum(json['rating'] ?? 4.5),
      isActive: json['is_active'] != false && json['status'] != 'Inactive',
      status: json['status']?.toString() ?? 'Active',
      saasPlan: json['saas_plan']?.toString(),
      platformSplit: json['platform_split']?.toString(),
      commissionRate: parseNum(json['commission_rate']),
      hospital: hosp,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lab_id': labId,
        'lab_name': labName,
        'lab_code': labCode,
        'lab_type': labType,
        'lab_classification': labClassification,
        'category': category,
        'incharge_name': inchargeName,
        'phone': phone,
        'email': email,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
        'location': location,
        'nabl_accredited': nablAccredited,
        'home_collection_available': homeCollectionAvailable,
        'home_collection_charges': homeCollectionCharges,
        'timing': timing,
        'rating': rating,
        'status': status,
        'saas_plan': saasPlan,
        'platform_split': platformSplit,
        'commission_rate': commissionRate,
        'hospital': hospital?.toJson(),
      };
}

class LabTestCenterInfo {
  final int? labId;
  final String labName;
  final String? labCode;
  final String? location;
  final String? city;
  final num price;
  final String? time;
  final num rating;
  final bool homeCollection;
  final num homeCollectionCharges;
  final HospitalInfo? hospital;

  LabTestCenterInfo({
    this.labId,
    required this.labName,
    this.labCode,
    this.location,
    this.city,
    this.price = 0,
    this.time,
    this.rating = 4.5,
    this.homeCollection = false,
    this.homeCollectionCharges = 0,
    this.hospital,
  });

  factory LabTestCenterInfo.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic v) {
      if (v is num) return v;
      if (v != null) return num.tryParse(v.toString()) ?? 0;
      return 0;
    }

    HospitalInfo? hosp;
    if (json['hospital'] is Map) {
      hosp = HospitalInfo.fromJson(Map<String, dynamic>.from(json['hospital']));
    }

    return LabTestCenterInfo(
      labId: json['lab_id'] is int ? json['lab_id'] : int.tryParse(json['lab_id']?.toString() ?? ''),
      labName: json['lab_name']?.toString() ?? 'Diagnostic Center',
      labCode: json['lab_code']?.toString(),
      location: json['location']?.toString(),
      city: json['city']?.toString(),
      price: parseNum(json['price']),
      time: json['time']?.toString(),
      rating: parseNum(json['rating'] ?? 4.5),
      homeCollection: json['home_collection'] == true || json['home_collection'] == 1,
      homeCollectionCharges: parseNum(json['home_collection_charges']),
      hospital: hosp,
    );
  }

  Map<String, dynamic> toJson() => {
        'lab_id': labId,
        'lab_name': labName,
        'lab_code': labCode,
        'location': location,
        'city': city,
        'price': price,
        'time': time,
        'rating': rating,
        'home_collection': homeCollection,
        'home_collection_charges': homeCollectionCharges,
        'hospital': hospital?.toJson(),
      };
}

class LabTestModel {
  final int id;
  final String? slug;
  final String testName;
  final String? shortName;
  final String? testType;
  final int? categoryId;
  final String? category;
  final String? subCategory;
  final String? method;
  final String? sampleType;
  final String? description;
  final int reportDays;
  final String? reportTime;
  final num basePrice;
  final num standardCharge;
  final num tax;
  final HospitalInfo? hospital;
  final List<LabTestCenterInfo> labs;

  LabTestModel({
    required this.id,
    this.slug,
    required this.testName,
    this.shortName,
    this.testType,
    this.categoryId,
    this.category,
    this.subCategory,
    this.method,
    this.sampleType,
    this.description,
    this.reportDays = 1,
    this.reportTime,
    required this.basePrice,
    this.standardCharge = 0,
    this.tax = 0,
    this.hospital,
    this.labs = const [],
  });

  factory LabTestModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v != null) return int.tryParse(v.toString()) ?? 0;
      return 0;
    }

    num parseNum(dynamic v) {
      if (v is num) return v;
      if (v != null) return num.tryParse(v.toString()) ?? 0;
      return 0;
    }

    HospitalInfo? hosp;
    if (json['hospital'] is Map) {
      hosp = HospitalInfo.fromJson(Map<String, dynamic>.from(json['hospital']));
    }

    List<LabTestCenterInfo> labsList = [];
    if (json['labs'] is List) {
      labsList = (json['labs'] as List)
          .map((e) => LabTestCenterInfo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final price = parseNum(json['base_price'] ?? json['standard_charge'] ?? json['price']);

    return LabTestModel(
      id: parseInt(json['id']),
      slug: json['slug']?.toString(),
      testName: json['test_name']?.toString() ?? 'Diagnostic Test',
      shortName: json['short_name']?.toString(),
      testType: json['test_type']?.toString() ?? 'Pathology',
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id']?.toString() ?? ''),
      category: json['category']?.toString(),
      subCategory: json['sub_category']?.toString(),
      method: json['method']?.toString(),
      sampleType: json['sample_type']?.toString() ?? 'Blood Sample',
      description: json['description']?.toString(),
      reportDays: parseInt(json['report_days'] ?? 1),
      reportTime: json['report_time']?.toString() ?? 'Report within 24 Hours',
      basePrice: price,
      standardCharge: parseNum(json['standard_charge'] ?? price),
      tax: parseNum(json['tax']),
      hospital: hosp,
      labs: labsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'test_name': testName,
        'short_name': shortName,
        'test_type': testType,
        'category_id': categoryId,
        'category': category,
        'sub_category': subCategory,
        'method': method,
        'sample_type': sampleType,
        'description': description,
        'report_days': reportDays,
        'report_time': reportTime,
        'base_price': basePrice,
        'standard_charge': standardCharge,
        'tax': tax,
        'hospital': hospital?.toJson(),
        'labs': labs.map((e) => e.toJson()).toList(),
      };
}

class LabBookingRequest {
  final String patientName;
  final String patientPhone;
  final String address;
  final String collectionType;
  final String bookingDate;
  final String testName;
  final String paymentMode;
  final String? hospital;
  final int? labId;

  LabBookingRequest({
    required this.patientName,
    required this.patientPhone,
    required this.address,
    this.collectionType = 'Home',
    required this.bookingDate,
    required this.testName,
    this.paymentMode = 'Razorpay',
    this.hospital,
    this.labId,
  });

  Map<String, dynamic> toJson() => {
        'patient_name': patientName,
        'patient_phone': patientPhone,
        'address': address,
        'collection_type': collectionType,
        'booking_date': bookingDate,
        'test_name': testName,
        'payment_mode': paymentMode,
        if (hospital != null && hospital!.isNotEmpty) 'hospital': hospital,
        if (labId != null) 'lab_id': labId,
      };
}

class LabBookingResponse {
  final bool success;
  final int? bookingId;
  final String? bookingNo;
  final String? patientName;
  final String? patientPhone;
  final String? testName;
  final String? labName;
  final String? collectionType;
  final String? bookingDate;
  final num? testAmount;
  final num? homeCollectionCharges;
  final num? netAmount;
  final String? paymentMode;
  final String? paymentStatus;
  final String? bookingStatus;
  final RazorpayOrderData? razorpay;
  final HospitalInfo? hospital;
  final String? message;

  LabBookingResponse({
    this.success = false,
    this.bookingId,
    this.bookingNo,
    this.patientName,
    this.patientPhone,
    this.testName,
    this.labName,
    this.collectionType,
    this.bookingDate,
    this.testAmount,
    this.homeCollectionCharges,
    this.netAmount,
    this.paymentMode,
    this.paymentStatus,
    this.bookingStatus,
    this.razorpay,
    this.hospital,
    this.message,
  });

  factory LabBookingResponse.fromJson(Map<String, dynamic> json,
      {String? msg, bool? isSuccess}) {
    num parseNum(dynamic v) {
      if (v is num) return v;
      if (v != null) return num.tryParse(v.toString()) ?? 0;
      return 0;
    }

    final hasSuccess = isSuccess ??
        (json['success'] == true ||
            json['success'] == 1 ||
            json['status'] == true ||
            json['booking_id'] != null ||
            json['booking_no'] != null);

    return LabBookingResponse(
      success: hasSuccess,
      bookingId: json['booking_id'] is int
          ? json['booking_id']
          : int.tryParse(json['booking_id']?.toString() ?? ''),
      bookingNo: json['booking_no']?.toString(),
      patientName: json['patient_name']?.toString(),
      patientPhone: json['patient_phone']?.toString(),
      testName: json['test_name']?.toString(),
      labName: json['lab_name']?.toString(),
      collectionType: json['collection_type']?.toString(),
      bookingDate: json['booking_date']?.toString(),
      testAmount: parseNum(json['test_amount']),
      homeCollectionCharges: parseNum(json['home_collection_charges']),
      netAmount: parseNum(json['net_amount']),
      paymentMode: json['payment_mode']?.toString() ?? 'Razorpay',
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      bookingStatus: json['booking_status']?.toString() ?? 'pending',
      razorpay: json['razorpay'] is Map
          ? RazorpayOrderData.fromJson(
              Map<String, dynamic>.from(json['razorpay']))
          : null,
      hospital: json['hospital'] is Map
          ? HospitalInfo.fromJson(Map<String, dynamic>.from(json['hospital']))
          : null,
      message: msg ?? json['message']?.toString(),
    );
  }
}

class LabVerifyPaymentResponse {
  final bool success;
  final int? bookingId;
  final String? bookingNo;
  final String? bookingStatus;
  final String? paymentStatus;
  final String? paymentMode;
  final String? razorpayPaymentId;
  final String? message;

  LabVerifyPaymentResponse({
    this.success = false,
    this.bookingId,
    this.bookingNo,
    this.bookingStatus,
    this.paymentStatus,
    this.paymentMode,
    this.razorpayPaymentId,
    this.message,
  });

  factory LabVerifyPaymentResponse.fromJson(Map<String, dynamic> json, {String? msg}) {
    final data = json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json;

    return LabVerifyPaymentResponse(
      success: json['success'] == true || json['status'] == true,
      bookingId: data['booking_id'] is int ? data['booking_id'] : int.tryParse(data['booking_id']?.toString() ?? ''),
      bookingNo: data['booking_no']?.toString(),
      bookingStatus: data['booking_status']?.toString() ?? 'confirmed',
      paymentStatus: data['payment_status']?.toString() ?? 'paid',
      paymentMode: data['payment_mode']?.toString() ?? 'Razorpay',
      razorpayPaymentId: data['razorpay_payment_id']?.toString(),
      message: msg ?? json['message']?.toString(),
    );
  }
}

class PatientLabBookingItemModel {
  final int? id;
  final int? bookingId;
  final int? testId;
  final String? testName;
  final String? testType;
  final String? categoryName;
  final dynamic price;
  final dynamic resultValues;
  final String? createdAt;
  final String? updatedAt;

  PatientLabBookingItemModel({
    this.id,
    this.bookingId,
    this.testId,
    this.testName,
    this.testType,
    this.categoryName,
    this.price,
    this.resultValues,
    this.createdAt,
    this.updatedAt,
  });

  factory PatientLabBookingItemModel.fromJson(Map<String, dynamic> json) {
    return PatientLabBookingItemModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      bookingId: json['booking_id'] is int
          ? json['booking_id']
          : int.tryParse(json['booking_id']?.toString() ?? ''),
      testId: json['test_id'] is int
          ? json['test_id']
          : int.tryParse(json['test_id']?.toString() ?? ''),
      testName: json['test_name']?.toString(),
      testType: json['test_type']?.toString(),
      categoryName: json['category_name']?.toString(),
      price: json['price'],
      resultValues: json['result_values'],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_id': bookingId,
        'test_id': testId,
        'test_name': testName,
        'test_type': testType,
        'category_name': categoryName,
        'price': price,
        'result_values': resultValues,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class PatientLabBookingModel {
  final int? bookingId;
  final String? bookingNo;
  final int? appUserId;
  final int? patientId;
  final String? patientName;
  final String? patientPhone;
  final String? collectionType;
  final String? bookingDate;
  final String? timeSlot;
  final dynamic netAmount;
  final String? paymentMode;
  final String? paymentStatus;
  final String? bookingStatus;
  final String? reportPdf;
  final String? labName;
  final List<PatientLabBookingItemModel> items;
  final HospitalInfo? hospital;

  PatientLabBookingModel({
    this.bookingId,
    this.bookingNo,
    this.appUserId,
    this.patientId,
    this.patientName,
    this.patientPhone,
    this.collectionType,
    this.bookingDate,
    this.timeSlot,
    this.netAmount,
    this.paymentMode,
    this.paymentStatus,
    this.bookingStatus,
    this.reportPdf,
    this.labName,
    this.items = const [],
    this.hospital,
  });

  String get primaryTestName {
    if (items.isNotEmpty &&
        items.first.testName != null &&
        items.first.testName!.isNotEmpty) {
      return items.first.testName!;
    }
    return 'Diagnostic Lab Test';
  }

  factory PatientLabBookingModel.fromJson(Map<String, dynamic> json) {
    List<PatientLabBookingItemModel> parsedItems = [];
    if (json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((i) =>
              PatientLabBookingItemModel.fromJson(Map<String, dynamic>.from(i)))
          .toList();
    }

    HospitalInfo? hosp;
    if (json['hospital'] is Map) {
      hosp = HospitalInfo.fromJson(Map<String, dynamic>.from(json['hospital']));
    }

    return PatientLabBookingModel(
      bookingId: json['booking_id'] is int
          ? json['booking_id']
          : int.tryParse(json['booking_id']?.toString() ?? ''),
      bookingNo: json['booking_no']?.toString(),
      appUserId: json['app_user_id'] is int
          ? json['app_user_id']
          : int.tryParse(json['app_user_id']?.toString() ?? ''),
      patientId: json['patient_id'] is int
          ? json['patient_id']
          : int.tryParse(json['patient_id']?.toString() ?? ''),
      patientName: json['patient_name']?.toString(),
      patientPhone: json['patient_phone']?.toString(),
      collectionType: json['collection_type']?.toString(),
      bookingDate: json['booking_date']?.toString(),
      timeSlot: json['time_slot']?.toString(),
      netAmount: json['net_amount'],
      paymentMode: json['payment_mode']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      bookingStatus: json['booking_status']?.toString(),
      reportPdf: json['report_pdf']?.toString(),
      labName: json['lab_name']?.toString(),
      items: parsedItems,
      hospital: hosp,
    );
  }

  Map<String, dynamic> toJson() => {
        'booking_id': bookingId,
        'booking_no': bookingNo,
        'app_user_id': appUserId,
        'patient_id': patientId,
        'patient_name': patientName,
        'patient_phone': patientPhone,
        'collection_type': collectionType,
        'booking_date': bookingDate,
        'time_slot': timeSlot,
        'net_amount': netAmount,
        'payment_mode': paymentMode,
        'payment_status': paymentStatus,
        'booking_status': bookingStatus,
        'report_pdf': reportPdf,
        'lab_name': labName,
        'items': items.map((e) => e.toJson()).toList(),
        'hospital': hospital?.toJson(),
      };
}

