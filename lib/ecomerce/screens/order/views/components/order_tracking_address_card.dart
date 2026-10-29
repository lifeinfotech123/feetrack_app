import 'package:flutter/material.dart';
import 'package:vlr/ecomerce/constants.dart';
import 'package:vlr/ecomerce/models/order_tracking_model.dart';

class OrderTrackingAddressCard extends StatelessWidget {
  final TrackingAddressInfo? address;
  final String? orderNote;
  final bool isDark;
  final Color cardBg;

  const OrderTrackingAddressCard({
    super.key,
    required this.address,
    this.orderNote,
    required this.isDark,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    if (address == null) return const SizedBox.shrink();

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
          const Row(
            children: [
              Icon(Icons.location_on_rounded, color: primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                "Delivery Address",
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            address!.contactName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          ),
          if (address!.phone != null && address!.phone!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              address!.phone!,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : greyColor,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            address!.displayAddress,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? Colors.white70 : blackColor60,
            ),
          ),
          if (orderNote != null && orderNote!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF282836)
                    : const Color(0xFFF4F4F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.note_alt_outlined,
                    size: 14,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Note: ${orderNote!.trim()}",
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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
