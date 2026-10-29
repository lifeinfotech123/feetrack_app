import 'package:flutter/material.dart';
import 'package:vlr/ecomerce/constants.dart';
import 'package:vlr/ecomerce/models/order_tracking_model.dart';

class OrderTrackingSummaryCard extends StatelessWidget {
  final OrderTrackingModel model;
  final bool isDark;
  final Color cardBg;

  const OrderTrackingSummaryCard({
    super.key,
    required this.model,
    required this.isDark,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFECECF2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "Order Summary",
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                model.vendorName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (model.items.isNotEmpty) ...[
            for (final it in model.items.take(4))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      "${it.quantity}x",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        it.name,
                        style: const TextStyle(fontSize: 12.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "₹${it.lineTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            if (model.items.length > 4)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "+${model.items.length - 4} more items",
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white54 : greyColor,
                  ),
                ),
              ),
            const Divider(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount (${model.itemsCount} items)",
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? Colors.white60 : greyColor,
                ),
              ),
              Text(
                "₹${model.totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
