class TransactionSummary {
  final int? totalTransactions;
  final num? totalSpent;
  final String? formattedSpent;
  final num? totalCredited;
  final String? formattedCredited;
  final num? walletBalance;
  final Map<String, dynamic>? counts;

  TransactionSummary({
    this.totalTransactions,
    this.totalSpent,
    this.formattedSpent,
    this.totalCredited,
    this.formattedCredited,
    this.walletBalance,
    this.counts,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      totalTransactions: json['total_transactions'],
      totalSpent: json['total_spent'],
      formattedSpent: json['formatted_spent']?.toString(),
      totalCredited: json['total_credited'],
      formattedCredited: json['formatted_credited']?.toString(),
      walletBalance: json['wallet_balance'],
      counts: json['counts'] is Map ? Map<String, dynamic>.from(json['counts']) : null,
    );
  }
}

class TransactionDetails {
  final String? transactionNo;
  final num? openingBalance;
  final num? closingBalance;
  final String? referenceType;
  final String? referenceId;

  TransactionDetails({
    this.transactionNo,
    this.openingBalance,
    this.closingBalance,
    this.referenceType,
    this.referenceId,
  });

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      transactionNo: json['transaction_no']?.toString(),
      openingBalance: json['opening_balance'],
      closingBalance: json['closing_balance'],
      referenceType: json['reference_type']?.toString(),
      referenceId: json['reference_id']?.toString(),
    );
  }
}

class MyTransactionItem {
  final String? id;
  final String? reference;
  final String? module;
  final String? category;
  final String? title;
  final String? businessName;
  final num? amount;
  final String? formattedAmount;
  final String? type;
  final String? paymentMode;
  final String? paymentStatus;
  final String? bookingStatus;
  final String? date;
  final Map<String, dynamic>? details;

  MyTransactionItem({
    this.id,
    this.reference,
    this.module,
    this.category,
    this.title,
    this.businessName,
    this.amount,
    this.formattedAmount,
    this.type,
    this.paymentMode,
    this.paymentStatus,
    this.bookingStatus,
    this.date,
    this.details,
  });

  factory MyTransactionItem.fromJson(Map<String, dynamic> json) {
    return MyTransactionItem(
      id: json['id']?.toString(),
      reference: json['reference']?.toString(),
      module: json['module']?.toString(),
      category: json['category']?.toString(),
      title: json['title']?.toString(),
      businessName: json['business_name']?.toString(),
      amount: json['amount'],
      formattedAmount: json['formatted_amount']?.toString(),
      type: json['type']?.toString(),
      paymentMode: json['payment_mode']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      bookingStatus: json['booking_status']?.toString(),
      date: json['date']?.toString(),
      details: json['details'] is Map ? Map<String, dynamic>.from(json['details']) : null,
    );
  }

  bool get isCredit => type?.toLowerCase() == 'credit';
}
