import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/data/models/category_model/facilities_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/shimmer.dart';
import 'package:vlr/views/screens/gym/gym_profile/widget/gym_med_section/gym_profile_facilities_widget.dart';

class GYMprofileAboutAndFacilitiesSection extends StatefulWidget {
  const GYMprofileAboutAndFacilitiesSection({
    super.key,
  });

  @override
  State<GYMprofileAboutAndFacilitiesSection> createState() =>
      _GYMprofileAboutAndFacilitiesSectionState();
}

class _GYMprofileAboutAndFacilitiesSectionState
    extends State<GYMprofileAboutAndFacilitiesSection> {
  bool isExpanded = false;

  // final String aboutText =
  //     "Iron Haven Elite is more than just a gym. We provide a curated fitness experience with state-of-the-art Italian equipment, Olympic-standard lifting zones, and recovery suites that rival top-tier spas. Our philosophy is built on performance and luxury.  Iron Haven Elite is more than just a gym. We provide a curated fitness experience with state-of-the-art Italian equipment, Olympic-standard lifting zones, and recovery suites that rival top-tier spas. Our philosophy is built on performance and luxury.";

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final textStyle = Helper(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: greyText2,
              );

          final aboutText = (homeController.selectListingModel?.about != null &&
                  homeController.selectListingModel!.about!.isNotEmpty)
              ? homeController.selectListingModel!.about!
              : homeController.selectListingModel?.description ?? "";

          final textPainter = TextPainter(
            text: TextSpan(
              text: aboutText,
              style: textStyle,
            ),
            // maxLines: 6,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth);

          final isTextOverflowing = textPainter.didExceedMaxLines;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sizedBoxHeight(height: 40),
              Text(
                "About",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: blackText1,
                    ),
              ),
              sizedBoxHeight(height: 7.5),
              Text(
                aboutText,
                maxLines: isExpanded ? null : 6,
                overflow:
                    isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: textStyle,
              ),
              if (isTextOverflowing) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Text(
                    isExpanded ? "Read less" : "Read more",
                    style: Helper(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                  ),
                ),
              ],
              sizedBoxHeight(height: 40),
              Text(
                "Facilities",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: blackText1,
                    ),
              ),
              sizedBoxHeight(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(
                  homeController.isFacilitiesLoading
                      ? 4
                      : homeController.facilityList.length,
                  (index) {
                    final facilitiesModel = homeController.isFacilitiesLoading
                        ? FacilityModel()
                        : homeController.facilityList[index];

                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 44) / 2,
                      child: CustomShimmer(
                        isLoading: homeController.isFacilitiesLoading,
                        child: GYMProfileFacilitesWidget(
                          facilitiesModel: facilitiesModel,
                        ),
                      ),
                    );
                  },
                ),
              )
              //
            ],
          );
        },
      );
    });
  }
}
