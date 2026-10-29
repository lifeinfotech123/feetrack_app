import 'package:flutter/material.dart';

import '../../../../constants.dart';
import 'categories.dart';
import 'top_slider_banner_widget.dart';

class OffersCarouselAndCategories extends StatelessWidget {
  const OffersCarouselAndCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Slider Banners (api/v1/ecommerce/top-slider)
        TopSliderBannerWidget(),
        SizedBox(height: defaultPadding / 2),
        Categories(),
      ],
    );
  }
}
