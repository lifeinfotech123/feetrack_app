import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/skleton/product/products_skelton.dart';
import '../../../../constants.dart';
import '../../../../controllers/home_screen_api_controller.dart';
import '../../../../models/store_model.dart';
import '../../../store/views/store_detail_screen.dart';

class BestSellers extends StatelessWidget {
  const BestSellers({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final HomeScreenApiController apiController =
        Get.put(HomeScreenApiController());

    return Obx(() {
          if (apiController.isTopSellersLoading.value) {
            return const ProductsSkelton();
          }

          final sellers = apiController.topSellers;

          if (sellers.isNotEmpty) {
            return SizedBox(
              height: 130,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                itemCount: sellers.length,
                itemBuilder: (context, index) {
                  final seller = sellers[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () {
                        final store = StoreModel(
                          id: seller.id,
                          shopId: seller.sellerId,
                          name: seller.name,
                          slug: seller.slug,
                          logo: seller.logo,
                          banner: seller.banner,
                          rating: seller.rating ?? 4.8,
                          totalProducts: seller.productsCount ?? 0,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StoreDetailScreen(store: store),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 140,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? darkGreyColor : lightGreyColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white12 : blackColor10,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.3 : 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border:
                                    Border.all(color: primaryColor, width: 1.5),
                              ),
                              child: ClipOval(
                                child: seller.logo != null &&
                                        seller.logo!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: seller.logo!,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => const Icon(
                                          Icons.storefront_rounded,
                                          color: primaryColor,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.storefront_rounded,
                                        color: primaryColor,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              seller.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : blackColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${seller.productsCount ?? 0} Products",
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white54 : blackColor60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        });
  }
}
