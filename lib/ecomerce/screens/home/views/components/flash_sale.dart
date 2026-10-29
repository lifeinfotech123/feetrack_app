import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/Banner/M/banner_m_with_counter.dart';
import '../../../../components/product/product_card.dart';
import '../../../../components/skleton/product/products_skelton.dart';
import '../../../../constants.dart';
import '../../../../controllers/deals_controller.dart';
import '../../../../route/app_text_constants.dart';

class FlashSale extends StatelessWidget {
  const FlashSale({super.key});

  @override
  Widget build(BuildContext context) {
    final DealsController dealsController = Get.put(DealsController());

    return Obx(() {
      if (dealsController.isLoading.value) {
        return const ProductsSkelton();
      }

      final flashDeals = dealsController.flashDeals;
      final dealOfTheDay = dealsController.dealOfTheDay.value;

      final activeDeal = flashDeals.isNotEmpty ? flashDeals.first : null;
      // Filter out food products from the deal for eCommerce home screen
      final dealProducts = activeDeal?.products
              .where((p) => !p.toProductModel().isFood)
              .toList() ??
          [];

      final bool hasDealOfTheDay = dealOfTheDay != null &&
          dealOfTheDay.product != null &&
          !dealOfTheDay.product!.toProductModel().isFood;

      if (dealProducts.isEmpty && !hasDealOfTheDay) {
        return const SizedBox.shrink();
      }

      final seconds = activeDeal?.secondsRemaining ?? 86400;

      final bannerText = activeDeal != null
          ? "${activeDeal.title}\nSpecial Flash Deal"
          : "Exclusive Deals \nLimited Time Offer";

      final bannerImage =
          (activeDeal?.banner != null && activeDeal!.banner!.isNotEmpty)
              ? activeDeal.banner!
              : (hasDealOfTheDay
                  ? dealOfTheDay.product?.thumbnail ?? ''
                  : '');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Live Countdown Banner with API Image & Time
          BannerMWithCounter(
            key: ValueKey(activeDeal?.id ?? 0),
            duration: Duration(seconds: seconds > 0 ? seconds : 3600),
            text: bannerText,
            image: bannerImage,
            press: () {
              Navigator.pushNamed(context, onSaleScreenRoute);
            },
          ),

          const SizedBox(height: defaultPadding / 2),

          // 3. Horizontal Products Slider from Live Flash Deal (Filtered for non-food)
          if (dealProducts.isNotEmpty)
            SizedBox(
              height: 242,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: dealProducts.length,
                itemBuilder: (context, index) {
                  final dealProduct = dealProducts[index];
                  final productModel = dealProduct.toProductModel();

                  return Padding(
                    padding: EdgeInsets.only(
                      left: defaultPadding,
                      right:
                          index == dealProducts.length - 1 ? defaultPadding : 0,
                    ),
                    child: ProductCard(
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
                      storeName:
                          activeDeal?.store?.name ?? productModel.storeName,
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
                    ),
                  );
                },
              ),
            ),

          // 4. Deal of the Day Highlight (Filtered for non-food)
          if (hasDealOfTheDay) ...[
            const SizedBox(height: defaultPadding),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: InkWell(
                onTap: () {
                  final pModel = dealOfTheDay.product!.toProductModel();
                  Navigator.pushNamed(
                    context,
                    productDetailsScreenRoute,
                    arguments: pModel,
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C0A52), Color(0xFF4A148C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: dealOfTheDay.product!.thumbnail != null &&
                                  dealOfTheDay.product!.thumbnail!.isNotEmpty
                              ? Image.network(
                                  dealOfTheDay.product!.thumbnail!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: primaryColor,
                                  ),
                                )
                              : const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: primaryColor,
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "DEAL OF THE DAY",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dealOfTheDay.product!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  "₹${dealOfTheDay.dealPrice.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: Color(0xFF00E676),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "₹${dealOfTheDay.product!.originalPrice.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}
