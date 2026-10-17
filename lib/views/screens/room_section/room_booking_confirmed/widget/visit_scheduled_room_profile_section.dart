import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/common_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class VisitScheduleRoomProfile extends StatelessWidget {
  const VisitScheduleRoomProfile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoomController>(
      builder: (roomController) {
        return GetBuilder<HomeController>(
          builder: (homeController) {
            final listing = roomController.selectedListingDetails ??
                homeController.selectListingModel;
            final imagePath = (listing?.images?.isNotEmpty ?? false)
                ? listing!.images!.first.url ??
                    listing.images!.first.imagePath ??
                    listing.image ??
                    ""
                : listing?.image ?? "";
            final title = listing?.title ?? "PG Accommodation";
            final address = listing?.landmark ??
                listing?.address ??
                listing?.city ??
                "Verified Stay";
            final gender = listing?.genderType ?? "PG Accommodation";

            return Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: white,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                    spreadRadius: 0,
                    color: black.withValues(alpha: 0.05),
                  )
                ],
                border: Border.all(
                  width: 1,
                  color: greyLight6,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      imagePath.isNotEmpty
                          ? Image.network(
                              imagePath,
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height / 3.5,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => CustomImage(
                                path: Assets.imagesPgRoom,
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height / 3.5,
                                fit: BoxFit.cover,
                              ),
                            )
                          : CustomImage(
                              path: Assets.imagesPgRoom,
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height / 3.5,
                              fit: BoxFit.cover,
                            ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: white.withValues(alpha: 0.92),
                          ),
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Helper(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: blackText3,
                                ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: primaryColor.withValues(alpha: 0.10),
                              ),
                              child: Icon(
                                Icons.location_on_outlined,
                                color: blueLight3,
                              ),
                            ),
                            sizedBoxWidth(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Location",
                                    style: Helper(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 13,
                                          color: greyDart2,
                                        ),
                                  ),
                                  Text(
                                    address,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Helper(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: blackText3,
                                        ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        GetBuilder<CommonController>(
                          builder: (commonController) {
                            return Column(
                              children: [
                                sizedBoxHeight(height: 20),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: primaryColor.withValues(alpha: 0.10),
                                      ),
                                      child: Icon(
                                        Icons.home_work_rounded,
                                        color: blueLight3,
                                      ),
                                    ),
                                    sizedBoxWidth(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Stay Type",
                                            style: Helper(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 13,
                                                  color: greyDart2,
                                                ),
                                          ),
                                          Text(
                                            capitalize(gender),
                                            style: Helper(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color: blackText3,
                                                ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
