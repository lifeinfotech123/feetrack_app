import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/ecomerce/constants.dart';

import '../../../../components/product/secondary_product_card.dart';
import '../../../../components/skleton/product/secondery_produts_skelton.dart';
import '../../../../controllers/home_screen_api_controller.dart';
import '../../../../route/app_text_constants.dart';

class MostPopular extends StatelessWidget {
  const MostPopular({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeScreenApiController apiController =
        Get.put(HomeScreenApiController());

    return Obx(() {
          if (apiController.isMostPopularLoading.value) {
            return const SeconderyProductsSkelton();
          }

          final products = apiController.mostPopularProducts
              .where((p) => !p.isFood)
              .toList();

          if (products.isEmpty) {
            return const SizedBox.shrink();
          }

          return SizedBox(
            height: 120,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final apiItem = products[index];
                final productModel = apiItem.toProductModel();
                return Padding(
                  padding: EdgeInsets.only(
                    left: defaultPadding,
                    right: index == products.length - 1 ? defaultPadding : 0,
                  ),
                  child: SecondaryProductCard(
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
                    storeName: productModel.storeName,
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
          );
        });
  }
}
