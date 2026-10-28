import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vlr/generated/assets.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:flutter/material.dart';
import 'package:vlr/views/base/custom_image.dart';

class AuthTopSection extends StatelessWidget {
  const AuthTopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10.h),
            height: 100.h,
            width: 100.w,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: white, boxShadow: [
              BoxShadow(
                offset: Offset(0, 8),
                spreadRadius: 5.r,
                blurRadius: 10.r,
                color: black.withValues(alpha: 0.1),
              )
            ]),
            child: CustomImage(
              path: Assets.imagesLogo,
              height: 90.h,
              width: 90.w,
              radius: 999.r,
              fit: BoxFit.cover,
            ),
          ),
          sizedBoxHeight(height: 24.sp),
          RichText(
            text: TextSpan(
                text: "Fee",
                style: Helper(context).textTheme.titleMedium?.copyWith(
                      fontSize: 30.sp,
                      color: blackText1,
                    ),
                children: [
                  TextSpan(
                    text: "Track",
                    style: Helper(context).textTheme.titleMedium?.copyWith(
                          fontSize: 30.sp,
                          color: primaryColor,
                        ),
                  )
                ]),
          ),
          sizedBoxHeight(height: 4.h),
          RichText(
            text: TextSpan(
                text: "Collect Smart.",
                style: Helper(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14.sp,
                      color: greyDart2,
                    ),
                children: [
                  TextSpan(
                    text: " Pay Easy.",
                    style: Helper(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14.sp,
                          color: primaryColor,
                        ),
                  )
                ]),
          ),
          sizedBoxHeight(height: 32.h),
        ],
      ),
    );
  }
}
