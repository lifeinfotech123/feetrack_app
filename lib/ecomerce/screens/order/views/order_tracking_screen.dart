import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants.dart';
import '../../../controllers/order_tracking_controller.dart';
import '../../../models/order_model.dart';
import 'components/order_tracking_address_card.dart';
import 'components/order_tracking_delivery_partner_card.dart';
import 'components/order_tracking_map_view.dart';
import 'components/order_tracking_status_card.dart';
import 'components/order_tracking_summary_card.dart';
import 'components/order_tracking_timeline_widget.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;
  final String? storeDomain;
  final OrderListItemModel? initialOrder;
  final Map<String, dynamic>? initialData;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    this.storeDomain,
    this.initialOrder,
    this.initialData,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late final OrderTrackingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      OrderTrackingController(
        orderId: widget.orderId,
        storeDomain: widget.storeDomain,
        initialOrder: widget.initialOrder,
        initialData: widget.initialData,
      ),
      tag: 'tracking_${widget.orderId}',
    );
  }

  @override
  void dispose() {
    Get.delete<OrderTrackingController>(tag: 'tracking_${widget.orderId}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final bodyBg = isDark ? const Color(0xFF121218) : const Color(0xFFF7F7FA);

    return Scaffold(
      backgroundColor: bodyBg,
      appBar: AppBar(
        title: Text(
          "Track Order #${widget.orderId}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: cardBg,
        actions: [
          IconButton(
            onPressed: () {
              controller.loadTrackingDetails();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Tracking updated"),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Tracking",
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.trackingData.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: primaryColor),
                SizedBox(height: 16),
                Text(
                  "Loading live tracking details...",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        final model = controller.trackingData.value;

        if (model == null) {
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
                    "Tracking details could not be loaded",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => controller.loadTrackingDetails(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text("Try Again"),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: primaryColor,
          onRefresh: controller.loadTrackingDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Google Map View Container
                OrderTrackingMapView(
                  controller: controller,
                  isDark: isDark,
                  cardBg: cardBg,
                ),

                const SizedBox(height: 16),

                // 2. Status & Estimated Arrival Card
                OrderTrackingStatusCard(
                  model: model,
                  controller: controller,
                  isDark: isDark,
                  cardBg: cardBg,
                ),

                const SizedBox(height: 16),

                // 3. Delivery Partner Info Card
                OrderTrackingDeliveryPartnerCard(
                  partner: model.deliveryPartner,
                  status: model.orderStatus,
                  controller: controller,
                  isDark: isDark,
                  cardBg: cardBg,
                ),

                const SizedBox(height: 16),

                // 4. Step-by-Step Order Status Timeline
                OrderTrackingTimelineWidget(
                  steps: model.timelineSteps,
                  isDelivered: model.isDelivered,
                  isCancelled: model.isCancelled,
                  isDark: isDark,
                  cardBg: cardBg,
                ),

                const SizedBox(height: 16),

                // 5. Delivery Address Card
                if (model.shippingAddress != null) ...[
                  OrderTrackingAddressCard(
                    address: model.shippingAddress,
                    orderNote: model.orderNote,
                    isDark: isDark,
                    cardBg: cardBg,
                  ),
                  const SizedBox(height: 16),
                ],

                // 6. Order Summary Card
                OrderTrackingSummaryCard(
                  model: model,
                  isDark: isDark,
                  cardBg: cardBg,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }
}
