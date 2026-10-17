import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/hospital/core/constants/colors.dart';

import '../../logics/pharmacy_controller.dart';
import 'GetPharmacyCategoryScreen.dart';
import 'pharmacy__place_order.dart';
import 'pharmacy_all_medicine_screen.dart';
import 'pharmacy_bookings_screen.dart';
import 'pharmacy_screen.dart';
import 'pharmacy_store_screen.dart';

class PharmacyMainScreen extends StatefulWidget {
  const PharmacyMainScreen({super.key});

  @override
  State<PharmacyMainScreen> createState() => _PharmacyMainScreenState();
}

class _PharmacyMainScreenState extends State<PharmacyMainScreen> {
  late final PharmacyController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PharmacyController>()
        ? Get.find<PharmacyController>()
        : Get.put(PharmacyController());
    controller.fetchPatientOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: pharmacyTeal,
        title: const Text(
          'Pharmacy Hub & Orders',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: colorWhite,
          ),
        ),
        actions: [
          Obx(() {
            final count = controller.cartCount;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined,
                      color: colorWhite),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PharmacyPlaceOrderScreen()),
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
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
              // Welcome Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [pharmacyTeal, Color(0xFF004D40)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: pharmacyTeal.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'HOSPITAL PHARMACY SYSTEM',
                              style: TextStyle(
                                color: colorWhite,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'My Medicine Orders & Hub',
                            style: TextStyle(
                              color: colorWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Track booked medicine orders, digital invoices, and access all pharmacy modules.',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_pharmacy_rounded,
                        color: colorWhite,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ========================================================
              // 2. Pharmacy Modules & Screens
              // ========================================================
              const Text(
                'Pharmacy Modules & Navigation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Access catalog, categories, stores and place order',
                style: TextStyle(fontSize: 12, color: textMuted),
              ),

              const SizedBox(height: 14),

              _buildNavTile(
                title: 'Pharmacy Home Dashboard',
                subtitle:
                    'Main pharmacy storefront with search, banners & top catalog',
                icon: Icons.storefront_rounded,
                badgeText: 'Main Screen',
                badgeColor: pharmacyTeal,
                badgeBg: pharmacyTealBg,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PharmacyScreen()),
                ),
              ),

              _buildNavTile(
                title: 'All Medicines Catalog',
                subtitle:
                    'Complete medicines list with search bar & category chips',
                icon: Icons.medication_liquid_rounded,
                badgeText: 'Listing',
                badgeColor: const Color(0xFF0288D1),
                badgeBg: const Color(0xFFE1F5FE),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PharmacyAllMedicineScreen()),
                ),
              ),

              _buildNavTile(
                title: 'Medicine Categories',
                subtitle:
                    'Browse medicines by category (Capsules, Syrups, Tablets)',
                icon: Icons.category_rounded,
                badgeText: 'Categories',
                badgeColor: const Color(0xFF7B1FA2),
                badgeBg: const Color(0xFFF3E5F5),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const Getpharmacycategoryscreen()),
                ),
              ),

              _buildNavTile(
                title: 'Pharmacy Stores',
                subtitle:
                    'Active hospital pharmacy outlets, contact & delivery charges',
                icon: Icons.store_rounded,
                badgeText: 'Stores',
                badgeColor: const Color(0xFFE65100),
                badgeBg: const Color(0xFFFFF3E0),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PharmacyStoreScreen()),
                ),
              ),

              // _buildNavTile(
              //   title: 'Payment Verification',
              //   subtitle:
              //       'Order confirmation & payment verification status screen',
              //   icon: Icons.verified_rounded,
              //   badgeText: 'Verification',
              //   badgeColor: const Color(0xFF2E7D32),
              //   badgeBg: const Color(0xFFE8F5E9),
              //   onTap: () {
              //     final currOrder = controller.currentOrder.value;
              //     if (currOrder != null) {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (_) => PaymentVerifedScreen(
              //             billId: currOrder.billId,
              //             groupOrderNo: currOrder.groupOrderNo,
              //             grandTotal: currOrder.grandTotal,
              //             paymentMode: currOrder.paymentMode,
              //             hospitalName: currOrder.hospital?.name,
              //             isCashOnDelivery: currOrder.paymentMode
              //                     ?.toLowerCase()
              //                     .contains('cash') ==
              //                 true,
              //           ),
              //         ),
              //       );
              //     } else {
              //       Get.snackbar(
              //         'No Recent Order',
              //         'Place a medicine order to view confirmation details.',
              //         snackPosition: SnackPosition.BOTTOM,
              //         backgroundColor: pharmacyTeal,
              //         colorText: colorWhite,
              //       );
              //     }
              //   },
              // ),

              Obx(() {
                final count = controller.patientOrders.length;
                return _buildNavTile(
                  title: 'Invoice Details',
                  subtitle: count > 0
                      ? '$count booked orders • View invoices & receipts'
                      : 'View your booked orders, digital invoices & receipts',
                  icon: Icons.receipt_long_rounded,
                  badgeText: count > 0 ? '$count Orders' : 'Invoice',
                  badgeColor: const Color(0xFF512DA8),
                  badgeBg: const Color(0xFFEDE7F6),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PharmacyBookingsScreen(),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderGrey),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: badgeColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 11, color: textMuted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
