import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/job_candidate_profile_update_controller.dart';
import 'package:vlr/data/models/candidate_profile_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class EditResumeJobProfileScreen extends StatefulWidget {
  final CandidateProfileData? candidateProfile;

  const EditResumeJobProfileScreen({
    super.key,
    this.candidateProfile,
  });

  @override
  State<EditResumeJobProfileScreen> createState() => _EditResumeJobProfileScreenState();
}

class _EditResumeJobProfileScreenState extends State<EditResumeJobProfileScreen> {
  PlatformFile? _selectedFile;

  late String _currentResumeName;
  late String _currentResumeDate;
  late bool _hasExistingResume;

  @override
  void initState() {
    super.initState();
    final profile = widget.candidateProfile ?? Get.find<JobCandidateProfileUpdateController>().candidateProfile;
    _hasExistingResume = profile?.resumePath != null && profile!.resumePath!.isNotEmpty;
    _currentResumeName = _hasExistingResume ? profile!.resumePath!.split('/').last : "MohdZaid_Resume.pdf";
    _currentResumeDate = (profile?.resumeUpdatedAt != null && profile!.resumeUpdatedAt!.isNotEmpty)
        ? "Last updated ${profile.resumeUpdatedAt}"
        : "Last updated recently";
  }

  Future<void> _pickResume() async {
    try {
      FilePickerResult? result;
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx'],
          allowMultiple: false,
        );
      } catch (e) {
        if (e is MissingPluginException) {
          rethrow;
        }
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final extension = file.extension?.toLowerCase() ?? file.name.split('.').last.toLowerCase();

        if (!['pdf', 'doc', 'docx'].contains(extension)) {
          showToast(
            message: "Invalid file format. Please choose a PDF, DOC, or DOCX file.",
            toastType: ToastType.warning,
          );
          return;
        }

        if (file.size > 5 * 1024 * 1024) {
          showToast(
            message: "File size exceeds 5MB limit. Please choose a smaller file.",
            toastType: ToastType.warning,
          );
          return;
        }

        setState(() {
          _selectedFile = file;
        });
      }
    } on MissingPluginException {
      showToast(
        message: "File picker plugin not registered. Please stop and restart the app.",
        toastType: ToastType.error,
      );
    } catch (e) {
      showToast(
        message: "Failed to pick file: $e",
        toastType: ToastType.error,
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  void _saveResume() async {
    if (_selectedFile == null && !_hasExistingResume) {
      showToast(
        message: "Please upload or select a resume file first.",
        toastType: ToastType.warning,
      );
      return;
    }

    final controller = Get.find<JobCandidateProfileUpdateController>();
    final currentProfile = controller.candidateProfile ?? CandidateProfileData();

    dynamic filePayload;
    if (_selectedFile?.path != null && _selectedFile!.path!.isNotEmpty) {
      filePayload = File(_selectedFile!.path!);
    } else if (_selectedFile?.name != null) {
      filePayload = _selectedFile!.name;
    }

    final response = await controller.updateCandidateProfile(
      profileData: currentProfile,
      resumeFile: filePayload,
      resumeBytes: _selectedFile?.bytes,
      resumeFileName: _selectedFile?.name,
    );

    if (response.isSuccess) {
      showToast(
        message: response.message,
        toastType: ToastType.success,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      showToast(
        message: response.message,
        toastType: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: const Color(0xFF101828), size: 22.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Resume",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF101828),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Current Resume Section
                    if (_hasExistingResume) ...[
                      Text(
                        "Current Resume",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF101828),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _buildCurrentResumeCard(),
                      SizedBox(height: 24.h),
                    ],

                    // 2. Upload / Replace Resume Box
                    Text(
                      _hasExistingResume ? "Replace Resume" : "Upload Resume",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildUploadBox(),

                    SizedBox(height: 24.h),

                    // 3. Resume Tips Card
                    _buildTipsCard(),
                  ],
                ),
              ),
            ),

            // Bottom Save Button
            GetBuilder<JobCandidateProfileUpdateController>(
              builder: (controller) {
                final isUpdating = controller.isUpdating;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: isUpdating ? null : _saveResume,
                      child: isUpdating
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              "SAVE RESUME",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentResumeCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.picture_as_pdf_rounded, color: const Color(0xFFDC2626), size: 26.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentResumeName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF101828),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  _currentResumeDate,
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
              setState(() {
                _hasExistingResume = false;
              });
              showToast(message: "Resume removed", toastType: ToastType.info);
            },
            icon: Icon(Icons.delete_outline_rounded, color: const Color(0xFFDC2626), size: 22.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox() {
    if (_selectedFile != null) {
      final isPdf = _selectedFile!.extension?.toLowerCase() == 'pdf';
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF10B981), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isPdf ? const Color(0xFFFEE2E2) : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                isPdf ? Icons.picture_as_pdf_rounded : Icons.description_rounded,
                color: isPdf ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                size: 26.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedFile!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF101828),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _formatFileSize(_selectedFile!.size),
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
                setState(() {
                  _selectedFile = null;
                });
              },
              icon: Icon(Icons.close_rounded, color: const Color(0xFF667085), size: 20.sp),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _pickResume,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFD0D5DD),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                color: primaryColor,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Click to upload CV / Resume",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF344054),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "PDF, DOC, DOCX (Max 5MB)",
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF98A2B3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: const Color(0xFF1D4ED8), size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Resume Tips",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "• Ensure your phone number & email are up to date.\n• Mention your top technical skills and recent experience.\n• Keep file size under 5MB in PDF/DOC format.",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF1E40AF),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
