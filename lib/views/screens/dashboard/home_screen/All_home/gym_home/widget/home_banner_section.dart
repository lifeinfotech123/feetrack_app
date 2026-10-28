import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/common_controller.dart';

import '../../../../../../../services/theme.dart';
import '../../../../../../base/custom_image.dart';
import '../../../../../../base/shimmer.dart';

// ignore: must_be_immutable
class HomeBanner extends StatefulWidget {
  const HomeBanner({
    super.key,
  });

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommonController>(
      builder: (commonController) {
        return Column(
          children: [
            CarouselSlider(
              items: List.generate(
                commonController.isLoading
                    ? 1
                    : commonController.bannerModelList.length,
                    (index) {
                  return CustomShimmer(
                    isLoading: commonController.isLoading,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 135,
                          child: CustomImage(
                            radius: 12,
                            path: commonController.isLoading
                                ? ""
                                : commonController
                                .bannerModelList[index].imageUrl ??
                                "",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              options: CarouselOptions(
                height: 150,
                viewportFraction: 1.0,
                autoPlay: true,
                initialPage: 0,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration:
                const Duration(milliseconds: 2000),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: false,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                commonController.isLoading
                    ? 4
                    : commonController.bannerModelList.length,
                    (index) {
                  return CustomShimmer(
                    isLoading: commonController.isLoading,
                    child: BannerIndicatorWidget(
                      isActive: currentIndex == index,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class BannerIndicatorWidget extends StatelessWidget {
  const BannerIndicatorWidget({
    super.key,
    this.isActive = false,
  });
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: isActive ? 12 : 8,
      height: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? primaryColor : grey,
        shape: BoxShape.circle,
      ),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }
}
