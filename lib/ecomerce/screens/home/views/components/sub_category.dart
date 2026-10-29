// ignore_for_file: camel_case_types

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants.dart';
import '../../../../controllers/categories_controller.dart';
import '../../../../models/home_screen_models.dart';
import '../../../../route/app_text_constants.dart';
import '../../../product/views/category_products_screen.dart';
import '../../../../components/product/product_quantity_button.dart';
import '../../../../components/product/wishlist_heart_button.dart';

typedef SubCategory = Sub_category;

class Sub_category extends StatefulWidget {
  final String? categorySlug;

  const Sub_category({
    super.key,
    this.categorySlug,
  });

  @override
  State<Sub_category> createState() => _Sub_categoryState();
}

class _Sub_categoryState extends State<Sub_category> {
  late final CategoriesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CategoriesController>()
        ? Get.find<CategoriesController>()
        : Get.put(CategoriesController());

    if (widget.categorySlug != null && widget.categorySlug!.isNotEmpty) {
      controller.fetchCategoryDetails(widget.categorySlug!);
    }
  }

  @override
  void didUpdateWidget(covariant Sub_category oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categorySlug != null &&
        widget.categorySlug != oldWidget.categorySlug) {
      controller.fetchCategoryDetails(widget.categorySlug!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final currentCategory = controller.selectedCategory.value ??
          controller.selectedCategoryDetails.value;

      if (currentCategory == null && controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (currentCategory == null) {
        return const Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Center(child: Text("Select a category")),
        );
      }

      final subCategories = currentCategory.subCategories ?? [];
      final products = controller.categoryProducts;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Flipkart-style Category Promotional Banner
            _buildCategoryBanner(currentCategory, isDark),

            const SizedBox(height: 12),

            // 2. Subcategories Expansion Tiles (if present)
            if (subCategories.isNotEmpty) ...[
              Text(
                "Subcategories",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF22222E),
                ),
              ),
              const SizedBox(height: 8),
              ...subCategories.map((subCat) => _buildSubCategoryTile(subCat, isDark)),
              const SizedBox(height: 14),
            ],

            // 3. Category Products Header & "View All" Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Popular in ${currentCategory.name}",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E1E28),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryProductsScreen(
                          category: currentCategory,
                          categoryTitle: currentCategory.name,
                          categoryImage: currentCategory.icon,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "View All",
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 4. Category Live Products (Loading / Empty / Grid)
            if (controller.isProductsLoading.value) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (products.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF20202C) : const Color(0xFFF7F7FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white10 : const Color(0xFFE8E8EE),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      currentCategory.isFood
                          ? Icons.restaurant_rounded
                          : Icons.inventory_2_outlined,
                      size: 34,
                      color: primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "No products found in ${currentCategory.name}",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : blackColor80,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Check back soon for new arrivals and exclusive deals",
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? Colors.white38 : blackColor40,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Grid of products matching category
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length > 6 ? 6 : products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final item = products[index];
                  return _buildProductCard(item, isDark);
                },
              ),

              const SizedBox(height: 12),

              // Bottom "See All [Category] Products" Bar
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryProductsScreen(
                          category: currentCategory,
                          categoryTitle: currentCategory.name,
                          categoryImage: currentCategory.icon,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryColor, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    "Explore All ${currentCategory.name} (${products.length}+ Items)",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildCategoryBanner(dynamic currentCategory, bool isDark) {
    final catName = currentCategory.name ?? "Category";
    final isFood = currentCategory.isFood ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: isFood
              ? [const Color(0xFFFF6D00), const Color(0xFFFF3D00)]
              : [const Color(0xFF7B61FF), const Color(0xFF4A148C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isFood ? const Color(0xFFFF6D00) : primaryColor)
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isFood ? "DELICIOUS & FRESH" : "SPECIAL OFFERS",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  catName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  "Up to 50% Off • Assured Quality",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryProductsScreen(
                    category: currentCategory,
                    categoryTitle: currentCategory.name,
                    categoryImage: currentCategory.icon,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Shop Now",
                style: TextStyle(
                  color: isFood ? const Color(0xFFFF3D00) : primaryColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryTile(dynamic subCat, bool isDark) {
    final subSubCats = subCat.subCategories ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF20202A) : const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE8E8EE),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          dense: true,
          leading: subCat.icon != null && subCat.icon!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: subCat.icon!,
                    height: 22,
                    width: 22,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  Icons.category,
                  size: 20,
                  color: isDark ? Colors.white70 : blackColor80,
                ),
          title: Text(
            subCat.name,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : blackColor,
            ),
          ),
          children: [
            if (subSubCats.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: subSubCats.map<Widget>((subSub) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryProductsScreen(
                              categoryTitle: subSub.name,
                              categorySlug: subSub.slug,
                              categoryId: subSub.id,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          subSub.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ApiProductModel item, bool isDark) {
    final effectivePrice = item.finalPrice ?? item.discountedPrice ?? item.unitPrice;
    final originalPrice = item.unitPrice;
    final hasDiscount = effectivePrice < originalPrice;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E28) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE8E8EE),
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              productDetailsScreenRoute,
              arguments: item.toProductModel(),
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 10,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                        child: Container(
                          color: isDark ? const Color(0xFF252532) : const Color(0xFFF6F6F9),
                          width: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: item.thumbnail ?? '',
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image, size: 24),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: WishlistHeartButton(
                        productId: item.id,
                        storeDomain: item.store?.domain,
                        size: 24,
                        iconSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : blackColor,
                              height: 1.15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                "₹${effectivePrice.toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : blackColor,
                                ),
                              ),
                              if (hasDiscount) ...[
                                const SizedBox(width: 4),
                                Text(
                                  "₹${originalPrice.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: isDark ? Colors.white38 : blackColor40,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      ProductQuantityButton(
                        product: item.toProductModel(),
                        storeDomain: item.store?.domain,
                        isFullWidth: true,
                        height: 26,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
