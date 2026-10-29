import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/product/product_card.dart';
import '../../../components/skleton/skelton.dart';
import '../../../constants.dart';
import '../../../controllers/brand_crontoller.dart';
import '../../../models/product_model.dart';
import '../../../route/app_text_constants.dart';

class BrandDetailScreen extends StatefulWidget {
  final String? brandSlug;

  const BrandDetailScreen({
    super.key,
    this.brandSlug,
  });

  @override
  State<BrandDetailScreen> createState() => _BrandDetailScreenState();
}

class _BrandDetailScreenState extends State<BrandDetailScreen> {
  late final BrandCrontoller _controller;
  late String _slug;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(BrandCrontoller());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      _slug = args;
    } else if (widget.brandSlug != null && widget.brandSlug!.isNotEmpty) {
      _slug = widget.brandSlug!;
    } else {
      _slug = 'cetaphil';
    }
    _controller.fetchBrandDetails(_slug);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final detail = _controller.brandDetail.value;
          return Text(
            detail?.brand.name ?? "Brand Details",
            style: TextStyle(
              color: isDark ? Colors.white : blackColor,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, cartScreenRoute);
            },
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isDetailLoading.value) {
          return const _BrandDetailSkeleton();
        }

        if (_controller.detailError.value.isNotEmpty &&
            _controller.brandDetail.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: errorColor,
                  ),
                  const SizedBox(height: defaultPadding),
                  Text(
                    _controller.detailError.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton.icon(
                    onPressed: () => _controller.fetchBrandDetails(_slug),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  ),
                ],
              ),
            ),
          );
        }

        final detail = _controller.brandDetail.value;
        if (detail == null) {
          return const Center(child: Text("No brand details available"));
        }

        final filteredProducts = _controller.filteredProducts;

        return RefreshIndicator(
          onRefresh: () => _controller.fetchBrandDetails(_slug),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Brand Header Card Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Container(
                    padding: const EdgeInsets.all(defaultPadding),
                    decoration: BoxDecoration(
                      color: isDark ? darkGreyColor : lightGreyColor,
                      borderRadius:
                          BorderRadius.circular(defaultBorderRadious * 1.2),
                      border: Border.all(
                        color: isDark ? Colors.white12 : blackColor10,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.3 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Brand Image / Logo
                        Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(defaultBorderRadious),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: detail.brand.image != null &&
                                    detail.brand.image!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: detail.brand.image!,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) =>
                                        const Skeleton(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                      Icons.verified_rounded,
                                      size: 32,
                                      color: primaryColor,
                                    ),
                                  )
                                : const Icon(
                                    Icons.verified_rounded,
                                    size: 32,
                                    color: primaryColor,
                                  ),
                          ),
                        ),
                        const SizedBox(width: defaultPadding),

                        // Brand Text Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      detail.brand.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isDark ? Colors.white : blackColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified_rounded,
                                    color: primaryColor,
                                    size: 16,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "${detail.brand.productsCount ?? detail.products.length} Products Available",
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
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
              ),

              // Categories Filter Bar (if brand has categories)
              if (detail.categories.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: defaultPadding,
                          vertical: defaultPadding / 4,
                        ),
                        child: Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 38,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: defaultPadding),
                          itemCount: detail.categories.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              final isSelected =
                                  _controller.selectedCategoryId.value == 0;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  selected: isSelected,
                                  label: Text(
                                    "All (${detail.products.length})",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.white70
                                              : blackColor),
                                    ),
                                  ),
                                  selectedColor: primaryColor,
                                  backgroundColor: isDark
                                      ? darkGreyColor
                                      : lightGreyColor,
                                  onSelected: (_) =>
                                      _controller.selectCategory(0),
                                ),
                              );
                            }

                            final category = detail.categories[index - 1];
                            final isSelected =
                                _controller.selectedCategoryId.value ==
                                    category.id;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                selected: isSelected,
                                label: Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white70
                                            : blackColor),
                                  ),
                                ),
                                selectedColor: primaryColor,
                                backgroundColor:
                                    isDark ? darkGreyColor : lightGreyColor,
                                onSelected: (_) {
                                  if (category.id != null) {
                                    _controller.selectCategory(category.id!);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: defaultPadding),
                    ],
                  ),
                ),
              ],

              // Products Section Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                    vertical: defaultPadding / 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Products (${filteredProducts.length})",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Product Grid List
              filteredProducts.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(defaultPadding * 2),
                        child: Center(
                          child: Text(
                            "No products found in this category",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: defaultPadding,
                        vertical: defaultPadding / 2,
                      ),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          mainAxisSpacing: defaultPadding,
                          crossAxisSpacing: defaultPadding,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = filteredProducts[index];
                            return ProductCard(
                              id: product.id,
                              image: (product.thumbnail != null &&
                                      !product.thumbnail!.contains('imgur.com'))
                                  ? product.thumbnail!
                                  : '',
                              brandName: detail.brand.name,
                              title: product.name,
                              price: product.unitPrice,
                              priceAfetDiscount: product.discount != null &&
                                      product.discount! > 0
                                  ? product.priceAfterDiscount
                                  : null,
                              dicountpercent: product.discountPercent,
                              press: () {
                                final productModel = ProductModel(
                                  id: product.id,
                                  image: (product.thumbnail != null &&
                                          !product.thumbnail!
                                              .contains('imgur.com'))
                                      ? product.thumbnail!
                                      : '',
                                  brandName: detail.brand.name,
                                  title: product.name,
                                  price: product.unitPrice,
                                  priceAfetDiscount: product.discount != null &&
                                          product.discount! > 0
                                      ? product.priceAfterDiscount
                                      : null,
                                  dicountpercent: product.discountPercent,
                                );
                                Navigator.pushNamed(
                                  context,
                                  productDetailsScreenRoute,
                                  arguments: productModel,
                                );
                              },
                            );
                          },
                          childCount: filteredProducts.length,
                        ),
                      ),
                    ),

              const SliverToBoxAdapter(
                child: SizedBox(height: defaultPadding * 2),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _BrandDetailSkeleton extends StatelessWidget {
  const _BrandDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          const Skeleton(
            height: 90,
            width: double.infinity,
            radious: defaultBorderRadious,
          ),
          const SizedBox(height: defaultPadding),
          const Skeleton(
            height: 38,
            width: double.infinity,
            radious: 20,
          ),
          const SizedBox(height: defaultPadding),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              mainAxisSpacing: defaultPadding,
              crossAxisSpacing: defaultPadding,
            ),
            itemBuilder: (context, index) {
              return const Skeleton(
                height: 220,
                width: double.infinity,
                radious: defaultBorderRadious,
              );
            },
          ),
        ],
      ),
    );
  }
}
