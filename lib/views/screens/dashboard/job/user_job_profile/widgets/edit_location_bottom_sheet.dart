import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/job_candidate_profile_update_controller.dart';
import 'package:vlr/data/models/candidate_profile_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class EditLocationBottomSheet extends StatefulWidget {
  final CandidateProfileData? candidateProfile;

  const EditLocationBottomSheet({
    super.key,
    this.candidateProfile,
  });

  @override
  State<EditLocationBottomSheet> createState() => _EditLocationBottomSheetState();
}

class _EditLocationBottomSheetState extends State<EditLocationBottomSheet> {
  late List<String> _preferredCities;
  final TextEditingController _currentCityController = TextEditingController();
  final TextEditingController _currentAreaController = TextEditingController();
  final TextEditingController _hometownController = TextEditingController();

  String? _selectedCityFromDropdown;

  static const List<String> _availableCities = [
    "Lucknow, UP",
    "Delhi NCR",
    "Noida, UP",
    "Gurgaon, HR",
    "Bengaluru, KA",
    "Mumbai, MH",
    "Pune, MH",
    "Hyderabad, TS",
    "Remote",
  ];

  @override
  void initState() {
    super.initState();
    final profile = widget.candidateProfile ?? Get.find<JobCandidateProfileUpdateController>().candidateProfile;
    
    _preferredCities = List<String>.from(profile?.preferredLocations ?? ["Lucknow, UP"]);

    _currentCityController.text = "Lucknow";
    _currentAreaController.text = "Kaiserbagh";
    _hometownController.text = "";
  }

  @override
  void dispose() {
    _currentCityController.dispose();
    _currentAreaController.dispose();
    _hometownController.dispose();
    super.dispose();
  }

  void _addPreferredCity(String city) {
    if (_preferredCities.contains(city)) {
      showToast(message: "'$city' is already added", toastType: ToastType.warning);
      return;
    }
    if (_preferredCities.length >= 3) {
      showToast(message: "You can add up to 3 preferred job cities", toastType: ToastType.warning);
      return;
    }
    setState(() {
      _preferredCities.add(city);
      _selectedCityFromDropdown = null;
    });
  }

  void _removePreferredCity(String city) {
    setState(() {
      _preferredCities.remove(city);
    });
  }

  void _saveLocation() async {
    final controller = Get.find<JobCandidateProfileUpdateController>();
    final currentProfile = controller.candidateProfile ?? CandidateProfileData();

    // Prepare updated preferred locations
    List<String> updatedLocations = List<String>.from(_preferredCities);
    if (_currentCityController.text.trim().isNotEmpty && !updatedLocations.contains(_currentCityController.text.trim())) {
      // Add current location if not present
      String currentLoc = _currentAreaController.text.trim().isNotEmpty
          ? "${_currentAreaController.text.trim()}, ${_currentCityController.text.trim()}"
          : _currentCityController.text.trim();
      if (!updatedLocations.contains(currentLoc)) {
        updatedLocations.add(currentLoc);
      }
    }

    final updatedProfile = CandidateProfileData(
      highestEducation: currentProfile.highestEducation,
      doctorate: currentProfile.doctorate,
      educations: currentProfile.educations,
      skills: currentProfile.skills,
      preferredJobRoles: currentProfile.preferredJobRoles,
      preferredLocations: updatedLocations,
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
      showToast(message: "Location updated successfully!", toastType: ToastType.success);
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
                    "Edit Location",
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
                    // 1. Preferred Job City
                    Text(
                      "Preferred job city",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Jobs are shown based on your preferred city",
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF667085)),
                    ),
                    SizedBox(height: 12.h),

                    // City Selector Dropdown
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFEAECF0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCityFromDropdown,
                          hint: Text(
                            "Add upto 3 cities",
                            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF98A2B3)),
                          ),
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor, size: 22.sp),
                          isExpanded: true,
                          items: _availableCities.map((city) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Text(city, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF101828))),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              _addPreferredCity(val);
                            }
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Tip Banner
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          Text("💡 ", style: TextStyle(fontSize: 14.sp)),
                          Expanded(
                            child: Text(
                              "Add more preferred job cities to increase your chances of getting a job",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF92400E),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Preferred City Chips
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _preferredCities.map((city) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF0FF),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: primaryColor, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                city,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: () => _removePreferredCity(city),
                                child: Icon(Icons.close_rounded, size: 16.sp, color: primaryColor),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 24.h),

                    // 2. Current Location Header with "Pick current location" action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Current location",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF101828),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _currentCityController.text = "Lucknow";
                              _currentAreaController.text = "Kaiserbagh";
                            });
                            showToast(message: "Location detected", toastType: ToastType.info);
                          },
                          child: Row(
                            children: [
                              Icon(Icons.my_location_rounded, size: 16.sp, color: primaryColor),
                              SizedBox(width: 4.w),
                              Text(
                                "Pick current location",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    // City input
                    _buildTextField(
                      controller: _currentCityController,
                      hintText: "City",
                    ),
                    SizedBox(height: 10.h),

                    // Area/Locality input
                    _buildTextField(
                      controller: _currentAreaController,
                      hintText: "Area / Locality",
                    ),

                    SizedBox(height: 24.h),

                    // 3. Hometown
                    Text(
                      "Hometown",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    _buildTextField(
                      controller: _hometownController,
                      hintText: "Enter your hometown",
                      borderColor: primaryColor,
                    ),

                    SizedBox(height: 24.h),
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
                      onPressed: isUpdating ? null : _saveLocation,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    Color? borderColor,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(fontSize: 14.sp, color: const Color(0xFF101828)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF98A2B3)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: borderColor ?? const Color(0xFFEAECF0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: borderColor ?? const Color(0xFFEAECF0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }
}
