import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/school/school_home/widget/school_profile_row_hightlight.dart';
import 'package:vlr/views/widget/add_fav_widge/add_fav_widge.dart';

class SchoolProfileWIdget extends StatelessWidget {
  const SchoolProfileWIdget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
              color: greyLight6.withValues(
                alpha: 0.30,
              ),
            ),
          ),
          child: Column(
            children: [
              const Stack(
                children: [
                  CustomImage(
                    path: Assets.imagesSchoolProfile,
                    height: 192,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  AddFavWidget(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "Greenwood High",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Helper(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 18,
                                      color: blackText3,
                                    ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: whiteSmoke,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: greenDark,
                              ),
                              sizedBoxWidth(width: 4),
                              Text(
                                "4.8",
                                style: Helper(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontSize: 14,
                                      color: blackText1,
                                    ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    sizedBoxHeight(height: 8),
                    Row(
                      children: [
                        SchoolProfileRowHighlightWidget(
                            iconWidget: SvgPicture.asset(
                              Assets.svgsLocation,
                              width: 12,
                              height: 10,
                              fit: BoxFit.cover,
                              colorFilter:
                                  ColorFilter.mode(greyDart2, BlendMode.srcIn),
                            ),
                            title: "1.2 km away"),
                        sizedBoxWidth(width: 12),
                        SchoolProfileRowHighlightWidget(
                            iconWidget: SvgPicture.asset(
                              Assets.svgsStudy,
                              width: 12,
                              height: 10,
                              fit: BoxFit.cover,
                              colorFilter:
                                  ColorFilter.mode(greyDart2, BlendMode.srcIn),
                            ),
                            title: "Pre-K to 12"),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Divider(
                        color: greyLight6,
                      ),
                    ),
                    Text(
                      "Sarjapur Road, Bengaluru Sarjapur Road, Bengaluru Sarjapur Road, Bengaluru",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Helper(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: greyDart2,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
