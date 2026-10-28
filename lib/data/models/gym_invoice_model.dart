import 'gym_attendance_model.dart';

bool _parseGymInvoiceBool(dynamic value, {bool defaultValue = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes' || normalized == 'y' || normalized == 'on') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no' || normalized == 'n' || normalized == 'off' || normalized.isEmpty) {
      return false;
    }
  }
  return defaultValue;
}

class GymInvoicesResponse {
  final bool? status;
  final String? message;
  final GymInvoicesData? data;

  GymInvoicesResponse({this.status, this.message, this.data});

  factory GymInvoicesResponse.fromJson(Map<String, dynamic> json) {
    return GymInvoicesResponse(
      status: _parseGymInvoiceBool(json['status']),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? GymInvoicesData.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }
}

class GymSingleInvoiceResponse {
  final bool? status;
  final String? message;
  final GymInvoiceItem? data;

  GymSingleInvoiceResponse({this.status, this.message, this.data});

  factory GymSingleInvoiceResponse.fromJson(Map<String, dynamic> json) {
    return GymSingleInvoiceResponse(
      status: _parseGymInvoiceBool(json['status']),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? GymInvoiceItem.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }
}

class GymInvoicesData {
  final GymInvoicesSummary? summary;
  final GymAttendancePagination? pagination;
  final List<GymInvoiceItem> invoices;

  GymInvoicesData({
    this.summary,
    this.pagination,
    this.invoices = const [],
  });

  factory GymInvoicesData.fromJson(Map<String, dynamic> json) {
    var rawList = json['invoices'];
    List<GymInvoiceItem> list = [];
    if (rawList is List) {
      list = rawList
          .map((e) => GymInvoiceItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return GymInvoicesData(
      summary: json['summary'] is Map
          ? GymInvoicesSummary.fromJson(
              Map<String, dynamic>.from(json['summary'] as Map))
          : null,
      pagination: json['pagination'] is Map
          ? GymAttendancePagination.fromJson(
              Map<String, dynamic>.from(json['pagination'] as Map))
          : null,
      invoices: list,
    );
  }
}

class GymInvoicesSummary {
  final int totalInvoices;
  final num totalPaid;
  final String? totalPaidFormatted;

  GymInvoicesSummary({
    this.totalInvoices = 0,
    this.totalPaid = 0,
    this.totalPaidFormatted,
  });

  factory GymInvoicesSummary.fromJson(Map<String, dynamic> json) {
    return GymInvoicesSummary(
      totalInvoices: json['total_invoices'] is num
          ? (json['total_invoices'] as num).toInt()
          : int.tryParse(json['total_invoices']?.toString() ?? '0') ?? 0,
      totalPaid: json['total_paid'] is num
          ? (json['total_paid'] as num)
          : num.tryParse(json['total_paid']?.toString() ?? '0') ?? 0,
      totalPaidFormatted: json['total_paid_formatted']?.toString(),
    );
  }
}

class GymInvoicePackage {
  final dynamic id;
  final String? name;
  final num? price;
  final int? validityDays;

  GymInvoicePackage({this.id, this.name, this.price, this.validityDays});

  factory GymInvoicePackage.fromJson(Map<String, dynamic> json) {
    return GymInvoicePackage(
      id: json['id'],
      name: json['name']?.toString(),
      price: json['price'] is num
          ? (json['price'] as num)
          : num.tryParse(json['price']?.toString() ?? ''),
      validityDays: json['validity_days'] is num
          ? (json['validity_days'] as num).toInt()
          : int.tryParse(json['validity_days']?.toString() ?? ''),
    );
  }
}

class GymInvoiceItem {
  final String? id;
  final String? invoiceNumber;
  final num? amount;
  final num? tax;
  final num? total;
  final String? totalFormatted;
  final String? status;
  final String? dueDate;
  final String? createdAt;
  final GymInvoicePackage? package;
  final GymAttendanceGym? gym;
  final GymAttendanceCustomer? customer;
  final dynamic payment;
  final String? receiptUrl;
  final String? downloadUrl;

  GymInvoiceItem({
    this.id,
    this.invoiceNumber,
    this.amount,
    this.tax,
    this.total,
    this.totalFormatted,
    this.status,
    this.dueDate,
    this.createdAt,
    this.package,
    this.gym,
    this.customer,
    this.payment,
    this.receiptUrl,
    this.downloadUrl,
  });

  factory GymInvoiceItem.fromJson(Map<String, dynamic> json) {
    return GymInvoiceItem(
      id: json['id']?.toString(),
      invoiceNumber: json['invoice_number']?.toString(),
      amount: json['amount'] is num
          ? (json['amount'] as num)
          : num.tryParse(json['amount']?.toString() ?? ''),
      tax: json['tax'] is num
          ? (json['tax'] as num)
          : num.tryParse(json['tax']?.toString() ?? ''),
      total: json['total'] is num
          ? (json['total'] as num)
          : num.tryParse(json['total']?.toString() ?? ''),
      totalFormatted: json['total_formatted']?.toString(),
      status: json['status']?.toString(),
      dueDate: json['due_date']?.toString(),
      createdAt: json['created_at']?.toString(),
      package: json['package'] is Map
          ? GymInvoicePackage.fromJson(
              Map<String, dynamic>.from(json['package'] as Map))
          : null,
      gym: json['gym'] is Map
          ? GymAttendanceGym.fromJson(
              Map<String, dynamic>.from(json['gym'] as Map))
          : null,
      customer: json['customer'] is Map
          ? GymAttendanceCustomer.fromJson(
              Map<String, dynamic>.from(json['customer'] as Map))
          : null,
      payment: json['payment'],
      receiptUrl: json['receipt_url']?.toString(),
      downloadUrl: json['download_url']?.toString(),
    );
  }
}
