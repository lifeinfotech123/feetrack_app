import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';
import 'product_availability_tag.dart';

class ProductInfo extends StatelessWidget {
  const ProductInfo({
    super.key,
    required this.title,
    required this.brand,
    required this.description,
    required this.rating,
    required this.numOfReviews,
    required this.isAvailable,
    this.price,
    this.originalPrice,
    this.discountAmount,
    this.discountPercent,
  });

  final String title, brand, description;
  final double rating;
  final int numOfReviews;
  final bool isAvailable;
  final double? price;
  final double? originalPrice;
  final double? discountAmount;
  final int? discountPercent;

  String _formatPrice(num? value) {
    if (value == null) return "0";
    return value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double? currentP = price;
    final double? origP = (originalPrice != null &&
            currentP != null &&
            originalPrice! > currentP)
        ? originalPrice
        : null;
    final bool hasDiscount = origP != null;

    final double effectiveDiscountAmt = discountAmount ??
        (hasDiscount && currentP != null ? (origP - currentP) : 0.0);

    final int effectiveDiscountPct = discountPercent ??
        (hasDiscount && origP > 0
            ? ((effectiveDiscountAmt / origP) * 100).round()
            : 0);

    return SliverPadding(
      padding: const EdgeInsets.all(defaultPadding),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand Name
            Text(
              brand.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: primaryColor,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),

            // Product Title
            Text(
              title,
              maxLines: 2,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
            ),
            const SizedBox(height: defaultPadding * 0.75),

            // ============================================
            // 🏷️ ALL PRICING DETAILS SECTION
            // ============================================
            if (currentP != null) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E28)
                      : const Color(0xFFF8F9FD),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white12 : const Color(0xFFE9ECEF),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Final Price (After Discount)
                        Text(
                          "₹${_formatPrice(currentP)}",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                            letterSpacing: -0.5,
                          ),
                        ),

                        // Original Price (MRP) & Discount Badge
                        if (hasDiscount) ...[
                          const SizedBox(width: 10),
                          Text(
                            "₹${_formatPrice(origP)}",
                            style: TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.grey.shade500,
                              decorationThickness: 1.8,
                              color: isDark
                                  ? Colors.white38
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00C853), Color(0xFF00B248)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              effectiveDiscountAmt > 0
                                  ? "₹${_formatPrice(effectiveDiscountAmt)} OFF"
                                  : "$effectiveDiscountPct% OFF",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // You Save text
                    if (hasDiscount && effectiveDiscountAmt > 0) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: Color(0xFF00C853),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "You Save: ₹${_formatPrice(effectiveDiscountAmt)}${effectiveDiscountPct > 0 ? ' ($effectiveDiscountPct% OFF)' : ''}",
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00C853),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 3),
                    Text(
                      "Inclusive of all taxes • Best Price Guaranteed",
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: defaultPadding * 0.75),
            ],

            // Availability & Ratings
            Row(
              children: [
                ProductAvailabilityTag(isAvailable: isAvailable),
                const Spacer(),
                SvgPicture.asset("assets/icons/Star_filled.svg"),
                const SizedBox(width: defaultPadding / 4),
                Text(
                  "$rating ",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  "($numOfReviews Reviews)",
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),

            // Product Description Info
            Text(
              "Product info",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              description,
              style: TextStyle(
                height: 1.45,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
          ],
        ),
      ),
    );
  }
}
