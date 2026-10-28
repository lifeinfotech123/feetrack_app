import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/job_candidate_profile_update_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/dashboard/job/user_job_profile/widgets/education_widget.dart';
import 'package:vlr/views/screens/dashboard/job/user_job_profile/widgets/my_activities_widget.dart';
import 'package:vlr/views/screens/dashboard/job/user_job_profile/widgets/other_details_widget.dart';
import 'package:vlr/views/screens/dashboard/job/user_job_profile/widgets/profile_header_widget.dart';
import 'package:vlr/views/screens/dashboard/job/user_job_profile/widgets/resume_widget.dart';
import 'package:vlr/views/screens/dashboard/job/user_job_profile/widgets/skills_widget.dart';
import 'package:vlr/views/screens/dashboard/job/user_job_profile/widgets/work_experience_widget.dart';

class UserJobProfileScreen extends StatefulWidget {
  const UserJobProfileScreen({super.key});

  @override
  State<UserJobProfileScreen> createState() => _UserJobProfileScreenState();
}

class _UserJobProfileScreenState extends State<UserJobProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authCtrl = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
      if (authCtrl != null && authCtrl.isLoggedIn()) {
        authCtrl.fetchProfile();
        if (Get.isRegistered<JobCandidateProfileUpdateController>()) {
          Get.find<JobCandidateProfileUpdateController>().getCandidateProfile();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFF101828), size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Update Job Profile",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF101828),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline_rounded, color: const Color(0xFF475467), size: 22.sp),
            onPressed: () {
              showToast(message: "Help & Support", toastType: ToastType.info);
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: const Color(0xFF475467), size: 22.sp),
            onPressed: () {
              showToast(message: "Settings", toastType: ToastType.info);
            },
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: GetBuilder<JobCandidateProfileUpdateController>(
        builder: (candidateController) {
          final authController = Get.find<AuthController>();
          final userModel = authController.userModel;

          if (candidateController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await authController.fetchProfile();
              await candidateController.getCandidateProfile();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Profile Header (Avatar, Name, Title, Location)
                  ProfileHeaderWidget(
                    userModel: userModel,
                    candidateUser: candidateController.candidateUser,
                    candidateProfile: candidateController.candidateProfile,
                  ),

                  SizedBox(height: 16.h),

                  // 2. My Activities (My Applications, My Calls)
                  const MyActivitiesWidget(),

                  SizedBox(height: 16.h),

                  // 3. Work Experience Section
                  WorkExperienceWidget(candidateProfile: candidateController.candidateProfile),

                  SizedBox(height: 16.h),

                  // 4. Education Section
                  EducationWidget(candidateProfile: candidateController.candidateProfile),

                  SizedBox(height: 16.h),

                  // 5. Skills Section
                  SkillsWidget(candidateProfile: candidateController.candidateProfile),

                  SizedBox(height: 16.h),

                  // 6. Resume Section
                  ResumeWidget(candidateProfile: candidateController.candidateProfile),

                  SizedBox(height: 16.h),

                  // 7. Other Details (Location, Job Preferences, Documents, Basic Details)
                  OtherDetailsWidget(
                    userModel: userModel,
                    candidateProfile: candidateController.candidateProfile,
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


