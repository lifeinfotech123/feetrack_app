import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/ecomerce/controllers/return_refund_controller.dart';
import 'package:vlr/ecomerce/ecomerce_banner/components/skleton/skelton.dart';
import 'package:vlr/ecomerce/models/return_refund_model.dart';

import '../../../constants.dart';

class ReturnRefundDetailScreen extends StatefulWidget {
  final int refundId;
  final String? domain;

  const ReturnRefundDetailScreen({
    super.key,
    required this.refundId,
    this.domain,
  });

  @override
  State<ReturnRefundDetailScreen> createState() =>
      _ReturnRefundDetailScreenState();
}

class _ReturnRefundDetailScreenState extends State<ReturnRefundDetailScreen> {
  late final ReturnRefundController _controller;
  ReturnRefundModel? _refund;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ReturnRefundController>()
        ? Get.find<ReturnRefundController>()
        : Get.put(ReturnRefundController());
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await _controller.fetchRefundDetails(widget.refundId,
        domain: widget.domain);
    if (mounted) {
      setState(() {
        _refund = res;
        _loading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'approved' || s == 'completed') return const Color(0xFF22C55E);
    if (s == 'rejected' || s == 'cancelled') return const Color(0xFFEF4444);
    if (s == 'processing') return const Color(0xFF3B82F6);
    return const Color(0xFFF59E0B);
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
          "Return Request Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: cardBg,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _refund == null
              ? const Center(child: Text("Failed to load details"))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isDark
                                ? Colors.white12
                                : const Color(0xFFECECF2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getStatusColor(_refund!.status)
                                  .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.assignment_return_rounded,
                                color: _getStatusColor(_refund!.status)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Refund #${_refund!.refundId}",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Status: ${_refund!.statusLabel}",
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      color: _getStatusColor(_refund!.status),
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Text(_refund!.createdAt,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isDark
                                ? Colors.white12
                                : const Color(0xFFECECF2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Product Details",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          const Divider(height: 20),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _refund!.productThumbnail != null &&
                                        _refund!.productThumbnail!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: _refund!.productThumbnail!,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) =>
                                            const Skeleton(),
                                      )
                                    : Container(
                                        width: 64,
                                        height: 64,
                                        color:
                                            primaryColor.withValues(alpha: 0.1),
                                        child: const Icon(
                                            Icons.shopping_bag_outlined,
                                            color: primaryColor)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_refund!.productName,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                    if (_refund!.variant != null &&
                                        _refund!.variant!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(_refund!.variant!,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? Colors.white60
                                                  : Colors.black54)),
                                    ],
                                    const SizedBox(height: 4),
                                    Text("Order #${_refund!.orderId}",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white60
                                                : Colors.black54)),
                                  ],
                                ),
                              ),
                              Text("₹${_refund!.amount.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isDark
                                ? Colors.white12
                                : const Color(0xFFECECF2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Refund Information",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          const Divider(height: 20),
                          _buildRow("Refund Reason", _refund!.refundReason),
                          const SizedBox(height: 10),
                          if (_refund!.paymentInfo != null &&
                              _refund!.paymentInfo!.isNotEmpty)
                            _buildRow("Payment Info", _refund!.paymentInfo!),
                          if (_refund!.approvedNote != null &&
                              _refund!.approvedNote!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _buildRow("Approved Note", _refund!.approvedNote!),
                          ],
                          if (_refund!.rejectedNote != null &&
                              _refund!.rejectedNote!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _buildRow("Rejected Note", _refund!.rejectedNote!),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 13.5, color: isDark ? Colors.white : Colors.black87)),
      ],
    );
  }
}
