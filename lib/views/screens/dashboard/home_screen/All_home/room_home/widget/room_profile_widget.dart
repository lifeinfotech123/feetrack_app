import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/room_home/widget/facility_container_widget.dart';

import 'package:vlr/data/models/category_model/room_detail_model.dart';


class RoomProfileWidget extends StatelessWidget {
  final RoomDetailModel? roomDetail;
  final bool isSelected;
  final VoidCallback? onTap;
  final double? width;
  const RoomProfileWidget({
    super.key,
    this.roomDetail,
    this.isSelected = false,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 280,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? Border.all(color: primaryColor, width: 2) : null,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 8),
              blurRadius: 24,
              color: black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  CustomImage(
                    path: roomDetail != null ? Assets.imagesPgRoom : Assets.imagesGymBanner2,
                    width: width ?? 280,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                  // Bottom Gradient Scrim for readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Room Info Overlay
                  Positioned(
                    bottom: 8,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            roomDetail != null
                                ? "Room ${roomDetail!.roomNumber ?? ''} (${roomDetail!.roomType ?? ''})"
                                : "Green Valley 1BHK",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Helper(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, size: 10, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                "4.8",
                                style: Helper(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GetBuilder<RoomController>(builder: (roomController) {
                      return GestureDetector(
                        onTap: () {
                          roomController.isAddFavorite = !roomController.isAddFavorite;
                          roomController.update();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            roomController.isAddFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: redDark,
                          ),
                        ),
                      );
                    }),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: white, size: 10),
                            const SizedBox(width: 4),
                            Text(
                              "Selected",
                              style: Helper(context).textTheme.bodySmall?.copyWith(
                                    color: white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 8,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: primaryColor, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            roomDetail != null
                                ? "Dep: ₹${roomDetail!.securityDeposit ?? ''} | Cap: ${roomDetail!.capacity ?? ''}"
                                : "Whitefield, Bangalore",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Helper(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                  color: greyText3,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: roomDetail != null ? "₹${roomDetail!.securityDeposit ?? '0'}" : "₹8500",
                            style: Helper(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: primaryColor,
                                ),
                            children: [
                              TextSpan(
                                text: " /mo",
                                style: Helper(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 9,
                                      color: greyText3,
                                      fontWeight: FontWeight.w500,
                                    ),
                              )
                            ],
                          ),
                        ),
                        if (onTap != null)
                          GestureDetector(
                            onTap: onTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryColor : white,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected ? null : Border.all(color: primaryColor),
                              ),
                              child: Text(
                                isSelected ? "Selected" : "Select",
                                style: Helper(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? white : primaryColor,
                                    ),
                              ),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );

  }
}