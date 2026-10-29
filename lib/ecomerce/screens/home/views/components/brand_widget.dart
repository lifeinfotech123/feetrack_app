import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../components/skleton/skelton.dart';
import '../../../../constants.dart';
import '../../../../controllers/brand_crontoller.dart';
import '../../../../models/brand_model.dart';
import '../../../../route/app_text_constants.dart';

class BrandWidget extends StatelessWidget {
  const BrandWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final BrandCrontoller controller = Get.put(BrandCrontoller());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
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
                      Icons.storefront_rounded,
                      color: primaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Brands",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, brandScreenRoute);
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

        // Brand Content Area
        Obx(() {
          if (controller.isLoading.value) {
            return const BrandWidgetSkeleton();
          }

          if (controller.brands.isEmpty) {
            if (controller.errorMessage.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        controller.errorMessage.value,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => controller.fetchBrands(),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          }

          return SizedBox(
            height: 110,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              itemCount: controller.brands.length,
              itemBuilder: (context, index) {
                final brand = controller.brands[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: BrandCard(brand: brand),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}

class BrandCard extends StatelessWidget {
  final BrandModel brand;

  const BrandCard({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        if (brand.slug != null && brand.slug!.isNotEmpty) {
          Navigator.pushNamed(context, brandScreenRoute, arguments: brand.slug);
        } else {
          Navigator.pushNamed(context, onSaleScreenRoute);
        }
      },
      borderRadius: BorderRadius.circular(defaultBorderRadious),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? darkGreyColor : lightGreyColor,
          borderRadius: BorderRadius.circular(defaultBorderRadious),
          border: Border.all(
            color: isDark ? Colors.white12 : blackColor10,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Brand Logo / Image
            SizedBox(
              height: 42,
              width: 42,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: brand.image != null && brand.image!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: brand.image!,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Skeleton(),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.verified_rounded,
                          size: 24,
                          color: primaryColor,
                        ),
                      )
                    : const Icon(
                        Icons.verified_rounded,
                        size: 24,
                        color: primaryColor,
                      ),
              ),
            ),
            const SizedBox(height: 8),

            // Brand Name
            Text(
              brand.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : blackColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            if (brand.productsCount != null) ...[
              const SizedBox(height: 2),
              Text(
                "${brand.productsCount} ${brand.productsCount == 1 ? 'item' : 'items'}",
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white54 : blackColor40,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BrandWidgetSkeleton extends StatelessWidget {
  const BrandWidgetSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        itemCount: 5,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Skeleton(
              height: 110,
              width: 100,
              radious: defaultBorderRadious,
            ),
          );
        },
      ),
    );
  }
}
