import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants.dart';
import '../../../controllers/deals_controller.dart';
import '../../../controllers/home_screen_api_controller.dart';
import '../../../route/app_text_constants.dart';
import '../../product/views/all_products_screen.dart';
import '../../store/views/all_stores_screen.dart';
import 'all_brands_screen.dart';
import 'components/best_sellers.dart';
import 'components/categories.dart';
import 'components/flash_sale.dart';
import 'components/home_app_bar_header_widget.dart';
import 'components/most_popular.dart';
import 'components/new_arrivals_widgets.dart';
import 'components/popular_brands.dart';
import 'components/top_slider_banner_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeScreenApiController apiController =
        Get.put(HomeScreenApiController());
    final DealsController dealsController = Get.put(DealsController());

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. App Bar Header with Real Dynamic Location & User Profile
          const HomeAppBarHeaderWidget(),

          // 2. Top Slider Banners & Categories
          SliverPadding(
            padding: const EdgeInsets.only(top: defaultPadding * 0.75),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TopSliderBannerWidget(),
                  const SizedBox(height: defaultPadding / 2),
                  HomeSectionHeader(
                    title: "Categories",
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: primaryColor,
                        size: 18,
                      ),
                    ),
                    onSeeAll: () {
                      Navigator.pushNamed(context, discoverScreenRoute);
                    },
                  ),
                  const Categories(),
                ],
              ),
            ),
          ),

          // 3. Flash Deals & Deal of the Day (Live API)
          SliverToBoxAdapter(
            child: Obx(() {
              final flashDeals = dealsController.flashDeals;
              final dotd = dealsController.dealOfTheDay.value;
              final bool hasDeals = flashDeals.any((d) =>
                      d.products.any((p) => !p.toProductModel().isFood)) ||
                  (dotd != null &&
                      dotd.product != null &&
                      !dotd.product!.toProductModel().isFood);

              if (!hasDeals && !dealsController.isLoading.value) {
                return const SizedBox.shrink();
              }

              final activeDeal =
                  flashDeals.isNotEmpty ? flashDeals.first : null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeSectionHeader(
                    title: activeDeal?.title ?? "Flash Deals",
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Color(0xFFFF5252),
                        size: 18,
                      ),
                    ),
                    onSeeAll: () {
                      Navigator.pushNamed(context, onSaleScreenRoute);
                    },
                  ),
                  const FlashSale(),
                ],
              );
            }),
          ),

          // 4. Stores & Vendors Directory from Live API (api/v1/ecommerce/stores)
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.5),
            sliver: SliverToBoxAdapter(
              child: Obx(() {
                if (apiController.topSellers.isEmpty &&
                    !apiController.isTopSellersLoading.value) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeSectionHeader(
                      title: "Stores & Vendors",
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFFB300).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: Color(0xFFFF8F00),
                          size: 18,
                        ),
                      ),
                      onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllStoresScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    const BestSellers(),
                  ],
                );
              }),
            ),
          ),

          // 5. Top Brands from Live API (api/v1/ecommerce/brands)
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.5),
            sliver: SliverToBoxAdapter(
              child: Obx(() {
                if (apiController.topBrands.isEmpty &&
                    !apiController.isTopBrandsLoading.value) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeSectionHeader(
                      title: "Top Brands",
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: primaryColor,
                          size: 18,
                        ),
                      ),
                      onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllBrandsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: defaultPadding / 3),
                    const PopularBrands(),
                  ],
                );
              }),
            ),
          ),

          // 6. Dynamic Products Grid from Live API (api/v1/ecommerce/products)
          SliverToBoxAdapter(
            child: Obx(() {
              final products = apiController.newArrivalsProducts
                  .where((p) => !p.isFood)
                  .toList();
              if (products.isEmpty &&
                  !apiController.isNewArrivalsLoading.value) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeSectionHeader(
                    title: "New Arrivals",
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.new_releases_rounded,
                        color: primaryColor,
                        size: 18,
                      ),
                    ),
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllProductsScreen(
                            title: "New Arrivals",
                            type: ProductSectionType.newArrivals,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  const NewArrivalsWidgets(),
                ],
              );
            }),
          ),

          // 7. Dynamic Secondary Products List from Live API
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
            sliver: SliverToBoxAdapter(
              child: Obx(() {
                final products = apiController.mostPopularProducts
                    .where((p) => !p.isFood)
                    .toList();
                if (products.isEmpty &&
                    !apiController.isMostPopularLoading.value) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeSectionHeader(
                      title: "Most Popular",
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF00B0FF).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF00B0FF),
                          size: 18,
                        ),
                      ),
                      onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllProductsScreen(
                              title: "Most Popular",
                              type: ProductSectionType.mostPopular,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    const MostPopular(),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable Section Header with Title and Working See All Action
class HomeSectionHeader extends StatelessWidget {
  final String title;
  final Widget? icon;
  final VoidCallback? onSeeAll;
  final bool showSeeAll;

  const HomeSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.onSeeAll,
    this.showSeeAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
              ),
            ],
          ),
          if (showSeeAll && onSeeAll != null)
            InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      "See All",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: primaryColor,
                      size: 11,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
