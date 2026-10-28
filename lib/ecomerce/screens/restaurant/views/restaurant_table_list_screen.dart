import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/ecomerce/screens/restaurant/views/dining/table_booking_screen.dart';
import '../../../../../ecomerce/constants.dart';
import '../../../../../ecomerce/controllers/dining_controller.dart';
import '../../../../../ecomerce/models/restaurant_model.dart';

class RestaurantTableListScreen extends StatefulWidget {
  const RestaurantTableListScreen({super.key, this.domain = 'e-team-12'});

  final String domain;

  @override
  State<RestaurantTableListScreen> createState() =>
      _RestaurantTableListScreenState();
}

class _RestaurantTableListScreenState extends State<RestaurantTableListScreen> {
  late final DiningController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<DiningController>()
        ? Get.find<DiningController>()
        : Get.put(DiningController());
    _controller.fetchDiningRestaurants(domain: widget.domain);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final bg = isDark ? const Color(0xFF12121A) : const Color(0xFFF7F7FA);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E28) : Colors.white,
        title: const Text(
          'Dine-In Restaurants',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoadingRestaurants.value &&
            _controller.diningRestaurants.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: primaryColor));
        }

        final list = _controller.diningRestaurants;
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_outlined,
                    size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('No dining restaurants found',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Pull to refresh or try again later',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: primaryColor,
          onRefresh: () =>
              _controller.fetchDiningRestaurants(domain: widget.domain),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final restaurant = list[index];
              return _buildRestaurantCard(context, restaurant, cardBg, isDark);
            },
          ),
        );
      }),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, RestaurantModel restaurant,
      Color cardBg, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFEAEAEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 160,
                width: double.infinity,
                child: restaurant.banner != null &&
                        restaurant.banner!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: restaurant.banner!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: Colors.grey.shade200),
                        errorWidget: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Color(0xFFE65100), Color(0xFFFF8F00)]),
                          ),
                          child: const Icon(Icons.restaurant,
                              color: Colors.white, size: 40),
                        ),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Color(0xFFE65100), Color(0xFFFF8F00)]),
                        ),
                        child: const Icon(Icons.restaurant,
                            color: Colors.white, size: 40),
                      ),
              ),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                left: 14,
                bottom: 14,
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: restaurant.logo != null &&
                                restaurant.logo!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: restaurant.logo!, fit: BoxFit.cover)
                            : const Icon(Icons.restaurant_menu,
                                color: primaryColor),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          restaurant.address ?? '',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (restaurant.isOpenNow)
                Positioned(
                  right: 14,
                  top: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('OPEN',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _infoChip(
                    Icons.star_rounded, '${restaurant.rating}', Colors.amber),
                const SizedBox(width: 8),
                _infoChip(Icons.people_outline_rounded,
                    '${restaurant.reviewsCount} Reviews', Colors.blueGrey),
                const SizedBox(width: 8),
                if (restaurant.estimatedDeliveryTime != null)
                  _infoChip(Icons.timer_outlined,
                      restaurant.estimatedDeliveryTime!, Colors.teal),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TableBookingScreen(
                          restaurant: restaurant,
                          domain: restaurant.domain ?? widget.domain,
                          shopId: restaurant.shopId ?? restaurant.id,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.table_restaurant_rounded, size: 18),
                  label: const Text('Book Table',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : Colors.black87)),
        ],
      ),
    );
  }
}
