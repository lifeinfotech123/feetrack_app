import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/kyc_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/custom_dropdown.dart';
import 'package:vlr/views/widget/text_box/app_text_box.dart';

class IdentityDetailsSection extends StatelessWidget {
  const IdentityDetailsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KycController>(builder: (kycController) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Identity Details",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800, fontSize: 24, color: primaryText1),
        ),
        sizedBoxHeight(height: 4),
        Text(
          "Please provide your official information",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400, fontSize: 14, color: greyText2),
        ),
        sizedBoxHeight(height: 24),
        AppTextFieldWithHeading(
          controller: kycController.fullNameController,
          borderRadius: 999,
          heading: "FULL NAME",
          hindText: "As per Aadhaar Card",
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your full name";
            }
            return null;
          },
        ),
        sizedBoxHeight(height: 16),
        Row(
          children: [
            Expanded(
              child: AppTextFieldWithHeading(
                controller: kycController.dobController,
                borderRadius: 999,
                suffix: const Icon(Icons.calendar_month_outlined),
                heading: " DATE OF BIRTH",
                hindText: "DD - MM -YYYY",
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).unfocus(); // Close keyboard

                  final DateTime? picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    initialDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: primaryColor,
                            onPrimary: Colors.white,
                            onSurface: black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (picked != null) {
                    final formatted =
                        "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";

                    kycController.dobController.text = formatted;
                    kycController.update();
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select of date of birth";
                  }
                  return null;
                },
              ),
            ),
            sizedBoxWidth(width: 16),
            Expanded(
              child: CustomDropDownList(
                heading: "GENDER",
                borderRadius: 999,
                items:
                    kycController.genderList.map((e) => e.toString()).toList(),
                value: kycController.gender,
                onChanged: (value) {
                  value = kycController.gender;
                  kycController.update();
                },
              ),
            )
          ],
        ),
        sizedBoxHeight(height: 16),
        AppTextFieldWithHeading(
          controller: kycController.penNoController,
          borderRadius: 999,
          heading: "PEN NUMBER",
          hindText: "ABCDE1234F",
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your PEN number";
            }
            return null;
          },
        ),
        sizedBoxHeight(height: 16),
        AppTextFieldWithHeading(
          controller: kycController.aadhaarNoController,
          borderRadius: 999,
          heading: "AADHAAR NUMBER",
          hindText: "1234 5678 9012",
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your aadhaar number";
            }
            return null;
          },
        ),
        sizedBoxHeight(height: 40),
      ]);
    });
  }
}
