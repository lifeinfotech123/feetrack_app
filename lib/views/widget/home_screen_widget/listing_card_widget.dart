import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vlr/data/models/category_model/listing_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class ListingCardWidget extends StatelessWidget {
  final ListingModel listingModel;
  final bool isLoading;
  final List<String> fallbackImages;
  final int imageIndex;
  final bool isGym;

  const ListingCardWidget({
    super.key,
    required this.listingModel,
    required this.isLoading,
    required this.fallbackImages,
    required this.imageIndex,
    required this.isGym,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final String imagePath = (listingModel.images?.isNotEmpty ?? false)
        ? listingModel.images!.first.imagePath ??
            listingModel.image ??
            fallbackImages[imageIndex]
        : listingModel.image ?? fallbackImages[imageIndex];

    final hasStartingPrice =
        listingModel.startingPrice != null && listingModel.startingPrice! > 0;
    final hasSecurityDeposit = listingModel.securityDeposit != null &&
        double.tryParse(listingModel.securityDeposit!) != null &&
        double.parse(listingModel.securityDeposit!) > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Graphic visual container
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: CustomImage(
                  path: imagePath,
                  width: double.infinity,
                  height: 130.h,
                  fit: BoxFit.cover,
                ),
              ),
              if (listingModel.genderType != null &&
                  listingModel.genderType!.isNotEmpty)
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      listingModel.genderType!,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 10.h,
                right: 10.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.orange, size: 14),
                      SizedBox(width: 2.w),
                      Text(
                        double.tryParse(listingModel.reviewsAvgRating ??
                                    listingModel.rating?.average?.toString() ??
                                    "0")
                                ?.toStringAsFixed(1) ??
                            "0.0",
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: blackText1,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              if (hasStartingPrice)
                Positioned(
                  bottom: 10.h,
                  left: 10.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Starts ₹${listingModel.startingPrice}",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (hasSecurityDeposit)
                Positioned(
                  bottom: 10.h,
                  right: 10.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Dep: ₹${listingModel.securityDeposit}",
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Title & Detail info text
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listingModel.title ?? 'Elite Location',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: blackText1,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 12.sp, color: greyText3),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              listingModel.address ??
                                  listingModel.landmark ??
                                  'Active Street, Noida',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: greyText3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (listingModel.effectiveDistanceKm != null) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.directions_walk_rounded,
                                size: 12.sp, color: primaryColor),
                            SizedBox(width: 4.w),
                            Text(
                              "${listingModel.effectiveDistanceKm?.toStringAsFixed(1)} km away",
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 12.sp, color: primaryColor),
                          SizedBox(width: 4.w),
                          Text(
                            "Open Now",
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16.sp,
                        color: primaryColor,
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
