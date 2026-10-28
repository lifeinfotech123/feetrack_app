import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/job_candidate_profile_update_controller.dart';
import 'package:vlr/data/models/candidate_profile_model.dart';
import 'package:vlr/data/models/user_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class EditBasicDetailsBottomSheet extends StatefulWidget {
  final UserModel? userModel;
  final CandidateProfileData? candidateProfile;

  const EditBasicDetailsBottomSheet({
    super.key,
    this.userModel,
    this.candidateProfile,
  });

  @override
  State<EditBasicDetailsBottomSheet> createState() => _EditBasicDetailsBottomSheetState();
}

class _EditBasicDetailsBottomSheetState extends State<EditBasicDetailsBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;

  String? _selectedGender;

  final List<String> _genders = ["Male", "Female", "Other"];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userModel?.name ?? "");
    _dobController = TextEditingController(); // Assuming no DOB in userModel currently
    _mobileController = TextEditingController(text: widget.userModel?.mobile ?? "");
    _emailController = TextEditingController(text: widget.userModel?.email ?? "");

    _selectedGender = widget.candidateProfile?.gender ?? "Male";
    if (!_genders.contains(_selectedGender)) {
      _selectedGender = "Male";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveBasicDetails() async {
    final authController = Get.find<AuthController>();
    final candidateController = Get.find<JobCandidateProfileUpdateController>();

    // Update AuthController text controllers
    authController.fullNameController.text = _nameController.text.trim();
    authController.emailController.text = _emailController.text.trim();
    authController.mobileNoController.text = _mobileController.text.trim();
    if (_dobController.text.isNotEmpty) {
      authController.dobController.text = _dobController.text.trim();
    }

    bool success = true;

    // Hit Auth API
    final authResponse = await authController.updateProfile();
    if (!authResponse.isSuccess) {
      success = false;
      showToast(message: authResponse.message, toastType: ToastType.error);
    }

    // Hit Candidate API for Gender
    if (success) {
      final currentProfile = candidateController.candidateProfile ?? CandidateProfileData();
      final updatedProfile = CandidateProfileData(
        highestEducation: currentProfile.highestEducation,
        doctorate: currentProfile.doctorate,
        educations: currentProfile.educations,
        skills: currentProfile.skills,
        preferredJobRoles: currentProfile.preferredJobRoles,
        preferredLocations: currentProfile.preferredLocations,
        preferredJobType: currentProfile.preferredJobType,
        preferredWorkMode: currentProfile.preferredWorkMode,
        preferredShift: currentProfile.preferredShift,
        expectedSalary: currentProfile.expectedSalary,
        documentsAndAssets: currentProfile.documentsAndAssets,
        workExperiences: currentProfile.workExperiences,
        totalExperienceYears: currentProfile.totalExperienceYears,
        totalExperienceMonths: currentProfile.totalExperienceMonths,
        currentMonthlySalary: currentProfile.currentMonthlySalary,
        gender: _selectedGender,
      );

      final candidateResponse = await candidateController.updateCandidateProfile(profileData: updatedProfile);
      if (!candidateResponse.isSuccess) {
        success = false;
        showToast(message: candidateResponse.message, toastType: ToastType.error);
      }
    }

    if (success) {
      showToast(message: "Basic details updated successfully!", toastType: ToastType.success);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Color(0xFF101828),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            SizedBox(height: 12.h),
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFEAECF0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 8.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: const Color(0xFF101828), size: 22.sp),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    "Edit basic details",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF101828),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFEAECF0)),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    _buildLabel("Name"),
                    _buildTextField(controller: _nameController, hintText: "Enter Name"),
                    SizedBox(height: 16.h),

                    // Gender
                    _buildLabel("Gender"),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFEAECF0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGender,
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor, size: 22.sp),
                          isExpanded: true,
                          items: _genders.map((gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF101828))),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedGender = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Date of Birth
                    _buildLabel("Date of Birth"),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: _dobController,
                          hintText: "DD/MM/YYYY",
                          suffixIcon: Icons.calendar_today_outlined,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Mobile number
                    _buildLabel("Mobile number"),
                    _buildTextField(
                      controller: _mobileController,
                      hintText: "+91-XXXXXXXXXX",
                      suffixIcon: Icons.lock_outline_rounded,
                      readOnly: true,
                      textColor: const Color(0xFF98A2B3),
                    ),
                    SizedBox(height: 16.h),

                    // Email ID
                    _buildLabel("Email ID"),
                    _buildTextField(
                      controller: _emailController,
                      hintText: "Enter Email ID",
                      suffixWidget: Text(
                        "Verify",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            // Bottom Save Button
            GetBuilder<AuthController>(
              builder: (authController) {
                return GetBuilder<JobCandidateProfileUpdateController>(
                  builder: (candidateController) {
                    final isUpdating = authController.isLoading || candidateController.isUpdating;
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
                          onPressed: isUpdating ? null : _saveBasicDetails,
                          child: isUpdating
                              ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  "Save",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF101828),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? suffixIcon,
    Widget? suffixWidget,
    bool readOnly = false,
    Color textColor = const Color(0xFF101828),
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: TextStyle(fontSize: 14.sp, color: textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF98A2B3)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Color(0xFFEAECF0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Color(0xFFEAECF0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        suffixIcon: suffixWidget != null
            ? Padding(
                padding: EdgeInsets.only(right: 14.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [suffixWidget],
                ),
              )
            : (suffixIcon != null
                ? Icon(suffixIcon, size: 20.sp, color: const Color(0xFF98A2B3))
                : null),
      ),
    );
  }
}
