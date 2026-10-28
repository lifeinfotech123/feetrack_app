import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';

import '../user_job_profile/screens/user_job_profile_screen.dart';

class AiHeader extends StatelessWidget {
  const AiHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (Navigator.canPop(context)) ...[
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 8.w),
        ],
        // --------------------------------------------------
        // GREETING
        // --------------------------------------------------
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetBuilder<AuthController>(
                builder: (authController) {
                  final bool isLoggedIn = authController.isLoggedIn();
                  final String name = isLoggedIn
                      ? (authController.userModel?.name ?? 'Guest')
                      : 'Guest';
                  return Text(
                    "Hello, $name 👋",
                    style: TextStyle(
                      fontSize: 27.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              SizedBox(height: 5.h),
              Text(
                "AI-powered job discovery",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 10.w),

        // --------------------------------------------------
        // NOTIFICATION
        // --------------------------------------------------
        SizedBox(
          width: 42.w,
          height: 42.w,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 29.sp,
                  color: Colors.white,
                ),
              ),
              Positioned(
                top: 3.h,
                right: 4.w,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 8.w),

        // --------------------------------------------------
        // PROFILE
        // --------------------------------------------------
        InkWell(
          onTap: () {
            final authCtrl = Get.isRegistered<AuthController>()
                ? Get.find<AuthController>()
                : null;
            if (authCtrl == null || !authCtrl.isLoggedIn()) {
              Get.to(() => const LoginScreen());
              return;
            }
            navigate(
              context: context,
              page: const UserJobProfileScreen(),
            );
          },
          child: Container(
            width: 58.w,
            height: 58.w,
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF3298FF),
                width: 2.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3298FF).withValues(alpha: 0.40),
                  blurRadius: 12.r,
                  spreadRadius: 1.r,
                ),
              ],
            ),
            child: ClipOval(
              child: GetBuilder<AuthController>(
                builder: (authController) {
                  final String imagePath = authController.isLoggedIn()
                      ? (authController.userModel?.image ?? "")
                      : "";
                  return CustomImage(
                    path: imagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    isProfile: true,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
