import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/room_section/pg_subscription/my_pg_subscription_detail_screen.dart';

class MyPgSubscriptionScreen extends StatefulWidget {
  const MyPgSubscriptionScreen({super.key});

  @override
  State<MyPgSubscriptionScreen> createState() => _MyPgSubscriptionScreenState();
}

class _MyPgSubscriptionScreenState extends State<MyPgSubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<RoomController>()) {
        Get.find<RoomController>().fetchPgCustomerSubscriptions();
      }
    });
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
          "My PG Subscriptions & Plans",
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
          final subscriptions = ctrl.customerSubscriptionsList;
          if (ctrl.isCustomerSubscriptionsLoading && subscriptions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (subscriptions.isEmpty) {
            return RefreshIndicator(
              color: const Color(0xFF002060),
              onRefresh: () async {
                await ctrl.fetchPgCustomerSubscriptions();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.card_membership_rounded,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        const Text(
                          "No active PG subscriptions found",
                          style:
                              TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF002060),
            onRefresh: () async {
              await ctrl.fetchPgCustomerSubscriptions();
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: subscriptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final sub = subscriptions[index];
                final isActive = (sub.status ?? "").toLowerCase() == 'active';
                final subId = sub.id ?? sub.subscriptionNumber ?? '';

                return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (subId.isNotEmpty) {
                        navigate(
                          context: context,
                          page: MyPgSubscriptionDetailScreen(
                            subscriptionId: subId,
                            initialData: sub,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                                  fontSize: 14,
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
                          const SizedBox(height: 8),
                          Text(
                            (sub.property is Map
                                    ? (sub.property['title']?.toString())
                                    : (sub.property.title?.toString())) ??
                                "PG Accommodation",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sub.package?['name']?.toString() ?? "Standard Plan",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const Divider(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Starts",
                                    style: TextStyle(
                                        fontSize: 11, color: Color(0xFF94A3B8)),
                                  ),
                                  Text(
                                    sub.formattedStartsAt ?? sub.startsAt ?? "",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        "Expires",
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF94A3B8)),
                                      ),
                                      Text(
                                        sub.formattedExpiresAt ??
                                            sub.expiresAt ??
                                            "",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: Color(0xFF94A3B8)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ));
              },
            ),
          );
        },
      ),
    );
  }
}
