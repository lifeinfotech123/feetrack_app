import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/data/models/category_model/listing_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/gym_home/widget/gym_home_details_screen.dart';

class GymHomeNearbySection extends StatelessWidget {
  const GymHomeNearbySection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sizedBoxHeight(height: 24),
        GetBuilder<HomeController>(builder: (homeController) {
          final gyms = homeController.displayedGymList;
          final count = gyms.length;
          final categoryName =
              homeController.selectCategoryModel?.name ?? "Gym";

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.fitness_center_rounded,
                            color: primaryColor,
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            homeController.selectedGymCity != null
                                ? "Gyms in ${homeController.selectedGymCity!.city}"
                                : "Nearby ${capitalize(categoryName)}s",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Helper(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w800,
                                      color: blackText1,
                                    ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      homeController.selectedGymCity != null
                          ? "Showing fitness sanctuaries in ${homeController.selectedGymCity!.city}"
                          : "Explore top-rated fitness centers near you",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: greyText3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!homeController.isGymLoading && count > 0)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "$count Found",
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
            ],
          );
        }),
        sizedBoxHeight(height: 18),
        GetBuilder<HomeController>(builder: (homeController) {
          final gyms = homeController.displayedGymList;
          final bool isListLoading = homeController.isGymLoading;
          final int itemCount = isListLoading ? 4 : gyms.length;

          if (!isListLoading && gyms.isEmpty) {
            final activeCity = homeController.selectedGymCity?.city;
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fitness_center_outlined,
                        size: 42.sp,
                        color: greyText3,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      activeCity != null
                          ? "No Gyms Found in $activeCity"
                          : "No Gyms Found Nearby",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: blackText1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Try selecting a different city or clearing the filter",
                      style: TextStyle(color: greyText3, fontSize: 12.sp),
                    ),
                    if (activeCity != null) ...[
                      SizedBox(height: 14.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          homeController.filterGymsByCity(null);
                        },
                        icon: const Icon(Icons.explore_rounded,
                            color: Colors.white, size: 16),
                        label: const Text(
                          "Show All Cities",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 14.w,
              mainAxisExtent: 285.h,
            ),
            itemBuilder: (context, index) {
              final ListingModel listingModel =
                  isListLoading ? ListingModel() : gyms[index];

              return _buildNearbyGridCard(
                context: context,
                listingModel: listingModel,
                isLoading: isListLoading,
                index: index,
                onTap: () {
                  if (isListLoading) return;

                  homeController.updateSelectListingModel(
                    value: listingModel,
                  );

                  navigate(
                    context: context,
                    page: GymHomeDetailsScreen(listingId: listingModel.id),
                  );
                },
              );
            },
          );
        }),
        sizedBoxHeight(height: 20),
      ],
    );
  }

  Widget _buildNearbyGridCard({
    required BuildContext context,
    required ListingModel listingModel,
    required bool isLoading,
    required int index,
    required VoidCallback onTap,
  }) {
    if (isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 135.h,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 70.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: 60.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }

    final String imagePath = (listingModel.images?.isNotEmpty ?? false)
        ? listingModel.images!.first.imagePath ?? listingModel.image ?? ""
        : listingModel.image ?? "";

    final String? displayPrice =
        (listingModel.startingPrice != null && listingModel.startingPrice! > 0)
            ? "₹${listingModel.startingPrice}"
            : (listingModel.packagesMinPrice != null &&
                    listingModel.packagesMinPrice!.isNotEmpty
                ? (listingModel.packagesMinPrice!.startsWith("₹")
                    ? listingModel.packagesMinPrice!
                    : "₹${listingModel.packagesMinPrice}")
                : null);

    final double? avgRating = listingModel.rating?.average ??
        (listingModel.reviewsAvgRating != null
            ? double.tryParse(listingModel.reviewsAvgRating!)
            : null);
    final String ratingText = (avgRating != null && avgRating > 0)
        ? avgRating.toStringAsFixed(1)
        : "4.5";

    final String genderText = listingModel.genderType?.isNotEmpty == true
        ? listingModel.genderType!
        : "Unisex";

    final String titleText = listingModel.title?.isNotEmpty == true
        ? listingModel.title!
        : 'Fitness Sanctuary';

    final String addressText = listingModel.address?.isNotEmpty == true
        ? listingModel.address!
        : (listingModel.landmark?.isNotEmpty == true
            ? listingModel.landmark!
            : 'Central Area');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              )
            ],
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container with overlays
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18.r),
                    ),
                    child: CustomImage(
                      path: imagePath,
                      width: double.infinity,
                      height: 135.h,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Subtle bottom gradient for image clarity
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18.r),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.35),
                          ],
                          stops: const [0.65, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Top Left: Gender / Unisex pill
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 7.w, vertical: 3.5.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fitness_center_rounded,
                            size: 11.sp,
                            color: primaryColor,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            genderText,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top Right: Rating badge
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 7.w, vertical: 3.5.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber.shade700,
                            size: 14.sp,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            ratingText,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w800,
                              color: blackText1,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  // Bottom Left on Image: Verified indicator if verified
                  if (listingModel.isVerified == true)
                    Positioned(
                      bottom: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.5.h),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 10.sp),
                            SizedBox(width: 3.w),
                            Text(
                              "Verified",
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Content & Typography Details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gym Title (Enhanced & Larger font)
                      Text(
                        titleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: blackText1,
                        ),
                      ),
                      SizedBox(height: 5.h),

                      // Location / Address (Larger & clearer)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 13.sp,
                            color: primaryColor,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              addressText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: greyText3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),

                      // Distance or Timings
                      Row(
                        children: [
                          if (listingModel.effectiveDistanceKm != null) ...[
                            Icon(
                              Icons.directions_walk_rounded,
                              size: 13.sp,
                              color: Colors.blue.shade700,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              "${listingModel.effectiveDistanceKm?.toStringAsFixed(1)} km",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 6.w),
                          ],
                          Container(
                            width: 6.w,
                            height: 6.h,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              listingModel.openingTime != null
                                  ? "Open ${listingModel.openingTime}"
                                  : "Open Now",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Bottom Row: Price & Navigation Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (displayPrice != null) ...[
                                  Text(
                                    "Starts from",
                                    style: TextStyle(
                                      fontSize: 9.5.sp,
                                      color: greyText3,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    displayPrice,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15.5.sp,
                                      fontWeight: FontWeight.w900,
                                      color: primaryColor,
                                      height: 1.15,
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    "Explore",
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            width: 30.w,
                            height: 30.h,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(9.r),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 15.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
