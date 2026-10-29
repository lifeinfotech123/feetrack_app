import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../controllers/cart_controller.dart';
import 'cart_product_item_row.dart';

class StoreGroupCard extends StatelessWidget {
  final String storeName;
  final List<CartItemModel> items;
  final CartController cart;
  final Color cardBg;
  final bool isDark;
  final String Function(num?) formatPrice;

  const StoreGroupCard({
    super.key,
    required this.storeName,
    required this.items,
    required this.cart,
    required this.cardBg,
    required this.isDark,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAllStoreSelected = cart.isStoreSelected(storeName);

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
          // 1. Store Header with Checkbox, Icon, Name & Verified Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF262636) : const Color(0xFFF9FAFB),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : const Color(0xFFEEF0F2),
                ),
              ),
            ),
            child: Row(
              children: [
                // Store Select Checkbox
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Checkbox(
                    value: isAllStoreSelected,
                    activeColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      cart.toggleStoreSelection(storeName, val ?? true);
                    },
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.storefront_rounded,
                  size: 18,
                  color: primaryColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    storeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Status / Verified badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5252).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 12,
                        color: primaryColor,
                      ),
                      SizedBox(width: 3),
                      Text(
                        "Verified Shop",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Product Items list in this Store
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.8,
              color: isDark ? Colors.white10 : const Color(0xFFF0F1F4),
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return CartProductItemRow(
                item: item,
                cart: cart,
                isDark: isDark,
                formatPrice: formatPrice,
              );
            },
          ),
        ],
      ),
    );
  }
}

