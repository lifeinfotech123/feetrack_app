import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../constants.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/categories_controller.dart';
import '../../../models/category_model.dart';
import '../../../models/home_screen_models.dart';
import '../../../route/route_constants.dart';
import '../../../components/product/product_quantity_button.dart';
import '../../../components/product/wishlist_heart_button.dart';

class CategoryProductsScreen extends StatefulWidget {
  final CategoryModel? category;
  final String? categoryTitle;
  final String? categorySlug;
  final int? categoryId;
  final String? categoryImage;
  final String? categoryType;

  const CategoryProductsScreen({
    super.key,
    this.category,
    this.categoryTitle,
    this.categorySlug,
    this.categoryId,
    this.categoryImage,
    this.categoryType,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late final CategoriesController _categoriesController;
  final CartController _cart = CartController.instance;
  final TextEditingController _searchController = TextEditingController();

  late final CategoryModel _currentCategory;
  String _searchQuery = "";
  int _selectedFilterIndex =
      0; // 0: All, 1: Under ₹200, 2: Under ₹500, 3: 4★+, 4: Fast Delivery, 5: 20%+ Off
  String _sortBy = "popular"; // popular, price_low, price_high, rating, newest
  bool _isSearchOpen = false;

  final List<String> _quickFilters = [
    "All",
    "Under ₹200",
    "Under ₹500",
    "⚡ Instant Delivery",
    "Offers (20%+)",
  ];

  @override
  void initState() {
    super.initState();
    _categoriesController = Get.isRegistered<CategoriesController>()
        ? Get.find<CategoriesController>()
        : Get.put(CategoriesController());

    _currentCategory = widget.category ??
        CategoryModel(
          id: widget.categoryId,
          name: widget.categoryTitle ?? "Category",
          slug: widget.categorySlug,
          icon: widget.categoryImage,
          categoryType: widget.categoryType,
        );

    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    _categoriesController.fetchCategoryProducts(
      _currentCategory,
      sortBy: _sortBy != 'popular' ? _sortBy : null,
    );
  }

  List<ApiProductModel> _getFilteredProducts(List<ApiProductModel> list) {
    var result = List<ApiProductModel>.from(list);

    // Search query filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              (p.brand?.name ?? '').toLowerCase().contains(q))
          .toList();
    }

    // Quick filter chips
    switch (_selectedFilterIndex) {
      case 1: // Under ₹200
        result = result
            .where((p) =>
                (p.finalPrice ?? p.discountedPrice ?? p.unitPrice) <= 200)
            .toList();
        break;
      case 2: // Under ₹500
        result = result
            .where((p) =>
                (p.finalPrice ?? p.discountedPrice ?? p.unitPrice) <= 500)
            .toList();
        break;
      case 3: // 4★+
        result = result.where((p) => (p.rating ?? 4.0) >= 4.0).toList();
        break;
      case 4: // Instant Delivery
        result = result.where((p) => p.isInstantDelivery == true).toList();
        break;
      case 5: // 20%+ Off
        result = result
            .where(
                (p) => (p.discountPercent ?? 0) >= 20 || (p.discount ?? 0) > 0)
            .toList();
        break;
      default:
        break;
    }

    // Sort order
    if (_sortBy == "price_low") {
      result.sort((a, b) {
        final pa = a.finalPrice ?? a.discountedPrice ?? a.unitPrice;
        final pb = b.finalPrice ?? b.discountedPrice ?? b.unitPrice;
        return pa.compareTo(pb);
      });
    } else if (_sortBy == "price_high") {
      result.sort((a, b) {
        final pa = a.finalPrice ?? a.discountedPrice ?? a.unitPrice;
        final pb = b.finalPrice ?? b.discountedPrice ?? b.unitPrice;
        return pb.compareTo(pa);
      });
    } else if (_sortBy == "rating") {
      result.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    } else if (_sortBy == "newest") {
      result.sort((a, b) => b.id.compareTo(a.id));
    }

    return result;
  }

  void _showSortBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E28) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "SORT BY",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _sortTile("popular", "Popularity", ctx),
                _sortTile("price_low", "Price -- Low to High", ctx),
                _sortTile("price_high", "Price -- High to Low", ctx),
                _sortTile("rating", "Customer Rating", ctx),
                _sortTile("newest", "Newest Arrivals", ctx),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sortTile(String value, String label, BuildContext ctx) {
    final isSelected = _sortBy == value;
    return ListTile(
      dense: true,
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? primaryColor : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: primaryColor)
          : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(ctx);
        _loadProducts();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF101017) : const Color(0xFFF4F5F8);

