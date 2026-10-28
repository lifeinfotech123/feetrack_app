import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vlr/generated/assets.dart';
import 'package:vlr/views/base/custom_image.dart';

class PlanImageCard extends StatelessWidget {
  const PlanImageCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 16.r,
            offset: Offset(
              0,
              6.h,
            ),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),

        child: CustomImage(
          path: Assets.imagesGymBanner,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}