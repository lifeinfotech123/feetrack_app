import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/data/models/candidate_profile_model.dart';
import 'package:vlr/data/models/user_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/dashboard/job/user_job_profile/widgets/edit_location_bottom_sheet.dart';
import 'package:vlr/views/screens/dashboard/job/user_job_profile/widgets/edit_basic_details_bottom_sheet.dart';
class OtherDetailsWidget extends StatelessWidget {
  final UserModel? userModel;
  final CandidateProfileData? candidateProfile;

  const OtherDetailsWidget({
    super.key,
    this.userModel,
    this.candidateProfile,
  });

  @override
  Widget build(BuildContext context) {
    final email = userModel?.email ?? "";
    final mobile = userModel?.mobile ?? "";

    // Location Subtitle
    String locationSub = "Lucknow • Preferred locations";
    if (candidateProfile?.preferredLocations != null && candidateProfile!.preferredLocations!.isNotEmpty) {
      locationSub = "${candidateProfile!.preferredLocations!.join(', ')} • ${candidateProfile!.preferredLocations!.length} preferred location(s)";
    }

    // Job Preference Subtitle
    List<String> prefParts = [];
    if (candidateProfile?.preferredJobType != null) prefParts.add(candidateProfile!.preferredJobType!);
    if (candidateProfile?.preferredWorkMode != null) prefParts.add(candidateProfile!.preferredWorkMode!);
    if (candidateProfile?.preferredShift != null) prefParts.add(candidateProfile!.preferredShift!);
    if (candidateProfile?.expectedSalary != null) prefParts.add("₹ ${candidateProfile!.expectedSalary} / month");
    String jobPrefSub = prefParts.isNotEmpty
        ? prefParts.join(" • ")
        : "Full Time • Work from Office • Day Shift • ₹ 45,000 / month";

    // Documents & Assets Subtitle
    String docsSub = "PAN Card • Aadhaar Card • Android Phone • Laptop";
    if (candidateProfile?.documentsAndAssets != null && candidateProfile!.documentsAndAssets!.isNotEmpty) {
      docsSub = candidateProfile!.documentsAndAssets!.join(" • ");
    }

    // Basic details Subtitle
    final gender = candidateProfile?.gender ?? "Male";
    String basicSub = "$gender • $email • $mobile";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          "Other details",
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF101828),
          ),
        ),

        SizedBox(height: 8.h),

        // Preferred Job Title / Role
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
              Text(
                "Preferred job title/role",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF101828),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                candidateProfile?.preferredJobRoles != null && candidateProfile!.preferredJobRoles!.isNotEmpty
                    ? candidateProfile!.preferredJobRoles!.join(", ")
                    : "Add your preferred job title/role to get recommendations",
                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF667085)),
              ),
              SizedBox(height: 12.h),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 44.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  side: const BorderSide(color: Color(0xFFD0D5DD)),
                ),
                onPressed: () {
                  showToast(message: "Add preferred title clicked", toastType: ToastType.info);
                },
                icon: Icon(Icons.add, size: 16.sp, color: primaryColor),
                label: Text(
                  "Add preferred title/role",
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: primaryColor),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 10.h),

        // Other Detail Rows Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          child: Column(
            children: [
              _buildDetailRow(
                title: "Location",
                subtitle: locationSub,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => EditLocationBottomSheet(
                      candidateProfile: candidateProfile,
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF2F4F7)),
              _buildDetailRow(
                title: "Job preference",
                subtitle: jobPrefSub,
                onTap: () {},
              ),
              const Divider(height: 1, color: Color(0xFFF2F4F7)),
              _buildDetailRow(
                title: "Documents & assets",
                subtitle: docsSub,
                onTap: () {},
              ),
              const Divider(height: 1, color: Color(0xFFF2F4F7)),
              _buildDetailRow(
                title: "Basic details",
                subtitle: basicSub,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => EditBasicDetailsBottomSheet(
                      userModel: userModel,
                      candidateProfile: candidateProfile,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
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
            Icon(Icons.chevron_right_rounded, size: 20.sp, color: const Color(0xFF98A2B3)),
          ],
        ),
      ),
    );
  }
}
