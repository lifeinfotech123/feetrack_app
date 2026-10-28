import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AiSearchSection extends StatelessWidget {
  const AiSearchSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58.h,
      padding: EdgeInsets.symmetric(
        horizontal: 17.w,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        color: const Color(0xFF0B2860).withValues(alpha: 0.9),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.12),
            blurRadius: 20.r,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 27.sp,
            color: Colors.white,
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: Text(
              "Ask AI to find your perfect role",
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ),

          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 21.sp,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}