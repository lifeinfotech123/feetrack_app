import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/rooom/pg_customer_dashboard_model.dart';

class MyPgSubscriptionDetailScreen extends StatefulWidget {
  final String subscriptionId;
  final PgCustomerSubscriptionItem? initialData;

  const MyPgSubscriptionDetailScreen({
    super.key,
    required this.subscriptionId,
    this.initialData,
  });

  @override
  State<MyPgSubscriptionDetailScreen> createState() =>
      _MyPgSubscriptionDetailScreenState();
}

class _MyPgSubscriptionDetailScreenState
    extends State<MyPgSubscriptionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<RoomController>();
      if (widget.initialData != null) {
        controller.selectedCustomerSubscription = widget.initialData;
        controller.update();
      }
      if (widget.subscriptionId.isNotEmpty) {
        controller.fetchPgCustomerSubscriptionDetail(widget.subscriptionId);
      }
    });
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value?.isNotEmpty == true ? value! : "—",
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF002060),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Subscription Details",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<RoomController>(
        builder: (ctrl) {
          final sub = ctrl.selectedCustomerSubscription ?? widget.initialData;
          final isLoading =
              ctrl.isCustomerSubscriptionDetailLoading && sub == null;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (sub == null) {
            return const Center(
              child: Text(
                "Subscription details not found",
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            );
          }

          final isActive = (sub.status ?? "").toLowerCase() == 'active';

          return RefreshIndicator(
            color: const Color(0xFF002060),
            onRefresh: () async {
              if (widget.subscriptionId.isNotEmpty) {
                await ctrl
                    .fetchPgCustomerSubscriptionDetail(widget.subscriptionId);
              }
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sub.subscriptionNumber ?? "Plan",
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF002060),
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              sub.statusLabel ??
                                  (isActive ? "ACTIVE" : "EXPIRED"),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        (sub.property is Map
                                ? (sub.property['title']?.toString())
                                : null) ??
                            "PG Accommodation",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (sub.property is Map
                                ? ((sub.property['full_address']?.toString()) ??
                                    (sub.property['address']?.toString()))
                                : null) ??
                            "",
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Plan Details",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow("Plan Name",
                          sub.package?['name']?.toString()),
                      _buildInfoRow("Duration (Days)",
                          sub.package?['duration_days']?.toString()),
                      _buildInfoRow("Occupancy",
                          sub.package?['occupancy_type']?.toString()),
                      _buildInfoRow("Price", sub.package?['price']?.toString()),
                      _buildInfoRow("Start Date", sub.formattedStartsAt ?? sub.startsAt),
                      _buildInfoRow("Expiry Date", sub.formattedExpiresAt ?? sub.expiresAt),
                      _buildInfoRow("Source", sub.source),
                    ],
                  ),
                ),
                if (sub.property != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Property Information",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (sub.property is Map) ...[
                          _buildInfoRow(
                              "Title", sub.property['title']?.toString()),
                          _buildInfoRow(
                              "Phone", sub.property['phone']?.toString()),
                          _buildInfoRow(
                              "City", sub.property['city']?.toString()),
                          _buildInfoRow(
                              "Address", sub.property['address']?.toString()),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
