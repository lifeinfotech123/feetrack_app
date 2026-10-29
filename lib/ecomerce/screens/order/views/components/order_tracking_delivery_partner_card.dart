import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vlr/ecomerce/constants.dart';
import 'package:vlr/ecomerce/controllers/order_tracking_controller.dart';
import 'package:vlr/ecomerce/models/order_tracking_model.dart';

class OrderTrackingDeliveryPartnerCard extends StatelessWidget {
  final DeliveryPartnerInfo? partner;
  final String status;
  final OrderTrackingController controller;
  final bool isDark;
  final Color cardBg;

  const OrderTrackingDeliveryPartnerCard({
    super.key,
    required this.partner,
    required this.status,
    required this.controller,
    required this.isDark,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAssigned = partner != null && partner!.isAssigned;
    final partnerName = partner?.name ?? "Delivery Partner";
    final partnerPhone = partner?.phone;
    final partnerImage = partner?.avatar;
    final partnerRating = partner?.rating ?? "4.8";

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
                Icons.two_wheeler_rounded,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "Delivery Partner",
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAssigned
                      ? const Color(0xFF00C853).withValues(alpha: 0.12)
                      : Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isAssigned ? "ASSIGNED" : "ALLOCATING",
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isAssigned ? const Color(0xFF00C853) : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isAssigned) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  backgroundImage:
                      (partnerImage != null && partnerImage.isNotEmpty)
                          ? CachedNetworkImageProvider(partnerImage)
                          : null,
                  child: (partnerImage == null || partnerImage.isEmpty)
                      ? const Icon(
                          Icons.person_rounded,
                          color: primaryColor,
                          size: 26,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partnerName,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            partnerRating,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "• Verified Rider",
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : greyColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (partnerPhone != null && partnerPhone.isNotEmpty)
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () =>
                        controller.makePhoneCall(context, partnerPhone),
                    icon: const Icon(Icons.call_rounded, size: 18),
                    tooltip: "Call Delivery Partner",
                  ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    status == 'delivered'
                        ? "Delivered by store personnel"
                        : "A delivery partner will be assigned shortly once your order is ready.",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? Colors.white70 : blackColor60,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
