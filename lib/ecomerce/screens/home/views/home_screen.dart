import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'components/best_sellers.dart';
import 'components/flash_sale.dart';
import 'components/home_app_bar_header_widget.dart';
import 'components/most_popular.dart';
import 'components/new_arrivals_widgets.dart';
import 'components/offer_carousel_and_categories.dart';
import 'components/popular_brands.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // 1. App Bar Header with Real Dynamic Location & User Profile
          HomeAppBarHeaderWidget(),

          // 3. Dynamic Banners & Categories
          SliverPadding(
            padding: EdgeInsets.only(top: defaultPadding * 0.75),
            sliver: SliverToBoxAdapter(child: OffersCarouselAndCategories()),
          ),

          // 5. Flash Deals & Deal of the Day (Live API)
          SliverToBoxAdapter(child: FlashSale()),

          // 5. Stores & Vendors Directory from Live API (api/v1/ecommerce/stores)
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
            sliver: SliverToBoxAdapter(child: BestSellers()),
          ),

          // 6. Top Brands from Live API (api/v1/ecommerce/brands)
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
            sliver: SliverToBoxAdapter(child: PopularBrands()),
          ),

          // 7. Dynamic Products Grid from Live API (api/v1/ecommerce/products)
          SliverToBoxAdapter(child: NewArrivalsWidgets()),

          // 8. Dynamic Secondary Products List from Live API
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
            sliver: SliverToBoxAdapter(child: MostPopular()),
          ),
        ],
      ),
    );
  }
}
