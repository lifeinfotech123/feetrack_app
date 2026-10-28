import 'package:flutter/material.dart';


import '../../constants.dart';
import '../../models/product_model.dart';
import '../network_image_with_loader.dart';
import 'product_quantity_button.dart';
import 'wishlist_heart_button.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    this.id,
    this.shopId,
    this.variant,
    this.color,
    this.choices,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
    this.dicountpercent,
    this.discountAmount,
    this.storeName,
    this.storeDomain,
    this.categoryId,
    this.categoryName,
    this.categorySlug,
    this.categoryType,
    required this.press,
  });

  final int? id;
  final int? shopId;
  final String? variant;
  final String? color;
  final Map<String, dynamic>? choices;
  final String image, brandName, title;
  final double price;
  final double? priceAfetDiscount;
  final int? dicountpercent;
  final double? discountAmount;
  final String? storeName;
  final String? storeDomain;
  final int? categoryId;
  final String? categoryName;
  final String? categorySlug;
  final String? categoryType;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double? effectiveDiscountAmount = discountAmount ??
        (priceAfetDiscount != null && priceAfetDiscount! < price
            ? (price - priceAfetDiscount!)
            : null);
    final double finalPrice = priceAfetDiscount ?? price;
    final bool hasDiscount =
        priceAfetDiscount != null && priceAfetDiscount! < price;

    String formatPrice(num? value) {
      if (value == null) return "0";
      return value % 1 == 0
          ? value.toInt().toString()
          : value.toStringAsFixed(2);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: press,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 154,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFECECF0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with Badges
              Padding(
                padding: const EdgeInsets.all(6),
                child: AspectRatio(
                  aspectRatio: 1.15,
                  child: Stack(
                    children: [
                      // Main Product Image
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: NetworkImageWithLoader(
                            image,
                            radius: 12,
                          ),
                        ),
                      ),

                      // Discount Tag on Top Left
                      if (hasDiscount)
                        Positioned(
                          left: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              (effectiveDiscountAmount != null &&
                                      effectiveDiscountAmount > 0)
                                  ? "₹${formatPrice(effectiveDiscountAmount)} OFF"
                                  : "-$dicountpercent%",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),

                      // Wishlist Heart on Top Right
                      Positioned(
                        right: 6,
                        top: 6,
                        child: WishlistHeartButton(
                          productId: id,
                          storeDomain: storeDomain,
                          size: 26,
                          iconSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Product Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Brand Name
                          Text(
                            brandName.toUpperCase(),
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),

                          // Product Title
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF222228),
                              height: 1.2,
                            ),
                          ),
                          if (storeName != null && storeName!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.storefront_outlined,
                                  size: 10,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    storeName!,
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.grey.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                      // Price & Add to Cart Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: hasDiscount
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Final Price (Main highlighted in bold)
                                      Text(
                                        "₹${formatPrice(finalPrice)}",
                                        style: const TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      // Unit Price (MRP with Strikethrough) & Discount Text
                                      Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 4,
                                        children: [
                                          Text(
                                            "₹${formatPrice(price)}",
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white38
                                                  : Colors.grey.shade500,
                                              fontSize: 9.5,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                          if (effectiveDiscountAmount != null &&
                                              effectiveDiscountAmount > 0)
                                            Text(
                                              "Save ₹${formatPrice(effectiveDiscountAmount)}",
                                              style: const TextStyle(
                                                color: Color(0xFF00C853),
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Text(
                                    "₹${formatPrice(price)}",
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1E1E24),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),

                          // Interactive Add / Quantity Stepper Button
                          ProductQuantityButton(
                            product: ProductModel(
                              id: id,
                              shopId: shopId,
                              variant: variant,
                              color: color,
                              choices: choices,
                              image: image,
                              brandName: brandName,
                              title: title,
                              price: price,
                              priceAfetDiscount: priceAfetDiscount,
                              dicountpercent: dicountpercent,
                              discountAmount: effectiveDiscountAmount,
                              storeName: storeName,
                              storeDomain: storeDomain,
                              categoryId: categoryId,
                              categoryName: categoryName,
                              categorySlug: categorySlug,
                              categoryType: categoryType,
                            ),
                            storeDomain: storeDomain,
                            isMini: true,
                            showText: false,
                            variant: variant,
                            color: color,
                            choices: choices,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
