import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/data/models/candidate_profile_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/dashboard/job/user_job_profile/screens/intership_and_work_experience_screen.dart';

class WorkExperienceWidget extends StatelessWidget {
  final CandidateProfileData? candidateProfile;

  const WorkExperienceWidget({
    super.key,
    this.candidateProfile,
  });

  @override
  Widget build(BuildContext context) {
    final hasWorkExp = candidateProfile?.workExperiences != null && candidateProfile!.workExperiences!.isNotEmpty;
    final exp = hasWorkExp ? candidateProfile!.workExperiences!.first : null;

    final jobTitle = exp?.jobTitle ?? "Flutter Developer";
    final company = exp?.company ?? "Zaleem";
    final industry = exp?.industry ?? "Ecommerce";
    final isCurrentlyWorking = exp?.currentlyWorking ?? true;
    final type = exp?.type ?? "Full Time";

    final totalYears = candidateProfile?.totalExperienceYears ?? 0;
    final totalMonths = candidateProfile?.totalExperienceMonths ?? 0;
    final salary = candidateProfile?.currentMonthlySalary != null
        ? "₹ ${candidateProfile!.currentMonthlySalary}"
        : "₹ 35,000";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Work Experience",
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
                  page: const IntershipAndWorkExperienceScreen(isInternship: false),
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

        // Main Experience Card
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
                    child: Icon(Icons.business_rounded, color: const Color(0xFF475467), size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          jobTitle,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF101828),
                          ),
                        ),
                        Text(
                          company,
                          style: TextStyle(
                            fontSize: 13.sp,
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
                        page: const IntershipAndWorkExperienceScreen(isInternship: false),
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

              _buildFieldLabelValue("Job Role", jobTitle),
              SizedBox(height: 6.h),
              _buildFieldLabelValue("Industry", industry),

              SizedBox(height: 12.h),

              Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: [
                  if (isCurrentlyWorking) _buildStatusChip("Currently Working"),
                  if (type.isNotEmpty) _buildStatusChip(type),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 10.h),

        // Summary Rows Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                title: "Total Years of Experience",
                value: "$totalYears years, $totalMonths months",
                onTap: () {
                  navigate(
                    context: context,
                    page: const IntershipAndWorkExperienceScreen(isInternship: false),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF2F4F7)),
              _buildSummaryRow(
                title: "Current Monthly Salary",
                value: salary,
                onTap: () {
                  navigate(
                    context: context,
                    page: const IntershipAndWorkExperienceScreen(isInternship: false),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF2F4F7)),
              _buildSummaryRow(
                title: "Internships",
                value: "+ Add",
                valueColor: primaryColor,
                onTap: () {
                  navigate(
                    context: context,
                    page: const IntershipAndWorkExperienceScreen(isInternship: true),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: const Color(0xFF98A2B3)),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF344054)),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label) {
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

  Widget _buildSummaryRow({
    required String title,
    required String value,
    Color? valueColor,
    required VoidCallback onTap,
  }) {
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
                    color: valueColor ?? const Color(0xFF101828),
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
}
