import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../components/Banner/M/banner_m_with_counter.dart';
import '../../../components/product/product_card.dart';
import '../../../components/skleton/product/products_skelton.dart';
import '../../../constants.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/deals_controller.dart';
import '../../../models/product_model.dart';
import '../../../route/route_constants.dart';

class OnSaleScreen extends StatelessWidget {
  const OnSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DealsController dealsController = Get.put(DealsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Flash Deals & Offers",
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
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          "${cart.totalItemCount}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
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
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (dealsController.isLoading.value) {
          return const SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: Column(
                children: [
                  ProductsSkelton(),
                  SizedBox(height: 16),
                  ProductsSkelton(),
                ],
              ),
            ),
          );
        }

        final flashDeals = dealsController.flashDeals;
        final dealOfTheDay = dealsController.dealOfTheDay.value;

        // Collect all products from all flash deals
        final List<ProductModel> allDealProducts = [];
        for (var deal in flashDeals) {
          for (var p in deal.products) {
            allDealProducts.add(p.toProductModel());
          }
        }

        final activeDeal = flashDeals.isNotEmpty ? flashDeals.first : null;
        final seconds = activeDeal?.secondsRemaining ?? 86400;

        return RefreshIndicator(
          onRefresh: () => dealsController.fetchAllDeals(),
          color: primaryColor,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // 1. Live Countdown Banner
              if (activeDeal != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      defaultPadding,
                      defaultPadding / 2,
                      defaultPadding,
                      defaultPadding,
                    ),
                    child: BannerMWithCounter(
                      key: ValueKey(activeDeal.id),
                      duration: Duration(seconds: seconds > 0 ? seconds : 3600),
                      text: "${activeDeal.title}\nSpecial Flash Deal",
                      image: activeDeal.banner ?? productDemoImg1,
                      press: () {},
                    ),
                  ),
                ),

              // 2. Deal of the Day Highlight Banner
              if (dealOfTheDay != null && dealOfTheDay.product != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                      vertical: 6,
                    ),
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
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A237E), Color(0xFF311B92)],
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
                              height: 74,
                              width: 74,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: dealOfTheDay.product!.thumbnail != null &&
                                        dealOfTheDay
                                            .product!.thumbnail!.isNotEmpty
                                    ? Image.network(
                                        dealOfTheDay.product!.thumbnail!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.local_offer_rounded,
                                          color: primaryColor,
                                        ),
                                      )

                                    : const Icon(
                                        Icons.local_offer_rounded,
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
                                        horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFB300),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "DEAL OF THE DAY",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    dealOfTheDay.product!.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5,
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
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "₹${dealOfTheDay.product!.originalPrice.toStringAsFixed(0)}",
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12.5,
                                          decoration:
                                              TextDecoration.lineThrough,
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
                ),

              // 3. Section Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    defaultPadding,
                    defaultPadding,
                    defaultPadding,
                    defaultPadding / 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "All Deals (${allDealProducts.length} Items)",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                      ),
                      const Text(
                        "Up to 50% Off",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Products Grid
              if (allDealProducts.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200.0,
                      mainAxisSpacing: defaultPadding,
                      crossAxisSpacing: defaultPadding,
                      childAspectRatio: 0.64,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final product = allDealProducts[index];
                        return ProductCard(
                          id: product.id,
                          shopId: product.shopId,
                          storeDomain: product.storeDomain,
                          discountAmount: product.discountAmount,
                          variant: product.variant,
                          color: product.color,
                          choices: product.choices,
                          image: product.image,
                          brandName: product.brandName,
                          title: product.title,
                          price: product.price,
                          priceAfetDiscount: product.priceAfetDiscount,
                          dicountpercent: product.dicountpercent,
                          storeName: product.storeName,
                          press: () {
                            Navigator.pushNamed(
                              context,
                              productDetailsScreenRoute,
                              arguments: product,
                            );
                          },
                        );
                      },
                      childCount: allDealProducts.length,
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
                          Icon(Icons.local_offer_outlined,
                              size: 48,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          const Text(
                            "No active flash deals at the moment",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Check back soon for exciting limited-time discounts!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: greyColor, fontSize: 12),
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
          ),
        );
      }),
    );
  }
}
