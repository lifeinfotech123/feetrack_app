import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../constants.dart';
import '../../../controllers/orders_controller.dart';
import '../../../models/order_model.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  final String? initialFilter;

  const OrdersScreen({
    super.key,
    this.initialFilter,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final OrdersController _controller;
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _filterTabs = const [
    'All',
    'Food',
    'eCommerce',
    'Pending',
    'Delivered',
    'Canceled',
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<OrdersController>()
        ? Get.find<OrdersController>()
        : Get.put(OrdersController());

    if (widget.initialFilter != null && widget.initialFilter!.isNotEmpty) {
      _controller.setFilter(widget.initialFilter!);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatDate(String rawDate) {
    if (rawDate.isEmpty) return 'Date not available';
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final bodyBg = isDark ? const Color(0xFF121218) : const Color(0xFFF7F7FA);

    return Scaffold(
      backgroundColor: bodyBg,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "My Orders",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 8),
            Obx(() {
              final count = _controller.orders.length;
              if (count == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$count",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              );
            }),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: cardBg,
        actions: [
          IconButton(
            onPressed: () => _controller.fetchOrders(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Orders",
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Box & Filter Chips Bar (Sticky Header)
          Container(
            color: cardBg,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search Input
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF282836) : const Color(0xFFF1F1F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => _controller.setSearch(val),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      hintText: "Search by Order ID, store, status...",
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: isDark ? Colors.white60 : Colors.black45,
                      ),
                      suffixIcon: Obx(() {
                        if (_controller.searchQuery.value.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            _controller.setSearch('');
                          },
                        );
                      }),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Horizontal Filter Chips
                SizedBox(
                  height: 36,
                  child: Obx(() {
                    final current = _controller.selectedFilter.value;
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filterTabs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final tab = _filterTabs[index];
                        final isSelected =
                            current.toLowerCase() == tab.toLowerCase();

                        Color activeColor = primaryColor;
                        IconData? tabIcon;
                        if (tab == 'Food') {
                          activeColor = const Color(0xFFFF9800);
                          tabIcon = Icons.restaurant_rounded;
                        } else if (tab == 'eCommerce') {
                          activeColor = const Color(0xFF7C4DFF);
                          tabIcon = Icons.local_mall_rounded;
                        } else if (tab == 'Pending') {
                          activeColor = const Color(0xFFFFB300);
                          tabIcon = Icons.hourglass_top_rounded;
                        } else if (tab == 'Delivered') {
                          activeColor = const Color(0xFF00C853);
                          tabIcon = Icons.check_circle_rounded;
                        } else if (tab == 'Canceled') {
                          activeColor = const Color(0xFFFF5252);
                          tabIcon = Icons.cancel_rounded;
                        }

                        return InkWell(
                          onTap: () => _controller.setFilter(tab),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? activeColor
                                  : (isDark
                                      ? const Color(0xFF282836)
                                      : const Color(0xFFF1F1F5)),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? activeColor
                                    : (isDark
                                        ? Colors.white12
                                        : Colors.transparent),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (tabIcon != null) ...[
                                  Icon(
                                    tabIcon,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white70
                                            : Colors.black54),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                                Text(
                                  tab,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white70
                                            : Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),

          // 2. Orders List View
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value && _controller.orders.isEmpty) {
                return _buildLoadingSkeleton(isDark);
              }

              if (_controller.errorMessage.value.isNotEmpty &&
                  _controller.orders.isEmpty) {
                return _buildErrorState(
                  message: _controller.errorMessage.value,
                  onRetry: () => _controller.fetchOrders(),
                );
              }

              final displayOrders = _controller.filteredOrders;

              if (displayOrders.isEmpty) {
                return _buildEmptyState(
                  context,
                  isDark: isDark,
                  hasFilter: _controller.selectedFilter.value != 'All' ||
                      _controller.searchQuery.value.isNotEmpty,
                );
              }

              return RefreshIndicator(
                color: primaryColor,
                onRefresh: () => _controller.fetchOrders(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: displayOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = displayOrders[index];
                    return _buildOrderCard(
                      context,
                      order: order,
                      isDark: isDark,
                      cardBg: cardBg,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Single Order Card
  Widget _buildOrderCard(
    BuildContext context, {
    required OrderListItemModel order,
    required bool isDark,
    required Color cardBg,
  }) {
    final bool isFood = order.isFood;
    final String status = order.orderStatus.toLowerCase();

    // Status visual configuration
    Color statusColor;
    IconData statusIcon;
    String statusTitle;

    if (status == 'delivered') {
      statusColor = const Color(0xFF00C853);
      statusIcon = Icons.check_circle_rounded;
      statusTitle = "Delivered";
    } else if (status == 'canceled' || status == 'cancelled') {
      statusColor = const Color(0xFFFF5252);
      statusIcon = Icons.cancel_rounded;
      statusTitle = "Canceled";
    } else if (status == 'confirmed' || status == 'processing') {
      statusColor = const Color(0xFF2979FF);
      statusIcon = Icons.sync_rounded;
      statusTitle = "Processing";
    } else {
      statusColor = const Color(0xFFFFB300);
      statusIcon = Icons.hourglass_top_rounded;
      statusTitle = "Pending";
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFECECF2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailsScreen(
                  orderId: order.orderId,
                  storeDomain: order.domain,
                  initialOrder: order,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Order ID + Type Badge + Status Badge
                Row(
                  children: [
                    // Order ID Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF282836)
                            : const Color(0xFFEFEFF6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "#${order.orderId}",
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Order Type Pill (Food vs eCommerce)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isFood
                            ? const Color(0xFFFF9800).withValues(alpha: 0.12)
                            : const Color(0xFF7C4DFF).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isFood
                                ? Icons.restaurant_rounded
                                : Icons.shopping_bag_outlined,
                            size: 12,
                            color: isFood
                                ? const Color(0xFFE65100)
                                : const Color(0xFF7C4DFF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isFood ? "FOOD" : "STORE",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                              color: isFood
                                  ? const Color(0xFFE65100)
                                  : const Color(0xFF7C4DFF),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Order Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusTitle,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Row 2: Store / Vendor Name & Placed Date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: primaryColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.vendor.isNotEmpty ? order.vendor : "Store",
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: isDark ? Colors.white38 : Colors.black45,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  _formatDate(order.createdAt),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark ? Colors.white10 : const Color(0xFFF1F1F5),
                ),
                const SizedBox(height: 12),

                // Row 3: Items Count, Payment Status & Total Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Items Count & Payment pill
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${order.itemsCount} ${order.itemsCount == 1 ? 'item' : 'items'}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: order.isPaid
                                    ? const Color(0xFF00C853)
                                    : const Color(0xFFFF9800),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "${order.paymentMethod.replaceAll('_', ' ').toUpperCase()} • ${order.paymentStatus.toUpperCase()}",
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: order.isPaid
                                    ? const Color(0xFF00C853)
                                    : const Color(0xFFFF9800),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Amount + CTA
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "Total Amount",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "₹${order.orderAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        if (status == 'delivered')
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailsScreen(
                                    orderId: order.orderId,
                                    storeDomain: order.domain,
                                    initialOrder: order,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.star_rate_rounded, size: 16),
                            label: const Text("Review"),
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 13,
                              color: primaryColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Loading Skeleton UI
  Widget _buildLoadingSkeleton(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 140,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E28) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 90,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : const Color(0xFFECECF2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  width: 70,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : const Color(0xFFECECF2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: 180,
              height: 14,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFECECF2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 12,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFECECF2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : const Color(0xFFECECF2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  width: 70,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : const Color(0xFFECECF2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Empty State UI
  Widget _buildEmptyState(
    BuildContext context, {
    required bool isDark,
    required bool hasFilter,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 54,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasFilter ? "No Matching Orders" : "No Orders Placed Yet",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? "Try changing your search query or selected filter to see other orders."
                  : "Explore our stores and restaurants to place your first order!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            if (hasFilter)
              OutlinedButton.icon(
                onPressed: () {
                  _searchCtrl.clear();
                  _controller.setSearch('');
                  _controller.setFilter('All');
                },
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text("Reset Filters"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: const BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => _controller.fetchOrders(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Refresh"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Error State UI
  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 54,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              "Unable to load orders",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }
}
