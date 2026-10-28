import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/job_controller.dart';
import 'package:vlr/services/appsflyer_service.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';

class JobApplyBottomSheet extends StatefulWidget {
  final int jobId;
  final String? jobTitle;
  final String? referralCode;

  const JobApplyBottomSheet({
    super.key,
    required this.jobId,
    this.jobTitle,
    this.referralCode,
  });

  static Future<void> show(
    BuildContext context, {
    required int jobId,
    String? jobTitle,
    String? referralCode,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobApplyBottomSheet(
        jobId: jobId,
        jobTitle: jobTitle,
        referralCode: referralCode,
      ),
    );
  }

  @override
  State<JobApplyBottomSheet> createState() => _JobApplyBottomSheetState();
}

class _JobApplyBottomSheetState extends State<JobApplyBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  PlatformFile? _selectedFile;
  File? _resumeFile;

  @override
  void initState() {
    super.initState();
    // Pre-fill designation if job title available
    if (widget.jobTitle != null && widget.jobTitle!.isNotEmpty) {
      _designationController.text = widget.jobTitle!;
    }

    // Pre-fill referral code from widget or SharedPreferences
    if (widget.referralCode != null && widget.referralCode!.isNotEmpty) {
      _referralController.text = widget.referralCode!;
    } else {
      AppsFlyerService.getSavedReferralCode().then((saved) {
        if (saved != null && saved.isNotEmpty && mounted) {
          setState(() {
            _referralController.text = saved;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _designationController.dispose();
    _addressController.dispose();
    _referralController.dispose();
    super.dispose();
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
        // Fallback to FileType.any if custom type picker fails on specific device
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final extension = file.extension?.toLowerCase() ?? file.name.split('.').last.toLowerCase();

        // Validate extension
        if (!['pdf', 'doc', 'docx'].contains(extension)) {
          showToast(
            message: "Invalid format. Please select a PDF, DOC, or DOCX file.",
            toastType: ToastType.warning,
          );
          return;
        }

        // Check 5MB limit (5 * 1024 * 1024 bytes)
        if (file.size > 5 * 1024 * 1024) {
          showToast(
            message: "File size exceeds 5MB limit. Please choose a smaller file.",
            toastType: ToastType.warning,
          );
          return;
        }

        setState(() {
          _selectedFile = file;
          if (file.path != null) {
            _resumeFile = File(file.path!);
          }
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

  void _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_resumeFile == null && _selectedFile == null) {
      showToast(
        message: "Please upload your resume (PDF, DOC, or DOCX)",
        toastType: ToastType.warning,
      );
      return;
    }

    final controller = Get.find<JobController>();
    final referral = _referralController.text.trim();

    final result = await controller.applyJob(
      postId: widget.jobId,
      referralCode: referral.isNotEmpty ? referral : null,
      designation: _designationController.text.trim(),
      address: _addressController.text.trim(),
      resumeFile: _resumeFile,
      resumeBytes: _selectedFile?.bytes,
      resumeFileName: _selectedFile?.name,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.pop(context); // Close bottom sheet
      showToast(
        message: result.message,
        typeCheck: true,
      );
      AppsFlyerService.clearPending();
    } else {
      showToast(
        message: result.message,
        toastType: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 16.h,
        bottom: bottomInset + 24.h,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E7EC),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Apply for Job",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF101828),
                          ),
                        ),
                        if (widget.jobTitle != null && widget.jobTitle!.isNotEmpty)
                          Text(
                            widget.jobTitle!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF667085),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2F4F7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 18.sp, color: const Color(0xFF667085)),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFF2F4F7)),

              // 1. Designation Field
              _buildFieldLabel("Designation", isRequired: true),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _designationController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  hintText: "e.g. Lucknow / Sales Executive",
                  prefixIcon: Icons.badge_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter your designation";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // 2. Address Field
              _buildFieldLabel("Address", isRequired: true),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                maxLength: 1000,
                decoration: _inputDecoration(
                  hintText: "Enter your full address (Max 1000 characters)",
                  prefixIcon: Icons.location_on_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter your address";
                  }
                  if (value.length > 1000) {
                    return "Address cannot exceed 1000 characters";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // 3. Referral Code Field
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFieldLabel("Referral Code", isRequired: false),
                  if (_referralController.text.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        "Applied",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _referralController,
                decoration: _inputDecoration(
                  hintText: "Enter referral code (Optional)",
                  prefixIcon: Icons.card_giftcard_rounded,
                  suffixIcon: _referralController.text.isNotEmpty
                      ? const Icon(Icons.check_circle, color: Color(0xFF10B981))
                      : null,
                ),
              ),
              SizedBox(height: 20.h),

              // 4. Resume / CV Upload Section
              _buildFieldLabel("Upload Resume / CV", isRequired: true),
              SizedBox(height: 8.h),
              _buildResumeUploadBox(),
              SizedBox(height: 24.h),

              // 5. Submit Button
              GetBuilder<JobController>(
                builder: (jobController) {
                  return CustomButton(
                    isLoading: jobController.isApplying,
                    height: 52.h,
                    color: primaryColor, // Coral Orange
                    radius: 14.r,
                    onTap: _submitApplication,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "SUBMIT APPLICATION",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.send_rounded, color: Colors.white, size: 18.sp),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF344054),
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: " *",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 14.sp,
        color: const Color(0xFF98A2B3),
      ),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF667085), size: 20.sp),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }

  Widget _buildResumeUploadBox() {
    if (_selectedFile != null) {
      // File Selected View
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
                size: 24.sp,
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
                  _resumeFile = null;
                });
              },
              icon: Icon(Icons.close, color: const Color(0xFF667085), size: 20.sp),
            ),
          ],
        ),
      );
    }

    // Empty Upload Prompt
    return GestureDetector(
      onTap: _pickResume,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFD0D5DD),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                color: primaryColor,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Click to upload CV / Resume",
              style: TextStyle(
                fontSize: 14.sp,
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
}
