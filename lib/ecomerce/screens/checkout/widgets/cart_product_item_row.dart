import 'package:flutter/material.dart';

import '../../../components/network_image_with_loader.dart';
import '../../../constants.dart';
import '../../../controllers/cart_controller.dart';
import '../../../route/app_text_constants.dart';

class CartProductItemRow extends StatelessWidget {
  final CartItemModel item;
  final CartController cart;
  final bool isDark;
  final String Function(num?) formatPrice;

  const CartProductItemRow({
    super.key,
    required this.item,
    required this.cart,
    required this.isDark,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = item.originalUnitPrice > item.unitPrice;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Checkbox for individual product selection
          SizedBox(
            width: 26,
            height: 26,
            child: Checkbox(
              value: item.isSelected,
              activeColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (_) {
                cart.toggleItemSelection(item);
              },
            ),
          ),
          const SizedBox(width: 6),

          // 2. Product Image Thumbnail (Clickable to open Product Details)
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                productDetailsScreenRoute,
                arguments: item.product,
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 52,
                height: 52,
                child: NetworkImageWithLoader(
                  item.product.image,
                  radius: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 3. Title, Attributes, Unit Price & Tax
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  productDetailsScreenRoute,
                  arguments: item.product,
                );
              },
              borderRadius: BorderRadius.circular(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  if (item.effectiveVariant.isNotEmpty ||
                      item.effectiveColor != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      "${item.effectiveVariant.isNotEmpty ? 'Variant: ${item.effectiveVariant}' : ''}${item.effectiveColor != null ? '  Color: ${item.effectiveColor}' : ''}",
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),

                  // Unit Price & Unit Tax
                  Row(
                    children: [
                      if (hasDiscount) ...[
                        Text(
                          "₹${formatPrice(item.originalUnitPrice)}",
                          style: TextStyle(
                            fontSize: 10.5,
                            decoration: TextDecoration.lineThrough,
                            color: isDark ? Colors.white38 : Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        "₹${formatPrice(item.unitPrice)}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "(Tax : ₹${formatPrice(item.unitTax)})",
                    style: TextStyle(
                      fontSize: 9.5,
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 4. Quantity Stepper, Delete Button, and Item Total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Stepper [-] [qty] [+] & Delete trash button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stepper [-] [qty] [+]
                  Container(
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF262636)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            isDark ? Colors.white12 : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            cart.updateQuantity(
                                item.product, item.quantity - 1);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(
                              Icons.remove_rounded,
                              size: 14,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        Text(
                          "${item.quantity}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            cart.updateQuantity(
                                item.product, item.quantity + 1);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(
                              Icons.add_rounded,
                              size: 14,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Delete / Trash Icon
                  InkWell(
                    onTap: () {
                      cart.removeItem(item);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: errorColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: errorColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Item Total (strikethrough original + final bold)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasDiscount) ...[
                    Text(
                      "₹${formatPrice(item.originalTotalPrice)}",
                      style: TextStyle(
                        fontSize: 10,
                        decoration: TextDecoration.lineThrough,
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    "₹${formatPrice(item.totalPrice)}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

