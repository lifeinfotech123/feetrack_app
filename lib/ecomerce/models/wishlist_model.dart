import 'product_model.dart';

class WishlistItemModel {
  final int wishlistId;
  final int productId;
  final String name;
  final String slug;
  final int? categoryId;
  final String? categoryName;
  final int? brandId;
  final String? brandName;
  final double unitPrice;
  final double discount;
  final String? discountType;
  final double finalPrice;
  final String formattedPrice;
  final String? formattedOldPrice;
  final bool inStock;
  final int stockQuantity;
  final String? thumbnail;
  final bool isFood;
  final String? unit;
  final int minimumOrderQty;
  final double rating;
  final int reviewCount;
  final int shopId;
  final int vendorId;
  final String vendor;
  final String vendorName;
  final String addedAt;
  final String domain;

  WishlistItemModel({
    required this.wishlistId,
    required this.productId,
    required this.name,
    required this.slug,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    required this.unitPrice,
    required this.discount,
    this.discountType,
    required this.finalPrice,
    required this.formattedPrice,
    this.formattedOldPrice,
    required this.inStock,
    required this.stockQuantity,
    this.thumbnail,
    required this.isFood,
    this.unit,
    required this.minimumOrderQty,
    required this.rating,
    required this.reviewCount,
    required this.shopId,
    required this.vendorId,
    required this.vendor,
    required this.vendorName,
    required this.addedAt,
    required this.domain,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json, {String defaultDomain = 'e-team-12'}) {
    return WishlistItemModel(
      wishlistId: json['wishlist_id'] is int
          ? json['wishlist_id']
          : int.tryParse(json['wishlist_id']?.toString() ?? '0') ?? 0,
      productId: json['product_id'] is int
          ? json['product_id']
          : int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id']?.toString() ?? ''),
      categoryName: json['category_name']?.toString(),
      brandId: json['brand_id'] is int
          ? json['brand_id']
          : int.tryParse(json['brand_id']?.toString() ?? ''),
      brandName: json['brand_name']?.toString(),
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discount_type']?.toString(),
      finalPrice: (json['final_price'] as num?)?.toDouble() ??
          (json['unit_price'] as num?)?.toDouble() ??
          0.0,
      formattedPrice: json['formatted_price']?.toString() ?? '₹0.00',
      formattedOldPrice: json['formatted_old_price']?.toString(),
      inStock: json['in_stock'] == true || json['in_stock'] == 1,
      stockQuantity: json['stock_quantity'] is int
          ? json['stock_quantity']
          : int.tryParse(json['stock_quantity']?.toString() ?? '0') ?? 0,
      thumbnail: json['thumbnail']?.toString(),
      isFood: json['is_food'] == true || json['is_food'] == 1,
      unit: json['unit']?.toString(),
      minimumOrderQty: json['minimum_order_qty'] is int
          ? json['minimum_order_qty']
          : int.tryParse(json['minimum_order_qty']?.toString() ?? '1') ?? 1,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: json['review_count'] is int
          ? json['review_count']
          : int.tryParse(json['review_count']?.toString() ?? '0') ?? 0,
      shopId: json['shop_id'] is int
          ? json['shop_id']
          : int.tryParse(json['shop_id']?.toString() ?? '0') ?? 0,
      vendorId: json['vendor_id'] is int
          ? json['vendor_id']
          : int.tryParse(json['vendor_id']?.toString() ?? '0') ?? 0,
      vendor: json['vendor']?.toString() ?? 'Store',
      vendorName: json['vendor_name']?.toString() ?? 'Store',
      addedAt: json['added_at']?.toString() ?? '',
      domain: json['domain']?.toString() ?? defaultDomain,
    );
  }

  ProductModel toProductModel() {
    int? discountPct;
    if (unitPrice > 0 && finalPrice < unitPrice) {
      discountPct = (((unitPrice - finalPrice) / unitPrice) * 100).round();
    }

    return ProductModel(
      id: productId,
      shopId: shopId,
      storeDomain: domain,
      storeName: vendorName.isNotEmpty ? vendorName : vendor,
      image: thumbnail ?? '',
      brandName: brandName ?? 'Brand',
      title: name,
      price: unitPrice,
      priceAfetDiscount: finalPrice < unitPrice ? finalPrice : null,
      dicountpercent: discountPct,
      discountAmount: discount > 0 ? discount : null,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryType: isFood ? 'food' : 'default',
    );
  }
}
