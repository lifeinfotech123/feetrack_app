import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../components/skleton/skelton.dart';
import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../controllers/return_refund_controller.dart';
import '../../../models/order_model.dart';
import 'order_tracking_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  final String? storeDomain;
  final OrderListItemModel? initialOrder;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    this.storeDomain,
    this.initialOrder,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late final OrdersController _controller;
  late final ReturnRefundController _returnController;

  String? get _effectiveStore =>
      widget.storeDomain ?? widget.initialOrder?.domain;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<OrdersController>()
        ? Get.find<OrdersController>()
        : Get.put(OrdersController());
    _returnController = Get.isRegistered<ReturnRefundController>()
        ? Get.find<ReturnRefundController>()
        : Get.put(ReturnRefundController());
    _controller.fetchOrderDetails(widget.orderId, storeDomain: _effectiveStore);
  }

  Future<void> _downloadInvoice() async {
    final domain = _effectiveStore ?? 'e-team-12';
    final invoiceUrl =
        await _controller.fetchInvoiceUrl(widget.orderId, domain: domain);
    final uri = Uri.parse(invoiceUrl ??
        '${ecomBaseUrl}orders/invoice?domain=$domain&order_id=${widget.orderId}&download=1');

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not open invoice"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to open invoice"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final bodyBg = isDark ? const Color(0xFF121218) : const Color(0xFFF7F7FA);

    return Scaffold(
      backgroundColor: bodyBg,
      appBar: AppBar(
        title: Text(
          "Order #${widget.orderId}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: cardBg,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderTrackingScreen(
                    orderId: widget.orderId,
                    storeDomain: _effectiveStore,
                    initialOrder: widget.initialOrder,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.location_on_rounded, color: primaryColor),
            tooltip: "Track Order",
          ),
          IconButton(
            onPressed: _downloadInvoice,
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: "Download Invoice",
          ),
          IconButton(
            onPressed: () => _controller.fetchOrderDetails(
              widget.orderId,
              storeDomain: _effectiveStore,
            ),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Details",
          ),
        ],
      ),

      // FIX: Obx must be inside Scaffold.body.
      body: Obx(() {
        if (_controller.isDetailLoading.value &&
            _controller.currentOrderDetail.value == null) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          );
        }

        final detail = _controller.currentOrderDetail.value;
        final initial = widget.initialOrder;

        if (detail == null && initial == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Order details could not be loaded",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _controller.fetchOrderDetails(
                      widget.orderId,
                      storeDomain: _effectiveStore,
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text("Try Again"),
                  ),
                ],
              ),
            ),
          );
        }

        final status =
            (detail?.orderStatus ?? initial?.orderStatus ?? 'pending')
                .toLowerCase();

        final amount = detail?.orderAmount ?? initial?.orderAmount ?? 0.0;
        final shipping = detail?.shippingCost ?? initial?.shippingCost ?? 0.0;
        final discount = detail?.discountAmount ?? 0.0;
        final paymentMethod = detail?.paymentMethod ??
            initial?.paymentMethod ??
            'cash_on_delivery';
        final paymentStatus =
            detail?.paymentStatus ?? initial?.paymentStatus ?? 'unpaid';
        final createdAt = detail?.createdAt ?? initial?.createdAt ?? '';
        final verifyCode = detail?.verificationCode;
        final orderNote = detail?.orderNote;
        final orderGroupId = detail?.orderGroupId;
        final isFood = initial?.isFood ?? false;
        final vendor = detail?.vendor ?? initial?.vendor ?? 'Store';
        final vendorDetails = detail?.vendorDetails;
        final statusTimeline = detail?.statusTimeline;

        return RefreshIndicator(
          color: primaryColor,
          onRefresh: () => _controller.fetchOrderDetails(
            widget.orderId,
            storeDomain: _effectiveStore,
          ),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatusBannerCard(
                status: status,
                isFood: isFood,
                createdAt: createdAt,
                isDark: isDark,
                cardBg: cardBg,
              ),
              if (status != 'delivered' &&
                  status != 'canceled' &&
                  status != 'cancelled') ...[
                const SizedBox(height: 14),
                _buildTrackOrderCard(
                  status: status,
                  isDark: isDark,
                  cardBg: cardBg,
                ),
              ],
              const SizedBox(height: 14),
              if (verifyCode != null && verifyCode.trim().isNotEmpty) ...[
                _buildVerificationCard(
                  verifyCode.trim(),
                  isDark: isDark,
                  cardBg: cardBg,
                ),
                const SizedBox(height: 14),
              ],
              _buildVendorCard(
                vendor: vendor,
                vendorDetails: vendorDetails,
                isDark: isDark,
                cardBg: cardBg,
              ),
              if (orderNote != null && orderNote.trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildOrderNoteCard(
                  note: orderNote.trim(),
                  isDark: isDark,
                  cardBg: cardBg,
                ),
              ],
              const SizedBox(height: 14),
              _buildOrderedItemsCard(
                items: detail?.items ?? [],
                isDark: isDark,
                cardBg: cardBg,
              ),
              if (statusTimeline != null && statusTimeline.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildStatusTimelineCard(
                  timeline: statusTimeline,
                  orderStatus: status,
                  isDark: isDark,
                  cardBg: cardBg,
                ),
              ],
              if (detail?.shippingAddress != null) ...[
                const SizedBox(height: 14),
                _buildShippingAddressCard(
                  address: detail!.shippingAddress!,
                  isDark: isDark,
                  cardBg: cardBg,
                ),
              ],
              const SizedBox(height: 14),
              _buildPriceBreakdownCard(
                orderGroupId: orderGroupId,
                amount: amount,
                shipping: shipping,
                discount: discount,
                couponCode: detail?.couponCode,
                couponDiscount: detail?.couponDiscount ?? 0.0,
                paymentMethod: paymentMethod,
                paymentStatus: paymentStatus,
                isDark: isDark,
                cardBg: cardBg,
              ),
              const SizedBox(height: 14),
              if (status != 'delivered' &&
                  status != 'canceled' &&
                  status != 'cancelled') ...[
                _buildActionTile(
                  icon: Icons.location_on_rounded,
                  iconColor: const Color(0xFF00C853),
                  title: "Track Order (Live Map)",
                  subtitle: "View real-time delivery location & timeline",
                  isDark: isDark,
                  cardBg: cardBg,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(
                          orderId: widget.orderId,
                          storeDomain: _effectiveStore,
                          initialOrder: widget.initialOrder,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
              _buildActionTile(
                icon: Icons.download_rounded,
                iconColor: primaryColor,
                title: "Download Invoice",
                subtitle: "Get PDF copy of your order invoice",
                isDark: isDark,
                cardBg: cardBg,
                onTap: _downloadInvoice,
              ),
              if (status == 'delivered' || status == 'completed') ...[
                const SizedBox(height: 12),
                _buildActionTile(
                  icon: Icons.replay_rounded,
                  iconColor: const Color(0xFF22C55E),
                  title: "Reorder",
                  subtitle: "Add all items from this order to cart again",
                  isDark: isDark,
                  cardBg: cardBg,
                  onTap: () async {
                    final domain = _effectiveStore ?? 'e-team-12';
                    final res = await _controller.reorder(
                      orderId: widget.orderId,
                      domain: domain,
                      clearCart: true,
                    );

                    if (!mounted) return;

                    if (res != null && res['status'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            res['message'] ?? 'Items added to cart',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pushNamed(context, '/cart');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to reorder'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildActionTile(
                  icon: Icons.star_rate_rounded,
                  iconColor: const Color(0xFFFFB300),
                  title: "Write a Review",
                  subtitle: "Rate and review your delivered items",
                  isDark: isDark,
                  cardBg: cardBg,
                  onTap: () => _showReviewBottomSheet(context, detail),
                ),
              ],
              const SizedBox(height: 12),
              _buildActionTile(
                icon: Icons.assignment_return_rounded,
                iconColor: const Color(0xFFFB923C),
                title: "Return / Refund",
                subtitle: "Request return or refund for this order",
                isDark: isDark,
                cardBg: cardBg,
                onTap: () => _showReturnBottomSheet(context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),

      // FIX: bottomNavigationBar is a Scaffold property,
      // separate from body.
      bottomNavigationBar: Obx(() {
        final status = (_controller.currentOrderDetail.value?.orderStatus ??
                widget.initialOrder?.orderStatus ??
                'pending')
            .toLowerCase();

        final canCancel = status != 'delivered' &&
            status != 'completed' &&
            status != 'cancelled' &&
            status != 'canceled';

        final isDarkBottom = Theme.of(context).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDarkBottom ? const Color(0xFF1E1E28) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDarkBottom ? Colors.white10 : const Color(0xFFE9E9F3),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                children: [
                  if (canCancel)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmCancelOrder(),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                        ),
                        label: const Text("Cancel Order"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(
                            color: Color(0xFFEF4444),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  if (canCancel) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showReturnBottomSheet(context),
                      icon: const Icon(
                        Icons.assignment_return_rounded,
                        size: 18,
                      ),
                      label: const Text("Return Order"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _confirmCancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFEF4444),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Cancel Order",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to cancel this order?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final domain = _effectiveStore ?? 'e-team-12';

    final res = await _controller.cancelOrder(
      orderId: widget.orderId,
      domain: domain,
      cause: 'Changed mind',
    );

    if (!mounted) return;

    if (res != null && res['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res['message'] ?? 'Order canceled successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await _controller.fetchOrderDetails(
        widget.orderId,
        storeDomain: _effectiveStore,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel order'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required Color cardBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFECECF2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const SizedBox.shrink(),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewBottomSheet(
      BuildContext context, OrderDetailsDataModel? detail) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final items = detail?.items ?? [];
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No items to review'),
            behavior: SnackBarBehavior.floating),
      );
      return;
    }
    int selectedIndex = 0;
    int rating = 5;
    final commentCtrl = TextEditingController();
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final item = items[selectedIndex];
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Write Review",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text("Select Item",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 64,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (context, i) {
                            final it = items[i];
                            final selected = i == selectedIndex;
                            return GestureDetector(
                              onTap: () => setState(() => selectedIndex = i),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? primaryColor.withValues(alpha: 0.1)
                                      : (isDark
                                          ? const Color(0xFF262634)
                                          : const Color(0xFFF7F7FA)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: selected
                                          ? primaryColor
                                          : Colors.transparent),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: it.thumbnail != null &&
                                              it.thumbnail!.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: it.thumbnail!,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover)
                                          : Container(
                                              width: 40,
                                              height: 40,
                                              color: Colors.grey.shade300),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(it.name,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text("Rating",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (i) {
                          return IconButton(
                            onPressed: () => setState(() => rating = i + 1),
                            icon: Icon(
                              i < rating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: const Color(0xFFFFB300),
                              size: 32,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: commentCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Review",
                          hintText: "Write your review...",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: submitting
                              ? null
                              : () async {
                                  setState(() => submitting = true);
                                  final domain = _effectiveStore ?? 'e-team-12';
                                  try {
                                    final token =
                                        await _controller.getAuthToken();
                                    final url = Uri.parse(
                                        '${ecomBaseUrl}reviews/submit');
                                    final res = await http.Client().post(
                                      url,
                                      headers: {
                                        'Accept': 'application/json',
                                        'Content-Type': 'application/json',
                                        'Authorization': 'Bearer $token',
                                      },
                                      body: jsonEncode({
                                        'domain': domain,
                                        'product_id': item.productId,
                                        'rating': rating,
                                        'comment': commentCtrl.text.trim(),
                                      }),
                                    );
                                    if (res.statusCode == 200 ||
                                        res.statusCode == 201) {
                                      final decoded = jsonDecode(res.body);
                                      if (mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(decoded['message'] ??
                                                'Your review has been updated successfully.'),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    }
                                  } catch (_) {}
                                  if (mounted) {
                                    setState(() => submitting = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: submitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text("Submit Review",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReturnBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final detail = _controller.currentOrderDetail.value;
    final items = detail?.items ?? [];
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No items found to return'),
            behavior: SnackBarBehavior.floating),
      );
      return;
    }
    int selectedIndex = 0;
    final reasonCtrl = TextEditingController();
    final paymentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final item = items[selectedIndex];
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Request Return / Refund",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text("Select Item",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 64,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (context, i) {
                            final it = items[i];
                            final selected = i == selectedIndex;
                            return GestureDetector(
                              onTap: () => setState(() => selectedIndex = i),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? primaryColor.withValues(alpha: 0.1)
                                      : (isDark
                                          ? const Color(0xFF262634)
                                          : const Color(0xFFF7F7FA)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: selected
                                          ? primaryColor
                                          : Colors.transparent),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: it.thumbnail != null &&
                                              it.thumbnail!.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: it.thumbnail!,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover)
                                          : Container(
                                              width: 40,
                                              height: 40,
                                              color: Colors.grey.shade300),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(it.name,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                        Text(
                                            "₹${it.lineTotal.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: reasonCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Reason for return",
                          hintText: "Enter reason...",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: paymentCtrl,
                        decoration: InputDecoration(
                          labelText: "Payment info (UPI/Account)",
                          hintText: "e.g. UPI: name@bank",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (reasonCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Please enter reason'),
                                    behavior: SnackBarBehavior.floating),
                              );
                              return;
                            }
                            final domain = _effectiveStore ?? 'e-team-12';
                            final success =
                                await _returnController.requestRefund(
                              domain: domain,
                              orderDetailsId: item.detailId,
                              refundReason: reasonCtrl.text.trim(),
                              paymentInfo: paymentCtrl.text.trim().isEmpty
                                  ? null
                                  : paymentCtrl.text.trim(),
                            );
                            if (success && mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Refund & return request submitted successfully.'),
                                    behavior: SnackBarBehavior.floating),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Submit Request",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTrackOrderCard({
    required String status,
    required bool isDark,
    required Color cardBg,
  }) {
    final bool isDelivered = status == 'delivered';
    final bool isCanceled = status == 'canceled' || status == 'cancelled';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Live Order Tracking",
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Track delivery partner & live route on Google Map",
                      style: TextStyle(
                        fontSize: 11.5,
                        color: greyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingScreen(
                      orderId: widget.orderId,
                      storeDomain: _effectiveStore,
                      initialOrder: widget.initialOrder,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.location_on_rounded, size: 18),
              label: Text(
                isDelivered
                    ? "VIEW DELIVERY SUMMARY & ROUTE"
                    : (isCanceled ? "VIEW ORDER TRACKING" : "TRACK ORDER ON LIVE MAP"),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBannerCard({
    required String status,
    required bool isFood,
    required String createdAt,
    required bool isDark,
    required Color cardBg,
  }) {
    Color statusColor;
    IconData statusIcon;
    String statusTitle;

    if (status == 'delivered') {
      statusColor = const Color(0xFF00C853);
      statusIcon = Icons.check_circle_rounded;
      statusTitle = "Order Delivered Successfully";
    } else if (status == 'canceled' || status == 'cancelled') {
      statusColor = const Color(0xFFE53935);
      statusIcon = Icons.cancel_rounded;
      statusTitle = "Order Cancelled";
    } else if (status == 'shipped' || status == 'processing') {
      statusColor = const Color(0xFF2196F3);
      statusIcon = Icons.local_shipping_rounded;
      statusTitle = "Order in Transit";
    } else {
      statusColor = const Color(0xFFFF9800);
      statusIcon = Icons.hourglass_top_rounded;
      statusTitle = "Order Placed & Pending";
    }

    return Container(
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
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        statusTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (isFood
                                ? const Color(0xFFFF5722)
                                : const Color(0xFF7C4DFF))
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isFood ? "FOOD" : "ECOMMERCE",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: isFood
                              ? const Color(0xFFFF5722)
                              : const Color(0xFF7C4DFF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  createdAt.isNotEmpty
                      ? "Placed on: $createdAt"
                      : "Recent Order",
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
    );
  }

  Widget _buildVerificationCard(
    String code, {
    required bool isDark,
    required Color cardBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF00C853).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF00C853).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_rounded, color: Color(0xFF00C853), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Delivery OTP / Code",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00C853),
                  ),
                ),
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Verification code copied!"),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            tooltip: "Copy Code",
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard({
    required String vendor,
    Map<String, dynamic>? vendorDetails,
    required bool isDark,
    required Color cardBg,
  }) {
    final shopName =
        vendorDetails?['shop_name']?.toString().trim().isNotEmpty == true
            ? vendorDetails!['shop_name'].toString()
            : (vendor.isNotEmpty ? vendor : "Store");
    final shopAddress = vendorDetails?['address']?.toString();
    final shopContact = vendorDetails?['contact']?.toString();

    return Container(
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shopName,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Verified Merchant",
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
          if (shopAddress != null && shopAddress.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 15,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    shopAddress.trim(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (shopContact != null && shopContact.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 15,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                const SizedBox(width: 6),
                Text(
                  shopContact.trim(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderNoteCard({
    required String note,
    required bool isDark,
    required Color cardBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF9800).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.note_alt_outlined,
            color: Color(0xFFE65100),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Order Note / Instructions",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  note,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderedItemsCard({
    required List<OrderDetailItemModel> items,
    required bool isDark,
    required Color cardBg,
  }) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Ordered Items",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${items.length} ${items.length == 1 ? 'item' : 'items'}",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Loading items details...",
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            )
          else
            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF262634)
                            : const Color(0xFFF4F4F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            item.thumbnail != null && item.thumbnail!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: item.thumbnail!,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const Skeleton(),
                                    errorWidget: (_, __, ___) => const Icon(
                                      Icons.shopping_bag_outlined,
                                      color: primaryColor,
                                      size: 22,
                                    ),
                                  )
                                : const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: primaryColor,
                                    size: 22,
                                  ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.variant != null &&
                              item.variant!.trim().isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              "Variant: ${item.variant}",
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 2),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                "Qty: ${item.quantity} × ₹${item.unitPrice.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color:
                                      isDark ? Colors.white60 : Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item.deliveryStatus.isNotEmpty &&
                                  item.deliveryStatus.toLowerCase() !=
                                      'pending') ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00C853)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.deliveryStatus.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF00C853),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 0,
                      child: Text(
                        "₹${item.lineTotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatusTimelineCard({
    required List<dynamic> timeline,
    String? orderStatus,
    required bool isDark,
    required Color cardBg,
  }) {
    final currentStatus = (orderStatus ?? '').toLowerCase().trim();
    final bool isDelivered = currentStatus == 'delivered' ||
        currentStatus == 'completed' ||
        timeline.any((entry) {
          if (entry is Map) {
            final s = entry['status']?.toString().toLowerCase().trim() ?? '';
            return s == 'delivered' || s == 'completed';
          }
          return false;
        });

    const Color deliveredGreen = Color(0xFF00C853);

    // If backend only returns 1 entry and order is delivered, synthesize full 4-step delivery milestones
    List<Map<String, dynamic>> effectiveTimeline = [];
    if (isDelivered && timeline.length == 1 && timeline.first is Map) {
      final single = timeline.first as Map<String, dynamic>;
      final timestamp = single['timestamp']?.toString() ?? '';
      effectiveTimeline = [
        {
          'status': 'ORDER PLACED',
          'cause': 'Your order has been placed successfully.',
          'timestamp': timestamp,
        },
        {
          'status': 'ORDER CONFIRMED',
          'cause': 'Seller has confirmed your order.',
          'timestamp': timestamp,
        },
        {
          'status': 'OUT FOR DELIVERY',
          'cause': 'Order is out for delivery.',
          'timestamp': timestamp,
        },
        {
          'status': 'DELIVERED',
          'cause':
              single['cause']?.toString() ?? 'Order delivered successfully.',
          'timestamp': timestamp,
        },
      ];
    } else {
      effectiveTimeline = timeline.whereType<Map<String, dynamic>>().toList();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDelivered
              ? deliveredGreen.withValues(alpha: 0.35)
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
                color: isDelivered ? deliveredGreen : primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "Order Tracking Timeline",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (!isDelivered &&
                  orderStatus != 'canceled' &&
                  orderStatus != 'cancelled') ...[
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(
                          orderId: widget.orderId,
                          storeDomain: _effectiveStore,
                          initialOrder: widget.initialOrder,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_rounded, size: 14),
                  label: const Text(
                    "Live Map",
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
              if (isDelivered) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: deliveredGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: deliveredGreen.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: deliveredGreen, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "Delivered",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: deliveredGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const Divider(height: 20),
          ...List.generate(effectiveTimeline.length, (index) {
            final entry = effectiveTimeline[index];
            final isLast = index == effectiveTimeline.length - 1;
            final isFirst = index == 0;
            final itemStatus =
                (entry['status']?.toString() ?? 'Update').toUpperCase();
            final cause = entry['cause']?.toString() ?? '';
            final time = entry['timestamp']?.toString() ?? '';

            final Color circleColor = isDelivered
                ? deliveredGreen
                : (isFirst ? primaryColor : Colors.grey.shade400);

            // When delivered, the left vertical line runs continuously from start to end in green
            final Color lineColor = isDelivered
                ? deliveredGreen
                : (isDark ? Colors.white24 : const Color(0xFFE0E0E0));

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: circleColor,
                          border: Border.all(
                            color:
                                isDark ? const Color(0xFF1E1E28) : Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: circleColor.withValues(alpha: 0.35),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: isDelivered
                            ? const Center(
                                child: Icon(
                                  Icons.check,
                                  size: 11,
                                  color: Colors.white,
                                ),
                              )
                            : (isFirst
                                ? Center(
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : null),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 3,
                            color: lineColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                itemStatus,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDelivered
                                      ? deliveredGreen
                                      : (isFirst
                                          ? primaryColor
                                          : (isDark
                                              ? Colors.white
                                              : Colors.black87)),
                                ),
                              ),
                              if (time.isNotEmpty)
                                Text(
                                  time,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black45,
                                  ),
                                ),
                            ],
                          ),
                          if (cause.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              cause,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildShippingAddressCard({
    required Map<String, dynamic> address,
    required bool isDark,
    required Color cardBg,
  }) {
    final contactName =
        address['contact_person_name'] ?? address['name'] ?? 'Customer';
    final phone = address['phone']?.toString() ?? '';
    final addr = address['address']?.toString() ?? '';
    final city = address['city']?.toString() ?? '';
    final state = address['state']?.toString() ?? '';
    final zip = address['zip']?.toString() ?? '';
    final addressType = address['address_type']?.toString();

    return Container(
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
                Icons.location_on_rounded,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Delivery Address",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              if (addressType != null && addressType.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    addressType.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 20),
          Text(
            contactName.toString(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 13,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                const SizedBox(width: 4),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Text(
            "$addr, $city, $state $zip".replaceAll(RegExp(r'\s+'), ' ').trim(),
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownCard({
    String? orderGroupId,
    required double amount,
    required double shipping,
    required double discount,
    String? couponCode,
    double couponDiscount = 0.0,
    required String paymentMethod,
    required String paymentStatus,
    required bool isDark,
    required Color cardBg,
  }) {
    final isPaid = paymentStatus.toLowerCase() == 'paid';
    final double itemsSubtotal = (amount - shipping + discount > 0)
        ? (amount - shipping + discount)
        : amount;

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Payment & Bill Details",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              // if (orderGroupId != null && orderGroupId.isNotEmpty)
              //   Text(
              //     "Ref: $orderGroupId",
              //     style: TextStyle(
              //       fontSize: 11,
              //       color: isDark ? Colors.white38 : Colors.black38,
              //     ),
              //   ),
            ],
          ),
          const Divider(height: 20),

          // Payment Mode
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Payment Mode",
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPaid
                      ? const Color(0xFF00C853).withValues(alpha: 0.12)
                      : const Color(0xFFFF9800).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${paymentMethod.replaceAll('_', ' ').toUpperCase()} (${paymentStatus.toUpperCase()})",
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isPaid
                        ? const Color(0xFF00C853)
                        : const Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Items Subtotal",
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              Text(
                "₹${itemsSubtotal.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Shipping Fee
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Delivery / Shipping Fee",
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              Text(
                shipping > 0 ? "₹${shipping.toStringAsFixed(2)}" : "FREE",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: shipping > 0
                      ? (isDark ? Colors.white70 : Colors.black87)
                      : const Color(0xFF00C853),
                ),
              ),
            ],
          ),

          // Discount / Coupon
          if (discount > 0 || couponDiscount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      "Discount",
                      style: TextStyle(fontSize: 13, color: Color(0xFF00C853)),
                    ),
                    if (couponCode != null && couponCode.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        "($couponCode)",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF00C853),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  "-₹${(discount > 0 ? discount : couponDiscount).toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C853),
                  ),
                ),
              ],
            ),
          ],

          const Divider(height: 20),

          // Total Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                "₹${amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 17,
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