    final title = _currentCategory.name.isNotEmpty
        ? _currentCategory.name
        : (widget.categoryTitle ?? "Category");

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF161622) : Colors.white,
        elevation: 0.8,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_currentCategory.store?.name != null)
              Text(
                "Store: ${_currentCategory.store!.name}",
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white60 : blackColor60,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        actions: [
          // Search toggle
          IconButton(
            icon: Icon(
              _isSearchOpen ? Icons.close : Icons.search_rounded,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _isSearchOpen = !_isSearchOpen;
                if (!_isSearchOpen) {
                  _searchQuery = "";
                  _searchController.clear();
                }
              });
            },
          ),

          // Wishlist
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/Wishlist.svg",
              height: 20,
              width: 20,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : const Color(0xFF22222A),
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => Navigator.pushNamed(context, bookmarkScreenRoute),
          ),

          // Cart with live badge
          AnimatedBuilder(
            animation: _cart,
            builder: (context, _) {
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
                    onPressed: () =>
                        Navigator.pushNamed(context, cartScreenRoute),
                  ),
                  if (_cart.totalItemCount > 0)
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
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          "${_cart.totalItemCount}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
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
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Inline Search Bar (Expandable)
            if (_isSearchOpen)
              Container(
                color: isDark ? const Color(0xFF161622) : Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF232330)
                        : const Color(0xFFF1F1F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search in $title...",
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : blackColor40,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),

            // Top Flipkart Category Highlight Banner
            _buildCategoryHeroBanner(isDark),

            // Quick Filter Chips Bar
            _buildQuickFilterBar(isDark),

            // Sticky Sort & Product Count Header
            _buildSortAndCountBar(isDark),

            // Products Grid
            Expanded(
              child: Obx(() {
                if (_categoriesController.isProductsLoading.value) {
                  return _buildShimmerGrid(isDark);
                }

                final rawList = _categoriesController.categoryProducts;
                final products = _getFilteredProducts(rawList);

                if (products.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadProducts(),
                  color: primaryColor,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    itemBuilder: (context, index) {
                      final item = products[index];
                      return _buildFlipkartProductCard(item, isDark);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeroBanner(bool isDark) {
    final icon = _currentCategory.icon;
    final catType = _currentCategory.categoryType?.toUpperCase() ?? "ECOMMERCE";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2C2248), const Color(0xFF1C1A2E)]
              : [const Color(0xFFF1ECFF), const Color(0xFFE8E0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (icon != null && icon.isNotEmpty)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: icon,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.category_rounded,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        catType,
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "• BEST OFFERS",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  "Explore ${_currentCategory.name}",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E1E28),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "UP TO 50% OFF",
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterBar(bool isDark) {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _quickFilters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor
                      : (isDark ? const Color(0xFF1E1E2A) : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? primaryColor
                        : (isDark ? Colors.white10 : const Color(0xFFE2E2E8)),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  _quickFilters[index],
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF33333E)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortAndCountBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14141E) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : const Color(0xFFEDEDF2),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final count =
                _getFilteredProducts(_categoriesController.categoryProducts)
                    .length;
            return Text(
              "$count Products found",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : blackColor60,
              ),
            );
          }),
          InkWell(
            onTap: () => _showSortBottomSheet(context, isDark),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF222230) : const Color(0xFFF2F2F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swap_vert_rounded,
                      size: 16, color: primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    _getSortLabel(),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case "price_low":
        return "Price: Low to High";
      case "price_high":
        return "Price: High to Low";
      case "rating":
        return "Top Rated";
      case "newest":
        return "Newest";
      default:
        return "Sort";
    }
  }

  Widget _buildFlipkartProductCard(ApiProductModel item, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1A1A24) : Colors.white;
    final effectivePrice =
        item.finalPrice ?? item.discountedPrice ?? item.unitPrice;
    final originalPrice = item.unitPrice;
    final hasDiscount = effectivePrice < originalPrice;
    final discountPercent = item.discountPercent?.round() ??
        (hasDiscount && originalPrice > 0
            ? (((originalPrice - effectivePrice) / originalPrice) * 100).round()
            : null);

    final rating = item.rating ?? 4.2;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFEAEAEE),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
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
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with badges
              Expanded(
                flex: 11,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Container(
                        color: isDark
                            ? const Color(0xFF22222E)
                            : const Color(0xFFF7F7F9),
                        child: CachedNetworkImage(
                          imageUrl: item.thumbnail != null &&
                                  item.thumbnail!.isNotEmpty
                              ? item.thumbnail!
                              : productDemoImg1,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const Center(
                            child: Icon(Icons.image_not_supported_outlined,
                                size: 36),
                          ),
                        ),
                      ),
                    ),

                    // Discount tag (Flipkart green/purple badge)
                    if (hasDiscount &&
                        discountPercent != null &&
                        discountPercent > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            "$discountPercent% OFF",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),

                    // Instant Delivery badge
                    if (item.isInstantDelivery == true)
                      Positioned(
                        bottom: 6,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt,
                                  size: 10, color: Color(0xFFFFD700)),
                              SizedBox(width: 2),
                              Text(
                                "Instant",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Wishlist Heart on Top Right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: WishlistHeartButton(
                        productId: item.id,
                        storeDomain: item.store?.domain,
                        size: 26,
                        iconSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Product Info Section
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Brand name
                          Text(
                            (item.brand?.name ?? item.store?.name ?? "BRAND")
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white54 : blackColor60,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),

                          // Product Title
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A22),
                              height: 1.15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Rating badge (Flipkart style: green pill)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.star,
                                        size: 9, color: Colors.white),
                                  ],
                                ),
                              ),
                              if (item.reviewsCount != null &&
                                  item.reviewsCount! > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  "(${item.reviewsCount})",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        isDark ? Colors.white38 : blackColor40,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),

                      // Price & Add to Cart button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "₹${effectivePrice.toStringAsFixed(0)}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF181820),
                                      ),
                                    ),
                                    if (hasDiscount) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        "₹${originalPrice.toStringAsFixed(0)}",
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: isDark
                                              ? Colors.white38
                                              : blackColor40,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Flipkart Add / Quantity Stepper Button
                          ProductQuantityButton(
                            product: item.toProductModel(),
                            storeDomain: item.store?.domain,
                            isMini: false,
                            showText: true,
                            height: 28,
                          ),
                        ],
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

  Widget _buildShimmerGrid(bool isDark) {
    final shimmerColor = isDark ? Colors.white10 : const Color(0xFFE8E8EE);
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A24) : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 11,
                child: Container(
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(height: 10, width: 60, color: shimmerColor),
                      Container(
                          height: 14,
                          width: double.infinity,
                          color: shimmerColor),
                      Container(height: 14, width: 90, color: shimmerColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(height: 16, width: 50, color: shimmerColor),
                          Container(height: 24, width: 50, color: shimmerColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 40,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "No products found",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E1E28),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We couldn't find any products in '${_currentCategory.name}'. Try clearing filters or exploring other categories.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : blackColor60,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedFilterIndex = 0;
                  _searchQuery = "";
                  _searchController.clear();
                });
                _loadProducts();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Reset Filters",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
