import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vlr/services/custom_text.dart';

class GymFeatureCard extends StatelessWidget {
  const GymFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),

        borderRadius: BorderRadius.circular(15.r),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 26.w,
            height: 26.w,

            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              size: 17.sp,
              color: iconColor,
            ),
          ),

          SizedBox(height: 5.h),

          CustomText(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF152A58),
            ),
          ),

          SizedBox(height: 2.h),

          CustomText(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 8.sp,
              color: const Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}