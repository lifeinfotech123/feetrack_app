import 'medicine_model.dart';

class InvoiceMedicineItem {
  final String? medicineName;
  final String? batchNo;
  final int? quantity;
  final num? salePrice;
  final num? tax;
  final num? amount;

  InvoiceMedicineItem({
    this.medicineName,
    this.batchNo,
    this.quantity,
    this.salePrice,
    this.tax,
    this.amount,
  });

  factory InvoiceMedicineItem.fromJson(Map<String, dynamic> json) {
    return InvoiceMedicineItem(
      medicineName: json['medicine_name']?.toString(),
      batchNo: json['batch_no']?.toString(),
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity']?.toString() ?? '1'),
      salePrice: json['sale_price'] is num
          ? json['sale_price']
          : num.tryParse(json['sale_price']?.toString() ?? '0'),
      tax: json['tax'] is num
          ? json['tax']
          : num.tryParse(json['tax']?.toString() ?? '0'),
      amount: json['amount'] is num
          ? json['amount']
          : num.tryParse(json['amount']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_name': medicineName,
      'batch_no': batchNo,
      'quantity': quantity,
      'sale_price': salePrice,
      'tax': tax,
      'amount': amount,
    };
  }
}

class PharmacyInvoiceModel {
  final int? billId;
  final String? billNo;
  final String? groupOrderNo;
  final String? billDate;
  final String? orderStatus;
  final String? customerName;
  final String? customerPhone;
  final String? shippingAddress;
  final num? totalAmount;
  final num? tax;
  final num? deliveryFee;
  final num? netAmount;
  final String? paymentMode;
  final num? paymentAmount;
  final List<InvoiceMedicineItem> items;
  final HospitalInfo? hospital;

  PharmacyInvoiceModel({
    this.billId,
    this.billNo,
    this.groupOrderNo,
    this.billDate,
    this.orderStatus,
    this.customerName,
    this.customerPhone,
    this.shippingAddress,
    this.totalAmount,
    this.tax,
    this.deliveryFee,
    this.netAmount,
    this.paymentMode,
    this.paymentAmount,
    this.items = const [],
    this.hospital,
  });

  factory PharmacyInvoiceModel.fromJson(Map<String, dynamic> json) {
    List<InvoiceMedicineItem> itemsList = [];
    if (json['items'] is List) {
      itemsList = (json['items'] as List)
          .map((e) => InvoiceMedicineItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return PharmacyInvoiceModel(
      billId: json['bill_id'] is int ? json['bill_id'] : int.tryParse(json['bill_id']?.toString() ?? ''),
      billNo: json['bill_no']?.toString(),
      groupOrderNo: json['group_order_no']?.toString(),
      billDate: json['bill_date']?.toString(),
      orderStatus: json['order_status']?.toString(),
      customerName: json['customer_name']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
      shippingAddress: json['shipping_address']?.toString(),
      totalAmount: json['total_amount'] is num
          ? json['total_amount']
          : num.tryParse(json['total_amount']?.toString() ?? '0'),
      tax: json['tax'] is num
          ? json['tax']
          : num.tryParse(json['tax']?.toString() ?? '0'),
      deliveryFee: json['delivery_fee'] is num
          ? json['delivery_fee']
          : num.tryParse(json['delivery_fee']?.toString() ?? '0'),
      netAmount: json['net_amount'] is num
          ? json['net_amount']
          : num.tryParse(json['net_amount']?.toString() ?? '0'),
      paymentMode: json['payment_mode']?.toString(),
      paymentAmount: json['payment_amount'] is num
          ? json['payment_amount']
          : num.tryParse(json['payment_amount']?.toString() ?? '0'),
      items: itemsList,
      hospital: json['hospital'] is Map
          ? HospitalInfo.fromJson(Map<String, dynamic>.from(json['hospital']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bill_id': billId,
      'bill_no': billNo,
      'group_order_no': groupOrderNo,
      'bill_date': billDate,
      'order_status': orderStatus,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'shipping_address': shippingAddress,
      'total_amount': totalAmount,
      'tax': tax,
      'delivery_fee': deliveryFee,
      'net_amount': netAmount,
      'payment_mode': paymentMode,
      'payment_amount': paymentAmount,
      'items': items.map((e) => e.toJson()).toList(),
      'hospital': hospital?.toJson(),
    };
  }
}
