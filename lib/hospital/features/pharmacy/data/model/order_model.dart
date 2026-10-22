import 'medicine_model.dart';

class CartItem {
  final MedicineModel medicine;
  int qty;
  final AvailableBatch? selectedBatch;

  CartItem({
    required this.medicine,
    this.qty = 1,
    this.selectedBatch,
  });

  num get itemPrice => selectedBatch?.salePrice ?? medicine.salePrice;
  num get itemTax => medicine.tax ?? 0;
  num get totalItemPrice => itemPrice * qty;
  num get totalItemTax => (totalItemPrice * (itemTax / 100));
  String get cartKey => medicine.cartKey;
}

class PlaceOrderItem {
  final int id;
  final int qty;

  PlaceOrderItem({required this.id, required this.qty});

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicine_id': id,
        'qty': qty,
        'quantity': qty,
      };
}

class PlaceOrderRequest {
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String shippingAddress;
  final String paymentMode;
  final String hospital;
  final List<PlaceOrderItem> items;

  PlaceOrderRequest({
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.shippingAddress,
    this.paymentMode = 'online',
    required this.hospital,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_email': customerEmail,
        'shipping_address': shippingAddress,
        'payment_mode': paymentMode,
        'payment_method': paymentMode,
        'hospital': hospital.isNotEmpty ? hospital : 'usha',
        'hospital_domain': hospital.isNotEmpty ? hospital : 'usha',
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class RazorpayPrefill {
  final String? name;
  final String? contact;
  final String? email;

  RazorpayPrefill({this.name, this.contact, this.email});

  factory RazorpayPrefill.fromJson(Map<String, dynamic> json) {
    return RazorpayPrefill(
      name: json['name']?.toString(),
      contact: json['contact']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

class RazorpayOrderData {
  final String? orderId;
  final num? amount;
  final num? amountRupees;
  final String? currency;
  final String? key;
  final String? name;
  final String? description;
  final RazorpayPrefill? prefill;

  RazorpayOrderData({
    this.orderId,
    this.amount,
    this.amountRupees,
    this.currency,
    this.key,
    this.name,
    this.description,
    this.prefill,
  });

  factory RazorpayOrderData.fromJson(Map<String, dynamic> json) {
    return RazorpayOrderData(
      orderId: (json['order_id'] ?? json['razorpay_order_id'] ?? json['id'])
          ?.toString(),
      amount: json['amount'] is num
          ? json['amount']
          : num.tryParse(
              (json['amount'] ?? json['amount_in_paise'])?.toString() ?? '0',
            ),
      amountRupees: json['amount_rupees'] is num
          ? json['amount_rupees']
          : num.tryParse(json['amount_rupees']?.toString() ?? '0'),
      currency: json['currency']?.toString() ?? 'INR',
      key: (json['key'] ?? json['key_id'] ?? json['razorpay_key_id'])
          ?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      prefill: json['prefill'] is Map
          ? RazorpayPrefill.fromJson(Map<String, dynamic>.from(json['prefill']))
          : null,
    );
  }
}

class OrderBillItem {
  final int? billId;
  final String? billNo;
  final String? groupOrderNo;
  final num? netAmount;
  final String? orderStatus;
  final String? paymentStatus;

  OrderBillItem({
    this.billId,
    this.billNo,
    this.groupOrderNo,
    this.netAmount,
    this.orderStatus,
    this.paymentStatus,
  });

  factory OrderBillItem.fromJson(Map<String, dynamic> json) {
    return OrderBillItem(
      billId: json['bill_id'] is int
          ? json['bill_id']
          : int.tryParse(json['bill_id']?.toString() ?? ''),
      billNo: json['bill_no']?.toString(),
      groupOrderNo: json['group_order_no']?.toString(),
      netAmount: json['net_amount'] is num
          ? json['net_amount']
          : num.tryParse(json['net_amount']?.toString() ?? '0'),
      orderStatus: json['order_status']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
    );
  }
}

class PlaceOrderResponse {
  final bool success;
  final int? billId;
  final String? billNo;
  final String? groupOrderNo;
  final num? grandTotal;
  final String? paymentMode;
  final String? orderStatus;
  final List<OrderBillItem> bills;
  final RazorpayOrderData? razorpay;
  final HospitalInfo? hospital;
  final String? message;
  final String? labName;
  final String? storeName;

  PlaceOrderResponse({
    this.success = false,
    this.billId,
    this.billNo,
    this.groupOrderNo,
    this.grandTotal,
    this.paymentMode,
    this.orderStatus,
    this.bills = const [],
    this.razorpay,
    this.hospital,
    this.message,
    this.labName,
    this.storeName,
  });

  factory PlaceOrderResponse.fromJson(Map<String, dynamic> json,
      {String? msg}) {
    var data = Map<String, dynamic>.from(json);
    for (var depth = 0; depth < 3 && data['data'] is Map; depth++) {
      data = {
        ...data,
        ...Map<String, dynamic>.from(data['data'] as Map),
      };
    }

    final rawRazorpay =
        data['razorpay'] ?? data['payment'] ?? data['payment_gateway'];
    final razorpayData = <String, dynamic>{
      ...data,
      if (rawRazorpay is Map) ...Map<String, dynamic>.from(rawRazorpay),
    };
    if (razorpayData['order'] is Map) {
      razorpayData.addAll(Map<String, dynamic>.from(razorpayData['order']));
    }
    final hasRazorpayDetails = razorpayData['order_id'] != null ||
        razorpayData['razorpay_order_id'] != null ||
        razorpayData['amount'] != null ||
        razorpayData['key'] != null ||
        razorpayData['key_id'] != null;

    List<OrderBillItem> billsList = [];
    if (data['bills'] is List) {
      billsList = (data['bills'] as List)
          .map((e) => OrderBillItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final resolvedLabName = data['lab_name']?.toString() ??
        data['lab']?.toString() ??
        data['pharmacy_name']?.toString() ??
        data['hospital_name']?.toString() ??
        (data['hospital'] is Map
            ? data['hospital']['name']?.toString()
            : null) ??
        (data['hospital'] is String ? data['hospital']?.toString() : null);

    return PlaceOrderResponse(
      success: data['success'] == true ||
          data['success'] == 1 ||
          data['status'] == true ||
          hasRazorpayDetails ||
          (data['group_order_no'] != null &&
              data['group_order_no'].toString().isNotEmpty) ||
          (data['bill_id'] != null),
      billId: data['bill_id'] is int
          ? data['bill_id']
          : int.tryParse(data['bill_id']?.toString() ?? ''),
      billNo: data['bill_no']?.toString(),
      groupOrderNo: data['group_order_no']?.toString(),
      grandTotal: data['grand_total'] is num
          ? data['grand_total']
          : num.tryParse(data['grand_total']?.toString() ?? '0'),
      paymentMode: data['payment_mode']?.toString(),
      orderStatus: data['order_status']?.toString() ?? 'pending',
      bills: billsList,
      razorpay:
          hasRazorpayDetails ? RazorpayOrderData.fromJson(razorpayData) : null,
      hospital: data['hospital'] is Map
          ? HospitalInfo.fromJson(Map<String, dynamic>.from(data['hospital']))
          : null,
      message: msg,
      labName: resolvedLabName,
      storeName:
          data['store_name']?.toString() ?? data['pharmacy_name']?.toString(),
    );
  }
}

class VerifyPaymentRequest {
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;
  final String groupOrderNo;
  final int billId;
  final String hospital;

  VerifyPaymentRequest({
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
    required this.groupOrderNo,
    required this.billId,
    required this.hospital,
  });

  Map<String, dynamic> toJson() => {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
        'group_order_no': groupOrderNo,
        'bill_id': billId,
        'hospital': hospital,
      };
}

class VerifyPaymentResponse {
  final bool success;
  final bool alreadyVerified;
  final String? orderStatus;
  final String? paymentStatus;
  final String? paymentMode;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final List<OrderBillItem> bills;
  final HospitalInfo? hospital;
  final String? message;
  final String? labName;
  final String? storeName;

  VerifyPaymentResponse({
    this.success = false,
    this.alreadyVerified = false,
    this.orderStatus,
    this.paymentStatus,
    this.paymentMode,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.bills = const [],
    this.hospital,
    this.message,
    this.labName,
    this.storeName,
  });

  factory VerifyPaymentResponse.fromJson(Map<String, dynamic> json,
      {String? msg}) {
    List<OrderBillItem> billsList = [];
    if (json['bills'] is List) {
      billsList = (json['bills'] as List)
          .map((e) => OrderBillItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final resolvedLabName = json['lab_name']?.toString() ??
        json['lab']?.toString() ??
        json['pharmacy_name']?.toString() ??
        json['hospital_name']?.toString() ??
        (json['hospital'] is Map
            ? json['hospital']['name']?.toString()
            : null) ??
        (json['hospital'] is String ? json['hospital']?.toString() : null);

    return VerifyPaymentResponse(
      success: json['success'] == true ||
          json['success'] == 1 ||
          json['status'] == true ||
          json['order_status'] == 'confirmed' ||
          json['payment_status'] == 'paid' ||
          (msg != null && msg.toLowerCase().contains('success')),
      alreadyVerified:
          json['already_verified'] == true || json['already_verified'] == 1,
      orderStatus: json['order_status']?.toString() ?? 'confirmed',
      paymentStatus: json['payment_status']?.toString() ?? 'paid',
      paymentMode: json['payment_mode']?.toString(),
      razorpayOrderId: json['razorpay_order_id']?.toString(),
      razorpayPaymentId: json['razorpay_payment_id']?.toString(),
      bills: billsList,
      hospital: json['hospital'] is Map
          ? HospitalInfo.fromJson(Map<String, dynamic>.from(json['hospital']))
          : null,
      message: msg,
      labName: resolvedLabName,
      storeName:
          json['store_name']?.toString() ?? json['pharmacy_name']?.toString(),
    );
  }
}

class PatientMedicineOrder {
  final int? billId;
  final String? billNo;
  final int? appUserId;
  final int? patientId;
  final String? customerName;
  final String? customerPhone;
  final String? groupOrderNo;
  final String? billDate;
  final num? netAmount;
  final String? orderStatus;
  final String? paymentMode;
  final num? paymentAmount;
  final HospitalInfo? hospital;

  PatientMedicineOrder({
    this.billId,
    this.billNo,
    this.appUserId,
    this.patientId,
    this.customerName,
    this.customerPhone,
    this.groupOrderNo,
    this.billDate,
    this.netAmount,
    this.orderStatus,
    this.paymentMode,
    this.paymentAmount,
    this.hospital,
  });

  factory PatientMedicineOrder.fromJson(Map<String, dynamic> json) {
    return PatientMedicineOrder(
      billId: json['bill_id'] is int
          ? json['bill_id']
          : int.tryParse(json['bill_id']?.toString() ?? ''),
      billNo: json['bill_no']?.toString(),
      appUserId: json['app_user_id'] is int
          ? json['app_user_id']
          : int.tryParse(json['app_user_id']?.toString() ?? ''),
      patientId: json['patient_id'] is int
          ? json['patient_id']
          : int.tryParse(json['patient_id']?.toString() ?? ''),
      customerName: json['customer_name']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
      groupOrderNo: json['group_order_no']?.toString(),
      billDate: json['bill_date']?.toString(),
      netAmount: json['net_amount'] is num
          ? json['net_amount']
          : num.tryParse(json['net_amount']?.toString() ?? '0'),
      orderStatus: json['order_status']?.toString(),
      paymentMode: json['payment_mode']?.toString(),
      paymentAmount: json['payment_amount'] is num
          ? json['payment_amount']
          : num.tryParse(json['payment_amount']?.toString() ?? '0'),
      hospital: json['hospital'] is Map
          ? HospitalInfo.fromJson(Map<String, dynamic>.from(json['hospital']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'bill_id': billId,
        'bill_no': billNo,
        'app_user_id': appUserId,
        'patient_id': patientId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'group_order_no': groupOrderNo,
        'bill_date': billDate,
        'net_amount': netAmount,
        'order_status': orderStatus,
        'payment_mode': paymentMode,
        'payment_amount': paymentAmount,
        'hospital': hospital?.toJson(),
      };
}
