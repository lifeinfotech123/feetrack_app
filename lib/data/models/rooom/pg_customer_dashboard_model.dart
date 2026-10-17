class PgCustomerDashboardData {
  final PgCustomerInfo? customer;
  final PgDashboardHeader? header;
  final PgDashboardMetrics? metrics;
  final PgDashboardSections? sections;

  PgCustomerDashboardData({
    this.customer,
    this.header,
    this.metrics,
    this.sections,
  });

  factory PgCustomerDashboardData.fromJson(Map<String, dynamic> json) {
    return PgCustomerDashboardData(
      customer: json['customer'] is Map
          ? PgCustomerInfo.fromJson(Map<String, dynamic>.from(json['customer']))
          : null,
      header: json['header'] is Map
          ? PgDashboardHeader.fromJson(Map<String, dynamic>.from(json['header']))
          : null,
      metrics: json['metrics'] is Map
          ? PgDashboardMetrics.fromJson(Map<String, dynamic>.from(json['metrics']))
          : null,
      sections: json['sections'] is Map
          ? PgDashboardSections.fromJson(Map<String, dynamic>.from(json['sections']))
          : null,
    );
  }
}

class PgCustomerInfo {
  final dynamic id;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? initials;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? city;
  final String? address;
  final String? gender;

  PgCustomerInfo({
    this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.initials,
    this.email,
    this.phone,
    this.avatar,
    this.city,
    this.address,
    this.gender,
  });

  factory PgCustomerInfo.fromJson(Map<String, dynamic> json) {
    return PgCustomerInfo(
      id: json['id'],
      name: json['name']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      initials: json['initials']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      avatar: json['avatar']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      gender: json['gender']?.toString(),
    );
  }
}

class PgDashboardHeader {
  final dynamic walletBalance;
  final String? formattedWalletBalance;
  final int? unreadNotificationsCount;
  final String? initials;

  PgDashboardHeader({
    this.walletBalance,
    this.formattedWalletBalance,
    this.unreadNotificationsCount,
    this.initials,
  });

  factory PgDashboardHeader.fromJson(Map<String, dynamic> json) {
    return PgDashboardHeader(
      walletBalance: json['wallet_balance'],
      formattedWalletBalance: json['formatted_wallet_balance']?.toString() ?? "₹0.00",
      unreadNotificationsCount: json['unread_notifications_count'] != null
          ? int.tryParse(json['unread_notifications_count'].toString())
          : 0,
      initials: json['initials']?.toString(),
    );
  }
}

class PgDashboardMetrics {
  final int totalBookings;
  final int confirmedBookings;
  final int pendingOtpBookings;
  final int pendingPaymentBookings;
  final int completedBookings;
  final int cancelledBookings;
  final int activeSubscriptions;
  final int totalAttendanceDays;
  final dynamic pendingInvoicesAmount;
  final dynamic totalSpent;
  final dynamic walletBalance;
  final int scheduledVisits;
  final int savedListingsCount;
  final int totalReviewsCount;
  final int unreadNotificationsCount;

  PgDashboardMetrics({
    this.totalBookings = 0,
    this.confirmedBookings = 0,
    this.pendingOtpBookings = 0,
    this.pendingPaymentBookings = 0,
    this.completedBookings = 0,
    this.cancelledBookings = 0,
    this.activeSubscriptions = 0,
    this.totalAttendanceDays = 0,
    this.pendingInvoicesAmount = 0,
    this.totalSpent = 0,
    this.walletBalance = 0,
    this.scheduledVisits = 0,
    this.savedListingsCount = 0,
    this.totalReviewsCount = 0,
    this.unreadNotificationsCount = 0,
  });

