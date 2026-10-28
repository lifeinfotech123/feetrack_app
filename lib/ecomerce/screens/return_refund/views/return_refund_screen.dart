import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/ecomerce/controllers/return_refund_controller.dart';
import 'package:vlr/ecomerce/ecomerce_banner/components/skleton/skelton.dart';

import '../../../constants.dart';
import 'return_refund_detail_screen.dart';

class ReturnRefundScreen extends StatefulWidget {
  const ReturnRefundScreen({super.key});

  @override
  State<ReturnRefundScreen> createState() => _ReturnRefundScreenState();
}

class _ReturnRefundScreenState extends State<ReturnRefundScreen> {
  late final ReturnRefundController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ReturnRefundController>()
        ? Get.find<ReturnRefundController>()
        : Get.put(ReturnRefundController());
    _controller.fetchRefunds();
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'approved' || s == 'completed') return const Color(0xFF22C55E);
    if (s == 'rejected' || s == 'cancelled') return const Color(0xFFEF4444);
    if (s == 'processing') return const Color(0xFF3B82F6);
    return const Color(0xFFF59E0B);
  }

  IconData _getStatusIcon(String status) {
    final s = status.toLowerCase();
    if (s == 'approved' || s == 'completed') return Icons.check_circle_rounded;
    if (s == 'rejected' || s == 'cancelled') return Icons.cancel_rounded;
    if (s == 'processing') return Icons.sync_rounded;
    return Icons.hourglass_top_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final bodyBg = isDark ? const Color(0xFF121218) : const Color(0xFFF7F7FA);

    return Scaffold(
      backgroundColor: bodyBg,
      appBar: AppBar(
        title: const Text(
          "Returns & Refunds",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: cardBg,
        actions: [
          IconButton(
            onPressed: () => _controller.fetchRefunds(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.refunds.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: primaryColor));
        }

        if (_controller.refunds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.assignment_return_rounded,
                      size: 48, color: primaryColor),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No Return/Refund Requests",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "Your return and refund requests will appear here",
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: primaryColor,
          onRefresh: () => _controller.fetchRefunds(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.refunds.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final refund = _controller.refunds[index];
              final statusColor = _getStatusColor(refund.status);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ReturnRefundDetailScreen(refundId: refund.refundId),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isDark
                              ? Colors.white12
                              : const Color(0xFFECECF2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.25 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2A2A3A)
                                      : const Color(0xFFF6F6FA),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  "Refund #${refund.refundId}",
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_getStatusIcon(refund.status),
                                        size: 13, color: statusColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      refund.status.toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: statusColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: refund.productThumbnail != null &&
                                        refund.productThumbnail!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: refund.productThumbnail!,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) =>
                                            const Skeleton(),
                                        errorWidget: (_, __, ___) => Container(
                                          width: 56,
                                          height: 56,
                                          color: primaryColor.withValues(
                                              alpha: 0.1),
                                          child: const Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                              color: primaryColor),
                                        ),
                                      )
                                    : Container(
                                        width: 56,
                                        height: 56,
                                        color:
                                            primaryColor.withValues(alpha: 0.1),
                                        child: const Icon(
                                            Icons.shopping_bag_outlined,
                                            color: primaryColor),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      refund.productName,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (refund.variant != null &&
                                        refund.variant!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        refund.variant!,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white60
                                                : Colors.black54),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      "Order #${refund.orderId} • ${refund.createdAt}",
                                      style: TextStyle(
                                          fontSize: 11.5,
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("Amount",
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.grey)),
                                  Text(
                                    "₹${refund.amount.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: primaryColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF262634)
                                  : const Color(0xFFF7F7FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Reason",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  refund.refundReason,
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87),
                                ),
                                if (refund.paymentInfo != null &&
                                    refund.paymentInfo!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text("Payment Info: ${refund.paymentInfo}",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.black54)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
