import 'dart:math';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../order/views/orders_screen.dart';

class ThanksForOrderScreen extends StatelessWidget {
  final Map<String, dynamic>? orderData;

  const ThanksForOrderScreen({super.key, this.orderData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? darkGreyColor : Colors.white;
    final bodyBg = isDark ? const Color(0xFF121218) : const Color(0xFFF6F6F9);

    final Map<String, dynamic> rawArgs = orderData ??
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
        {};

    final Map<String, dynamic> data = (rawArgs['data'] is Map<String, dynamic>)
        ? (rawArgs['data'] as Map<String, dynamic>)
        : rawArgs;

    final String orderId =
        (data['order_id'] ?? rawArgs['order_id'] ?? data['orderId'] ??
                '${100000 + Random().nextInt(90000)}')
            .toString();
    final String orderGroupId = (data['order_group_id'] ??
            rawArgs['order_group_id'] ??
            '${DateTime.now().millisecondsSinceEpoch}-756')
        .toString();
    final String verificationCode = (data['verification_code'] ??
            rawArgs['verification_code'] ??
            '${1000 + Random().nextInt(9000)}')
        .toString();
    final String vendor = (data['vendor'] ??
            (data['vendor_details'] is Map
                ? data['vendor_details']['shop_name']
                : null) ??
            rawArgs['vendor'] ??
            'The Corner')
        .toString();
    final String paymentMethod = (data['payment_method'] ??
            rawArgs['paymentMethod'] ??
            'cash_on_delivery')
        .toString();
    final String paymentStatus =
        (data['payment_status'] ?? (paymentMethod.contains('cash') ? 'unpaid' : 'paid'))
            .toString();
    final String placedAt = (data['placed_at'] ?? 'Just now').toString();
    final String? orderNote = data['order_note'] ?? rawArgs['order_note'];

    final List items = (data['items'] is List)
        ? data['items'] as List
        : (rawArgs['items'] is List ? rawArgs['items'] as List : []);

    final Map<String, dynamic>? billSummary =
        data['bill_summary'] is Map<String, dynamic>
            ? data['bill_summary'] as Map<String, dynamic>
            : (rawArgs['bill_summary'] is Map<String, dynamic>
                ? rawArgs['bill_summary'] as Map<String, dynamic>
                : null);

    final Map<String, dynamic>? shippingAddress =
        data['shipping_address'] is Map<String, dynamic>
            ? data['shipping_address'] as Map<String, dynamic>
            : (rawArgs['shipping_address'] is Map<String, dynamic>
                ? rawArgs['shipping_address'] as Map<String, dynamic>
                : null);

    final double totalAmount = billSummary != null &&
            billSummary['total_payable_amount'] != null
        ? (billSummary['total_payable_amount'] as num).toDouble()
        : (rawArgs['amount'] as num?)?.toDouble() ?? 0.0;

    final double savings = billSummary != null &&
            billSummary['item_discounts'] != null
        ? (billSummary['item_discounts'] as num).toDouble()
        : (rawArgs['savings'] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      backgroundColor: bodyBg,
      appBar: AppBar(
        backgroundColor: bodyBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text(
          "Order Confirmation",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            tooltip: "Close",
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. TOP ORDER CONFIRMED BANNER
              _buildTopConfirmedSection(
                cardBg: cardBg,
                isDark: isDark,
                orderId: orderId,
                orderGroupId: orderGroupId,
                verificationCode: verificationCode,
                vendor: vendor,
                placedAt: placedAt,
              ),

              const SizedBox(height: 16),

              // 2. ORDER TRACK TIMELINE CARD ("Order Track")
              _buildOrderTrackCard(
                cardBg: cardBg,
                isDark: isDark,
                orderId: orderId,
                placedAt: placedAt,
              ),

              const SizedBox(height: 16),

              // 3. SHIPPING ADDRESS SUMMARY
              if (shippingAddress != null)
                _buildShippingAddressCard(
                  cardBg: cardBg,
                  isDark: isDark,
                  shippingAddress: shippingAddress,
                  orderNote: orderNote,
                ),

              if (shippingAddress != null) const SizedBox(height: 16),

              // 4. ORDER ITEMS & BILL SUMMARY
              _buildBillAndItemsCard(
                cardBg: cardBg,
                isDark: isDark,
                items: items,
                billSummary: billSummary,
                totalAmount: totalAmount,
                savings: savings,
                paymentMethod: paymentMethod,
                paymentStatus: paymentStatus,
              ),

              const SizedBox(height: 24),

              // 5. ACTION BUTTONS
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrdersScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.receipt_long_rounded,
                    color: Colors.white, size: 20),
                label: const Text(
                  "VIEW ALL ORDERS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.4,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                label: const Text(
                  "CONTINUE SHOPPING",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopConfirmedSection({
    required Color cardBg,
    required bool isDark,
    required String orderId,
    required String orderGroupId,
    required String verificationCode,
    required String vendor,
    required String placedAt,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(
          color: successColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: successColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated Check Badge
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: successColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: successColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            "Order Confirmed! 🎉",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Your order has been placed and confirmed by $vendor",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? Colors.white70 : blackColor60,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Order ID & Verification Code Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBadgeItem(
                label: "ORDER ID",
                value: "#$orderId",
                icon: Icons.tag_rounded,
                color: primaryColor,
                isDark: isDark,
              ),
              Container(width: 1, height: 36, color: Colors.grey.withValues(alpha: 0.2)),
              _buildBadgeItem(
                label: "DELIVERY CODE",
                value: verificationCode,
                icon: Icons.vpn_key_rounded,
                color: Colors.deepOrange,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242432) : const Color(0xFFF3F3F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_rounded, size: 13, color: greyColor),
                const SizedBox(width: 6),
                Text(
                  "Placed: $placedAt",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : greyColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white54 : greyColor,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : blackColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. ORDER TRACK TIMELINE CARD
  Widget _buildOrderTrackCard({
    required Color cardBg,
    required bool isDark,
    required String orderId,
    required String placedAt,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFECECF0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Live Order Status & Tracking",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "⚡ Estimated Delivery: 25 - 35 Mins",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: successColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      "LIVE",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Timeline Tracker Steps
          _buildTrackStep(
            title: "Order Placed",
            subtitle: "Order placed successfully at $placedAt",
            isCompleted: true,
            isActive: false,
            isLast: false,
            isDark: isDark,
          ),
          _buildTrackStep(
            title: "Order Confirmed",
            subtitle: "Store accepted your order",
            isCompleted: true,
            isActive: false,
            isLast: false,
            isDark: isDark,
          ),
          _buildTrackStep(
            title: "Preparing in Kitchen",
            subtitle: "Chef is freshly cooking & packing your items",
            isCompleted: false,
            isActive: true,
            isLast: false,
            isDark: isDark,
          ),
          _buildTrackStep(
            title: "Out for Delivery",
            subtitle: "Delivery partner will pick up soon",
            isCompleted: false,
            isActive: false,
            isLast: false,
            isDark: isDark,
          ),
          _buildTrackStep(
            title: "Delivered to Doorstep",
            subtitle: "Share verification code with delivery agent",
            isCompleted: false,
            isActive: false,
            isLast: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
    required bool isDark,
  }) {
    final Color stepColor = isCompleted
        ? successColor
        : (isActive ? primaryColor : (isDark ? Colors.white30 : Colors.grey.shade400));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? successColor
                    : (isActive ? primaryColor : Colors.transparent),
                border: Border.all(
                  color: stepColor,
                  width: isActive ? 3 : 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : (isActive
                      ? const Center(
                          child: CircleAvatar(
                            radius: 3,
                            backgroundColor: Colors.white,
                          ),
                        )
                      : null),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isCompleted
                    ? successColor
                    : (isDark ? Colors.white12 : Colors.grey.shade300),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? primaryColor
                        : (isCompleted
                            ? (isDark ? Colors.white : blackColor)
                            : (isDark ? Colors.white54 : greyColor)),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : greyColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 3. SHIPPING ADDRESS CARD
  Widget _buildShippingAddressCard({
    required Color cardBg,
    required bool isDark,
    required Map<String, dynamic> shippingAddress,
    String? orderNote,
  }) {
    final String name = (shippingAddress['contact_person_name'] ??
            shippingAddress['name'] ??
            'Recipient')
        .toString();
    final String phone = (shippingAddress['phone'] ?? '').toString();
    final String address = (shippingAddress['address'] ?? '').toString();
    final String city = (shippingAddress['city'] ?? '').toString();
    final String zip = (shippingAddress['zip'] ?? '').toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFECECF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_rounded, size: 18, color: primaryColor),
              SizedBox(width: 8),
              Text(
                "Delivery Address",
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              "Phone: $phone",
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? Colors.white70 : blackColor60,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            "$address${city.isNotEmpty ? ', $city' : ''}${zip.isNotEmpty ? ' - $zip' : ''}",
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : blackColor60,
              height: 1.3,
            ),
          ),
          if (orderNote != null && orderNote.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF242432) : const Color(0xFFF7F7F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note_alt_outlined, size: 14, color: greyColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Note: $orderNote",
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white70 : blackColor80,
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

  // 4. BILL & ITEMS CARD
  Widget _buildBillAndItemsCard({
    required Color cardBg,
    required bool isDark,
    required List items,
    required Map<String, dynamic>? billSummary,
    required double totalAmount,
    required double savings,
    required String paymentMethod,
    required String paymentStatus,
  }) {
    final bool isCod = paymentMethod.toLowerCase().contains('cash');
    final String paymentLabel =
        isCod ? "Cash on Delivery" : "Online (Razorpay)";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFECECF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Items List (if available)
          if (items.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.fastfood_rounded, size: 16, color: primaryColor),
                SizedBox(width: 8),
                Text(
                  "Order Items",
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...items.map((it) {
              final name = it['name'] ?? it['title'] ?? 'Product Item';
              final qty = it['quantity'] ?? 1;
              final price = (it['line_total'] ?? it['total_price'] ?? it['unit_price'] ?? 0);
              final prodId = it['id'] ?? it['product_id'];
              final catName = it['category_name'] ?? (it['category'] is Map ? it['category']['name'] : null);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$qty x $name",
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : blackColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (prodId != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white10 : const Color(0xFFF0F0F4),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "ID: #$prodId",
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white70 : blackColor60,
                                    ),
                                  ),
                                ),
                              if (catName != null && catName.toString().isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "Category: $catName",
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "₹$price",
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 20),
          ],

          // Payment Mode Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Payment Mode",
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? Colors.white60 : greyColor,
                ),
              ),
              Row(
                children: [
                  Text(
                    paymentLabel,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isCod ? warningColor : successColor)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isCod ? "UNPAID" : "PAID",
                      style: TextStyle(
                        color: isCod ? warningColor : successColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Total Amount Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                "₹${totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
            ],
          ),

          if (savings > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: successColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.savings_rounded, color: successColor, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    "You saved ₹${savings.toStringAsFixed(2)} on this order!",
                    style: const TextStyle(
                      color: successColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
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
