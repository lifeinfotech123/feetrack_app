import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/custom_dropdown.dart';
import 'package:vlr/views/widget/text_box/app_text_box.dart';

class PersonalInforSection extends StatelessWidget {
  const PersonalInforSection({
    super.key,
  });

  Future<void> _selectDate(
      BuildContext context, AuthController authController) async {
    DateTime initialDate =
        DateTime.now().subtract(const Duration(days: 365 * 18));
    if (authController.dobController.text.isNotEmpty) {
      String text = authController.dobController.text.trim();
      if (text.contains("-")) {
        List<String> parts = text.split("-");
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            // YYYY-MM-DD
            initialDate = DateTime.tryParse(text) ?? initialDate;
          } else {
            // DD-MM-YYYY
            int? day = int.tryParse(parts[0]);
            int? month = int.tryParse(parts[1]);
            int? year = int.tryParse(parts[2]);
            if (day != null && month != null && year != null) {
              initialDate = DateTime(year, month, day);
            }
          }
        }
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: white,
              onSurface: primaryText1,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      authController.dobController.text =
          "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year.toString().padLeft(4, '0')}";
      authController.update();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PERSONAL INFORMATION",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.4,
                  color: primaryColor.withValues(alpha: 0.60),
                ),
          ),
          sizedBoxHeight(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextFieldWithHeading(
                  controller: authController.firstNameController,
                  hindText: "First Name",
                  heading: "First Name",
                  borderRadius: 999,
                  onChanged: (val) {
                    authController.updateFirstAndLastName(
                      val,
                      authController.lastNameController.text,
                    );
                  },
                ),
              ),
              sizedBoxWidth(width: 12),
              Expanded(
                child: AppTextFieldWithHeading(
                  controller: authController.lastNameController,
                  hindText: "Last Name",
                  heading: "Last Name",
                  borderRadius: 999,
                  onChanged: (val) {
                    authController.updateFirstAndLastName(
                      authController.firstNameController.text,
                      val,
                    );
                  },
                ),
              ),
            ],
          ),
          sizedBoxHeight(height: 14),
          AppTextFieldWithHeading(
            controller: authController.fullNameController,
            hindText: "Enter full name",
            heading: "Full Name",
            borderRadius: 999,
            onChanged: (val) {
              authController.updateFullName(val);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your full name";
              }
              return null;
            },
          ),
          sizedBoxHeight(height: 14),
          AppTextFieldWithHeading(
            controller: authController.emailController,
            hindText: "Enter your email address",
            heading: "Email Address",
            borderRadius: 999,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your email address";
              }
              return null;
            },
          ),
          sizedBoxHeight(height: 14),
          AppTextFieldWithHeading(
            controller: authController.mobileNoController,
            hindText: "Enter your mobile number",
            heading: "Mobile Number",
            borderRadius: 999,
            keyboardType: TextInputType.phone,
            prefixText: "+91 ",
            prefixStyle: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: primaryText1,
                ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your mobile number";
              }
              if (value.length != 10) {
                return "Please enter a valid 10-digit mobile number";
              }
              return null;
            },
          ),
          sizedBoxHeight(height: 16),
          // Gender Selector
          Text(
            "Gender",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primaryText1,
                ),
          ),
          sizedBoxHeight(height: 8),
          Row(
            children: authController.genderList.map((g) {
              bool isSelected =
                  authController.gender?.toLowerCase() == g.toLowerCase();
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    authController.setGender(g);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryText1
                          : grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected
                            ? primaryText1
                            : grey.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          g == "Male"
                              ? Icons.male
                              : g == "Female"
                                  ? Icons.female
                                  : Icons.transgender,
                          size: 18,
                          color: isSelected ? white : primaryText1,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          g,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? white : primaryText1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          sizedBoxHeight(height: 16),
          // DOB
          AppTextFieldWithHeading(
            controller: authController.dobController,
            hindText: "DD-MM-YYYY",
            heading: "Date of Birth",
            borderRadius: 999,
            readOnly: true,
            suffix: const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: primaryColor,
            ),
            onTap: () {
              _selectDate(context, authController);
            },
          ),
          sizedBoxHeight(height: 16),
          // Blood Group
          CustomDropDownList<String>(
            heading: "Blood Group",
            hintText: "Select Blood Group",
            borderRadius: 999,
            items: authController.bloodGroupList,
            value: authController.bloodGroupList
                    .contains(authController.bloodGroup?.toUpperCase())
                ? authController.bloodGroup?.toUpperCase()
                : null,
            onChanged: (val) {
              authController.setBloodGroup(val);
            },
          ),
          sizedBoxHeight(height: 16),
        ],
      );
    });
  }
}
