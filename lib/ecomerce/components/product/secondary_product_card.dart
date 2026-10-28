import 'package:flutter/material.dart';


import '../../constants.dart';
import '../../models/product_model.dart';
import '../network_image_with_loader.dart';
import 'product_quantity_button.dart';
import 'wishlist_heart_button.dart';

class SecondaryProductCard extends StatelessWidget {
  const SecondaryProductCard({
    super.key,
    this.id,
    this.shopId,
    this.storeDomain,
    this.discountAmount,
    this.variant,
    this.color,
    this.choices,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
    this.dicountpercent,
    this.press,
    this.style,
    this.storeName,
    this.categoryId,
    this.categoryName,
    this.categorySlug,
    this.categoryType,
  });

  final int? id;
  final int? shopId;
  final String? storeDomain;
  final double? discountAmount;
  final String? variant;
  final String? color;
  final Map<String, dynamic>? choices;
  final String image, brandName, title;
  final double price;
  final double? priceAfetDiscount;
  final int? dicountpercent;
  final VoidCallback? press;
  final ButtonStyle? style;
  final String? storeName;
  final int? categoryId;
  final String? categoryName;
  final String? categorySlug;
  final String? categoryType;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: press ?? () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 260,
          height: 114,
          padding: const EdgeInsets.all(6),
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
          child: Row(
            children: [
              // Product Image
              AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: NetworkImageWithLoader(
                          image,
                          radius: 12,
                        ),
                      ),
                    ),
                    if (dicountpercent != null && dicountpercent! > 0)
                      Positioned(
                        left: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3D00),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "-$dicountpercent%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: WishlistHeartButton(
                        productId: id,
                        storeDomain: storeDomain,
                        size: 24,
                        iconSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Product Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            brandName.toUpperCase(),
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF222228),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          priceAfetDiscount != null
                              ? Row(
                                  children: [
                                    Text(
                                      "₹${priceAfetDiscount! % 1 == 0 ? priceAfetDiscount!.toInt() : priceAfetDiscount!.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "₹${price % 1 == 0 ? price.toInt() : price.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.grey.shade500,
                                        fontSize: 10,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  "₹${price % 1 == 0 ? price.toInt() : price.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF1E1E24),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
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
                              discountAmount: discountAmount,
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
                            height: 26,
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
