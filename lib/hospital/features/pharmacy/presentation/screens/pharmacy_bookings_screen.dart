import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/hospital/core/constants/colors.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';

import '../../data/model/order_model.dart';
import '../../logics/pharmacy_controller.dart';
import 'pharmacy_invoice_detail_screen.dart';
import 'pharmacy_screen.dart';

class PharmacyBookingsScreen extends StatefulWidget {
  const PharmacyBookingsScreen({super.key});

  @override
  State<PharmacyBookingsScreen> createState() => _PharmacyBookingsScreenState();
}

class _PharmacyBookingsScreenState extends State<PharmacyBookingsScreen> {
  late final PharmacyController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PharmacyController>()
        ? Get.find<PharmacyController>()
        : Get.put(PharmacyController());
    if (controller.isLoggedIn) {
      controller.fetchPatientOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: pharmacyTeal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: colorWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Bookings & Invoices',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: colorWhite,
          ),
        ),
        actions: [
          Obx(() {
            if (controller.isOrdersLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorWhite,
                    ),
                  ),
                ),
              );
            }
            return IconButton(
              icon: const Icon(Icons.refresh_rounded, color: colorWhite),
              tooltip: 'Refresh Orders',
              onPressed: () => controller.fetchPatientOrders(),
            );
          }),
        ],
      ),
      body: RefreshIndicator(
        color: pharmacyTeal,
        onRefresh: () async {
          await controller.fetchPatientOrders();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header summary banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [pharmacyTeal, Color(0xFF004D40)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: pharmacyTeal.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: colorWhite,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Medicine Booking History',
                            style: TextStyle(
                              color: colorWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() {
                            if (!controller.isLoggedIn) {
                              return const Text(
                                'Log in to view your orders • Guest mode',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              );
                            }
                            final count = controller.patientOrders.length;
                            return Text(
                              count == 0
                                  ? 'No orders booked yet'
                                  : '$count ${count == 1 ? "order" : "orders"} placed • Tap any order for invoice receipt',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Orders List or Empty/Loading State
              Obx(() {
                if (!controller.isLoggedIn) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderGrey),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_outline_rounded,
                            size: 48,
                            color: Colors.amber.shade800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Browsing as Guest',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Please log in with your FeeTrack account to view your past medicine bookings and invoices.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: textMuted),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => Get.to(() => const LoginScreen()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pharmacyTeal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.login_rounded,
                              color: colorWhite, size: 18),
                          label: const Text(
                            'Log In to FeeTrack',
                            style: TextStyle(
                              color: colorWhite,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.isOrdersLoading.value &&
                    controller.patientOrders.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(36),
                    decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderGrey),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: pharmacyTeal),
                        SizedBox(height: 14),
                        Text(
                          'Loading booked medicine orders...',
                          style: TextStyle(fontSize: 13, color: textMuted),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.patientOrders.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderGrey),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: pharmacyTealBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.medication_liquid_outlined,
                            size: 48,
                            color: pharmacyTeal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Medicine Orders Yet',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Your booked medicine orders and invoices will appear here automatically after checkout.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: textMuted),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PharmacyScreen()),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pharmacyTeal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.shopping_bag_outlined,
                              color: colorWhite, size: 18),
                          label: const Text(
                            'Browse Pharmacy Medicines',
                            style: TextStyle(
                              color: colorWhite,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Bookings (${controller.patientOrders.length})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const Text(
                          'Select order to view invoice',
                          style: TextStyle(
                            fontSize: 11,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.patientOrders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, idx) {
                        final order = controller.patientOrders[idx];
                        return _buildOrderCard(order);
                      },
                    ),
                  ],
                );
              }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(PatientMedicineOrder order) {
    final isConfirmed = order.orderStatus?.toLowerCase() == 'confirmed';
    final isRazorpay =
        order.paymentMode?.toLowerCase().contains('razorpay') == true;

    final displayOrderNo = (order.groupOrderNo?.isNotEmpty == true)
        ? order.groupOrderNo!
        : (order.billNo?.isNotEmpty == true
            ? order.billNo!
            : 'ORD-#${order.billId}');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openInvoice(order.billId),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: colorWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderGrey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isConfirmed
                      ? Colors.green.shade50
                      : Colors.amber.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tag_rounded,
                          size: 16,
                          color: isConfirmed
                              ? Colors.green.shade800
                              : Colors.amber.shade900,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          displayOrderNo,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isConfirmed
                                ? Colors.green.shade900
                                : Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isConfirmed
                            ? Colors.green.shade700
                            : Colors.orange.shade800,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.orderStatus?.toUpperCase() ?? 'PENDING',
                        style: const TextStyle(
                          color: colorWhite,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.hospital != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.local_hospital_rounded,
                              size: 14, color: pharmacyTeal),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${order.hospital!.name ?? "Hospital"} (${order.hospital!.domain ?? ""})',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customerName ?? 'Patient',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            if (order.customerPhone != null &&
                                order.customerPhone!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                order.customerPhone!,
                                style: const TextStyle(
                                    fontSize: 11, color: textMuted),
                              ),
                            ],
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(fontSize: 10, color: textMuted),
                            ),
                            Text(
                              '₹${order.netAmount ?? order.paymentAmount ?? 0}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: pharmacyTeal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Divider(height: 1, color: borderGrey),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isRazorpay
                                  ? Icons.credit_card_rounded
                                  : Icons.payments_outlined,
                              size: 15,
                              color: pharmacyTeal,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              order.paymentMode ?? 'Cash on Delivery',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textDark,
                              ),
                            ),
                          ],
                        ),
                        if (order.billDate != null &&
                            order.billDate!.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 12, color: textMuted),
                              const SizedBox(width: 4),
                              Text(
                                order.billDate!,
                                style: const TextStyle(
                                    fontSize: 11, color: textMuted),
                              ),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Action button
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton.icon(
                        onPressed: () => _openInvoice(order.billId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pharmacyTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.receipt_rounded,
                            color: colorWhite, size: 16),
                        label: const Text(
                          'VIEW INVOICE / RECEIPT',
                          style: TextStyle(
                            color: colorWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openInvoice(dynamic billId) {
    if (billId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PharmacyInvoiceDetailScreen(billId: billId),
        ),
      );
    } else {
      Get.snackbar(
        'Notice',
        'Invoice ID not available for this booking.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
