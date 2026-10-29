import 'package:flutter/material.dart';
import 'package:vlr/ecomerce/constants.dart';
import 'package:vlr/ecomerce/controllers/order_tracking_controller.dart';
import 'package:vlr/ecomerce/models/order_tracking_model.dart';

class OrderTrackingStatusCard extends StatelessWidget {
  final OrderTrackingModel model;
  final OrderTrackingController controller;
  final bool isDark;
  final Color cardBg;

  const OrderTrackingStatusCard({
    super.key,
    required this.model,
    required this.controller,
    required this.isDark,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFood = model.isFood;

    String statusTitle;
    String statusSubtitle;
    Color statusColor;

    if (model.isDelivered) {
      statusTitle = "Delivered to Doorstep";
      statusSubtitle = "Package handed over successfully";
      statusColor = const Color(0xFF00C853);
    } else if (model.isCancelled) {
      statusTitle = "Order Cancelled";
      statusSubtitle = "This order was cancelled";
      statusColor = const Color(0xFFE53935);
    } else if (model.isOutForDelivery) {
      statusTitle = "Out for Delivery";
      statusSubtitle = "Delivery partner is on the way to your address";
      statusColor = const Color(0xFF2979FF);
    } else if (model.isProcessing) {
      statusTitle = isFood ? "Preparing in Kitchen" : "Packing Your Items";
      statusSubtitle = isFood
          ? "The chef is preparing your meal"
          : "Seller is preparing and packing your order";
      statusColor = const Color(0xFFFF9800);
    } else {
      statusTitle = "Order Placed & Confirmed";
      statusSubtitle = "Waiting for store processing";
      statusColor = primaryColor;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Status Icon + Title + Subtitle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  model.isDelivered
                      ? Icons.check_circle_rounded
                      : (model.isCancelled
                          ? Icons.cancel_rounded
                          : Icons.local_shipping_rounded),
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      statusSubtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Estimated Arrival ETA Row
          if (!model.isDelivered && !model.isCancelled) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      "Estimated Arrival:",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                Text(
                  controller.etaDisplayText.value.isNotEmpty
                      ? controller.etaDisplayText.value
                      : (model.eta ?? "25 - 35 mins"),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ],

          // Delivery Verification PIN / Code
          if (model.deliveryCode != null && model.deliveryCode!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF262636) : const Color(0xFFF1F1F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.key_rounded,
                        size: 16,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Delivery PIN / Code:",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        model.deliveryCode!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => controller.copyDeliveryCode(
                          context,
                          model.deliveryCode!,
                        ),
                        child: const Icon(
                          Icons.copy_rounded,
                          size: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