  factory PgDashboardMetrics.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) =>
        val != null ? (int.tryParse(val.toString()) ?? 0) : 0;

    return PgDashboardMetrics(
      totalBookings: parseInt(json['total_bookings']),
      confirmedBookings: parseInt(json['confirmed_bookings']),
      pendingOtpBookings: parseInt(json['pending_otp_bookings']),
      pendingPaymentBookings: parseInt(json['pending_payment_bookings']),
      completedBookings: parseInt(json['completed_bookings']),
      cancelledBookings: parseInt(json['cancelled_bookings']),
      activeSubscriptions: parseInt(json['active_subscriptions']),
      totalAttendanceDays: parseInt(json['total_attendance_days']),
      pendingInvoicesAmount: json['pending_invoices_amount'] ?? 0,
      totalSpent: json['total_spent'] ?? 0,
      walletBalance: json['wallet_balance'] ?? 0,
      scheduledVisits: parseInt(json['scheduled_visits']),
      savedListingsCount: parseInt(json['saved_listings_count']),
      totalReviewsCount: parseInt(json['total_reviews_count']),
      unreadNotificationsCount: parseInt(json['unread_notifications_count']),
    );
  }
}

class PgDashboardSections {
  final List<PgCustomerBookingItem> recentBookings;
  final List<dynamic> activeSubscriptions;
  final List<dynamic> pendingInvoices;
  final List<dynamic> recentAttendance;
  final List<PgCustomerVisitItem> recentVisits;
  final List<dynamic> savedListings;
  final List<dynamic> recentReviews;
  final List<dynamic> notifications;

  PgDashboardSections({
    this.recentBookings = const [],
    this.activeSubscriptions = const [],
    this.pendingInvoices = const [],
    this.recentAttendance = const [],
    this.recentVisits = const [],
    this.savedListings = const [],
    this.recentReviews = const [],
    this.notifications = const [],
  });

  factory PgDashboardSections.fromJson(Map<String, dynamic> json) {
    return PgDashboardSections(
      recentBookings: (json['recent_bookings'] is List)
          ? (json['recent_bookings'] as List)
              .whereType<Map>()
              .map((b) => PgCustomerBookingItem.fromJson(Map<String, dynamic>.from(b)))
              .toList()
          : [],
      activeSubscriptions: (json['active_subscriptions'] is List)
          ? json['active_subscriptions']
          : [],
      pendingInvoices:
          (json['pending_invoices'] is List) ? json['pending_invoices'] : [],
      recentAttendance:
          (json['recent_attendance'] is List) ? json['recent_attendance'] : [],
      recentVisits: (json['recent_visits'] is List)
          ? (json['recent_visits'] as List)
              .whereType<Map>()
              .map((v) => PgCustomerVisitItem.fromJson(Map<String, dynamic>.from(v)))
              .toList()
          : [],
      savedListings:
          (json['saved_listings'] is List) ? json['saved_listings'] : [],
      recentReviews:
          (json['recent_reviews'] is List) ? json['recent_reviews'] : [],
      notifications:
          (json['notifications'] is List) ? json['notifications'] : [],
    );
  }
}

class PgCustomerVisitItem {
  final String? id;
  final String? visitDate;
  final String? formattedDate;
  final String? visitTime;
  final String? status;
  final String? note;
  final String? createdAt;
  final PgPropertyShortInfo? property;
  final Map<String, dynamic>? website;

  PgCustomerVisitItem({
    this.id,
    this.visitDate,
    this.formattedDate,
    this.visitTime,
    this.status,
    this.note,
    this.createdAt,
    this.property,
    this.website,
  });

  factory PgCustomerVisitItem.fromJson(Map<String, dynamic> json) {
    return PgCustomerVisitItem(
      id: json['id']?.toString(),
      visitDate: json['visit_date']?.toString(),
      formattedDate: json['formatted_date']?.toString(),
      visitTime: json['visit_time']?.toString(),
      status: json['status']?.toString() ?? "pending",
      note: json['note']?.toString(),
      createdAt: json['created_at']?.toString(),
      property: json['property'] is Map
          ? PgPropertyShortInfo.fromJson(Map<String, dynamic>.from(json['property']))
          : null,
      website: json['website'] is Map ? Map<String, dynamic>.from(json['website']) : null,
    );
  }
}

