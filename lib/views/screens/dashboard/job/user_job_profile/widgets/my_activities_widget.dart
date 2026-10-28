import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/dashboard/job/applied_job_history_screen.dart';

class MyActivitiesWidget extends StatelessWidget {
  const MyActivitiesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            "My Activities",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF101828),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          child: Column(
            children: [
              // 1. My Applications
              _buildActivityTile(
                context: context,
                icon: Icons.assignment_outlined,
                iconBgColor: const Color(0xFFE6F4EA),
                iconColor: primaryColor,
                title: "My Applications",
                subtitle: "Check all your job applied and selected status here",
                onTap: () {
                  navigate(
                    context: context,
                    page: const AppliedJobHistoryScreen(),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF2F4F7)),

              // 2. My Calls
              _buildActivityTile(
                context: context,
                icon: Icons.phone_callback_outlined,
                iconBgColor: const Color(0xFFE6F4EA),
                iconColor: primaryColor,
                title: "My Calls",
                subtitle: "Check all your responses and upcoming calls here",
                onTap: () {
                  showToast(message: "No upcoming calls right now.", toastType: ToastType.info);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: iconColor, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF101828),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: const Color(0xFF98A2B3), size: 20.sp),
          ],
        ),
      ),
    );
  }
}
