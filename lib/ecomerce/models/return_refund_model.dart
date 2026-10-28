class ReturnRefundModel {
  final int refundId;
  final int orderId;
  final int orderDetailsId;
  final int productId;
  final String productName;
  final String? variant;
  final String? productThumbnail;
  final double amount;
  final String status;
  final String statusLabel;
  final String refundReason;
  final String? approvedNote;
  final String? rejectedNote;
  final String? paymentInfo;
  final List<String> images;
  final String createdAt;
  final String? timeAgo;
  final String domain;
  final String vendor;

  ReturnRefundModel({
    required this.refundId,
    required this.orderId,
    required this.orderDetailsId,
    required this.productId,
    required this.productName,
    this.variant,
    this.productThumbnail,
    required this.amount,
    required this.status,
    required this.statusLabel,
    required this.refundReason,
    this.approvedNote,
    this.rejectedNote,
    this.paymentInfo,
    required this.images,
    required this.createdAt,
    this.timeAgo,
    required this.domain,
    required this.vendor,
  });

  factory ReturnRefundModel.fromJson(Map<String, dynamic> json) {
    List<String> imgs = [];
    if (json['images'] is List) {
      for (var img in json['images']) {
        if (img != null) imgs.add(img.toString());
      }
    }
    return ReturnRefundModel(
      refundId: json['id'] is int ? json['id'] : (json['refund_id'] is int ? json['refund_id'] : int.tryParse((json['id'] ?? json['refund_id'])?.toString() ?? '0') ?? 0),
      orderId: json['order_id'] is int ? json['order_id'] : int.tryParse(json['order_id']?.toString() ?? '0') ?? 0,
      orderDetailsId: json['order_details_id'] is int ? json['order_details_id'] : int.tryParse(json['order_details_id']?.toString() ?? '0') ?? 0,
      productId: json['product_id'] is int ? json['product_id'] : int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      productName: json['product_name']?.toString() ?? '',
      variant: json['variant']?.toString(),
      productThumbnail: json['product_thumbnail']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? (json['status']?.toString() ?? 'Pending'),
      refundReason: json['refund_reason']?.toString() ?? '',
      approvedNote: json['approved_note']?.toString(),
      rejectedNote: json['rejected_note']?.toString(),
      paymentInfo: json['payment_info']?.toString(),
      images: imgs,
      createdAt: json['created_at']?.toString() ?? '',
      timeAgo: json['time_ago']?.toString(),
      domain: json['domain']?.toString() ?? '',
      vendor: json['vendor']?.toString() ?? '',
    );
  }
}
