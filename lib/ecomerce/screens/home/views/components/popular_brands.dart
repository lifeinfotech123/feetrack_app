import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/network_image_with_loader.dart';
import '../../../../components/skleton/skelton.dart';
import '../../../../constants.dart';
import '../../../../controllers/home_screen_api_controller.dart';
import '../../../../route/app_text_constants.dart';

class PopularBrandModel {
  final String name;
  final String image;
  final String offer;
  final String category;

  const PopularBrandModel({
    required this.name,
    required this.image,
    required this.offer,
    required this.category,
  });
}

const List<PopularBrandModel> demoPopularBrands = [
  PopularBrandModel(
    name: "Nike",
    image:
        "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=85",
    offer: "UP TO 40% OFF",
    category: "Footwear & Sports",
  ),
  PopularBrandModel(
    name: "Zara",
    image:
        "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=800&q=85",
    offer: "MIN 30% OFF",
    category: "Trendy Fashion",
  ),
  PopularBrandModel(
    name: "Adidas",
    image:
        "https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?auto=format&fit=crop&w=800&q=85",
    offer: "FLAT 25% OFF",
    category: "Originals & Sports",
  ),
  PopularBrandModel(
    name: "Levi's",
    image:
        "https://images.unsplash.com/photo-1582552938357-32b906df40cb?auto=format&fit=crop&w=800&q=85",
    offer: "UP TO 50% OFF",
    category: "Denim & Casuals",
  ),
  PopularBrandModel(
    name: "H&M",
    image:
        "https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?auto=format&fit=crop&w=800&q=85",
    offer: "STARTING ₹499",
    category: "Everyday Wear",
  ),
  PopularBrandModel(
    name: "Puma",
    image:
        "https://images.unsplash.com/photo-1608231387042-66d1773070a5?auto=format&fit=crop&w=800&q=85",
    offer: "FLAT 35% OFF",
    category: "Athletic & Running",
  ),
];

class PopularBrands extends StatelessWidget {
  const PopularBrands({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final HomeScreenApiController apiController =
        Get.put(HomeScreenApiController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: defaultPadding / 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
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
                  const SizedBox(width: 8),
                  Text(
                    "Top Brands",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PopularBrands(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        "See All",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 2),
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
        ),
        const SizedBox(height: defaultPadding / 3),

        // Horizontal Slider of Brand Cards
        Obx(() {
          if (apiController.isTopBrandsLoading.value) {
            return SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                itemCount: 5,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Skeleton(
                    height: 160,
                    width: 145,
                    radious: 16,
                  ),
                ),
              ),
            );
          }

          final brands = apiController.topBrands;
          if (brands.isEmpty) {
            return const SizedBox.shrink();
          }

          return SizedBox(
            height: 160,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                final String brandName = brand.name;
                final String? brandImage = brand.image;
                final String brandSlug = brand.slug ?? brandName.toLowerCase();
                final String subtitle = "${brand.productsCount ?? 0} Products";
                final String badgeText =
                    brand.storesCount != null && brand.storesCount! > 0
                        ? "${brand.storesCount} Stores"
                        : "OFFICIAL";

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        brandScreenRoute,
                        arguments: brandSlug,
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 145,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.35 : 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            // 1. HD Background Image
                            Positioned.fill(
                              child: NetworkImageWithLoader(
                                brandImage ?? "",
                                radius: 16,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // 2. Gradient Overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.3),
                                      Colors.black.withValues(alpha: 0.88),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: const [0.2, 0.55, 1.0],
                                  ),
                                ),
                              ),
                            ),

                            // 3. Top Offer Badge
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          primaryColor.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  badgeText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ),

                            // 4. Bottom Brand Details
                            Positioned(
                              bottom: 10,
                              left: 10,
                              right: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          brandName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.verified_rounded,
                                        color: primaryColor,
                                        size: 13,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.85),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
