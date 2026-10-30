import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../constants.dart';
import '../../../controllers/brand_crontoller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/home_screen_api_controller.dart';
import '../../../models/brand_model.dart';
import '../../../route/app_text_constants.dart';

class AllBrandsScreen extends StatefulWidget {
  const AllBrandsScreen({super.key});

  @override
  State<AllBrandsScreen> createState() => _AllBrandsScreenState();
}

class _AllBrandsScreenState extends State<AllBrandsScreen> {
  late final BrandCrontoller _brandController;
  late final HomeScreenApiController _homeApiController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _brandController = Get.isRegistered<BrandCrontoller>()
        ? Get.find<BrandCrontoller>()
        : Get.put(BrandCrontoller());
    _homeApiController = Get.put(HomeScreenApiController());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BrandModel> _getMergedBrands() {
    final List<BrandModel> allSources = [
      ..._brandController.brands,
      ..._homeApiController.topBrands,
    ];

    var list = BrandModel.deduplicate(allSources);

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((b) => b.name.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF101015) : const Color(0xFFF7F8FA);
    final cardColor = isDark ? const Color(0xFF1C1C24) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Top Brands",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
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
          // Search Input
          Container(
            color: isDark ? const Color(0xFF16161E) : Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: 10,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: "Search brands...",
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

          // Brands Grid
          Expanded(
            child: Obx(() {
              final isLoading = _brandController.isLoading.value ||
                  _homeApiController.isTopBrandsLoading.value;
              final brands = _getMergedBrands();

              if (isLoading && brands.isEmpty) {
                return GridView.builder(
                  padding: const EdgeInsets.all(defaultPadding),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.95,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    );
                  },
                );
              }

              if (brands.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 64,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty
                            ? "No brands matching \"$_searchQuery\""
                            : "No brands available",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _brandController.fetchBrands();
                          _homeApiController.fetchTopBrands();
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
                  await Future.wait([
                    _brandController.fetchBrands(),
                    _homeApiController.fetchTopBrands(),
                  ]);
                },
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.all(defaultPadding),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.92,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: brands.length,
                  itemBuilder: (context, index) {
                    final brand = brands[index];
                    return _buildBrandCard(context, brand, cardColor, isDark);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandCard(
    BuildContext context,
    BrandModel brand,
    Color cardColor,
    bool isDark,
  ) {
    final String brandSlug = brand.slug ?? brand.name.toLowerCase();

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: isDark ? 0 : 0.8,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            brandScreenRoute,
            arguments: brandSlug,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Brand Logo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF262632)
                      : const Color(0xFFF2F4F7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.white12 : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: brand.image != null && brand.image!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: brand.image!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.verified_rounded,
                            color: primaryColor,
                            size: 32,
                          ),
                        )
                      : const Icon(
                          Icons.verified_rounded,
                          color: primaryColor,
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // Brand Name
              Text(
                brand.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              // Product Count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  brand.productsCount != null && brand.productsCount! > 0
                      ? "${brand.productsCount} Products"
                      : "Official Brand",
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
      ),
    );
  }
}
