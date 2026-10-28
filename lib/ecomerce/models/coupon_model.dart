enum CouponType { percentage, flat, freeDelivery }

class CouponModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final CouponType discountType;
  final double discountValue;
  final double minOrderValue;
  final double? maxDiscountAmount;
  final String expiryDate;
  final String terms;
  final bool isApplicable;

  const CouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.minOrderValue = 0.0,
    this.maxDiscountAmount,
    required this.expiryDate,
    this.terms = "Applicable once per user. Cannot be clubbed with other offers.",
    this.isApplicable = true,
  });

  bool get isFreeDelivery => discountType == CouponType.freeDelivery;

  factory CouponModel.fromApiJson(Map<String, dynamic> json) {
    final discountTypeStr = (json['discount_type'] ?? '').toString().toLowerCase();
    final couponTypeStr = (json['coupon_type'] ?? '').toString().toLowerCase();
    CouponType type = CouponType.flat;
    if (discountTypeStr == 'percentage' || discountTypeStr == 'percent') {
      type = CouponType.percentage;
    } else if (couponTypeStr.contains('free') || discountTypeStr.contains('free')) {
      type = CouponType.freeDelivery;
    } else {
      type = CouponType.flat;
    }

    final discount = (json['discount'] as num?)?.toDouble() ?? 0.0;
    final minPurchase = (json['min_purchase'] as num?)?.toDouble() ?? 0.0;
    final maxDiscount = json['max_discount'] == null ? null : (json['max_discount'] as num?)?.toDouble();

    return CouponModel(
      id: (json['id'] ?? json['code'])?.toString() ?? '',
      code: (json['code'] ?? '').toString(),
      title: (json['title'] ?? json['code'] ?? '').toString(),
      description: (json['short_reason'] ?? json['terms'] ?? '').toString(),
      discountType: type,
      discountValue: discount,
      minOrderValue: minPurchase,
      maxDiscountAmount: maxDiscount,
      expiryDate: (json['formatted_expire_date'] ?? json['expire_date'] ?? '').toString(),
      terms: (json['terms'] ?? '').toString().isNotEmpty
          ? (json['terms'] ?? '').toString()
          : ((json['short_reason'] ?? '').toString()),
      isApplicable: json['is_applicable'] == true || json['is_applicable'] == null,
    );
  }

  /// Returns discount amount applicable on the subtotal.
  double calculateDiscount(double subtotal) {
    if (subtotal < minOrderValue || subtotal <= 0) return 0.0;

    switch (discountType) {
      case CouponType.percentage:
        double discount = subtotal * (discountValue / 100.0);
        if (maxDiscountAmount != null && discount > maxDiscountAmount!) {
          discount = maxDiscountAmount!;
        }
        return discount.clamp(0.0, subtotal);

      case CouponType.flat:
        return discountValue > subtotal ? subtotal : discountValue;

      case CouponType.freeDelivery:
        return 0.0; // Delivery fee is waived separately in cart
    }
  }

  bool isEligible(double subtotal) => subtotal >= minOrderValue;

  double neededToUnlock(double subtotal) {
    if (subtotal >= minOrderValue) return 0.0;
    return minOrderValue - subtotal;
  }
}
