import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/job_candidate_profile_update_controller.dart';
import 'package:vlr/data/models/candidate_profile_model.dart';
import 'package:vlr/services/constants.dart';

import '../../../../../../services/theme.dart';

class IntershipAndWorkExperienceScreen extends StatefulWidget {
  final bool isInternship;
  final bool isEducation;

  const IntershipAndWorkExperienceScreen({
    super.key,
    this.isInternship = false,
    this.isEducation = false,
  });

  @override
  State<IntershipAndWorkExperienceScreen> createState() => _IntershipAndWorkExperienceScreenState();
}

class _IntershipAndWorkExperienceScreenState extends State<IntershipAndWorkExperienceScreen> {
  // Common Controllers
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Education Controllers & State
  final TextEditingController _collegeController = TextEditingController();
  String _selectedEducationLevel = "Graduate";
  String? _selectedDegree;
  String? _selectedSpecialisation;

  final List<String> _educationLevels = const [
    "Diploma",
    "ITI",
    "Graduate",
    "Post Graduate",
  ];

  final List<String> _degrees = const [
    "B.Tech / B.E.",
    "B.Sc.",
    "B.Com",
    "B.A.",
    "BCA",
    "M.Tech",
    "M.Sc.",
    "MCA",
    "MBA",
  ];

  final List<String> _specialisations = const [
    "Computer Science / IT",
    "Mobile Application Development",
    "Information Security",
    "Electronics & Communication",
    "Mechanical Engineering",
    "Business Administration",
    "General",
  ];

  // Work Experience Specific State
  String? _selectedJobRole;
  String? _selectedIndustry;
  bool _isCurrentlyWorking = true;
  String _selectedEmploymentType = "Full-time";

  // Internship Specific State
  bool _isCurrentlyWorkingIntern = false;

  // Date selections
  String? _startMonth;
  String? _startYear;
  String? _endMonth;
  String? _endYear;

