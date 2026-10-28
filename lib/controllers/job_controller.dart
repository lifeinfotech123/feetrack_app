import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/data/models/job_post_model.dart';
import 'package:vlr/data/models/job_detail_model.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/data/repositories/job_repo.dart';

class JobController extends GetxController implements GetxService {
  final JobRepo jobRepo;
  JobController({required this.jobRepo});

  bool isLoading = false;
  List<JobPostModel> jobList = [];
  JobDetailData? selectedJob;

  Future<void> getJobList() async {
    isLoading = true;
    update();
    try {
      Response response = await jobRepo.getJobList();
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body != null) {
        if (response.body['success'] == true ||
            response.body['success'] == 'true' ||
            response.body['status'] == 'success') {
          var rawData = response.body['data'];
          List items = [];
          if (rawData is List) {
            items = rawData;
          } else if (rawData is Map && rawData['data'] is List) {
            items = rawData['data'];
          }
          jobList = items
              .map((e) => JobPostModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
    } catch (e) {
      log("Error fetching jobs in JobController: $e");
    }
    isLoading = false;
    update();
  }

  Future<void> getJobDetails(int id) async {
    selectedJob = null;
    isLoading = true;
    update();
    try {
      Response response = await jobRepo.getJobDetails(id);
      if (response.statusCode == 200 && response.body != null) {
        if (response.body['success'] == true) {
          selectedJob = JobDetailData.fromJson(response.body['data']);
        }
      }
    } catch (e) {
      log("Error fetching job details in JobController: $e");
    }
    isLoading = false;
    update();
  }

  Future<bool> shareReferral(
      {required int postId, required String referralCode}) async {
    try {
      Map<String, dynamic> data = {
        "post_id": postId,
        "referral_code": referralCode,
      };

      Response response = await jobRepo.shareReferral(data);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body != null) {
        if (response.body['success'] == true ||
            response.body['status'] == "success") {
          return true;
        }
      }
    } catch (e) {
      log("Error sharing referral in JobController: $e");
    }
    return false;
  }

  Future<void> getJobDetailsByReferral(String referralCode) async {
    selectedJob = null;
    isLoading = true;
    update();
    try {
      Response response = await jobRepo.getJobDetailsByReferral(referralCode);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body != null) {
        if (response.body['success'] == true && response.body['data'] != null) {
          selectedJob = JobDetailData.fromJson(response.body['data']);
        }
      }
    } catch (e) {
      log("Error fetching job details by referral in JobController: $e");
    }
    isLoading = false;
    update();
  }

  bool isApplying = false;

  Future<ResponseModel> applyJob({
    required int postId,
    String? referralCode,
    required String designation,
    required String address,
    File? resumeFile,
    Uint8List? resumeBytes,
    String? resumeFileName,
  }) async {
    isApplying = true;
    update();
    try {
      final Map<String, dynamic> data = {
        "post_id": postId.toString(),
        if (referralCode != null && referralCode.isNotEmpty)
          "referral_code": referralCode,
        "designation": designation,
        "address": address,
      };

      if (resumeFile != null) {
        final fileName = resumeFileName ??
            resumeFile.path.split(Platform.pathSeparator).last;
        data["resume"] = MultipartFile(resumeFile, filename: fileName);
      } else if (resumeBytes != null && resumeFileName != null) {
        data["resume"] = MultipartFile(resumeBytes, filename: resumeFileName);
      }

      final formData = FormData(data);
      Response response = await jobRepo.applyJob(formData);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body != null) {
        if (response.body['success'] == true ||
            response.body['status'] == "success") {
          return ResponseModel(
              true,
              response.body['message'] ??
                  "Application submitted successfully!");
        } else {
          return ResponseModel(false,
              response.body['message'] ?? "Failed to submit application.");
        }
      } else {
        final errorMsg = response.statusText ??
            response.body?['message'] ??
            "Failed to submit application. Please check your details.";
        return ResponseModel(false, errorMsg);
      }
    } catch (e) {
      log("Error applying job in JobController: $e");
      return ResponseModel(false, "An error occurred: $e");
    } finally {
      isApplying = false;
      update();
    }
  }

  bool isAppliedJobsLoading = false;
  List<JobPostModel> appliedJobList = [];

  Future<void> getAppliedJobList() async {
    isAppliedJobsLoading = true;
    update();
    try {
      Response response = await jobRepo.getAppliedJobs();
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body != null) {
        if (response.body['success'] == true && response.body['data'] != null) {
          var rawData = response.body['data'];
          List items = [];
          if (rawData is List) {
            items = rawData;
          } else if (rawData is Map) {
            if (rawData['data'] is List) {
              items = rawData['data'];
            } else {
              items = [rawData];
            }
          }
          appliedJobList = items
              .map((e) => JobPostModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          appliedJobList = [];
        }
      } else {
        appliedJobList = [];
      }
    } catch (e) {
      log("Error fetching applied jobs in JobController: $e");
      appliedJobList = [];
    }
    isAppliedJobsLoading = false;
    update();
  }

  bool isAppliedJobDetailLoading = false;
  JobPostModel? appliedJobDetail;

  Future<void> getAppliedJobDetail(dynamic appliedId) async {
    appliedJobDetail = null;
    isAppliedJobDetailLoading = true;
    update();
    try {
      Response response = await jobRepo.getAppliedJobDetails(appliedId);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body != null) {
        if (response.body['success'] == true && response.body['data'] != null) {
          appliedJobDetail = JobPostModel.fromJson(
              Map<String, dynamic>.from(response.body['data']));
        }
      }
    } catch (e) {
      log("Error fetching applied job detail in JobController: $e");
    }
    isAppliedJobDetailLoading = false;
    update();
  }
}
