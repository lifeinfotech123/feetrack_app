class BookingModel {
  final String? id;
  final String? subscriptionId;
  final String? status;
  final String? bookingStatus;
  final String? paymentMethod;
  final String? otp;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final int? daysRemaining;
  final bool? autoRenew;
  final DateTime? createdAt;
  final BookingListing? listing;
  final BookingPlan? plan;
  final dynamic shift;
  final dynamic trainers;
  final BookingBilling? billing;
  final List<Invoice>? invoices;
  final List<Payment>? payments;
  final BookingCustomer? customer;
  final BookingRoom? room;

  BookingModel({
    this.id,
    this.subscriptionId,
    this.status,
    this.bookingStatus,
    this.paymentMethod,
    this.otp,
    this.startsAt,
    this.expiresAt,
    this.daysRemaining,
    this.autoRenew,
    this.createdAt,
    this.listing,
    this.plan,
    this.shift,
    this.trainers,
    this.billing,
    this.invoices,
    this.payments,
    this.customer,
    this.room,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json["booking_id"]?.toString() ?? json["id"]?.toString(),
        subscriptionId: json["subscription_id"],
        status: json["status"],
        bookingStatus: json["booking_status"] ?? json["status"],
        paymentMethod: json["payment_method"],
        otp: json["otp"]?.toString(),
        startsAt: json["starts_at"] == null
            ? null
            : DateTime.parse(json["starts_at"]),
        expiresAt: json["expires_at"] == null
            ? null
            : DateTime.parse(json["expires_at"]),
        daysRemaining: json["days_remaining"],
        autoRenew: json["auto_renew"],
        createdAt: json["booking_date"] == null
            ? (json["created_at"] == null ? null : DateTime.parse(json["created_at"]))
            : DateTime.parse(json["booking_date"]),
        listing: json["listing"] == null
            ? null
            : BookingListing.fromJson(json["listing"]),
        plan: json["plan"] == null
            ? null
            : BookingPlan.fromJson(json["plan"]),
        shift: json["shift"],
        trainers: json["trainers"],
        billing: json["billing"] == null
            ? null
            : BookingBilling.fromJson(json["billing"]),
        invoices: json["invoices"] == null
            ? []
            : List<Invoice>.from(
                json["invoices"]!.map((x) => Invoice.fromJson(x))),
        payments: json["payments"] == null
            ? []
            : List<Payment>.from(
                json["payments"]!.map((x) => Payment.fromJson(x))),
        customer: json["customer"] == null
            ? null
            : BookingCustomer.fromJson(json["customer"]),
        room: json["room"] == null ? null : BookingRoom.fromJson(json["room"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "subscription_id": subscriptionId,
        "status": status,
        "booking_status": bookingStatus,
        "payment_method": paymentMethod,
        "otp": otp,
        "starts_at": startsAt?.toIso8601String(),
        "expires_at": expiresAt?.toIso8601String(),
        "days_remaining": daysRemaining,
        "auto_renew": autoRenew,
        "booking_date": createdAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "listing": listing?.toJson(),
        "plan": plan?.toJson(),
        "shift": shift,
        "trainers": trainers,
        "billing": billing?.toJson(),
        "invoices": invoices == null
            ? []
            : List<dynamic>.from(invoices!.map((x) => x.toJson())),
        "payments": payments == null
            ? []
            : List<dynamic>.from(payments!.map((x) => x.toJson())),
        "customer": customer?.toJson(),
        "room": room?.toJson(),
      };
}

class BookingRoom {
  final String? id;
  final String? roomNumber;
  final String? roomType;
  final int? securityDeposit;
  final dynamic floor;

  BookingRoom({
    this.id,
    this.roomNumber,
    this.roomType,
    this.securityDeposit,
    this.floor,
  });

  factory BookingRoom.fromJson(Map<String, dynamic> json) => BookingRoom(
        id: json["id"]?.toString(),
        roomNumber: json["room_number"]?.toString(),
        roomType: json["room_type"]?.toString(),
        securityDeposit: json["security_deposit"],
        floor: json["floor"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "room_number": roomNumber,
        "room_type": roomType,
        "security_deposit": securityDeposit,
        "floor": floor,
      };
}

class BookingListing {
  final String? id;
  final String? title;
  final String? category;
  final String? description;
  final String? address;
  final String? landmark;
  final String? lat;
  final String? lng;
  final String? phone;
  final String? openingTime;
  final String? closingTime;
  final String? image;
  final ListingPartner? partner;

  BookingListing({
    this.id,
    this.title,
    this.category,
    this.description,
    this.address,
    this.landmark,
    this.lat,
    this.lng,
    this.phone,
    this.openingTime,
    this.closingTime,
    this.image,
    this.partner,
  });

  factory BookingListing.fromJson(Map<String, dynamic> json) => BookingListing(
        id: json["id"],
        title: json["title"],
        category: json["category"],
        description: json["description"],
        address: json["address"],
        landmark: json["landmark"],
        lat: json["lat"],
        lng: json["lng"],
        phone: json["phone"],
        openingTime: json["opening_time"],
        closingTime: json["closing_time"],
        image: json["image"],
        partner: json["partner"] == null
            ? null
            : ListingPartner.fromJson(json["partner"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "category": category,
        "description": description,
        "address": address,
        "landmark": landmark,
        "lat": lat,
        "lng": lng,
        "phone": phone,
        "opening_time": openingTime,
        "closing_time": closingTime,
        "image": image,
        "partner": partner?.toJson(),
      };
}

class ListingPartner {
  final String? id;
  final String? name;
  final String? mobile;
  final String? email;

  ListingPartner({
    this.id,
    this.name,
    this.mobile,
    this.email,
  });

  factory ListingPartner.fromJson(Map<String, dynamic> json) => ListingPartner(
        id: json["id"],
        name: json["name"],
        mobile: json["mobile"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "mobile": mobile,
        "email": email,
      };
}

class BookingCustomer {
  final String? id;
  final String? name;
  final String? mobile;
  final String? email;

  BookingCustomer({
    this.id,
    this.name,
    this.mobile,
    this.email,
  });

  factory BookingCustomer.fromJson(Map<String, dynamic> json) => BookingCustomer(
        id: json["id"],
        name: json["name"],
        mobile: json["mobile"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "mobile": mobile,
        "email": email,
      };
}

class BookingPlan {
  final String? id;
  final String? name;
  final String? duration;
  final int? price;

  BookingPlan({
    this.id,
    this.name,
    this.duration,
    this.price,
  });

  factory BookingPlan.fromJson(Map<String, dynamic> json) => BookingPlan(
        id: json["id"],
        name: json["name"],
        duration: json["duration"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "duration": duration,
        "price": price,
      };
}

class BookingBilling {
  final int? subtotal;
  final int? discount;
  final int? securityDeposit;
  final int? reserveAmount;
  final int? shiftFee;
  final int? trainerFee;
  final int? bedsBooked;
  final int? finalAmount;
  final dynamic coupon;

  BookingBilling({
    this.subtotal,
    this.discount,
    this.securityDeposit,
    this.reserveAmount,
    this.shiftFee,
    this.trainerFee,
    this.bedsBooked,
    this.finalAmount,
    this.coupon,
  });

  factory BookingBilling.fromJson(Map<String, dynamic> json) => BookingBilling(
        subtotal: json["subtotal"],
        discount: json["discount"],
        securityDeposit: json["security_deposit"],
        reserveAmount: json["reserve_amount"],
        shiftFee: json["shift_fee"],
        trainerFee: json["trainer_fee"],
        bedsBooked: json["beds_booked"],
        finalAmount: json["final_amount"],
        coupon: json["coupon"],
      );

  Map<String, dynamic> toJson() => {
        "subtotal": subtotal,
        "discount": discount,
        "security_deposit": securityDeposit,
        "reserve_amount": reserveAmount,
        "shift_fee": shiftFee,
        "trainer_fee": trainerFee,
        "beds_booked": bedsBooked,
        "final_amount": finalAmount,
        "coupon": coupon,
      };
}

class Invoice {
  final String? id;
  final String? invoiceNumber;
  final int? amount;
  final int? total;
  final String? status;
  final DateTime? dueDate;

  Invoice({
    this.id,
    this.invoiceNumber,
    this.amount,
    this.total,
    this.status,
    this.dueDate,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json["id"],
        invoiceNumber: json["invoice_number"],
        amount: json["amount"],
        total: json["total"],
        status: json["status"],
        dueDate: json["due_date"] == null
            ? null
            : DateTime.parse(json["due_date"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "invoice_number": invoiceNumber,
        "amount": amount,
        "total": total,
        "status": status,
        "due_date": dueDate?.toIso8601String(),
      };
}

class Payment {
  final String? id;
  final String? gateway;
  final String? receiptNo;
  final String? transactionId;
  final int? amount;
  final String? status;
  final DateTime? paidAt;

  Payment({
    this.id,
    this.gateway,
    this.receiptNo,
    this.transactionId,
    this.amount,
    this.status,
    this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json["id"],
        gateway: json["gateway"],
        receiptNo: json["receipt_no"],
        transactionId: json["transaction_id"],
        amount: json["amount"],
        status: json["status"],
        paidAt: json["paid_at"] == null
            ? null
            : DateTime.parse(json["paid_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "gateway": gateway,
        "receipt_no": receiptNo,
        "transaction_id": transactionId,
        "amount": amount,
        "status": status,
        "paid_at": paidAt?.toIso8601String(),
      };
}
