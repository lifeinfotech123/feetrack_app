class PgCustomerInvoiceDetailResponse {
  final bool status;
  final String? message;
  final PgCustomerInvoiceDetailData? data;

  PgCustomerInvoiceDetailResponse({
    this.status = false,
    this.message,
    this.data,
  });

  factory PgCustomerInvoiceDetailResponse.fromJson(Map<String, dynamic> json) {
    return PgCustomerInvoiceDetailResponse(
      status: json['status'] == true || json['status'] == 'true',
      message: json['message']?.toString(),
      data: json['data'] is Map
          ? PgCustomerInvoiceDetailData.fromJson(
              Map<String, dynamic>.from(json['data']))
          : null,
    );
  }
}

class PgCustomerInvoiceDetailData {
  final String? id;
  final String? invoiceNumber;
  final String? bookingId;
  final String? bookingNumber;
  final num? amount;
  final num? tax;
  final num? total;
  final String? formattedTotal;
  final String? status;
  final String? statusLabel;
  final String? dueDate;
  final String? createdAt;
  final String? formattedDate;
  final PgInvoiceCustomer? customer;
  final PgInvoiceBooking? booking;
  final PgInvoiceProperty? property;
  final PgInvoicePackage? package;
  final PgInvoiceWebsite? website;

  PgCustomerInvoiceDetailData({
    this.id,
    this.invoiceNumber,
    this.bookingId,
    this.bookingNumber,
    this.amount,
    this.tax,
    this.total,
    this.formattedTotal,
    this.status,
    this.statusLabel,
    this.dueDate,
    this.createdAt,
    this.formattedDate,
    this.customer,
    this.booking,
    this.property,
    this.package,
    this.website,
  });

  factory PgCustomerInvoiceDetailData.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic val) =>
        val != null ? num.tryParse(val.toString()) : null;

    return PgCustomerInvoiceDetailData(
      id: json['id']?.toString() ??
          json['invoice_id']?.toString() ??
          json['uuid']?.toString(),
      invoiceNumber: json['invoice_number']?.toString(),
      bookingId: json['booking_id']?.toString(),
      bookingNumber: json['booking_number']?.toString(),
      amount: parseNum(json['amount']),
      tax: parseNum(json['tax']) ?? 0,
      total: parseNum(json['total']),
      formattedTotal: json['formatted_total']?.toString(),
      status: json['status']?.toString() ?? "paid",
      statusLabel: json['status_label']?.toString() ?? "Paid",
      dueDate: json['due_date']?.toString(),
      createdAt: json['created_at']?.toString(),
      formattedDate: json['formatted_date']?.toString(),
      customer: json['customer'] is Map
          ? PgInvoiceCustomer.fromJson(
              Map<String, dynamic>.from(json['customer']))
          : null,
      booking: json['booking'] is Map
          ? PgInvoiceBooking.fromJson(Map<String, dynamic>.from(json['booking']))
          : null,
      property: json['property'] is Map
          ? PgInvoiceProperty.fromJson(
              Map<String, dynamic>.from(json['property']))
          : null,
      package: json['package'] is Map
          ? PgInvoicePackage.fromJson(Map<String, dynamic>.from(json['package']))
          : null,
      website: json['website'] is Map
          ? PgInvoiceWebsite.fromJson(Map<String, dynamic>.from(json['website']))
          : null,
    );
  }
}

class PgInvoiceCustomer {
  final String? name;
  final String? email;
  final String? mobile;

  PgInvoiceCustomer({this.name, this.email, this.mobile});

  factory PgInvoiceCustomer.fromJson(Map<String, dynamic> json) {
    return PgInvoiceCustomer(
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString(),
    );
  }
}

class PgInvoiceBooking {
  final String? id;
  final String? bookingNumber;
  final String? status;
  final String? occupancyType;
  final int? bedsBooked;
  final num? finalAmount;
  final String? formattedAmount;

  PgInvoiceBooking({
    this.id,
    this.bookingNumber,
    this.status,
    this.occupancyType,
    this.bedsBooked,
    this.finalAmount,
    this.formattedAmount,
  });

  factory PgInvoiceBooking.fromJson(Map<String, dynamic> json) {
    return PgInvoiceBooking(
      id: json['id']?.toString(),
      bookingNumber: json['booking_number']?.toString(),
      status: json['status']?.toString(),
      occupancyType: json['occupancy_type']?.toString(),
      bedsBooked: json['beds_booked'] != null
          ? int.tryParse(json['beds_booked'].toString())
          : null,
      finalAmount: json['final_amount'] != null
          ? num.tryParse(json['final_amount'].toString())
          : null,
      formattedAmount: json['formatted_amount']?.toString(),
    );
  }
}

class PgInvoiceProperty {
  final String? id;
  final String? title;
  final String? address;
  final String? city;
  final String? phone;

  PgInvoiceProperty({
    this.id,
    this.title,
    this.address,
    this.city,
    this.phone,
  });

  factory PgInvoiceProperty.fromJson(Map<String, dynamic> json) {
    return PgInvoiceProperty(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}

class PgInvoicePackage {
  final String? id;
  final String? name;
  final num? price;
  final int? durationDays;

  PgInvoicePackage({
    this.id,
    this.name,
    this.price,
    this.durationDays,
  });

  factory PgInvoicePackage.fromJson(Map<String, dynamic> json) {
    return PgInvoicePackage(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      price: json['price'] != null
          ? num.tryParse(json['price'].toString())
          : null,
      durationDays: json['duration_days'] != null
          ? int.tryParse(json['duration_days'].toString())
          : null,
    );
  }
}

class PgInvoiceWebsite {
  final dynamic id;
  final String? name;
  final String? domain;

  PgInvoiceWebsite({this.id, this.name, this.domain});

  factory PgInvoiceWebsite.fromJson(Map<String, dynamic> json) {
    return PgInvoiceWebsite(
      id: json['id'],
      name: json['name']?.toString(),
      domain: json['domain']?.toString(),
    );
  }
}
