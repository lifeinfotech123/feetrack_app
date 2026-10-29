import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../controllers/cart_controller.dart';

class CartOrderSummaryCard extends StatelessWidget {
  final CartController cart;
  final TextEditingController couponController;
  final bool isApplyingCoupon;
  final VoidCallback onApplyCoupon;
  final VoidCallback onViewCoupons;
  final Color cardBg;
  final bool isDark;
  final String Function(num?) formatPrice;

  const CartOrderSummaryCard({
    super.key,
    required this.cart,
    required this.couponController,
    required this.isApplyingCoupon,
    required this.onApplyCoupon,
    required this.onViewCoupons,
    required this.cardBg,
    required this.isDark,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = cart.originalSubtotal;
    final tax = cart.totalTax;
    final shipping = cart.deliveryFee;
    final discount = cart.totalSavings;
    final grandTotal = cart.grandTotal;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Celebration Highlight: "You have Saved ₹X.XX!"
          if (discount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2979FF).withValues(alpha: 0.12),
                    const Color(0xFF00E5FF).withValues(alpha: 0.08),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(13)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: Color(0xFF1565C0),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "You have Saved ₹${formatPrice(discount)}!",
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sub total (Total Product Price)
                _buildSummaryLine(
                  "Sub total",
                  "₹${formatPrice(subtotal)}",
                  isDark: isDark,
                ),
                const SizedBox(height: 10),

                // Tax
                _buildSummaryLine(
                  "Tax",
                  "₹${formatPrice(tax)}",
                  isDark: isDark,
                ),
                const SizedBox(height: 10),

                // Shipping
                _buildSummaryLine(
                  "Shipping",
                  shipping == 0 ? "₹0.00" : "₹${formatPrice(shipping)}",
                  isDark: isDark,
                ),
                const SizedBox(height: 10),

                // Discount on product
                if (discount > 0) ...[
                  _buildSummaryLine(
                    "Discount on product",
                    "- ₹${formatPrice(discount)}",
                    isDiscount: true,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                ],

                // Coupon Code Input (Website Style)
                if (cart.appliedCoupon == null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF262636)
                                : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : const Color(0xFFD1D5DB),
                            ),
                          ),
                          child: TextField(
                            controller: couponController,
                            textCapitalization: TextCapitalization.characters,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            decoration: const InputDecoration(
                              hintText: "ENTER COUPON CODE",
                              hintStyle: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                letterSpacing: 0.3,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: isApplyingCoupon ? null : onApplyCoupon,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5252),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: isApplyingCoupon
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Apply",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: onViewCoupons,
                    child: const Text(
                      "View available coupons & offers",
                      style: TextStyle(
                        fontSize: 11,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else ...[
                  // Applied Coupon Pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: successColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: successColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: successColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Coupon ${cart.appliedCoupon!.code} applied",
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: successColor,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            cart.removeCoupon();
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: errorColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                // Grand Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "₹${formatPrice(grandTotal)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(
    String title,
    String value, {
    bool isDiscount = false,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : const Color(0xFF4B5563),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDiscount
                ? const Color(0xFFFF5252)
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }
}

