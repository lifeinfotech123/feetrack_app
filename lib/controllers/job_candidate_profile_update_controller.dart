import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/data/models/candidate_profile_model.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/data/repositories/job_repo.dart';

class JobCandidateProfileUpdateController extends GetxController
    implements GetxService {
  final JobRepo jobRepo;

  JobCandidateProfileUpdateController({required this.jobRepo});

  bool isLoading = false;
  bool isUpdating = false;

  CandidateUserData? candidateUser;
  CandidateProfileData? candidateProfile;

  void clearCandidateProfile() {
    candidateUser = null;
    candidateProfile = null;
    update();
  }

  /// Fetch Candidate Profile: GET /candidate-profile
  Future<void> getCandidateProfile() async {
    final authCtrl =
        Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    if (authCtrl == null || !authCtrl.isLoggedIn()) {
      candidateUser = null;
      candidateProfile = null;
      isLoading = false;
      update();
      return;
    }

    isLoading = true;
    update();
    try {
      Response response = await jobRepo.getCandidateProfile();
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body != null) {
        if (response.body['success'] == true) {
          final res = CandidateProfileResponse.fromJson(response.body);
          candidateUser = res.user;
          candidateProfile = res.profile;
        }
      }
    } catch (e) {
      log("Error fetching candidate profile in JobCandidateProfileUpdateController: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Update Candidate Profile: POST /candidate-profile
  /// Handles JSON body and Multipart/FormData (when resume is provided)
  Future<ResponseModel> updateCandidateProfile({
    required CandidateProfileData profileData,
    dynamic resumeFile, // File or String path
    List<int>? resumeBytes,
    String? resumeFileName,
  }) async {
    isUpdating = true;
    update();

    try {
      dynamic body;

      // If uploading a resume, send data as multipart/form-data
      if (resumeFile != null || resumeBytes != null) {
        Map<String, dynamic> fields = {};

        if (profileData.highestEducation != null)
          fields['highest_education'] = profileData.highestEducation;
        if (profileData.doctorate != null)
          fields['doctorate'] = profileData.doctorate;
        if (profileData.preferredJobType != null)
          fields['preferred_job_type'] = profileData.preferredJobType;
        if (profileData.preferredWorkMode != null)
          fields['preferred_work_mode'] = profileData.preferredWorkMode;
        if (profileData.preferredShift != null)
          fields['preferred_shift'] = profileData.preferredShift;
        if (profileData.expectedSalary != null)
          fields['expected_salary'] = profileData.expectedSalary.toString();
        if (profileData.totalExperienceYears != null)
          fields['total_experience_years'] =
              profileData.totalExperienceYears.toString();
        if (profileData.totalExperienceMonths != null)
          fields['total_experience_months'] =
              profileData.totalExperienceMonths.toString();
        if (profileData.currentMonthlySalary != null)
          fields['current_monthly_salary'] =
              profileData.currentMonthlySalary.toString();
        if (profileData.gender != null) fields['gender'] = profileData.gender;

        // Formats arrays like skills[0]=React Native&skills[1]=Flutter
        if (profileData.skills != null) {
          for (int i = 0; i < profileData.skills!.length; i++) {
            fields['skills[$i]'] = profileData.skills![i];
          }
        }

        if (profileData.preferredJobRoles != null) {
          for (int i = 0; i < profileData.preferredJobRoles!.length; i++) {
            fields['preferred_job_roles[$i]'] =
                profileData.preferredJobRoles![i];
          }
        }

        if (profileData.preferredLocations != null) {
          for (int i = 0; i < profileData.preferredLocations!.length; i++) {
            fields['preferred_locations[$i]'] =
                profileData.preferredLocations![i];
          }
        }

        if (profileData.documentsAndAssets != null) {
          for (int i = 0; i < profileData.documentsAndAssets!.length; i++) {
            fields['documents_and_assets[$i]'] =
                profileData.documentsAndAssets![i];
          }
        }

        if (profileData.educations != null) {
          for (int i = 0; i < profileData.educations!.length; i++) {
            final edu = profileData.educations![i];
            if (edu.degree != null)
              fields['educations[$i][degree]'] = edu.degree;
            if (edu.university != null)
              fields['educations[$i][university]'] = edu.university;
            if (edu.medium != null)
              fields['educations[$i][medium]'] = edu.medium;
            if (edu.type != null) fields['educations[$i][type]'] = edu.type;
          }
        }

        if (profileData.workExperiences != null) {
          for (int i = 0; i < profileData.workExperiences!.length; i++) {
            final exp = profileData.workExperiences![i];
            if (exp.jobTitle != null)
              fields['work_experiences[$i][job_title]'] = exp.jobTitle;
            if (exp.company != null)
              fields['work_experiences[$i][company]'] = exp.company;
            if (exp.industry != null)
              fields['work_experiences[$i][industry]'] = exp.industry;
            if (exp.currentlyWorking != null)
              fields['work_experiences[$i][currently_working]'] =
                  exp.currentlyWorking.toString();
            if (exp.type != null)
              fields['work_experiences[$i][type]'] = exp.type;
          }
        }

        // Attach resume file
        if (resumeFile is File) {
          String fileName = resumeFileName ?? resumeFile.path.split('/').last;
          fields['resume'] = MultipartFile(resumeFile.path, filename: fileName);
        } else if (resumeFile is String) {
          String fileName = resumeFileName ?? resumeFile.split('/').last;
          fields['resume'] = MultipartFile(resumeFile, filename: fileName);
        } else if (resumeBytes != null && resumeFileName != null) {
          fields['resume'] =
              MultipartFile(resumeBytes, filename: resumeFileName);
        }

        body = FormData(fields);
      } else {
        body = profileData.toJson();
      }

      Response response = await jobRepo.updateCandidateProfile(body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body != null) {
        if (response.body['success'] == true) {
          final resData = response.body['data'];
          if (resData != null && resData is Map<String, dynamic>) {
            candidateProfile = CandidateProfileData.fromJson(resData);
          } else {
            await getCandidateProfile();
          }
          update();
          return ResponseModel(
              true, response.body['message'] ?? "Profile updated successfully");
        } else {
          return ResponseModel(
              false, response.body['message'] ?? "Failed to update profile.");
        }
      } else {
        String errorMsg = response.statusText ??
            response.body?['message'] ??
            "Failed to update profile.";
        return ResponseModel(false, errorMsg);
      }
    } catch (e) {
      log("Error updating candidate profile: $e");
      return ResponseModel(false, "An error occurred: $e");
    } finally {
      isUpdating = false;
      update();
    }
  }
}
