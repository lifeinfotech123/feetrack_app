import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vlr/data/models/candidate_profile_model.dart';
import 'package:vlr/data/models/user_model.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserModel? userModel;
  final CandidateUserData? candidateUser;
  final CandidateProfileData? candidateProfile;

  const ProfileHeaderWidget({
    super.key,
    this.userModel,
    this.candidateUser,
    this.candidateProfile,
  });

  @override
  Widget build(BuildContext context) {
    final name = candidateUser?.name ?? userModel?.name ?? "Guest";
    final profileImage = candidateUser?.profileImageUrl ?? userModel?.image;

    String jobSubtitle = "Candidate";
    if (candidateProfile?.workExperiences != null && candidateProfile!.workExperiences!.isNotEmpty) {
      final exp = candidateProfile!.workExperiences!.first;
      if (exp.jobTitle != null && exp.company != null) {
        jobSubtitle = "${exp.jobTitle} at ${exp.company}";
      } else if (exp.jobTitle != null) {
        jobSubtitle = exp.jobTitle!;
      }
    } else if (candidateProfile?.preferredJobRoles != null && candidateProfile!.preferredJobRoles!.isNotEmpty) {
      jobSubtitle = candidateProfile!.preferredJobRoles!.join(", ");
    }

    String locationText = "Lucknow, UP";
    if (candidateProfile?.preferredLocations != null && candidateProfile!.preferredLocations!.isNotEmpty) {
      locationText = candidateProfile!.preferredLocations!.join(", ");
    }

    String initials = "MZ";
    if (name.trim().isNotEmpty) {
      List<String> parts = name.trim().split(" ");
      if (parts.length >= 2) {
        initials = "${parts[0][0]}${parts[1][0]}".toUpperCase();
      } else {
        initials = name.trim()[0].toUpperCase();
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: const Color(0xFF3B2D54),
              shape: BoxShape.circle,
              image: profileImage != null && profileImage.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(profileImage),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: profileImage == null || profileImage.isEmpty
                ? Text(
                    initials,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),

          SizedBox(width: 14.w),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF101828),
                  ),
                ),
                SizedBox(height: 4.h),

                Row(
                  children: [
                    Icon(Icons.business_center_outlined, size: 14.sp, color: const Color(0xFF667085)),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        jobSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF475467),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),

                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14.sp, color: const Color(0xFF667085)),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        locationText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
