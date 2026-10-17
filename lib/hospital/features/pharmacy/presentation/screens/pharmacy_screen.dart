import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/hospital/core/constants/colors.dart';
import '../../logics/pharmacy_controller.dart';
import '../../data/model/medicine_model.dart';
import 'GetPharmacyCategoryScreen.dart';
import 'pharmacy_all_medicine_screen.dart';
import 'pharmacy_medicine_detail_screen.dart';
import 'pharmacy_store_screen.dart';
import 'pharmacy__place_order.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final PharmacyController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PharmacyController>()
        ? Get.find<PharmacyController>()
        : Get.put(PharmacyController());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: pharmacyTeal,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hospital Pharmacy',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colorWhite,
              ),
            ),
            Text(
              'Verified Medicines & Healthcare Supplies',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront_rounded, color: colorWhite),
            tooltip: 'Pharmacy Stores',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PharmacyStoreScreen()),
            ),
          ),
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
          await controller.initPharmacyData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search & Header Banner
              _buildHeaderSearch(),

              // Quick Feature Actions
              _buildQuickActions(),

              // Promo Banner
              _buildPromoBanner(),

              // Categories Section
              _buildCategoriesSection(),

              // Featured Medicines Section
              _buildMedicinesSection(),

              // Pharmacy Stores Preview
              _buildStoresPreview(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomCartBar(),
    );
  }

  Widget _buildHeaderSearch() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: const BoxDecoration(
        color: pharmacyTeal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (val) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PharmacyAllMedicineScreen(initialSearch: val),
              ),
            );
          },
          decoration: InputDecoration(
            hintText: 'Search medicines, generic names, salt...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: const Icon(Icons.search, color: pharmacyTeal),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded,
                        color: pharmacyTeal),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PharmacyAllMedicineScreen(
                            initialSearch: _searchController.text.trim(),
                          ),
                        ),
                      );
                    },
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          _buildQuickActionItem(
            icon: Icons.category_rounded,
            title: 'Categories',
            color: const Color(0xFF0288D1),
            bg: const Color(0xFFE1F5FE),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const Getpharmacycategoryscreen()),
            ),
          ),
          const SizedBox(width: 12),
          _buildQuickActionItem(
            icon: Icons.medication_liquid_rounded,
            title: 'All Medicines',
            color: pharmacyTeal,
            bg: pharmacyTealBg,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PharmacyAllMedicineScreen()),
            ),
          ),
          const SizedBox(width: 12),
          _buildQuickActionItem(
            icon: Icons.store_rounded,
            title: 'Stores',
            color: const Color(0xFFE65100),
            bg: const Color(0xFFFFF3E0),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PharmacyStoreScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: colorWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderGrey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00796B), Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'GENUINE & LAB TESTED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Doorstep Delivery in 30 Mins',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() {
                  final store = controller.stores.isNotEmpty
                      ? controller.stores.first
                      : null;
                  final minAmt = store?.minFreeDeliveryAmount ?? 499;
                  final storeName =
                      store?.pharmacyName ?? 'hospital in-house pharmacy';
                  return Text(
                    'Free delivery on orders above ₹$minAmt from $storeName.',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: colorWhite,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Categories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const Getpharmacycategoryscreen()),
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: pharmacyTeal,
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          if (controller.isCategoriesLoading.value &&
              controller.categories.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: pharmacyTeal),
              ),
            );
          }
          final cats = controller.categories;
          if (cats.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('No categories available',
                  style: TextStyle(color: textMuted)),
            );
          }

          return SizedBox(
            height: 96,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: cats.length > 8 ? 8 : cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = cats[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PharmacyAllMedicineScreen(
                            selectedCategoryId: cat.id),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 86,
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderGrey),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: pharmacyTealBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.medical_services_outlined,
                            size: 18,
                            color: pharmacyTeal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textDark,
                          ),
                        ),
                        Text(
                          '${cat.medicinesCount} items',
                          style: const TextStyle(
                            fontSize: 9,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMedicinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Medicines Catalog',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PharmacyAllMedicineScreen()),
                ),
                child: const Text(
                  'Explore More',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: pharmacyTeal,
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          if (controller.isLoading.value &&
              controller.catalogMedicines.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(color: pharmacyTeal),
              ),
            );
          }

          final list = controller.catalogMedicines.isNotEmpty
              ? controller.catalogMedicines
              : controller.medicines;

          if (list.isEmpty) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderGrey),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('No medicines found in catalog',
                        style: TextStyle(
                            color: textDark, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Pull down to refresh or check again later',
                        style: TextStyle(color: textMuted, fontSize: 12)),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length > 5 ? 5 : list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final med = list[index];
              return _buildMedicineCard(med);
            },
          );
        }),
      ],
    );
  }

  Widget _buildMedicineCard(MedicineModel med) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PharmacyMedicineDetailScreen(medicine: med, medicineId: med.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorWhite,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: pharmacyTealBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  med.displayPhoto,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.medication_rounded,
                    color: pharmacyTeal,
                    size: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          med.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: med.inStock
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          med.inStock ? 'In Stock' : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: med.inStock
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (med.categoryName != null)
                    Text(
                      '${med.categoryName!} • ${med.unitPacking ?? 'Strip'}',
                      style: const TextStyle(fontSize: 11, color: textMuted),
                    ),
                  if (med.medicineCompany != null)
                    Text(
                      'By ${med.medicineCompany!}',
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '₹${med.salePrice}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: pharmacyTeal,
                            ),
                          ),
                          if (med.mrp > med.salePrice) ...[
                            const SizedBox(width: 6),
                            Text(
                              '₹${med.mrp}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: textMuted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Obx(() {
                        final inCart = controller.isInCart(med);
                        final qty = controller.getMedicineQuantity(med);

                        if (inCart) {
                          return Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: pharmacyTealBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints:
                                      const BoxConstraints(minWidth: 26),
                                  icon: const Icon(Icons.remove,
                                      size: 14, color: pharmacyTeal),
                                  onPressed: () =>
                                      controller.updateQuantity(med, qty - 1),
                                ),
                                Text(
                                  '$qty',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: pharmacyTeal,
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints:
                                      const BoxConstraints(minWidth: 26),
                                  icon: const Icon(Icons.add,
                                      size: 14, color: pharmacyTeal),
                                  onPressed: () =>
                                      controller.updateQuantity(med, qty + 1),
                                ),
                              ],
                            ),
                          );
                        }

                        return SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: med.inStock
                                ? () => controller.addToCart(med)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pharmacyTeal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text(
                              'ADD',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorWhite,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoresPreview() {
    return Obx(() {
      final storesList = controller.stores;
      if (storesList.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hospital Stores',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PharmacyStoreScreen()),
                  ),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: pharmacyTeal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderGrey),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: pharmacyTealBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_hospital_rounded,
                        color: pharmacyTeal, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storesList.first.pharmacyName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          storesList.first.address ?? 'Hospital Campus',
                          style:
                              const TextStyle(fontSize: 11, color: textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Delivery: ₹${storesList.first.deliveryCharge} (Free above ₹${storesList.first.minFreeDeliveryAmount})',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: pharmacyTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: textMuted),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PharmacyStoreScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget? _buildBottomCartBar() {
    return Obx(() {
      if (controller.cartCount == 0) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.cartTotalItems} items in cart',
                      style: const TextStyle(fontSize: 12, color: textMuted),
                    ),
                    Text(
                      '₹${controller.cartGrandTotal}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: pharmacyTeal,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PharmacyPlaceOrderScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pharmacyTeal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.shopping_bag_outlined,
                    color: colorWhite, size: 18),
                label: const Text(
                  'View Cart',
                  style: TextStyle(
                    color: colorWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
