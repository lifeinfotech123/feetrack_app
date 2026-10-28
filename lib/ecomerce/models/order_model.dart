class OrderListItemModel {
  final int orderId;
  final String? orderGroupId;
  final String domain;
  final String domainName;
  final String vendor;
  final int shopId;
  final bool isAdmin;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final double orderAmount;
  final double shippingCost;
  final int itemsCount;
  final String createdAt;
  final String orderType;

  OrderListItemModel({
    required this.orderId,
    this.orderGroupId,
    required this.domain,
    required this.domainName,
    required this.vendor,
    required this.shopId,
    required this.isAdmin,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.orderAmount,
    required this.shippingCost,
    required this.itemsCount,
    required this.createdAt,
    required this.orderType,
  });

  bool get isFood => orderType.toLowerCase().contains('food');
  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  factory OrderListItemModel.fromJson(Map<String, dynamic> json) {
    return OrderListItemModel(
      orderId: json['order_id'] is int
          ? json['order_id']
          : int.tryParse(json['order_id']?.toString() ?? '0') ?? 0,
      orderGroupId: json['order_group_id']?.toString(),
      domain: json['domain']?.toString() ?? '',
      domainName: json['domain_name']?.toString() ?? '',
      vendor: json['vendor']?.toString() ?? 'Store',
      shopId: json['shop_id'] is int
          ? json['shop_id']
          : int.tryParse(json['shop_id']?.toString() ?? '0') ?? 0,
      isAdmin: json['is_admin'] == true || json['is_admin'] == 1,
      orderStatus: json['order_status']?.toString() ?? 'pending',
      paymentStatus: json['payment_status']?.toString() ?? 'unpaid',
      paymentMethod: json['payment_method']?.toString() ?? 'cash_on_delivery',
      orderAmount: (json['order_amount'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0.0,
      itemsCount: json['items_count'] is int
          ? json['items_count']
          : int.tryParse(json['items_count']?.toString() ?? '1') ?? 1,
      createdAt: json['created_at']?.toString() ?? '',
      orderType: json['order_type']?.toString() ?? 'default',
    );
  }
}

class OrderDetailItemModel {
  final int detailId;
  final int productId;
  final String name;
  final String? thumbnail;
  final String? variant;
  final int quantity;
  final double unitPrice;
  final double tax;
  final double discount;
  final String deliveryStatus;
  final String paymentStatus;
  final double lineTotal;

  OrderDetailItemModel({
    required this.detailId,
    required this.productId,
    required this.name,
    this.thumbnail,
    this.variant,
    required this.quantity,
    required this.unitPrice,
    required this.tax,
    required this.discount,
    required this.deliveryStatus,
    required this.paymentStatus,
    required this.lineTotal,
  });

  factory OrderDetailItemModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailItemModel(
      detailId: json['detail_id'] is int
          ? json['detail_id']
          : int.tryParse(json['detail_id']?.toString() ?? '0') ?? 0,
      productId: json['product_id'] is int
          ? json['product_id']
          : int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Item',
      thumbnail: json['thumbnail']?.toString(),
      variant: json['variant']?.toString(),
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      deliveryStatus: json['delivery_status']?.toString() ?? 'pending',
      paymentStatus: json['payment_status']?.toString() ?? 'unpaid',
      lineTotal: (json['line_total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OrderDetailsDataModel {
  final int orderId;
  final String? orderGroupId;
  final String? verificationCode;
  final String domain;
  final String domainName;
  final String vendor;
  final int shopId;
  final bool isAdmin;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final double orderAmount;
  final double shippingCost;
  final double discountAmount;
  final String? couponCode;
  final double couponDiscount;
  final String? orderNote;
  final Map<String, dynamic>? vendorDetails;
  final List<dynamic>? statusTimeline;
  final Map<String, dynamic>? shippingAddress;
  final List<OrderDetailItemModel> items;
  final String createdAt;
  final String updatedAt;

  OrderDetailsDataModel({
    required this.orderId,
    this.orderGroupId,
    this.verificationCode,
    required this.domain,
    required this.domainName,
    required this.vendor,
    required this.shopId,
    required this.isAdmin,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.orderAmount,
    required this.shippingCost,
    required this.discountAmount,
    this.couponCode,
    required this.couponDiscount,
    this.orderNote,
    this.vendorDetails,
    this.statusTimeline,
    this.shippingAddress,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderDetailsDataModel.fromJson(Map<String, dynamic> json) {
    final List<OrderDetailItemModel> itemsList = [];
    if (json['items'] is List) {
      for (var it in json['items']) {
        if (it is Map<String, dynamic>) {
          itemsList.add(OrderDetailItemModel.fromJson(it));
        }
      }
    }

    return OrderDetailsDataModel(
      orderId: json['order_id'] is int
          ? json['order_id']
          : int.tryParse(json['order_id']?.toString() ?? '0') ?? 0,
      orderGroupId: json['order_group_id']?.toString(),
      verificationCode: json['verification_code']?.toString(),
      domain: json['domain']?.toString() ?? '',
      domainName: json['domain_name']?.toString() ?? '',
      vendor: json['vendor']?.toString() ?? 'Vendor',
      shopId: json['shop_id'] is int
          ? json['shop_id']
          : int.tryParse(json['shop_id']?.toString() ?? '0') ?? 0,
      isAdmin: json['is_admin'] == true || json['is_admin'] == 1,
      orderStatus: json['order_status']?.toString() ?? 'pending',
      paymentStatus: json['payment_status']?.toString() ?? 'unpaid',
      paymentMethod: json['payment_method']?.toString() ?? 'cash_on_delivery',
      orderAmount: (json['order_amount'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      couponCode: json['coupon_code']?.toString(),
      couponDiscount: (json['coupon_discount'] as num?)?.toDouble() ?? 0.0,
      orderNote: json['order_note']?.toString(),
      vendorDetails: json['vendor_details'] is Map<String, dynamic>
          ? json['vendor_details']
          : null,
      statusTimeline: json['status_timeline'] is List ? json['status_timeline'] : null,
      shippingAddress: json['shipping_address'] is Map<String, dynamic>
          ? json['shipping_address']
          : null,
      items: itemsList,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
