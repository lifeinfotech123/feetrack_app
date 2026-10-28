import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../components/product/product_card.dart';
import '../../../components/skleton/skelton.dart';
import '../../../constants.dart';
import '../../../controllers/home_screen_api_controller.dart';
import '../../../controllers/store_controller.dart';
import '../../../models/store_model.dart';
import '../../../route/route_constants.dart';

class StoreDetailScreen extends StatefulWidget {
  final StoreModel store;

  const StoreDetailScreen({
    super.key,
    required this.store,
  });

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  late final StoreController _storeController;
  late final HomeScreenApiController _homeController;

  @override
  void initState() {
    super.initState();
    _storeController = Get.put(StoreController());
    _homeController = Get.put(HomeScreenApiController());

    if (widget.store.shopId != null) {
      _storeController.fetchStoreDetails(widget.store.shopId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Obx(() {
        final store = _storeController.storeDetails.value ?? widget.store;
        final isSelected =
            _storeController.selectedStore.value?.id == store.id &&
                _storeController.selectedStore.value?.shopId == store.shopId;

        // Products belonging to this store
        final storeProducts = _homeController.allProducts.where((p) {
          final matchesShopId = store.shopId != null &&
              (p.shopId == store.shopId || p.store?.shopId == store.shopId);
          final matchesStoreId = store.id != 0 && p.store?.id == store.id;
          final matchesDomain = store.domain != null &&
              p.store?.domain?.toLowerCase() == store.domain?.toLowerCase();
          return matchesShopId || matchesStoreId || matchesDomain;
        }).toList();

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Sliver App Bar with Banner
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    store.banner != null && store.banner!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: store.banner!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Skeleton(),
                            errorWidget: (_, __, ___) => Container(
                              color: primaryColor.withValues(alpha: 0.3),
                            ),
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryColor, Color(0xFF4A148C)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
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

            // Store Info Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Store Logo
                        Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: primaryColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: store.logo != null && store.logo!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: store.logo!,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => const Icon(
                                      Icons.storefront_rounded,
                                      color: primaryColor,
                                      size: 32,
                                    ),
                                  )
                                : const Icon(
                                    Icons.storefront_rounded,
                                    color: primaryColor,
                                    size: 32,
                                  ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Store Name & Rating
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      store.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : blackColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 16,
                                    color: Color(0xFF00C853),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                "Official Verified Vendor",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: Color(0xFFFFB300), size: 16),
                                  const SizedBox(width: 3),
                                  Text(
                                    store.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "(${store.reviewsCount} Reviews)",
                                    style: TextStyle(
                                      color: isDark ? Colors.white60 : blackColor60,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Address & Contact info
                    if (store.address != null) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 16, color: primaryColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              store.address!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : blackColor80,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],

                    if (store.contact != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 16, color: primaryColor),
                          const SizedBox(width: 6),
                          Text(
                            store.contact!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : blackColor80,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],

                    // "Select This Store" Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (isSelected) {
                            _storeController.selectStore(null);
                          } else {
                            _storeController.selectStore(store);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: successColor,
                              content: Text(
                                isSelected
                                    ? "Switched back to All Stores"
                                    : "Now shopping exclusively from ${store.name}",
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isSelected ? const Color(0xFF00C853) : primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.shopping_bag_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          isSelected
                              ? "Active Store (Shopping Here)"
                              : "Shop From This Store",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const Divider(height: 32),

                    // Store Products Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Store Products (${storeProducts.length})",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : blackColor,
                          ),
                        ),
                        if (storeProducts.isEmpty)
                          const Text(
                            "Syncing items...",
                            style: TextStyle(
                              fontSize: 12,
                              color: primaryColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Products Grid
            if (storeProducts.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: defaultPadding,
                    crossAxisSpacing: defaultPadding,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = storeProducts[index];
                      final productModel =
                          p.toProductModel(overrideDomain: store.domain);
                      return ProductCard(
                        id: productModel.id,
                        shopId: productModel.shopId,
                        storeDomain: productModel.storeDomain,
                        discountAmount: productModel.discountAmount,
                        variant: productModel.variant,
                        color: productModel.color,
                        choices: productModel.choices,
                        image: productModel.image,
                        brandName: productModel.brandName,
                        title: productModel.title,
                        price: productModel.price,
                        priceAfetDiscount: productModel.priceAfetDiscount,
                        dicountpercent: productModel.dicountpercent,
                        press: () {
                          Navigator.pushNamed(
                            context,
                            productDetailsScreenRoute,
                            arguments: productModel,
                          );
                        },
                      );
                    },
                    childCount: storeProducts.length,
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding * 2),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "No products available from this store yet",
                          style: TextStyle(
                            color: isDark ? Colors.white60 : blackColor60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding * 2),
            ),
          ],
        );
      }),
    );
  }
}
