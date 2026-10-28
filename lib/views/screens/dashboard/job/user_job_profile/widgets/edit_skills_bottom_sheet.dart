import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vlr/services/theme.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/job_candidate_profile_update_controller.dart';
import 'package:vlr/data/models/candidate_profile_model.dart';
import 'package:vlr/services/constants.dart';

class EditSkillsBottomSheet extends StatefulWidget {
  final CandidateProfileData? candidateProfile;

  const EditSkillsBottomSheet({
    super.key,
    this.candidateProfile,
  });

  @override
  State<EditSkillsBottomSheet> createState() => _EditSkillsBottomSheetState();
}

class _EditSkillsBottomSheetState extends State<EditSkillsBottomSheet> {
  final TextEditingController _skillController = TextEditingController();
  late List<String> _skills;

  static const List<String> _suggestedSkills = [
    "Flutter",
    "React Native",
    "Android",
    "Dart",
    "Firebase",
    "Java",
    "Kotlin",
    "Python",
    "Node.js",
    "REST API",
    "Git",
    "SQL",
    "MongoDB",
    "UI/UX Design",
    "Software Development",
  ];

  @override
  void initState() {
    super.initState();
    final currentProfile = widget.candidateProfile ?? Get.find<JobCandidateProfileUpdateController>().candidateProfile;
    _skills = List<String>.from(currentProfile?.skills ?? [
      "React Native",
      "Flutter",
      "Android",
      "Firebase",
      "Dart",
    ]);
  }

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill(String skillName) {
    final trimmed = skillName.trim();
    if (trimmed.isEmpty) return;

    if (_skills.any((s) => s.toLowerCase() == trimmed.toLowerCase())) {
      showToast(message: "'$trimmed' is already added", toastType: ToastType.warning);
      return;
    }

    setState(() {
      _skills.add(trimmed);
      _skillController.clear();
    });
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  void _saveSkills() async {
    final controller = Get.find<JobCandidateProfileUpdateController>();
    final currentProfile = controller.candidateProfile ?? CandidateProfileData();

    final updatedProfile = CandidateProfileData(
      highestEducation: currentProfile.highestEducation,
      doctorate: currentProfile.doctorate,
      educations: currentProfile.educations,
      skills: _skills,
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

    final response = await controller.updateCandidateProfile(profileData: updatedProfile);

    if (response.isSuccess) {
      showToast(message: "Skills updated successfully!", toastType: ToastType.success);
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      showToast(message: response.message, toastType: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handlebar & Title Bar
            SizedBox(height: 12.h),
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFEAECF0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 12.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Skills",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF101828),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 22.sp, color: const Color(0xFF667085)),
                    onPressed: () => Navigator.pop(context),
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
                    // Input box for adding new skill
                    Text(
                      "Add Skills",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF344054),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _skillController,
                            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF101828)),
                            onFieldSubmitted: (val) => _addSkill(val),
                            decoration: InputDecoration(
                              hintText: "e.g. Flutter, React Native, SQL",
                              hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF98A2B3)),
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
                                borderSide: const BorderSide(color: primaryColor, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => _addSkill(_skillController.text),
                          child: Text(
                            "Add",
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Current Selected Skills Chips
                    Text(
                      "Your Selected Skills (${_skills.length})",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF344054),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    if (_skills.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Text(
                          "No skills added yet. Add skills above or select suggestions below.",
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF667085)),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _skills.map((skill) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBF0FF),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: primaryColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  skill,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                GestureDetector(
                                  onTap: () => _removeSkill(skill),
                                  child: Icon(Icons.cancel_rounded, size: 16.sp, color: primaryColor),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    SizedBox(height: 24.h),

                    // Suggested Skills Section
                    Text(
                      "Suggested Skills",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF344054),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _suggestedSkills.map((s) {
                        final isAdded = _skills.any((existing) => existing.toLowerCase() == s.toLowerCase());
                        return InkWell(
                          onTap: () {
                            if (isAdded) {
                              _removeSkill(_skills.firstWhere((existing) => existing.toLowerCase() == s.toLowerCase()));
                            } else {
                              _addSkill(s);
                            }
                          },
                          borderRadius: BorderRadius.circular(20.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: isAdded ? const Color(0xFFEBF0FF) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isAdded ? primaryColor : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isAdded ? Icons.check_rounded : Icons.add_rounded,
                                  size: 14.sp,
                                  color: isAdded ? primaryColor : const Color(0xFF64748B),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  s,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: isAdded ? FontWeight.w700 : FontWeight.w500,
                                    color: isAdded ? primaryColor : const Color(0xFF475467),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            // Save Button
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
                      onPressed: isUpdating ? null : _saveSkills,
                      child: isUpdating
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              "SAVE SKILLS",
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
}
