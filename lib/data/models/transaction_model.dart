import 'category_model/listing_model.dart';
import 'category_model/plan_model.dart';
import '../../generated/assets.dart';

class TransactionModel {
  final String transactionId;
  final String title;
  final String subtitle;
  final DateTime dateTime;
  final String paymentMode;
  final String status;
  final double amount;
  final String recipient;
  final String payerVpa;
  final String gatewayId;
  final String rrnNumber;
  final int feePoints;
  final String imagePath;
  final InvoiceModel? invoice;
  final ListingModel? listing;
  final PlanModel? plan;

  const TransactionModel({
    required this.transactionId,
    required this.title,
    required this.subtitle,
    required this.dateTime,
    required this.paymentMode,
    required this.status,
    required this.amount,
    required this.recipient,
    required this.payerVpa,
    required this.gatewayId,
    required this.rrnNumber,
    required this.feePoints,
    required this.imagePath,
    this.invoice,
    this.listing,
    this.plan,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['id']?.toString() ?? "",
      title: json['listing_name'] ?? (json['listing'] != null ? json['listing']['title'] ?? "" : "N/A"),
      subtitle: json['plan_name'] ?? (json['plan'] != null ? json['plan']['name'] ?? "" : "N/A"),
      dateTime: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'])
          : (json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now()),
      paymentMode: json['gateway']?.toString() ?? "N/A",
      status: json['status']?.toString() ?? "N/A",
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      recipient: json['listing_name'] ?? (json['listing'] != null ? json['listing']['title'] ?? "" : "N/A"),
      payerVpa: json['gateway_ref']?.toString() ?? "",
      gatewayId: json['gateway_ref']?.toString() ?? "N/A",
      rrnNumber: json['gateway_ref']?.toString() ?? "N/A",
      feePoints: 0,
      imagePath: Assets.imagesGymFee,
      invoice: json['invoice'] != null ? InvoiceModel.fromJson(json['invoice']) : null,
      listing: json['listing'] != null ? ListingModel.fromJson(json['listing']) : null,
      plan: json['plan'] != null ? PlanModel.fromJson(json['plan']) : null,
    );
  }
}

class InvoiceModel {
  final String? id;
  final String? invoiceNumber;
  final double? amount;
  final double? tax;
  final double? total;
  final DateTime? dueDate;
  final String? status;

  InvoiceModel({
    this.id,
    this.invoiceNumber,
    this.amount,
    this.tax,
    this.total,
    this.dueDate,
    this.status,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id']?.toString(),
      invoiceNumber: json['invoice_number']?.toString(),
      amount: (json['amount'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      status: json['status']?.toString(),
    );
  }
}
