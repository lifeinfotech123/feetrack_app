import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/job_controller.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/dashboard/job/widget/job_apply_bottom_sheet.dart';

class JobDetailBottomBar extends StatefulWidget {
  final int? jobId;
  final String? jobTitle;
  final String? referralCode;

  const JobDetailBottomBar({
    super.key,
    this.jobId,
    this.jobTitle,
    this.referralCode,
  });

  @override
  State<JobDetailBottomBar> createState() => _JobDetailBottomBarState();
}

class _JobDetailBottomBarState extends State<JobDetailBottomBar> {
  bool _isBookmarked = false;

  void _onApplyJob() {
    if (widget.jobId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to apply: Job ID missing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Open bottom sheet for filling application details & uploading CV/Resume
    JobApplyBottomSheet.show(
      context,
      jobId: widget.jobId!,
      jobTitle: widget.jobTitle,
      referralCode: widget.referralCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 16.h,
        bottom: 24.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.r,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bookmark Button
          GestureDetector(
            onTap: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
            },
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFEAECF0),
                  width: 1.5.w,
                ),
              ),
              child: Icon(
                _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: _isBookmarked ? primaryColor : const Color(0xFF475467),
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // Apply Now Button
          Expanded(
            child: GetBuilder<JobController>(
              builder: (jobController) {
                return GestureDetector(
                  onTap: jobController.isApplying ? null : _onApplyJob,
                  child: Container(
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: primaryColor, // Royal Blue
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.25),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: jobController.isApplying
                        ? SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            "APPLY NOW",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
