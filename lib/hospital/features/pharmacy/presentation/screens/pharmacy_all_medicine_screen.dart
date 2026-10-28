import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/hospital/core/constants/colors.dart';

import '../../data/model/medicine_model.dart';
import '../../logics/pharmacy_controller.dart';
import 'pharmacy_medicine_detail_screen.dart';
import 'pharmacy__place_order.dart';

class PharmacyAllMedicineScreen extends StatefulWidget {
  final String? initialSearch;
  final int? selectedCategoryId;
  final String? categoryName;

  const PharmacyAllMedicineScreen({
    super.key,
    this.initialSearch,
    this.selectedCategoryId,
    this.categoryName,
  });

  @override
  State<PharmacyAllMedicineScreen> createState() =>
      _PharmacyAllMedicineScreenState();
}

class _PharmacyAllMedicineScreenState extends State<PharmacyAllMedicineScreen> {
  late final TextEditingController _searchController;
  late final PharmacyController controller;
  int? _activeCategoryId;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearch ?? '');
    _activeCategoryId = widget.selectedCategoryId;

    controller = Get.isRegistered<PharmacyController>()
        ? Get.find<PharmacyController>()
        : Get.put(PharmacyController());

    _loadData();
  }

  void _loadData() {
    controller.fetchMedicines(
      search: _searchController.text.trim(),
      categoryId: _activeCategoryId,
    );
    if (controller.categories.isEmpty) {
      controller.fetchCategories();
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: colorWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName != null && widget.categoryName!.isNotEmpty
              ? widget.categoryName!
              : 'Pharmacy Medicines',
          style: const TextStyle(
            color: colorWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
      body: Column(
        children: [
          // Search Input Header
          Container(
            color: pharmacyTeal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (val) {
                  controller.fetchMedicines(
                    search: val.trim(),
                    categoryId: _activeCategoryId,
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Search medicine by name or composition...',
                  hintStyle: const TextStyle(color: textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: pharmacyTeal),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            controller.fetchMedicines(
                                categoryId: _activeCategoryId);
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Categories Filter Horizontal Bar
          _buildCategoryFilterBar(),

          // Medicines List
          Expanded(
            child: RefreshIndicator(
              color: pharmacyTeal,
              onRefresh: () async {
                await controller.fetchMedicines(
                  search: _searchController.text.trim(),
                  categoryId: _activeCategoryId,
                );
              },
              child: Obx(() {
                if (controller.isMedicinesLoading.value &&
                    controller.medicines.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: pharmacyTeal),
                  );
                }

                final medicinesList = controller.medicines;

                if (medicinesList.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.medication_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'No medicines available',
                              style: TextStyle(
                                color: textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Try clearing filters or search terms',
                              style: TextStyle(color: textMuted, fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _activeCategoryId = null;
                                });
                                controller.fetchMedicines();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pharmacyTeal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Reset Filters',
                                  style: TextStyle(color: colorWhite)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: medicinesList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final med = medicinesList[index];
                    return _buildMedicineCard(med);
                  },
                );
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomCartBar(),
    );
  }

  Widget _buildCategoryFilterBar() {
    return Container(
      color: colorWhite,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Obx(() {
        final categories = controller.categories;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip(
                label: 'All Medicines',
                isSelected: _activeCategoryId == null,
                onTap: () {
                  setState(() {
                    _activeCategoryId = null;
                  });
                  controller.fetchMedicines(
                      search: _searchController.text.trim());
                },
              ),
              ...categories.map((cat) {
                final isSel = _activeCategoryId == cat.id;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildFilterChip(
                    label: cat.name,
                    isSelected: isSel,
                    onTap: () {
                      setState(() {
                        _activeCategoryId = cat.id;
                      });
                      controller.fetchMedicines(
                        search: _searchController.text.trim(),
                        categoryId: cat.id,
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? pharmacyTeal : pharmacyTealBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? pharmacyTeal : borderGrey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? colorWhite : pharmacyTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineCard(MedicineModel med) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PharmacyMedicineDetailScreen(
              medicine: med,
              medicineId: med.id,
            ),
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
              width: 80,
              height: 80,
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
                    size: 38,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info Details
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
                  if (med.medicineComposition != null &&
                      med.medicineComposition!.isNotEmpty)
                    Text(
                      'Comp: ${med.medicineComposition!}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 10,
                          color: textMuted,
                          fontStyle: FontStyle.italic),
                    ),
                  const SizedBox(height: 8),

                  // Pricing & Add button
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
                            height: 32,
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
                                      const BoxConstraints(minWidth: 28),
                                  icon: const Icon(Icons.remove,
                                      size: 14, color: pharmacyTeal),
                                  onPressed: () => controller.updateQuantity(
                                      med, qty - 1),
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
                                      const BoxConstraints(minWidth: 28),
                                  icon: const Icon(Icons.add,
                                      size: 14, color: pharmacyTeal),
                                  onPressed: () => controller.updateQuantity(
                                      med, qty + 1),
                                ),
                              ],
                            ),
                          );
                        }

                        return SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: med.inStock
                                ? () => controller.addToCart(med)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pharmacyTeal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
