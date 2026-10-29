import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vlr/ecomerce/components/product/product_quantity_button.dart';
import 'package:vlr/ecomerce/components/skleton/skelton.dart';
import 'package:vlr/ecomerce/constants.dart';
import 'package:vlr/ecomerce/controllers/cart_controller.dart';
import 'package:vlr/ecomerce/controllers/restaurant_controller.dart';
import 'package:vlr/ecomerce/models/food_model.dart';
import 'package:vlr/ecomerce/models/home_screen_models.dart';
import 'package:vlr/ecomerce/models/restaurant_model.dart';
import 'package:vlr/ecomerce/screens/checkout/views/cart_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final int restaurantId;
  final RestaurantModel? initialRestaurant;
  final List<ApiProductModel>? allFoodProducts;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    this.initialRestaurant,
    this.allFoodProducts,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late final RestaurantController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = Get.put(RestaurantController());
    _controller.fetchRestaurantDetails(
      widget.restaurantId,
      shopId: widget.initialRestaurant?.shopId,
      domain: widget.initialRestaurant?.domain,
      initialRestaurant: widget.initialRestaurant,
      foodProductsList: widget.allFoodProducts,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final cart = CartController.instance;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF12121A) : const Color(0xFFF7F7FA),
      bottomNavigationBar: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          if (cart.items.isEmpty) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E28) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFF00C853),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${cart.totalItemCount} ${cart.totalItemCount == 1 ? 'item' : 'items'} added",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        Text(
                          "₹${cart.grandTotal.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "View Cart",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      body: Obx(() {
        final detail = _controller.restaurantDetail.value;
        final initial = widget.initialRestaurant;

        final name = detail?.name.isNotEmpty == true
            ? detail!.name
            : (initial?.name ?? "The Vendor Second");
        final banner = detail?.banner ?? initial?.banner;
        final logo = detail?.logo ?? initial?.logo;
        final address = detail?.address ??
            initial?.address ??
            "Shop No 1254/45 Lucknow Steen up india";
        final rating = initial?.rating ?? 4.8;
        final isOpen = detail?.isOpen ?? initial?.isOpenNow ?? true;
        final deliveryFee =
            detail?.minDeliveryCharge ?? initial?.minDeliveryCharge ?? 20.0;
        final packingTime =
            detail?.avgPackingTimeMin ?? initial?.avgPackingTimeMin ?? 5;
        final storeDomain = detail?.domain ?? initial?.domain ?? "e-team-12";
        final shopId = detail?.shopId ?? initial?.shopId ?? 2;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Header App Bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF1E1E28) : primaryColor,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.explore_outlined,
                      color: Colors.white, size: 16),
                  label: const Text(
                    "Explore All",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    banner != null && banner.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: banner,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Skeleton(),
                            errorWidget: (_, __, ___) => Container(
                              color: const Color(0xFF1A1A24),
                              child: const Icon(Icons.restaurant,
                                  color: Colors.white24, size: 48),
                            ),
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(Icons.restaurant,
                                size: 48, color: Colors.white54),
                          ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Restaurant Profile Info Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Branding Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              isDark ? Colors.white12 : const Color(0xFFEAEAEA),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.25 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white12
                                        : const Color(0xFFE0E0E0),
                                  ),
                                  color: isDark
                                      ? const Color(0xFF262634)
                                      : const Color(0xFFF5F5F8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: logo != null && logo.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: logo,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) =>
                                              const Icon(
                                            Icons.restaurant_menu_rounded,
                                            color: primaryColor,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.restaurant_menu_rounded,
                                          color: primaryColor,
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
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2196F3)
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.verified_rounded,
                                                  color: Color(0xFF2196F3),
                                                  size: 12),
                                              SizedBox(width: 3),
                                              Text(
                                                "VERIFIED",
                                                style: TextStyle(
                                                  color: Color(0xFF2196F3),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 9.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      address,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white60
                                            : Colors.black54,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Badges Row
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _buildPill(
                                icon: Icons.star_rounded,
                                iconColor: Colors.amber,
                                text: "$rating (500+ Ratings)",
                                bgColor: Colors.amber.withValues(alpha: 0.15),
                                textColor: isDark
                                    ? Colors.amber.shade200
                                    : Colors.amber.shade900,
                              ),
                              _buildPill(
                                icon: Icons.circle,
                                iconColor: isOpen
                                    ? const Color(0xFF00C853)
                                    : const Color(0xFFE53935),
                                text: isOpen ? "Open Now" : "Currently Closed",
                                bgColor: (isOpen
                                        ? const Color(0xFF00C853)
                                        : const Color(0xFFE53935))
                                    .withValues(alpha: 0.15),
                                textColor: isOpen
                                    ? const Color(0xFF00C853)
                                    : const Color(0xFFE53935),
                              ),
                              _buildPill(
                                icon: Icons.timer_outlined,
                                iconColor: const Color(0xFF00BCD4),
                                text: "~$packingTime mins prep",
                                bgColor: const Color(0xFF00BCD4)
                                    .withValues(alpha: 0.15),
                                textColor: const Color(0xFF00BCD4),
                              ),
                              _buildPill(
                                icon: Icons.delivery_dining_rounded,
                                iconColor: primaryColor,
                                text:
                                    "₹${deliveryFee.toStringAsFixed(0)} Delivery Fee",
                                bgColor: primaryColor.withValues(alpha: 0.12),
                                textColor: primaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Promo Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.local_offer_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Special Deal: 20% OFF on all gourmet combos above ₹299 • Use Code FOOD20",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 1. Menu Categories Horizontal Bar
                    Obx(() {
                      final categories = _controller.categoriesMenu;
                      final allCount = _controller.allDishes.length;
                      final selectedCat = _controller.selectedCategory.value;

                      return SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildCategoryChip(
                              name: "All Dishes",
                              count: allCount,
                              isSelected: selectedCat == "All",
                              isDark: isDark,
                              onTap: () => _controller.setCategory("All"),
                            ),
                            ...categories.map((cat) {
                              final isSelected = selectedCat.toLowerCase() ==
                                  cat.categoryName.toLowerCase();
                              return _buildCategoryChip(
                                name: cat.categoryName,
                                count: cat.dishesCount,
                                isSelected: isSelected,
                                isDark: isDark,
                                onTap: () =>
                                    _controller.setCategory(cat.categoryName),
                              );
                            }),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 14),

                    // 2. Food Preference (Veg / Non-Veg Filters)
                    Row(
                      children: [
                        _buildVegFilterChip("All", isDark),
                        const SizedBox(width: 8),
                        _buildVegFilterChip("Veg", isDark, isVeg: true),
                        const SizedBox(width: 8),
                        _buildVegFilterChip("Non-Veg", isDark, isNonVeg: true),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // 3. Search in Menu Field
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => _controller.setSearch(val),
                      decoration: InputDecoration(
                        hintText: "Search dishes in menu...",
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _controller.setSearch('');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: cardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white12
                                : const Color(0xFFE2E2E8),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white12
                                : const Color(0xFFE2E2E8),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 4. Dishes Header Status
                    Obx(() {
                      final selectedCat = _controller.selectedCategory.value;
                      final count = _controller.filteredDishes.length;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Showing: $selectedCat ($count ${count == 1 ? 'item' : 'items'})",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          if (selectedCat != "All" ||
                              _controller.selectedVegFilter.value != "All" ||
                              _searchController.text.isNotEmpty)
                            InkWell(
                              onTap: () {
                                _searchController.clear();
                                _controller.setSearch('');
                                _controller.setCategory('All');
                                _controller.setVegFilter('All');
                              },
                              child: const Text(
                                "Reset Filters",
                                style: TextStyle(
                                  color: Color(0xFFE53935),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

            // 5. Live Dishes List (List layout)
            Obx(() {
              if (_controller.isDetailLoading.value &&
                  _controller.allDishes.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                        child: CircularProgressIndicator(color: primaryColor)),
                  ),
                );
              }

              final dishes = _controller.filteredDishes;

              if (dishes.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 36),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.no_meals_rounded,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            "No dishes match your selection",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Try clearing filters or search for another item.",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final dish = dishes[index];
                      return _buildDishCard(
                        context,
                        dish,
                        storeDomain,
                        shopId,
                        name,
                        cardBg,
                        isDark,
                      );
                    },
                    childCount: dishes.length,
                  ),
                ),
              );
            }),

            const SliverToBoxAdapter(
              child: SizedBox(height: 60),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required Color iconColor,
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVegFilterChip(String label, bool isDark,
      {bool isVeg = false, bool isNonVeg = false}) {
    final isSelected = _controller.selectedVegFilter.value == label;
    return InkWell(
      onTap: () => _controller.setVegFilter(label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : Colors.black87)
              : (isDark ? const Color(0xFF262634) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Colors.white12 : const Color(0xFFE0E0E6)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isVeg) ...[
              _buildVegIcon(),
              const SizedBox(width: 6),
            ] else if (isNonVeg) ...[
              _buildNonVegIcon(),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String name,
    required int count,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFF5722)
                : (isDark ? const Color(0xFF20202E) : Colors.white),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFF5722)
                  : (isDark ? Colors.white12 : const Color(0xFFE2E2E8)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : (isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.06)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDishCard(
    BuildContext context,
    DishModel dish,
    String storeDomain,
    int shopId,
    String restaurantName,
    Color cardBg,
    bool isDark,
  ) {
    final productModel = dish.toProductModel(
      storeDomain: storeDomain,
      shopId: shopId,
      restaurantName: restaurantName,
    );

    final bool hasDiscount =
        dish.originalPrice > dish.dealPrice && dish.originalPrice > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE8E8EE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Dish Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Veg Indicator + Bestseller Badge Row
                Row(
                  children: [
                    dish.isVeg ? _buildVegIcon() : _buildNonVegIcon(),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "★ BESTSELLER",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE65100),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Dish Name
                Text(
                  dish.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),

                // Price Row
                Row(
                  children: [
                    Text(
                      "₹${dish.dealPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00C853),
                      ),
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        "₹${dish.originalPrice.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),

                // Category & Stock Tag
                Text(
                  "${dish.categoryName ?? 'Delicious Item'} • Freshly prepared",
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Right: Image & Add / Stepper Button
          Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: 94,
                    height: 94,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isDark
                          ? const Color(0xFF262634)
                          : const Color(0xFFF4F4F8),
                      border: Border.all(
                        color:
                            isDark ? Colors.white10 : const Color(0xFFEAEAEA),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child:
                          dish.thumbnail != null && dish.thumbnail!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: dish.thumbnail!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const Skeleton(),
                                  errorWidget: (_, __, ___) => const Icon(
                                    Icons.fastfood_rounded,
                                    color: primaryColor,
                                    size: 32,
                                  ),
                                )
                              : const Icon(
                                  Icons.fastfood_rounded,
                                  color: primaryColor,
                                  size: 32,
                                ),
                    ),
                  ),
                  Positioned(
                    bottom: -12,
                    child: SizedBox(
                      width: 84,
                      child: ProductQuantityButton(
                        product: productModel,
                        storeDomain: storeDomain,
                        activeColor: const Color(0xFF00C853),
                        height: 30,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVegIcon() {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF00C853), width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Color(0xFF00C853),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildNonVegIcon() {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE53935), width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(6, 6),
          painter: _TrianglePainter(color: const Color(0xFFE53935)),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
