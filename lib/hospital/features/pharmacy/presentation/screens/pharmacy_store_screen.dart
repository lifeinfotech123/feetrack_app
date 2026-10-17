import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/hospital/core/constants/colors.dart';

import '../../data/model/pharmacy_store_model.dart';
import '../../logics/pharmacy_controller.dart';
import 'pharmacy_all_medicine_screen.dart';

class PharmacyStoreScreen extends StatefulWidget {
  const PharmacyStoreScreen({super.key});

  @override
  State<PharmacyStoreScreen> createState() => _PharmacyStoreScreenState();
}

class _PharmacyStoreScreenState extends State<PharmacyStoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final PharmacyController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PharmacyController>()
        ? Get.find<PharmacyController>()
        : Get.put(PharmacyController());
    controller.fetchStores();
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
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Pharmacy Stores',
          style: TextStyle(
            color: colorWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
                  controller.fetchStores(search: val.trim());
                },
                decoration: InputDecoration(
                  hintText: 'Search pharmacy store by name or code...',
                  hintStyle: const TextStyle(color: textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: pharmacyTeal),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            controller.fetchStores();
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

          // Store list
          Expanded(
            child: RefreshIndicator(
              color: pharmacyTeal,
              onRefresh: () async {
                await controller.fetchStores(search: _searchController.text.trim());
              },
              child: Obx(() {
                if (controller.isStoresLoading.value && controller.stores.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: pharmacyTeal),
                  );
                }

                final storesList = controller.stores;

                if (storesList.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 100),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.storefront_outlined, size: 64, color: colorGrey),
                            SizedBox(height: 12),
                            Text(
                              'No pharmacy stores found',
                              style: TextStyle(
                                color: textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Try searching with a different name',
                              style: TextStyle(color: textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: storesList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final store = storesList[index];
                    return _buildStoreCard(store);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(PharmacyStoreModel store) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(18),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: pharmacyTealBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_pharmacy_rounded,
                  color: pharmacyTeal,
                  size: 28,
                ),
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
                            store.pharmacyName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                        ),
                        if (store.pharmacyType != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: pharmacyTealBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              store.pharmacyType!.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: pharmacyTeal,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (store.pharmacyCode != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Code: ${store.pharmacyCode!}',
                        style: const TextStyle(fontSize: 11, color: textMuted),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Address
          if (store.address != null && store.address!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: pharmacyTeal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${store.address!}${store.city != null ? ', ${store.city!}' : ''}',
                    style: const TextStyle(fontSize: 12, color: textDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Contact Details
          Row(
            children: [
              if (store.phone != null) ...[
                const Icon(Icons.phone_outlined, size: 16, color: pharmacyTeal),
                const SizedBox(width: 4),
                Text(store.phone!, style: const TextStyle(fontSize: 12, color: textDark)),
                const SizedBox(width: 16),
              ],
              if (store.contactPerson != null) ...[
                const Icon(Icons.person_outline, size: 16, color: pharmacyTeal),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    store.contactPerson!,
                    style: const TextStyle(fontSize: 12, color: textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Delivery Charges badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.delivery_dining, size: 18, color: pharmacyTeal),
                    SizedBox(width: 6),
                    Text(
                      'Delivery Charge',
                      style: TextStyle(fontSize: 12, color: textDark, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  '₹${store.deliveryCharge} (Free above ₹${store.minFreeDeliveryAmount})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: pharmacyTeal,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.to(() => const PharmacyAllMedicineScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: pharmacyTeal,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.medication_liquid_outlined, color: colorWhite, size: 18),
              label: const Text(
                'BROWSE STORE MEDICINES',
                style: TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
