import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants.dart';
import '../../../../controllers/store_controller.dart';
import '../../../store/views/store_detail_screen.dart';

class StoreSelectorBannerWidget extends StatelessWidget {
  const StoreSelectorBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final StoreController storeController = Get.put(StoreController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final selected = storeController.selectedStore.value;
      final isAllStores = selected == null;

      final storeName = isAllStores ? "All Stores (Global)" : selected.name;
      final storeAddress = isAllStores
          ? "Browse products across all vendors"
          : (selected.address ?? "Verified Vendor");
      final storeLogo = selected?.logo;

      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding / 2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF222030) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFE5E5EB),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _showStoreSelectionModal(context, storeController),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Store Icon / Logo
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: storeLogo != null && storeLogo.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: storeLogo,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.storefront_rounded,
                            color: primaryColor,
                            size: 22,
                          ),
                        )
                      : Icon(
                          isAllStores
                              ? Icons.public_rounded
                              : Icons.storefront_rounded,
                          color: primaryColor,
                          size: 22,
                        ),
                ),
              ),

              const SizedBox(width: 12),

              // Store Name & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            storeName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : blackColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (!isAllStores)
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: Color(0xFF00C853),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      storeAddress,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : blackColor60,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // "Change Store" Action Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Switch",
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showStoreSelectionModal(
      BuildContext context, StoreController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1C2B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 25,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),

              // Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.store_mall_directory_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Select Store / Vendor",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : blackColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              const Divider(height: 20),

              // Stores List
              Expanded(
                child: Obx(() {
                  if (controller.isStoresLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final stores = controller.stores;

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
                    children: [
                      // Option 1: All Stores / Global Marketplace
                      _buildStoreTile(
                        context: context,
                        isDark: isDark,
                        name: "All Stores (Global Marketplace)",
                        address: "Show products from all available stores",
                        isSelected: controller.selectedStore.value == null,
                        icon: Icons.public_rounded,
                        onTap: () {
                          controller.selectStore(null);
                          Navigator.pop(ctx);
                        },
                      ),

                      const SizedBox(height: 8),

                      // Store items from API
                      ...stores.map((store) {
                        final isSelected =
                            controller.selectedStore.value?.id == store.id &&
                                controller.selectedStore.value?.shopId ==
                                    store.shopId;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildStoreTile(
                            context: context,
                            isDark: isDark,
                            name: store.name,
                            address: store.address ?? "Lucknow, India",
                            logoUrl: store.logo,
                            rating: store.rating,
                            deliveryText: store.minDeliveryCharge != null
                                ? "Delivery ₹${store.minDeliveryCharge!.toStringAsFixed(0)}"
                                : null,
                            productsCount: store.totalProducts,
                            isSelected: isSelected,
                            onInfoTap: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      StoreDetailScreen(store: store),
                                ),
                              );
                            },
                            onTap: () {
                              controller.selectStore(store);
                              Navigator.pop(ctx);
                            },
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoreTile({
    required BuildContext context,
    required bool isDark,
    required String name,
    required String address,
    String? logoUrl,
    IconData? icon,
    double? rating,
    String? deliveryText,
    int? productsCount,
    required bool isSelected,
    VoidCallback? onInfoTap,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor.withValues(alpha: isDark ? 0.2 : 0.08)
            : (isDark ? const Color(0xFF282638) : const Color(0xFFF8F9FD)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? primaryColor
              : (isDark ? Colors.white12 : const Color(0xFFE8E8EE)),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: logoUrl != null && logoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: logoUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Icon(
                      icon ?? Icons.storefront_rounded,
                      color: primaryColor,
                      size: 22,
                    ),
                  )
                : Icon(
                    icon ?? Icons.storefront_rounded,
                    color: primaryColor,
                    size: 22,
                  ),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : blackColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.check_circle_rounded,
                color: primaryColor,
                size: 16,
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              address,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : blackColor60,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (rating != null || deliveryText != null || productsCount != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (rating != null) ...[
                    const Icon(Icons.star_rounded,
                        size: 13, color: Color(0xFFFFB300)),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (deliveryText != null) ...[
                    Text(
                      deliveryText,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? Colors.white54 : blackColor60,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (productsCount != null)
                    Text(
                      "$productsCount products",
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
        trailing: onInfoTap != null
            ? IconButton(
                icon: const Icon(Icons.info_outline_rounded, size: 20),
                color: primaryColor,
                onPressed: onInfoTap,
              )
            : null,
      ),
    );
  }
}
