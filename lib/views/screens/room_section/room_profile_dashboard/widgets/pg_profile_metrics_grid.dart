import 'package:flutter/material.dart';
import 'package:vlr/data/models/rooom/pg_customer_dashboard_model.dart';

class PgProfileMetricsGrid extends StatelessWidget {
  final PgDashboardMetrics? metrics;
  final VoidCallback onVisitsTap;
  final VoidCallback onBookingsTap;
  final VoidCallback onSubscriptionsTap;
  final VoidCallback onPaymentsTap;

  const PgProfileMetricsGrid({
    super.key,
    required this.metrics,
    required this.onVisitsTap,
    required this.onBookingsTap,
    required this.onSubscriptionsTap,
    required this.onPaymentsTap,
    required void Function() onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Stay & Booking Metrics",
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: PgMetricTile(
                title: "Scheduled Visits",
                value: metrics?.scheduledVisits?.toString() ?? "—",
                icon: Icons.calendar_month_rounded,
                bgColor: const Color(0xFFFFF7ED),
                iconColor: const Color(0xFFEA580C),
                onTap: onVisitsTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PgMetricTile(
                title: "Total Bookings",
                value: metrics?.totalBookings?.toString() ?? "—",
                icon: Icons.hotel_rounded,
                bgColor: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2563EB),
                onTap: onBookingsTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: PgMetricTile(
                title: "Active Stays",
                value: metrics?.activeSubscriptions?.toString() ?? "—",
                icon: Icons.home_work_rounded,
                bgColor: const Color(0xFFF0FDF4),
                iconColor: const Color(0xFF16A34A),
                onTap: onSubscriptionsTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PgMetricTile(
                title: "Total Spent",
                value: metrics?.totalSpent == null
                    ? "—"
                    : "₹${metrics!.totalSpent}",
                icon: Icons.payments_rounded,
                bgColor: const Color(0xFFFAF5FF),
                iconColor: const Color(0xFF7C3AED),
                onTap: onPaymentsTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PgMetricTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const PgMetricTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
