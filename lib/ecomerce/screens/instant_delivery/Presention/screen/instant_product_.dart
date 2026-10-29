import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/permission_controller.dart';

import 'package:vlr/ecomerce/components/skleton/skelton.dart';
import 'package:vlr/ecomerce/constants.dart';
import 'package:vlr/ecomerce/controllers/cart_controller.dart';
import 'package:vlr/ecomerce/controllers/food_controller.dart';
import 'package:vlr/ecomerce/models/restaurant_model.dart';
import 'package:vlr/ecomerce/route/app_text_constants.dart';
import 'package:vlr/ecomerce/screens/checkout/views/cart_screen.dart';
import 'package:vlr/ecomerce/screens/restaurant/views/restaurant_detail_screen.dart';

class InstantProduct extends StatefulWidget {
  const InstantProduct({super.key});

  @override
  State<InstantProduct> createState() => _HomePageState();
}

class _HomePageState extends State<InstantProduct> {
  late final FoodController _foodController;
  late final PermissionController _permissionController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _foodController = Get.put(FoodController());
    _permissionController = Get.isRegistered<PermissionController>()
        ? Get.find<PermissionController>()
        : Get.put(PermissionController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_permissionController.address == null ||
          _permissionController.address!.trim().isEmpty) {
        _permissionController.requestLocationPermissionAndFetch(context);
      }
    });
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
                          "${cart.totalItemCount} ${cart.totalItemCount == 1 ? 'item' : 'items'} in cart",
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _foodController.fetchFoodData(),
          color: primaryColor,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Top Express Location & Notifications Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF5722),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.flash_on_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            "25-35 MINS DELIVERY",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Food Delivery",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                GetBuilder<PermissionController>(
                                  init: _permissionController,
                                  builder: (permCtrl) {
                                    final hasLoc = permCtrl.address != null &&
                                        permCtrl.address!.trim().isNotEmpty;
                                    final locText = hasLoc
                                        ? permCtrl.address!.trim()
                                        : (permCtrl.locationFetched
                                            ? "Tap to detect address"
                                            : "Detecting current location...");

                                    return InkWell(
                                      onTap: () async {
                                        await permCtrl
                                            .requestLocationPermissionAndFetch(
                                                context);
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_rounded,
                                            size: 15,
                                            color: primaryColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              "Deliver to: $locText",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 16,
                                            color: greyColor,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, notificationsScreenRoute);
                            },
                            icon: SvgPicture.asset(
                              "assets/icons/Notification.svg",
                              height: 22,
                              colorFilter: ColorFilter.mode(
                                Theme.of(context).iconTheme.color!,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: defaultPadding),

                      // Search Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white12
                                : const Color(0xFFE2E2E8),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded,
                                color: primaryColor, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) =>
                                    _foodController.setSearch(val),
                                decoration: InputDecoration(
                                  hintText:
                                      "Search for restaurant, dish, or cuisine...",
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _foodController.setSearch('');
                                },
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: defaultPadding),

                      // 1. Dynamic Hero CMS Banner (api/v1/ecommerce/food)
                      Obx(() {
                        final hero = _foodController.foodData.value?.heroCms;
                        final badge = hero?.badgeText ??
                            "25-35 Mins Instant Food Delivery";
                        final titleMain =
                            hero?.titleMain ?? "Craving Something";
                        final titleHighlight =
                            hero?.titleHighlight ?? "Delicious?";
                        final subtitle = hero?.subtitle ??
                            "Order fresh, hot, and hygienic meals from the finest restaurants and cafes delivered to your doorstep.";
                        final avgDel = hero?.avgDelivery ?? "30-40m";
                        final topRated = hero?.topRated ?? "4.8+";
                        final tracking = hero?.liveTracking ?? "100%";

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE65100)
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.bolt_rounded,
                                        size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      badge.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "$titleMain ",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: titleHighlight,
                                      style: const TextStyle(
                                        color: Color(0xFFFFE082),
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 11.5,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildHeroStatPill(
                                      Icons.timer_outlined, avgDel, "Delivery"),
                                  const SizedBox(width: 6),
                                  _buildHeroStatPill(Icons.star_rounded,
                                      topRated, "Top Rated"),
                                  const SizedBox(width: 6),
                                  _buildHeroStatPill(
                                      Icons.track_changes_rounded,
                                      tracking,
                                      "Tracking"),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: defaultPadding * 1.2),

                      // 2. Popular Cuisines & Moods (19 Cuisines from api/v1/ecommerce/food)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Popular Cuisines & Moods",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Pick from your favorite categories",
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color:
                                      isDark ? Colors.white54 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          Obx(() => Text(
                                "${_foodController.cuisines.length} Cuisines",
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Cuisines Horizontal Slider
                      Obx(() {
                        final cuisines = _foodController.cuisines;
                        final selectedIndex =
                            _foodController.selectedCuisineIndex.value;

                        if (cuisines.isEmpty &&
                            _foodController.isLoading.value) {
                          return const SizedBox(
                            height: 70,
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: primaryColor)),
                          );
                        }

                        return SizedBox(
                          height: 42,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildCuisineFilterChip(
                                name: "All Menus",
                                iconUrl: null,
                                isSelected: selectedIndex == 0,
                                isDark: isDark,
                                onTap: () => _foodController.selectCuisine(0),
                              ),
                              ...List.generate(cuisines.length, (idx) {
                                final c = cuisines[idx];
                                return _buildCuisineFilterChip(
                                  name: c.name,
                                  iconUrl: c.icon,
                                  isSelected: selectedIndex == (idx + 1),
                                  isDark: isDark,
                                  onTap: () =>
                                      _foodController.selectCuisine(idx + 1),
                                );
                              }),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: defaultPadding * 1.4),

                      // 3. Restaurants Near You Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Restaurants Near You",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                              ),
                              Obx(() {
                                final count =
                                    _foodController.filteredRestaurants.length;
                                return Text(
                                  "$count ${count == 1 ? 'outlet' : 'outlets'} delivering fresh food right now",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                                );
                              }),
                            ],
                          ),
                          // Veg Filter Chips
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Row(
                      //   children: [
                      //     _buildVegFilterSmallChip("All", isDark),
                      //     const SizedBox(width: 4),
                      //     _buildVegFilterSmallChip("Pure Veg", isDark,
                      //         isVeg: true),
                      //     const SizedBox(width: 4),
                      //     _buildVegFilterSmallChip("Non-Veg", isDark,
                      //         isNonVeg: true),
                      //   ],
                      // ),

                      // const SizedBox(
                      //   height: 10,
                      // ),

                      // Restaurants List Cards
                      Obx(() {
                        final restaurants = _foodController.filteredRestaurants
                            .where((r) => r.isRestaurant)
                            .toList();

                        if (restaurants.isEmpty &&
                            !_foodController.isLoading.value) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text(
                                "No restaurants currently found.",
                                style:
                                    TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: restaurants.map((restaurant) {
                            return _buildRestaurantCard(
                              context,
                              restaurant,
                              cardBg,
                              isDark,
                            );
                          }).toList(),
                        );
                      }),

                      const SizedBox(height: defaultPadding),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 50),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStatPill(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            "$value $label",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuisineFilterChip({
    required String name,
    required String? iconUrl,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFF5722)
                : (isDark ? const Color(0xFF20202C) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFF5722)
                  : (isDark ? Colors.white12 : const Color(0xFFE2E2E8)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconUrl != null && iconUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: iconUrl,
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.fastfood, size: 14),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(
    BuildContext context,
    RestaurantModel restaurant,
    Color cardBg,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantDetailScreen(
                restaurantId: restaurant.id,
                initialRestaurant: restaurant,
                allFoodProducts: _foodController.foodProducts,
              ),
            ),
          );
        },
        onLongPress: () {
          try {
            _foodController.selectRestaurant(restaurant);
            _foodController.applyFilters();
          } catch (_) {}
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Showing dishes from ${restaurant.name}')),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFEAEAEA),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner with Status & Metrics
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: restaurant.banner != null &&
                            restaurant.banner!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: restaurant.banner!,
                            height: 135,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Skeleton(),
                            errorWidget: (_, __, ___) => Container(
                              height: 135,
                              color: primaryColor.withValues(alpha: 0.1),
                              child: const Icon(Icons.restaurant,
                                  color: primaryColor),
                            ),
                          )
                        : Container(
                            height: 135,
                            color: primaryColor.withValues(alpha: 0.1),
                            child: const Icon(Icons.restaurant,
                                color: primaryColor),
                          ),
                  ),

                  // Open / Closed Status Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: restaurant.isOpenNow
                            ? const Color(0xFF00C853)
                            : const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle,
                              size: 7, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.isOpenNow ? "Open" : "Closed",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Delivery Time & Fee Badges
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.estimatedDeliveryTime ?? "15 mins",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.delivery_dining_rounded,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            "₹${restaurant.minDeliveryCharge.toStringAsFixed(0)} Fee",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Details Row
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Text(
                                restaurant.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.star_rounded,
                                  color: Colors.white, size: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      restaurant.address ?? "Lucknow, India",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white10
                                : const Color(0xFFF0F0F5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Multi-Cuisine",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Row(
                          children: [
                            Text(
                              "View Menu",
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: primaryColor,
                              size: 15,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _SmallTrianglePainter extends CustomPainter {
  final Color color;

  _SmallTrianglePainter({required this.color});

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
