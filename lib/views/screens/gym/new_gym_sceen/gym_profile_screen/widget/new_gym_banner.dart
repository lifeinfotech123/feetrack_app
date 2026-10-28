import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/base/shimmer.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/gym_home/gym_home_screen.dart';

class NewGymProfileBanner extends StatefulWidget {
  const NewGymProfileBanner({
    super.key,
  });

  @override
  State<NewGymProfileBanner> createState() => _GymProfileBannerState();
}

class _GymProfileBannerState extends State<NewGymProfileBanner> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              const SizedBox(height: 10),
              Builder(builder: (context) {
                // if (homeController.selectListingModel?.images?.isEmpty ??
                //     false) {
                //   return const SizedBox.shrink();
                // }
                return CarouselSlider(
                  items: List.generate(
                    homeController.isLoading
                        ? 1
                        : ((homeController.selectListingModel?.images?.isNotEmpty ?? false)
                            ? homeController.selectListingModel!.images!.length
                            : (homeController.selectListingModel?.image != null ? 1 : 0)),
                    (index) => CustomShimmer(
                      isLoading: homeController.isLoading,
                      child: AspectRatio(
                        aspectRatio: 16 / 13,
                        child: CustomImage(
                          // radius: 12,
                          height: MediaQuery.sizeOf(context).height,
                          width: MediaQuery.sizeOf(context).width,
                          path: homeController.isLoading
                              ? ""
                              : (homeController.selectListingModel?.images?.isNotEmpty ?? false)
                                  ? homeController.selectListingModel!.images![index].imagePath ?? ""
                                  : homeController.selectListingModel?.image ?? "",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  options: CarouselOptions(
                    aspectRatio: 16 / 13,
                    viewportFraction: 1.0,
                    autoPlay: true,
                    initialPage: 0,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),

                    // REMOVE THESE
                    enlargeCenterPage: false,
                    // enlargeFactor: 0.4,

                    padEnds: false,
                    clipBehavior: Clip.none,

                    scrollDirection: Axis.horizontal,

                    onPageChanged: (index, reason) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                  ),
                );
              }),
              Positioned.fill(
                  child: CustomImage(
                path: Assets.imagesGymBannerLayer,
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                fit: BoxFit.cover,
              )),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            homeController.selectListingModel?.title ?? "",
                            style:
                                Helper(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 30,
                                      color: white,
                                    ),
                          ),
                        ],
                      ),
                      sizedBoxHeight(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          homeController.isLoading
                              ? 4
                              : ((homeController.selectListingModel?.images?.isNotEmpty ?? false)
                                  ? homeController.selectListingModel!.images!.length
                                  : (homeController.selectListingModel?.image != null ? 1 : 0)),
                          (index) {
                            return CustomShimmer(
                              isLoading: homeController.isLoading,
                              child: BannerIndicatorWidget(
                                isActive: currentIndex == index,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: black.withValues(alpha: 0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        navigate(
                            context: context,
                            isRemoveUntil: true,
                            page: const GymHomeScreen());
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      );
    });
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 36 : 12,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? white : grey,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
