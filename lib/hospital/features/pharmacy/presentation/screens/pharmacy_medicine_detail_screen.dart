import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/hospital/core/constants/colors.dart';

import '../../data/model/medicine_model.dart';
import '../../logics/pharmacy_controller.dart';
import 'pharmacy__place_order.dart';

class PharmacyMedicineDetailScreen extends StatefulWidget {
  final MedicineModel? medicine;
  final dynamic medicineId;

  const PharmacyMedicineDetailScreen({
    super.key,
    this.medicine,
    this.medicineId,
  });

  @override
  State<PharmacyMedicineDetailScreen> createState() => _PharmacyMedicineDetailScreenState();
}

class _PharmacyMedicineDetailScreenState extends State<PharmacyMedicineDetailScreen> {
  late final PharmacyController controller;
  int _selectedQty = 1;
  late MedicineModel? _currentMedicine;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PharmacyController>()
        ? Get.find<PharmacyController>()
        : Get.put(PharmacyController());

    // 1. Immediately bind the medicine clicked from the list
    _currentMedicine = widget.medicine;
    if (_currentMedicine != null) {
      controller.selectedMedicine.value = _currentMedicine;
    }

    final idToFetch = widget.medicineId ?? widget.medicine?.id;

    // Only fetch by ID if no medicine object was passed
    if (_currentMedicine == null && idToFetch != null) {
      _loadMedicineById(idToFetch);
    }
  }

  Future<void> _loadMedicineById(dynamic id) async {
    setState(() => _isLoading = true);
    try {
      final fetched = await controller.fetchMedicineDetails(id);
      if (mounted && fetched != null) {
        setState(() {
          _currentMedicine = fetched;
        });
        controller.selectedMedicine.value = fetched;
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        title: Text(
          _currentMedicine?.name ?? 'Medicine Details',
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
                  icon: const Icon(Icons.shopping_bag_outlined, color: colorWhite),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PharmacyPlaceOrderScreen()),
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
      body: Builder(builder: (context) {
        if (_isLoading && _currentMedicine == null) {
          return const Center(
            child: CircularProgressIndicator(color: pharmacyTeal),
          );
        }

        final med = _currentMedicine;

        if (med == null) {
          return const Center(
            child: Text('Medicine details not found', style: TextStyle(color: textDark)),
          );
        }

        return RefreshIndicator(
          color: pharmacyTeal,
          onRefresh: () async {
            await controller.fetchMedicines();
            if (mounted && _currentMedicine != null) {
              final updated = controller.medicines.firstWhereOrNull(
                (m) =>
                    m.id == _currentMedicine!.id &&
                    (m.hospital?.id == _currentMedicine!.hospital?.id ||
                        m.name.trim().toLowerCase() == _currentMedicine!.name.trim().toLowerCase()),
              );
              if (updated != null) {
                setState(() {
                  _currentMedicine = updated;
                });
                controller.selectedMedicine.value = updated;
              }
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medicine Hero Image & Price Banner
                _buildHeroCard(med),

                const SizedBox(height: 16),

                // Basic Info & Composition
                _buildInfoSection(med),

                const SizedBox(height: 16),

                // Hospital Info Card
                if (med.hospital != null) _buildHospitalInfoCard(med.hospital!),

                const SizedBox(height: 16),

                // Available Batches
                if (med.availableBatches.isNotEmpty) _buildBatchesSection(med.availableBatches),

                const SizedBox(height: 16),

                // Related / Suggested Medicines
                Builder(builder: (_) {
                  final relatedList = med.relatedMedicines.isNotEmpty
                      ? med.relatedMedicines
                      : controller.medicines
                          .where((m) =>
                              m.name.trim().toLowerCase() != med.name.trim().toLowerCase() ||
                              (m.hospital?.id != null && m.hospital?.id != med.hospital?.id))
                          .take(6)
                          .toList();

                  if (relatedList.isNotEmpty) {
                    return _buildRelatedSection(relatedList);
                  }
                  return const SizedBox.shrink();
                }),

                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeroCard(MedicineModel med) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: pharmacyTealBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                med.displayPhoto,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.medication_rounded,
                  color: pharmacyTeal,
                  size: 64,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    if (med.medicineCompany != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Manufacturer: ${med.medicineCompany!}',
                        style: const TextStyle(fontSize: 12, color: textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: med.inStock ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  med.inStock ? 'In Stock' : 'Out of Stock',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: med.inStock ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price per unit', style: TextStyle(fontSize: 11, color: textMuted)),
                  Row(
                    children: [
                      Text(
                        '₹${med.salePrice}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: pharmacyTeal,
                        ),
                      ),
                      if (med.mrp > med.salePrice) ...[
                        const SizedBox(width: 8),
                        Text(
                          '₹${med.mrp}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (med.tax != null && med.tax! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: pharmacyTealBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Tax: ${med.tax}% GST',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: pharmacyTeal,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(MedicineModel med) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Specifications',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Category', med.categoryName ?? 'General Medicine'),
          if (med.medicineComposition != null)
            _buildDetailRow('Composition / Salt', med.medicineComposition!),
          if (med.medicineGroup != null)
            _buildDetailRow('Medicine Group', med.medicineGroup!),
          if (med.unitPacking != null || med.unit != null)
            _buildDetailRow('Packaging / Unit', '${med.unitPacking ?? ''} (${med.unit ?? ''})'),
          if (med.stockQuantity > 0)
            _buildDetailRow('Available Stock', '${med.stockQuantity} units'),
          if (med.note != null && med.note!.isNotEmpty)
            _buildDetailRow('Note / Instructions', med.note!),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: textMuted, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: textDark, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalInfoCard(HospitalInfo hosp) {
    return Container(
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
            child: const Icon(Icons.local_hospital_rounded, color: pharmacyTeal, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hosp.name ?? 'Hospital Pharmacy',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                if (hosp.domain != null)
                  Text(
                    'Domain: ${hosp.domain!}',
                    style: const TextStyle(fontSize: 11, color: textMuted),
                  ),
              ],
            ),
          ),
          const Icon(Icons.verified_user_rounded, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildBatchesSection(List<AvailableBatch> batches) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Batches',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 10),
          ...batches.map((batch) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderGrey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Batch #${batch.batchNo ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Expiry: ${batch.expiryDate ?? 'N/A'}',
                        style: const TextStyle(fontSize: 11, color: textMuted),
                      ),
                      if (batch.pharmacyName != null)
                        Text(
                          batch.pharmacyName!,
                          style: const TextStyle(fontSize: 10, color: pharmacyTeal),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${batch.salePrice ?? 0}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: pharmacyTeal,
                        ),
                      ),
                      Text(
                        'Qty: ${batch.quantity ?? 0}',
                        style: const TextStyle(fontSize: 11, color: textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRelatedSection(List<MedicineModel> related) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Related Medicines',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: related.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final rel = related[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PharmacyMedicineDetailScreen(
                        medicine: rel,
                        medicineId: rel.id,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderGrey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: pharmacyTealBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              rel.displayPhoto,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.medication_rounded, color: pharmacyTeal, size: 32),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      Text(
                        '₹${rel.salePrice}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: pharmacyTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
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
        child: Obx(() {
          final med = _currentMedicine ?? widget.medicine ?? controller.selectedMedicine.value;
          if (med == null) return const SizedBox.shrink();

          final inCart = controller.isInCart(med);

          return Row(
            children: [
              // Quantity Selector
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: pharmacyTealBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18, color: pharmacyTeal),
                      onPressed: () {
                        if (_selectedQty > 1) {
                          setState(() {
                            _selectedQty--;
                          });
                        }
                      },
                    ),
                    Text(
                      '$_selectedQty',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: pharmacyTeal,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18, color: pharmacyTeal),
                      onPressed: () {
                        setState(() {
                          _selectedQty++;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Add to Cart / Go to Cart
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: med.inStock
                        ? () {
                            if (inCart) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PharmacyPlaceOrderScreen(),
                                ),
                              );
                            } else {
                              controller.addToCart(med, qty: _selectedQty);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pharmacyTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      inCart ? Icons.shopping_bag_outlined : Icons.add_shopping_cart_rounded,
                      color: colorWhite,
                      size: 18,
                    ),
                    label: Text(
                      inCart ? 'GO TO CART' : 'ADD TO CART',
                      style: const TextStyle(
                        color: colorWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