class PgPropertyShortInfo {
  final String? id;
  final String? title;
  final String? address;
  final String? city;
  final String? phone;
  final dynamic securityDeposit;
  final String? image;
  final List<String>? images;

  PgPropertyShortInfo({
    this.id,
    this.title,
    this.address,
    this.city,
    this.phone,
    this.securityDeposit,
    this.image,
    this.images,
  });

  factory PgPropertyShortInfo.fromJson(Map<String, dynamic> json) {
    List<String>? parsedImages;
    if (json['images'] is List) {
      parsedImages = (json['images'] as List).map((e) => e.toString()).toList();
    }
    return PgPropertyShortInfo(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      phone: json['phone']?.toString(),
      securityDeposit: json['security_deposit'],
      image: json['image']?.toString(),
      images: parsedImages,
    );
  }
}

class PgCustomerBookingItem {
  final String? id;
  final String? shortId;
  final String? bookingNumber;
  final String? status;
  final String? statusLabel;
  final String? statusColor;
  final String? paymentStatus;
  final String? paymentStatusBadge;
  final dynamic finalAmount;
  final String? formattedAmount;
  final String? occupancyType;
  final String? occupancyTypeDisplay;
  final int? bedsBooked;
  final String? bedsDisplay;
  final String? otp;
  final String? otpVerifiedAt;
  final String? createdAt;
  final String? formattedDate;
  final Map<String, dynamic>? actions;
  final PgPropertyShortInfo? property;
  final Map<String, dynamic>? package;
  final Map<String, dynamic>? room;
  final Map<String, dynamic>? invoice;
  final Map<String, dynamic>? website;
  final List<dynamic>? payments;

  PgCustomerBookingItem({
    this.id,
    this.shortId,
    this.bookingNumber,
    this.status,
    this.statusLabel,
    this.statusColor,
    this.paymentStatus,
    this.paymentStatusBadge,
    this.finalAmount,
    this.formattedAmount,
    this.occupancyType,
    this.occupancyTypeDisplay,
    this.bedsBooked,
    this.bedsDisplay,
    this.otp,
    this.otpVerifiedAt,
    this.createdAt,
    this.formattedDate,
    this.actions,
    this.property,
    this.package,
    this.room,
    this.invoice,
    this.website,
    this.payments,
  });

  factory PgCustomerBookingItem.fromJson(Map<String, dynamic> json) {
    return PgCustomerBookingItem(
      id: json['id']?.toString(),
      shortId: json['short_id']?.toString(),
      bookingNumber: json['booking_number']?.toString(),
      status: json['status']?.toString() ?? "pending",
      statusLabel: json['status_label']?.toString() ?? (json['status']?.toString() ?? ""),
      statusColor: json['status_color']?.toString(),
      paymentStatus: json['payment_status']?.toString() ?? "unpaid",
      paymentStatusBadge: json['payment_status_badge']?.toString() ?? "",
      finalAmount: json['final_amount'] ?? json['total_amount'] ?? 0,
      formattedAmount: json['formatted_amount']?.toString() ??
          "₹${json['final_amount'] ?? 0}",
      occupancyType: json['occupancy_type']?.toString(),
      occupancyTypeDisplay: json['occupancy_type_display']?.toString(),
      bedsBooked: json['beds_booked'] != null
          ? int.tryParse(json['beds_booked'].toString())
          : 1,
      bedsDisplay: json['beds_display']?.toString() ?? "1 Bed",
      otp: json['otp']?.toString(),
      otpVerifiedAt: json['otp_verified_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      formattedDate: json['formatted_date']?.toString() ??
          json['formatted_created_at']?.toString(),
      actions: json['actions'] is Map ? Map<String, dynamic>.from(json['actions']) : null,
      property: json['property'] is Map
          ? PgPropertyShortInfo.fromJson(Map<String, dynamic>.from(json['property']))
          : null,
      package: json['package'] is Map ? Map<String, dynamic>.from(json['package']) : null,
      room: json['room'] is Map ? Map<String, dynamic>.from(json['room']) : null,
      invoice: json['invoice'] is Map ? Map<String, dynamic>.from(json['invoice']) : null,
      website: json['website'] is Map ? Map<String, dynamic>.from(json['website']) : null,
      payments: json['payments'] is List ? json['payments'] : null,
    );
  }
}

class PgCustomerWalletModel {
  final dynamic balance;
  final String? formattedBalance;
  final String? currency;
  final String? currencySymbol;
  final int totalTransactions;
  final List<PgWalletTransaction> transactions;

