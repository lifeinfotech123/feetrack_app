import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'ai_header.dart';
import 'ai_search_section.dart';

class AiTopSection extends StatelessWidget {
  const AiTopSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF061A49),
            Color(0xFF03143A),
            Color(0xFF02112F),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35.r),
          bottomRight: Radius.circular(35.r),
        ),
      ),
      child: Stack(
        children: [
          // Graphical flowing lines
          // const Positioned.fill(
          //   child: AiFlowBackground(),
          // ),

          // Main content
          Padding(
            padding: EdgeInsets.only(
              top: 24.h,
              left: 20.w,
              right: 20.w,
              bottom: 28.h,
            ),
            child: Column(
              children: [
                const AiHeader(),

                SizedBox(height: 12.h),

                // AI sphere
                // const AiSphereSection(),

                SizedBox(height: 12.h),

                Text(
                  "What job are you looking for?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: 18.h),

                const AiSearchSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
