import 'package:flutter/material.dart';
import 'package:vlr/ecomerce/constants.dart';
import 'package:vlr/ecomerce/models/order_tracking_model.dart';

class OrderTrackingTimelineWidget extends StatelessWidget {
  final List<TrackingStepItem> steps;
  final bool isDelivered;
  final bool isCancelled;
  final bool isDark;
  final Color cardBg;

  const OrderTrackingTimelineWidget({
    super.key,
    required this.steps,
    required this.isDelivered,
    required this.isCancelled,
    required this.isDark,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    if (isCancelled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE53935).withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: Color(0xFFE53935), size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Cancelled",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53935),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "This order has been cancelled and will not be delivered.",
                    style: TextStyle(fontSize: 12, color: greyColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDelivered
              ? const Color(0xFF00C853).withValues(alpha: 0.35)
              : (isDark ? Colors.white12 : const Color(0xFFECECF2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                color: isDelivered ? const Color(0xFF00C853) : primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "Tracking Timeline",
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (isDelivered)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF00C853),
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "COMPLETED",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00C853),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          for (int i = 0; i < steps.length; i++)
            _buildTimelineStepRow(
              step: steps[i],
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineStepRow({
    required TrackingStepItem step,
    required bool isLast,
  }) {
    const Color greenColor = Color(0xFF00C853);
    final Color dotColor = step.isCompleted
        ? greenColor
        : (step.isActive
            ? primaryColor
            : (isDark ? Colors.white24 : Colors.grey.shade300));

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Dot + Vertical Connecting Line
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.isCompleted
                      ? greenColor
                      : (step.isActive
                          ? primaryColor.withValues(alpha: 0.15)
                          : Colors.transparent),
                  border: Border.all(
                    color: dotColor,
                    width: step.isActive ? 2.5 : 2,
                  ),
                ),
                child: Center(
                  child: step.isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 15,
                        )
                      : (step.isActive
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                              ),
                            )
                          : null),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.2,
                    color: step.isCompleted
                        ? greenColor
                        : (isDark ? Colors.white12 : Colors.grey.shade200),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Right Column: Title + Description
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 4 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: (step.isCompleted || step.isActive)
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: step.isCompleted
                          ? (isDark ? Colors.white : Colors.black87)
                          : (step.isActive ? primaryColor : greyColor),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.description,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? Colors.white54 : greyColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
