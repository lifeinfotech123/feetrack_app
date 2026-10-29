import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/product/product_card.dart';
import '../../../../components/skleton/product/product_card_skelton.dart';
import '../../../../constants.dart';
import '../../../../controllers/home_screen_api_controller.dart';
import '../../../../route/app_text_constants.dart';

class NewArrivalsWidgets extends StatelessWidget {
  const NewArrivalsWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeScreenApiController apiController =
        Get.put(HomeScreenApiController());

    return Obx(() {
          if (apiController.isNewArrivalsLoading.value) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) => const ProductCardSkelton(),
              ),
            );
          }

          final products = apiController.newArrivalsProducts
              .where((p) => !p.isFood)
              .toList();

          if (products.isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final apiItem = products[index];
                final productModel = apiItem.toProductModel();
                return ProductCard(
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
                  storeName: productModel.storeName,
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
                );
              },
            ),
          );
        });
  }
}
