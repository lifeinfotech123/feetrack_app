import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';
import '../../../../models/coupon_model.dart';


class CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final double currentSubtotal;
  final bool isApplied;
  final VoidCallback onApply;
  final VoidCallback? onRemove;

  const CouponCard({
    super.key,
    required this.coupon,
    required this.currentSubtotal,
    required this.isApplied,
    required this.onApply,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? darkGreyColor : whiteColor;
    final isEligible = coupon.isEligible(currentSubtotal);
    final needed = coupon.neededToUnlock(currentSubtotal);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(
          color: isApplied
              ? successColor
              : (isDark ? Colors.white10 : const Color(0xFFE5E5EA)),
          width: isApplied ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isApplied
                ? successColor.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coupon icon container
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isApplied
                        ? successColor.withValues(alpha: 0.15)
                        : primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    coupon.isFreeDelivery
                        ? "assets/icons/Delivery.svg"
                        : "assets/icons/Coupon.svg",
                    colorFilter: ColorFilter.mode(
                      isApplied ? successColor : primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Coupon Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Code Badge
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: coupon.code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Code ${coupon.code} copied!"),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFFF3F0FF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.4),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    coupon.code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 0.8,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.copy_rounded,
                                    size: 12,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),

                          // Expiry / Tag
                          Text(
                            coupon.expiryDate,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? Colors.white54 : greyColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        coupon.title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        coupon.description,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.white60 : blackColor60,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Dashed divider line
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: List.generate(
                30,
                (index) => Expanded(
                  child: Container(
                    height: 1,
                    color: index % 2 == 0
                        ? (isDark ? Colors.white12 : const Color(0xFFE5E5EA))
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Action bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: isEligible
                      ? Row(
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: successColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isApplied
                                  ? "Coupon currently applied"
                                  : (coupon.minOrderValue > 0
                                      ? "Min order ₹${coupon.minOrderValue.toStringAsFixed(0)} met"
                                      : "No min spend required"),
                              style: TextStyle(
                                fontSize: 11,
                                color: isApplied
                                    ? successColor
                                    : (isDark ? Colors.white70 : blackColor60),
                                fontWeight: isApplied
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: warningColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Add ₹${needed.toStringAsFixed(2)} more to unlock",
                              style: const TextStyle(
                                fontSize: 11,
                                color: warningColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),

                // Action button
                if (isApplied)
                  OutlinedButton(
                    onPressed: onRemove,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      side: const BorderSide(color: errorColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "REMOVE",
                      style: TextStyle(
                        fontSize: 11,
                        color: errorColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: isEligible ? onApply : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor:
                          isDark ? Colors.white12 : const Color(0xFFE5E5EA),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: 0,
                    ),
                    child: Text(
                      "APPLY",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isEligible
                            ? Colors.white
                            : (isDark ? Colors.white38 : greyColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