  final List<String> _months = const [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  final List<String> _years = List.generate(35, (index) => (2026 - index).toString());

  final List<String> _jobRoles = const [
    "Software Development",
    "Frontend Developer",
    "Backend Developer",
    "Full Stack Developer",
    "Mobile App Developer",
    "UI/UX Designer",
    "Data Scientist",
    "DevOps Engineer",
  ];

  final List<String> _industries = const [
    "IT & Software Services",
    "Ecommerce & Retail",
    "Finance & Banking",
    "Education & EdTech",
    "Healthcare",
    "Marketing & Advertising",
  ];

  final List<String> _employmentTypes = const [
    "Full-time",
    "Part-time",
    "Intern",
    "Contract",
  ];

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  void _onSave() async {
    final controller = Get.find<JobCandidateProfileUpdateController>();
    final currentProfile = controller.candidateProfile ?? CandidateProfileData();

    if (widget.isEducation) {
      if (_collegeController.text.trim().isEmpty) {
        showToast(message: "Please enter college name", toastType: ToastType.warning);
        return;
      }

      final newEdu = CandidateEducation(
        degree: _selectedDegree ?? "B.Sc., IT Mobile Application",
        university: _collegeController.text.trim(),
        medium: "English",
        type: "Full Time",
      );

      final updatedEducations = List<CandidateEducation>.from(currentProfile.educations ?? []);
      updatedEducations.add(newEdu);

      final profileToUpdate = CandidateProfileData(
        highestEducation: _selectedEducationLevel,
        doctorate: currentProfile.doctorate ?? "None",
        educations: updatedEducations,
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
        gender: currentProfile.gender,
      );

      final response = await controller.updateCandidateProfile(profileData: profileToUpdate);

      if (response.isSuccess) {
        showToast(message: response.message, toastType: ToastType.success);
        if (mounted) Navigator.pop(context);
      } else {
        showToast(message: response.message, toastType: ToastType.error);
      }
      return;
    }

    if (_companyController.text.trim().isEmpty) {
      showToast(message: "Please enter company name", toastType: ToastType.warning);
      return;
    }

    if (!widget.isInternship && _jobTitleController.text.trim().isEmpty) {
      showToast(message: "Please enter job title", toastType: ToastType.warning);
      return;
    }

    final newExp = CandidateWorkExperience(
      jobTitle: _jobTitleController.text.trim().isNotEmpty ? _jobTitleController.text.trim() : "Software Developer",
      company: _companyController.text.trim(),
      industry: _selectedIndustry ?? "Ecommerce",
      currentlyWorking: _isCurrentlyWorking,
      type: _selectedEmploymentType,
    );

    final updatedExperiences = List<CandidateWorkExperience>.from(currentProfile.workExperiences ?? []);
    updatedExperiences.add(newExp);

    final profileToUpdate = CandidateProfileData(
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
      workExperiences: updatedExperiences,
      totalExperienceYears: currentProfile.totalExperienceYears ?? 2,
      totalExperienceMonths: currentProfile.totalExperienceMonths ?? 5,
      currentMonthlySalary: currentProfile.currentMonthlySalary ?? 35000.0,
      gender: currentProfile.gender ?? "Male",
    );

    final response = await controller.updateCandidateProfile(profileData: profileToUpdate);

    if (response.isSuccess) {
      showToast(
        message: widget.isInternship
            ? "Internship details saved successfully!"
            : "Work experience saved successfully!",
        toastType: ToastType.success,
      );
      if (mounted) Navigator.pop(context);
    } else {
      showToast(message: response.message, toastType: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = "Add experience";
    if (widget.isEducation) {
      title = "Add education";
    } else if (widget.isInternship) {
      title = "Internship details";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: const Color(0xFF101828), size: 22.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
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
                child: widget.isEducation
                    ? _buildEducationForm()
                    : (widget.isInternship ? _buildInternshipForm() : _buildWorkExperienceForm()),
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
                      onPressed: isUpdating ? null : _onSave,
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
            ),
          ],
        ),
      ),
    );
  }

  // ================= ADD EDUCATION FORM =================
  Widget _buildEducationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Your current or highest completed level of education"),
        SizedBox(height: 10.h),

        // Education Level Chips
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _educationLevels.map((level) {
            final isSelected = _selectedEducationLevel == level;
            return _buildOptionPill(
              label: level,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedEducationLevel = level),
            );
          }).toList(),
        ),
        SizedBox(height: 20.h),

        // College Name
        _buildFieldLabel("College Name"),
        SizedBox(height: 6.h),
        _buildTextField(
          controller: _collegeController,
          hintText: "e.g. St. Stephens",
        ),
        SizedBox(height: 18.h),

        // Degree
        _buildFieldLabel("Degree"),
        SizedBox(height: 6.h),
        _buildDropdownSelector(
          hintText: _selectedDegree ?? "Select an option",
          items: _degrees,
          selectedValue: _selectedDegree,
          onChanged: (val) => setState(() => _selectedDegree = val),
        ),
        SizedBox(height: 18.h),

        // Specialisation
        _buildFieldLabel("Specialisation"),
        SizedBox(height: 6.h),
        _buildDropdownSelector(
          hintText: _selectedSpecialisation ?? "Select an option",
          items: _specialisations,
          selectedValue: _selectedSpecialisation,
          onChanged: (val) => setState(() => _selectedSpecialisation = val),
        ),
        SizedBox(height: 18.h),

        // Start date
        _buildFieldLabel("Start date"),
        SizedBox(height: 6.h),
        Row(
          children: [
            Expanded(
              child: _buildDropdownSelector(
                hintText: _startMonth ?? "Month",
                items: _months,
                selectedValue: _startMonth,
                onChanged: (val) => setState(() => _startMonth = val),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildDropdownSelector(
                hintText: _startYear ?? "Year",
                items: _years,
                selectedValue: _startYear,
                onChanged: (val) => setState(() => _startYear = val),
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),

        // End date (or expected)
        _buildFieldLabel("End date (or expected)"),
        SizedBox(height: 6.h),
        Row(
          children: [
            Expanded(
              child: _buildDropdownSelector(
                hintText: _endMonth ?? "Month",
                items: _months,
                selectedValue: _endMonth,
                onChanged: (val) => setState(() => _endMonth = val),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildDropdownSelector(
                hintText: _endYear ?? "Year",
                items: _years,
                selectedValue: _endYear,
                onChanged: (val) => setState(() => _endYear = val),
              ),
            ),
          ],
        ),

        SizedBox(height: 20.h),
      ],
    );
  }

  // ================= WORK EXPERIENCE FORM =================
  Widget _buildWorkExperienceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Job details
        _buildSectionHeader("Job details"),
        SizedBox(height: 12.h),

        _buildFieldLabel("Job title"),
        SizedBox(height: 6.h),
        _buildTextField(
          controller: _jobTitleController,
          hintText: "e.g. software developer",
        ),
        SizedBox(height: 16.h),

        _buildFieldLabel("Job role"),
        SizedBox(height: 6.h),
        _buildDropdownSelector(
          hintText: _selectedJobRole ?? "Select up to 10 roles for this field",
          items: _jobRoles,
          selectedValue: _selectedJobRole,
          onChanged: (val) {
            setState(() {
              _selectedJobRole = val;
            });
          },
        ),

        SizedBox(height: 16.h),

        _buildFieldLabel("Description (optional)"),

        SizedBox(height: 6.h),
        _buildDescriptionTextField(),
        SizedBox(height: 24.h),

        // 2. Company details
        _buildSectionHeader("Company details"),
        SizedBox(height: 12.h),

        _buildFieldLabel("Company name"),
        SizedBox(height: 6.h),
        _buildTextField(
          controller: _companyController,
          hintText: "e.g. ApnaTime Tech",
        ),
        SizedBox(height: 16.h),

        _buildFieldLabel("Industry"),
        SizedBox(height: 6.h),
        _buildDropdownSelector(
          hintText: _selectedIndustry ?? "Select an option",
          items: _industries,
          selectedValue: _selectedIndustry,
          onChanged: (val) {
            setState(() {
              _selectedIndustry = val;
            });
          },
        ),
        SizedBox(height: 24.h),

        // 3. Employment details
        _buildSectionHeader("Employment details"),
        SizedBox(height: 12.h),

        _buildFieldLabel("Are you currently working in this company?"),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildOptionPill(
              label: "Yes",
              isSelected: _isCurrentlyWorking,
              onTap: () => setState(() => _isCurrentlyWorking = true),
            ),
            SizedBox(width: 10.w),
            _buildOptionPill(
              label: "No",
              isSelected: !_isCurrentlyWorking,
              onTap: () => setState(() => _isCurrentlyWorking = false),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        _buildFieldLabel("Employment type"),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _employmentTypes
              .map((type) => _buildOptionPill(
                    label: type,
                    isSelected: _selectedEmploymentType == type,
                    onTap: () => setState(() => _selectedEmploymentType = type),
                  ))
              .toList(),
        ),
        SizedBox(height: 16.h),

        // Start Date
        _buildFieldLabel("Start Date"),
        SizedBox(height: 6.h),
        Row(
          children: [
            Expanded(
              child: _buildDropdownSelector(
                hintText: _startMonth ?? "Month",
                items: _months,
                selectedValue: _startMonth,
                onChanged: (val) => setState(() => _startMonth = val),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildDropdownSelector(
                hintText: _startYear ?? "Year",
                items: _years,
                selectedValue: _startYear,
                onChanged: (val) => setState(() => _startYear = val),
              ),
            ),
          ],
        ),

        if (!_isCurrentlyWorking) ...[
          SizedBox(height: 16.h),
          _buildFieldLabel("End Date"),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: _buildDropdownSelector(
                  hintText: _endMonth ?? "Month",
                  items: _months,
                  selectedValue: _endMonth,
                  onChanged: (val) => setState(() => _endMonth = val),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildDropdownSelector(
                  hintText: _endYear ?? "Year",
                  items: _years,
                  selectedValue: _endYear,
                  onChanged: (val) => setState(() => _endYear = val),
                ),
              ),
            ],
          ),
        ],

        SizedBox(height: 20.h),
      ],
    );
  }

  // ================= INTERNSHIP FORM =================
  Widget _buildInternshipForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Add your latest internship details",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF101828),
          ),
        ),
        SizedBox(height: 20.h),

        _buildFieldLabel("Company name"),
        SizedBox(height: 6.h),
        _buildTextField(
          controller: _companyController,
          hintText: "e.g. ApnaTime Tech",
        ),
        SizedBox(height: 16.h),

        _buildFieldLabel("Intern title"),
        SizedBox(height: 6.h),
        _buildTextField(
          controller: _jobTitleController,
          hintText: "e.g. software developer",
        ),
        SizedBox(height: 16.h),

        _buildFieldLabel("Description (optional)"),
        SizedBox(height: 6.h),
        _buildDescriptionTextField(),
        SizedBox(height: 20.h),

        // Internship start date
        _buildFieldLabel("Internship start date"),
        SizedBox(height: 6.h),
        Row(
          children: [
            Expanded(
              child: _buildDropdownSelector(
                hintText: _startMonth ?? "Month",
                items: _months,
                selectedValue: _startMonth,
                onChanged: (val) => setState(() => _startMonth = val),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildDropdownSelector(
                hintText: _startYear ?? "Year",
                items: _years,
                selectedValue: _startYear,
                onChanged: (val) => setState(() => _startYear = val),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Checkbox: Currently working here
        GestureDetector(
          onTap: () {
            setState(() {
              _isCurrentlyWorkingIntern = !_isCurrentlyWorkingIntern;
            });
          },
          child: Row(
            children: [
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: Checkbox(
                  value: _isCurrentlyWorkingIntern,
                  activeColor: const Color(0xFF86BAA1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                  onChanged: (val) {
                    setState(() {
                      _isCurrentlyWorkingIntern = val ?? false;
                    });
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                "I am currently working here",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF344054),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Internship end date (if not currently working)
        if (!_isCurrentlyWorkingIntern) ...[
          _buildFieldLabel("Internship end date"),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: _buildDropdownSelector(
                  hintText: _endMonth ?? "Month",
                  items: _months,
                  selectedValue: _endMonth,
                  onChanged: (val) => setState(() => _endMonth = val),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildDropdownSelector(
                  hintText: _endYear ?? "Year",
                  items: _years,
                  selectedValue: _endYear,
                  onChanged: (val) => setState(() => _endYear = val),
                ),
              ),
            ],
          ),
        ],

        SizedBox(height: 20.h),
      ],
    );
  }

  // ================= UI HELPER WIDGETS =================
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF101828),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF344054),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(fontSize: 14.sp, color: const Color(0xFF101828)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF98A2B3)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
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
          borderSide: const BorderSide(color: Color(0xFF86BAA1), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDescriptionTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 2000,
          onChanged: (_) => setState(() {}),
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF101828)),
          decoration: InputDecoration(
            hintText: "Enter description",
            hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF98A2B3)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            counterText: "",
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
              borderSide: const BorderSide(color: Color(0xFF86BAA1), width: 1.5),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "${_descriptionController.text.length}/2000",
          style: TextStyle(
            fontSize: 11.sp,
            color: const Color(0xFF98A2B3),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownSelector({
    required String hintText,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(
            hintText,
            style: TextStyle(
              fontSize: 13.sp,
              color: selectedValue != null ? const Color(0xFF101828) : const Color(0xFF98A2B3),
            ),
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF667085), size: 20.sp),
          isExpanded: true,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF101828)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildOptionPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF86BAA1) : const Color(0xFFD0D5DD),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF0D8A48) : const Color(0xFF344054),
          ),
        ),
      ),
    );
  }
}
