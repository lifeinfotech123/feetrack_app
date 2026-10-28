import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/data/models/candidate_profile_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/dashboard/job/user_job_profile/screens/intership_and_work_experience_screen.dart';

class EducationWidget extends StatelessWidget {
  final CandidateProfileData? candidateProfile;

  const EducationWidget({
    super.key,
    this.candidateProfile,
  });

  @override
  Widget build(BuildContext context) {
    final highestEducation = candidateProfile?.highestEducation ?? "Graduate";
    final doctorate = candidateProfile?.doctorate ?? "Explore";

    final hasEdu = candidateProfile?.educations != null && candidateProfile!.educations!.isNotEmpty;
    final edu = hasEdu ? candidateProfile!.educations!.first : null;

    final degree = edu?.degree ?? "B.Sc., IT Mobile Application and Information Security";
    final university = edu?.university ?? "Lucknow University";
    final medium = edu?.medium ?? "English";
    final type = edu?.type ?? "Full Time";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Education",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF101828),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                navigate(
                  context: context,
                  page: const IntershipAndWorkExperienceScreen(isEducation: true),
                );
              },
              icon: Icon(Icons.add, size: 16.sp, color: primaryColor),
              label: Text(
                "Add",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),

        // Education Summary Rows
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          child: Column(
            children: [
              _buildRow(
                "Highest education",
                highestEducation,
                onTap: () {
                  navigate(
                    context: context,
                    page: const IntershipAndWorkExperienceScreen(isEducation: true),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF2F4F7)),
              _buildRow(
                "Doctorate / PhD",
                doctorate,
                textColor: doctorate == "Explore" || doctorate == "None" ? primaryColor : const Color(0xFF101828),
                onTap: () {
                  navigate(
                    context: context,
                    page: const IntershipAndWorkExperienceScreen(isEducation: true),
                  );
                },
              ),
            ],
          ),
        ),

        SizedBox(height: 10.h),

        // Detailed Degree Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.school_rounded, color: const Color(0xFF475467), size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          degree,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF101828),
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "$university • $highestEducation",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      navigate(
                        context: context,
                        page: const IntershipAndWorkExperienceScreen(isEducation: true),
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

              SizedBox(height: 12.h),

              Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: [
                  if (medium.isNotEmpty) _buildTagChip("$medium Medium"),
                  if (type.isNotEmpty) _buildTagChip(type),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String title, String value, {Color? textColor, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF667085),
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor ?? const Color(0xFF101828),
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.chevron_right_rounded, size: 18.sp, color: const Color(0xFF98A2B3)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF475467),
        ),
      ),
    );
  }
}
