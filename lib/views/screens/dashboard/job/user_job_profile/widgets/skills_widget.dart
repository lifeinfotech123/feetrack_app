import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/data/models/candidate_profile_model.dart';
import 'package:vlr/views/screens/dashboard/job/user_job_profile/widgets/edit_skills_bottom_sheet.dart';

class SkillsWidget extends StatelessWidget {
  final CandidateProfileData? candidateProfile;

  const SkillsWidget({
    super.key,
    this.candidateProfile,
  });

  static const List<String> defaultSkills = [
    "React Native",
    "Flutter",
    "Android",
    "Firebase",
    "Dart",
    "REST API",
  ];

  void _openEditSkillsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditSkillsBottomSheet(candidateProfile: candidateProfile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final skills = (candidateProfile?.skills != null && candidateProfile!.skills!.isNotEmpty)
        ? candidateProfile!.skills!
        : defaultSkills;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Skills",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF101828),
              ),
            ),
            InkWell(
              onTap: () => _openEditSkillsSheet(context),
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

        // Skills Card
        GestureDetector(
          onTap: () => _openEditSkillsSheet(context),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFEAECF0)),
            ),
            padding: EdgeInsets.all(16.w),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: skills
                  .map((skill) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 14.sp, color: primaryColor),
                            SizedBox(width: 5.w),
                            Text(
                              skill,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