  PgCustomerWalletModel({
    this.balance = 0,
    this.formattedBalance = "₹0.00",
    this.currency = "INR",
    this.currencySymbol = "₹",
    this.totalTransactions = 0,
    this.transactions = const [],
  });

  factory PgCustomerWalletModel.fromJson(Map<String, dynamic> json) {
    return PgCustomerWalletModel(
      balance: json['balance'] ?? 0,
      formattedBalance: json['formatted_balance']?.toString() ?? "₹0.00",
      currency: json['currency']?.toString() ?? "INR",
      currencySymbol: json['currency_symbol']?.toString() ?? "₹",
      totalTransactions: json['total_transactions'] != null
          ? (int.tryParse(json['total_transactions'].toString()) ?? 0)
          : 0,
      transactions: (json['transactions'] is List)
          ? (json['transactions'] as List)
              .whereType<Map>()
              .map((t) => PgWalletTransaction.fromJson(Map<String, dynamic>.from(t)))
              .toList()
          : [],
    );
  }
}

class PgWalletTransaction {
  final String? id;
  final String? type;
  final dynamic amount;
  final String? formattedAmount;
  final String? description;
  final String? referenceType;
  final String? referenceId;
  final String? createdAt;
  final String? formattedDate;

  PgWalletTransaction({
    this.id,
    this.type,
    this.amount,
    this.formattedAmount,
    this.description,
    this.referenceType,
    this.referenceId,
    this.createdAt,
    this.formattedDate,
  });

  factory PgWalletTransaction.fromJson(Map<String, dynamic> json) {
    return PgWalletTransaction(
      id: json['id']?.toString(),
      type: json['type']?.toString(),
      amount: json['amount'],
      formattedAmount: json['formatted_amount']?.toString(),
      description: json['description']?.toString(),
      referenceType: json['reference_type']?.toString(),
      referenceId: json['reference_id']?.toString(),
      createdAt: json['created_at']?.toString(),
      formattedDate: json['formatted_date']?.toString(),
    );
  }
}

class PgCustomerProfileModel {
  final dynamic id;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? initials;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? gender;
  final String? dateOfBirth;
  final String? bloodGroup;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;
  final String? status;

  PgCustomerProfileModel({
    this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.initials,
    this.email,
    this.phone,
    this.avatar,
    this.gender,
    this.dateOfBirth,
    this.bloodGroup,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.country,
    this.status,
  });

  factory PgCustomerProfileModel.fromJson(Map<String, dynamic> json) {
    return PgCustomerProfileModel(
      id: json['id'],
      name: json['name']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      initials: json['initials']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      avatar: json['avatar']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      country: json['country']?.toString() ?? "India",
      status: json['status']?.toString() ?? "active",
    );
  }
}

class PgCustomerInvoiceItem {
  final String? id;
  final String? invoiceNumber;
  final String? bookingNumber;
  final num? amount;
  final num? tax;
  final num? total;
  final String? formattedTotal;
  final String? status;
  final String? statusLabel;
  final String? dueDate;
  final String? formattedDate;
  final PgPropertyShortInfo? property;
  final Map<String, dynamic>? website;

