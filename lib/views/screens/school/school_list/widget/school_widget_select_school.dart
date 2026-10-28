import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class SchoolWidgetSelectSchool extends StatelessWidget {
  const SchoolWidgetSelectSchool({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          width: 1,
          color: greyLight2.withValues(alpha: 40),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: 1,
                color: greyLight1.withValues(
                  alpha: 0.20,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 1),
                  blurRadius: 1,
                  spreadRadius: 0,
                  color: black.withValues(
                    alpha: 0.05,
                  ),
                ),
              ],
              image: const DecorationImage(
                image: AssetImage(
                  Assets.imagesGymBanner,
                ),
              ),
            ),
          ),
          sizedBoxWidth(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "St. Xavier's High School",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Helper(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        color: blackText3,
                      ),
                ),
                sizedBoxHeight(height: 2.5),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: greyDart2,
                      size: 14,
                    ),
                    sizedBoxWidth(width: 4),
                    Text(
                      "St. Xavier's High School",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: greyDart2,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: greyText2,
          )
        ],
      ),
    );
  }
}
