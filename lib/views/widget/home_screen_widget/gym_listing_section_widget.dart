import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vlr/data/models/category_model/listing_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/widget/home_screen_widget/listing_card_widget.dart';

import '../../../generated/assets.dart';

class GymListingSection extends StatelessWidget {
  final List<ListingModel> gymList;
  final bool isLoading;
  final List<String> fallbackImages;
  final VoidCallback onViewAll;
  final Function(ListingModel) onListingTap;

  const GymListingSection({
    super.key,
    required this.gymList,
    required this.isLoading,
    required this.fallbackImages,
    required this.onViewAll,
    required this.onListingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: "Recommended Gyms",
          icon: Icons.fitness_center_rounded,
          onViewAll: onViewAll,
        ),
        sizedBoxHeight(height: 10),
        SizedBox(
          height: 250.h,
          child: _buildListingList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required VoidCallback onViewAll,
    IconData? icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: primaryColor, size: 20.sp),
              sizedBoxWidth(width: 8.w),
            ],
            Text(
              title,
              style: Helper(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    color: blackText1,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Row(
            children: [
              Text(
                "View All",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Icon(
                Icons.keyboard_arrow_right_rounded,
                color: primaryColor,
                size: 16.sp,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildListingList() {
    if (!isLoading && gymList.isEmpty) {
      return Builder(builder: (context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(Assets.imagesNoGym, height: 100.h),
              sizedBoxHeight(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, color: greyText3, size: 20.sp),
                  sizedBoxWidth(width: 3.w),
                  Text(
                    "Gym Not Found in Your Area",
                    style: Helper(context).textTheme.bodySmall?.copyWith(
                          color: greyText3,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ],
          ),
        );
      });
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: isLoading ? 4 : gymList.length,
      separatorBuilder: (_, __) => sizedBoxWidth(width: 14.w),
      itemBuilder: (context, index) {
        ListingModel listingModel =
            isLoading ? ListingModel() : gymList[index];

        return GestureDetector(
          onTap: () => onListingTap(listingModel),
          child: SizedBox(
            width: 250.w,
            child: ListingCardWidget(
              listingModel: listingModel,
              isLoading: isLoading,
              fallbackImages: fallbackImages,
              imageIndex: index % fallbackImages.length,
              isGym: true,
            ),
          ),
        );
      },
    );
  }
}