  PgCustomerInvoiceItem({
    this.id,
    this.invoiceNumber,
    this.bookingNumber,
    this.amount,
    this.tax,
    this.total,
    this.formattedTotal,
    this.status,
    this.statusLabel,
    this.dueDate,
    this.formattedDate,
    this.property,
    this.website,
  });

  factory PgCustomerInvoiceItem.fromJson(Map<String, dynamic> json) {
    return PgCustomerInvoiceItem(
      id: json['id']?.toString() ??
          json['invoice_id']?.toString() ??
          json['uuid']?.toString(),
      invoiceNumber: json['invoice_number']?.toString(),
      bookingNumber: json['booking_number']?.toString(),
      amount: json['amount'] != null
          ? num.tryParse(json['amount'].toString())
          : null,
      tax: json['tax'] != null ? num.tryParse(json['tax'].toString()) : 0,
      total: json['total'] != null
          ? num.tryParse(json['total'].toString())
          : null,
      formattedTotal: json['formatted_total']?.toString(),
      status: json['status']?.toString() ?? "paid",
      statusLabel: json['status_label']?.toString() ?? "Paid",
      dueDate: json['due_date']?.toString(),
      formattedDate: json['formatted_date']?.toString(),
      property: json['property'] is Map
          ? PgPropertyShortInfo.fromJson(
              Map<String, dynamic>.from(json['property']))
          : null,
      website: json['website'] is Map
          ? Map<String, dynamic>.from(json['website'])
          : null,
    );
  }
}

class PgCustomerSubscriptionItem {
  final String? id;
  final String? subscriptionNumber;
  final String? status;
  final String? statusLabel;
  final String? startsAt;
  final String? expiresAt;
  final String? formattedStartsAt;
  final String? formattedExpiresAt;
  final int? daysRemaining;
  final bool? autoRenew;
  final String? occupancyType;
  final int? bedsBooked;
  final PgPropertyShortInfo? property;
  final Map<String, dynamic>? package;
  final Map<String, dynamic>? room;
  final Map<String, dynamic>? website;

  PgCustomerSubscriptionItem({
    this.id,
    this.subscriptionNumber,
    this.status,
    this.statusLabel,
    this.startsAt,
    this.expiresAt,
    this.formattedStartsAt,
    this.formattedExpiresAt,
    this.daysRemaining,
    this.autoRenew,
    this.occupancyType,
    this.bedsBooked,
    this.property,
    this.package,
    this.room,
    this.website,
  });

  factory PgCustomerSubscriptionItem.fromJson(Map<String, dynamic> json) {
    return PgCustomerSubscriptionItem(
      id: json['id']?.toString(),
      subscriptionNumber: json['subscription_number']?.toString(),
      status: json['status']?.toString() ?? "active",
      statusLabel: json['status_label']?.toString() ?? "Active",
      startsAt: json['starts_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
      formattedStartsAt: json['formatted_starts_at']?.toString(),
      formattedExpiresAt: json['formatted_expires_at']?.toString(),
      daysRemaining: json['days_remaining'] != null
          ? int.tryParse(json['days_remaining'].toString())
          : null,
      autoRenew: json['auto_renew'] is bool
          ? json['auto_renew']
          : json['auto_renew'] == 1,
      occupancyType: json['occupancy_type']?.toString(),
      bedsBooked: json['beds_booked'] != null
          ? int.tryParse(json['beds_booked'].toString())
          : 1,
      property: json['property'] is Map
          ? PgPropertyShortInfo.fromJson(
              Map<String, dynamic>.from(json['property']))
          : null,
      package: json['package'] is Map
          ? Map<String, dynamic>.from(json['package'])
          : null,
      room:
          json['room'] is Map ? Map<String, dynamic>.from(json['room']) : null,
      website: json['website'] is Map
          ? Map<String, dynamic>.from(json['website'])
          : null,
    );
  }
}
