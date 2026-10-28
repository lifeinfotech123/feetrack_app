import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/permission_controller.dart';
import 'package:vlr/data/models/gym_city_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/gym/gym_bottom_nav_bar/gym_bottom_nav_bar_screen.dart';

class GymCitySelectorSection extends StatelessWidget {
  final VoidCallback? onRefreshLocation;

  const GymCitySelectorSection({
    super.key,
    this.onRefreshLocation,
  });

  static void showCityPickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            20.w,
            12.h,
            20.w,
            MediaQuery.of(ctx).padding.bottom + 20.h,
          ),
          child: GetBuilder<HomeController>(builder: (homeController) {
            final cities = homeController.gymCityList;
            final selected = homeController.selectedGymCity;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Gym City",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: blackText1,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  "Choose a city to explore gyms and fitness centers",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: greyText3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16.h),

                // All Cities Option
                InkWell(
                  onTap: () {
                    homeController.filterGymsByCity(null);
                    Navigator.of(ctx).pop();
                  },
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: selected == null
                          ? primaryColor.withValues(alpha: 0.08)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: selected == null
                            ? primaryColor
                            : Colors.grey.shade200,
                        width: selected == null ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: selected == null
                                ? primaryColor
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_city_rounded,
                            size: 18.sp,
                            color: selected == null ? Colors.white : greyText3,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "All Cities",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: selected == null
                                      ? primaryColor
                                      : blackText1,
                                ),
                              ),
                              Text(
                                "View gyms across all locations",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: greyText3,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected == null)
                          Icon(
                            Icons.check_circle_rounded,
                            color: primaryColor,
                            size: 20.sp,
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                if (homeController.isGymCitiesLoading)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                else if (cities.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Center(
                      child: Text(
                        "No cities found",
                        style: TextStyle(color: greyText3, fontSize: 13.sp),
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 280.h),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: cities.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (context, index) {
                        final cityModel = cities[index];
                        final isSelected = selected?.city.toLowerCase() ==
                            cityModel.city.toLowerCase();

                        return InkWell(
                          onTap: () {
                            homeController.filterGymsByCity(cityModel);
                            Navigator.of(ctx).pop();
                          },
                          borderRadius: BorderRadius.circular(14.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withValues(alpha: 0.08)
                                  : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey.shade200,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.place_rounded,
                                    size: 18.sp,
                                    color: isSelected
                                        ? Colors.white
                                        : greyText3,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cityModel.city,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? primaryColor
                                              : blackText1,
                                        ),
                                      ),
                                      Text(
                                        "${cityModel.gymsCount} Gym${cityModel.gymsCount > 1 ? 's' : ''} available",
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: isSelected
                                              ? primaryColor
                                                  .withValues(alpha: 0.8)
                                              : greyText3,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: primaryColor,
                                    size: 20.sp,
                                  )
                                else
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius:
                                          BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      "${cityModel.gymsCount}",
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: greyText3,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      final cities = homeController.gymCityList;
      final selectedCity = homeController.selectedGymCity;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Top Location & City Dropdown Bar ────────────────────────
          Row(
            children: [
              // Current GPS / Address Pill
              Expanded(
                child: GetBuilder<PermissionController>(
                  builder: (permissionController) {
                    final address = selectedCity != null
                        ? "${selectedCity.city}, UP"
                        : (permissionController.address ??
                            (permissionController.locationFetched
                                ? "Location Found"
                                : "Select Location"));

                    return InkWell(
                      onTap: onRefreshLocation ??
                          () => showCityPickerBottomSheet(context),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: primaryColor,
                              size: 18,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                address,
                                style: Helper(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: blackText1,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: greyText3,
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 8.w),

              // City Dropdown Button
              InkWell(
                onTap: () => showCityPickerBottomSheet(context),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: selectedCity != null
                        ? primaryColor.withValues(alpha: 0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: selectedCity != null
                          ? primaryColor
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.apartment_rounded,
                        color: selectedCity != null ? primaryColor : greyText3,
                        size: 15.sp,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        selectedCity != null ? selectedCity.city : "City",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: selectedCity != null
                              ? primaryColor
                              : const Color(0xFF333333),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color: selectedCity != null ? primaryColor : greyText3,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // My Bookings Shortcut
              InkWell(
                onTap: () {
                  Get.to(() => const GymBottomNavBarScreen(initialIndex: 1));
                },
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF002060).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: const Color(0xFF002060).withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bookmark_added_rounded,
                        color: const Color(0xFF002060),
                        size: 15.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "Bookings",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF002060),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // ── 2. Horizontal City Filter Chips (Starting Strip) ───────────
          if (cities.isNotEmpty) ...[
            SizedBox(
              height: 36.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cities.length + 1, // +1 for "All Cities"
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final isAll = index == 0;
                  final GymCityModel? city =
                      isAll ? null : cities[index - 1];

                  final isSelected = isAll
                      ? selectedCity == null
                      : (selectedCity?.city.toLowerCase() ==
                          city?.city.toLowerCase());

                  final label = isAll ? "All Cities" : city!.city;
                  final count = isAll ? null : city!.gymsCount;

                  return InkWell(
                    onTap: () {
                      homeController.filterGymsByCity(city);
                    },
                    borderRadius: BorderRadius.circular(18.r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: isSelected
                              ? primaryColor
                              : Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? primaryColor.withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAll
                                ? Icons.explore_rounded
                                : Icons.place_rounded,
                            size: 13.sp,
                            color: isSelected ? Colors.white : greyText3,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF333333),
                            ),
                          ),
                          if (count != null) ...[
                            SizedBox(width: 5.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                "$count",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : greyText3,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ],
      );
    });
  }
}
