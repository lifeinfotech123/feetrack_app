import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../components/product/product_card.dart';
import '../../../components/skleton/product/product_card_skelton.dart';
import '../../../constants.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/home_screen_api_controller.dart';
import '../../../models/home_screen_models.dart';
import '../../../route/app_text_constants.dart';

enum ProductSectionType {
  newArrivals,
  featured,
  all,
}

class AllProductsScreen extends StatefulWidget {
  final String title;
  final ProductSectionType type;

  const AllProductsScreen({
    super.key,
    required this.title,
    this.type = ProductSectionType.all,
  });

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  late final HomeScreenApiController _apiController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  int _selectedFilterIndex = 0; // 0: All, 1: Under ₹500, 2: Under ₹1000, 3: 4★+, 4: Instant, 5: 20%+ Off
  String _sortBy = "default"; // default, price_low, price_high, rating

  final List<String> _quickFilters = [
    "All",
    "Under ₹500",
    "Under ₹1000",
    "4★ & above",
    "⚡ Instant Delivery",
    "20%+ Off",
  ];

  @override
  void initState() {
    super.initState();
    _apiController = Get.put(HomeScreenApiController());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ApiProductModel> _getSourceProducts() {
    List<ApiProductModel> baseList;
    switch (widget.type) {
      case ProductSectionType.newArrivals:
        baseList = _apiController.newArrivalsProducts.isNotEmpty
            ? _apiController.newArrivalsProducts
            : _apiController.allProducts;
        break;
      case ProductSectionType.featured:
        baseList = _apiController.featuredProducts.isNotEmpty
            ? _apiController.featuredProducts
            : _apiController.allProducts;
        break;
      case ProductSectionType.all:
        baseList = _apiController.allProducts;
        break;
    }

    return baseList.where((p) => !p.isFood).toList();
  }

  List<ApiProductModel> _getFilteredAndSortedProducts() {
    var list = _getSourceProducts();

    // 1. Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((p) {
        final matchesName = p.name.toLowerCase().contains(q);
        final matchesBrand = (p.brand?.name ?? '').toLowerCase().contains(q);
        final matchesStore = (p.store?.name ?? '').toLowerCase().contains(q);
        return matchesName || matchesBrand || matchesStore;
      }).toList();
    }

    // 2. Quick Filters
    switch (_selectedFilterIndex) {
      case 1: // Under ₹500
        list = list
            .where((p) =>
                (p.finalPrice ?? p.discountedPrice ?? p.unitPrice) <= 500)
            .toList();
        break;
      case 2: // Under ₹1000
        list = list
            .where((p) =>
                (p.finalPrice ?? p.discountedPrice ?? p.unitPrice) <= 1000)
            .toList();
        break;
      case 3: // 4★ & above
        list = list.where((p) => (p.rating ?? 4.0) >= 4.0).toList();
        break;
      case 4: // Instant Delivery
        list = list.where((p) => p.isInstantDelivery == true).toList();
        break;
      case 5: // 20%+ Off
        list = list
            .where(
                (p) => (p.discountPercent ?? 0) >= 20 || (p.discount ?? 0) > 0)
            .toList();
        break;
      default:
        break;
    }

    // 3. Sorting
    if (_sortBy == "price_low") {
      list.sort((a, b) {
        final pa = a.finalPrice ?? a.discountedPrice ?? a.unitPrice;
        final pb = b.finalPrice ?? b.discountedPrice ?? b.unitPrice;
        return pa.compareTo(pb);
      });
    } else if (_sortBy == "price_high") {
      list.sort((a, b) {
        final pa = a.finalPrice ?? a.discountedPrice ?? a.unitPrice;
        final pb = b.finalPrice ?? b.discountedPrice ?? b.unitPrice;
        return pb.compareTo(pa);
      });
    } else if (_sortBy == "rating") {
      list.sort((a, b) {
        final ra = a.rating ?? 0.0;
        final rb = b.rating ?? 0.0;
        return rb.compareTo(ra);
      });
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF101015) : const Color(0xFFF7F8FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          // Sort Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded, size: 22),
            tooltip: "Sort By",
            initialValue: _sortBy,
            onSelected: (val) {
              setState(() {
                _sortBy = val;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "default",
                child: Text("Recommended"),
              ),
              PopupMenuItem(
                value: "price_low",
                child: Text("Price: Low to High"),
              ),
              PopupMenuItem(
                value: "price_high",
                child: Text("Price: High to Low"),
              ),
              PopupMenuItem(
                value: "rating",
                child: Text("Highest Rated"),
              ),
            ],
          ),

          // Cart Button
          ListenableBuilder(
            listenable: CartController.instance,
            builder: (context, _) {
              final cart = CartController.instance;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/Bag.svg",
                      height: 22,
                      width: 22,
                      colorFilter: ColorFilter.mode(
                        isDark ? Colors.white : const Color(0xFF22222A),
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, cartScreenRoute);
                    },
                  ),
                  if (cart.totalItemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          "${cart.totalItemCount}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Container(
            color: isDark ? const Color(0xFF16161E) : Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: 8,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: "Search in ${widget.title}...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF22222E)
                    : const Color(0xFFF1F3F6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Quick Filter Chips
          Container(
            color: isDark ? const Color(0xFF16161E) : Colors.white,
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: 4,
              ),
              itemCount: _quickFilters.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_quickFilters[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilterIndex = selected ? index : 0;
                      });
                    },
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    backgroundColor: isDark
                        ? const Color(0xFF22222E)
                        : const Color(0xFFF0F1F5),
                    selectedColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? primaryColor
                            : (isDark ? Colors.white12 : const Color(0xFFE2E4EA)),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                  ),
                );
              },
            ),
          ),

          // Products Grid
          Expanded(
            child: Obx(() {
              final isLoading = _apiController.isNewArrivalsLoading.value ||
                  _apiController.isFeaturedLoading.value;
              final products = _getFilteredAndSortedProducts();

              if (isLoading && products.isEmpty) {
                return GridView.builder(
                  padding: const EdgeInsets.all(defaultPadding),
                  itemCount: 6,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) => const ProductCardSkelton(),
                );
              }

              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty
                            ? "No products matching \"$_searchQuery\""
                            : "No products available in this section",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _apiController.fetchAllData();
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text("Refresh"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await _apiController.fetchAllData();
                },
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.all(defaultPadding),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final apiProduct = products[index];
                    final productModel = apiProduct.toProductModel();

                    return ProductCard(
                      id: productModel.id,
                      shopId: productModel.shopId,
                      variant: productModel.variant,
                      color: productModel.color,
                      choices: productModel.choices,
                      image: productModel.image,
                      brandName: productModel.brandName,
                      title: productModel.title,
                      price: productModel.price,
                      priceAfetDiscount: productModel.priceAfetDiscount,
                      dicountpercent: productModel.dicountpercent,
                      discountAmount: productModel.discountAmount,
                      storeName: productModel.storeName,
                      storeDomain: productModel.storeDomain,
                      categoryId: productModel.categoryId,
                      categoryName: productModel.categoryName,
                      categorySlug: productModel.categorySlug,
                      categoryType: productModel.categoryType,
                      press: () {
                        Navigator.pushNamed(
                          context,
                          productDetailsScreenRoute,
                          arguments: productModel,
                        );
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
