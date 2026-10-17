import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/data/models/candidate_profile_model.dart';
import 'package:vlr/views/screens/dashboard/job/user_job_profile/screens/edit_resume_job_profile_screen.dart';
import 'package:vlr/services/constants.dart';

class ResumeWidget extends StatelessWidget {
  final CandidateProfileData? candidateProfile;

  const ResumeWidget({
    super.key,
    this.candidateProfile,
  });

  @override
  Widget build(BuildContext context) {
    String resumeName = "No resume uploaded";
    if (candidateProfile?.resumePath != null && candidateProfile!.resumePath!.isNotEmpty) {
      resumeName = candidateProfile!.resumePath!.split('/').last;
    }

    String updatedAtText = "Last updated recently";
    if (candidateProfile?.resumeUpdatedAt != null && candidateProfile!.resumeUpdatedAt!.isNotEmpty) {
      updatedAtText = "Last updated ${candidateProfile!.resumeUpdatedAt}";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Resume",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF101828),
              ),
            ),
            InkWell(
              onTap: () {
                navigate(
                  context: context,
                  page: EditResumeJobProfileScreen(candidateProfile: candidateProfile),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 14.sp, color: primaryColor),
                  SizedBox(width: 2.w),
                  Text(
                    "Edit",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 6.h),

        // Resume Card
        GestureDetector(
          onTap: () {
            navigate(
              context: context,
              page: EditResumeJobProfileScreen(candidateProfile: candidateProfile),
            );
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFEAECF0)),
            ),
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.picture_as_pdf_rounded, color: const Color(0xFFDC2626), size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resumeName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF101828),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        updatedAtText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    navigate(
                      context: context,
                      page: EditResumeJobProfileScreen(candidateProfile: candidateProfile),
                    );
                  },
                  icon: Icon(Icons.more_vert_rounded, color: const Color(0xFF667085), size: 20.sp),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
