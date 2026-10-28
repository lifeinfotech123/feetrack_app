import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/generated/assets.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class SelectRoomProfileWidget extends StatelessWidget {
  const SelectRoomProfileWidget({super.key});

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
            final price = listing?.startingPrice ?? 7000;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: white,
                border: Border.all(width: 1, color: greyLight3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imagePath.isNotEmpty
                        ? Image.network(
                            imagePath,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const CustomImage(
                              path: Assets.imagesPgRoom,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              radius: 12,
                            ),
                          )
                        : const CustomImage(
                            path: Assets.imagesPgRoom,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            radius: 12,
                          ),
                  ),
                  sizedBoxWidth(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Helper(context).textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: blackText1,
                              ),
                        ),
                        sizedBoxHeight(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: Color(0xFF2563EB),
                            ),
                            sizedBoxWidth(width: 4),
                            Expanded(
                              child: Text(
                                address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Helper(context).textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: greyDart2,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        sizedBoxHeight(height: 6),
                        Text(
                          "$price / month",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
