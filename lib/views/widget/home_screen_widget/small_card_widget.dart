import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class SmallCardWidget extends StatelessWidget {
  final String title;
  final Widget image;
  final VoidCallback onTap;
  final Color? bgColor;
  final double? size;

  const SmallCardWidget({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
    this.bgColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: size ?? 48.w,
            height: size ?? 48.w,
            decoration: BoxDecoration(
              color: bgColor ?? primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(child: image),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Helper(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: blackText1,
                ),
          ),
        ],
      ),
    );
  }
}
