import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/widget/text_box/app_text_box.dart';

class ProfileBillingAddressSection extends StatelessWidget {
  const ProfileBillingAddressSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ADDRESS & LOCATION",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.4,
                  color: primaryColor.withValues(alpha: 0.60),
                ),
          ),
          sizedBoxHeight(height: 16),
          AppTextFieldWithHeading(
            controller: authController.address1Controller,
            borderRadius: 999,
            heading: "Address",
            maxLines: 2,
            hindText: "House/Flat no., Street, Area",
          ),
          sizedBoxHeight(height: 14),
          Row(
            children: [
              Expanded(
                child: AppTextFieldWithHeading(
                  controller: authController.cityController,
                  borderRadius: 999,
                  heading: "City",
                  hindText: "Enter city",
                  onChanged: (val) {
                    authController.city = val;
                  },
                ),
              ),
              sizedBoxWidth(width: 12),
              Expanded(
                child: AppTextFieldWithHeading(
                  controller: authController.stateController,
                  borderRadius: 999,
                  heading: "State",
                  hindText: "Enter state",
                  onChanged: (val) {
                    authController.state = val;
                  },
                ),
              ),
            ],
          ),
          sizedBoxHeight(height: 14),
          Row(
            children: [
              Expanded(
                child: AppTextFieldWithHeading(
                  controller: authController.pinCodeController,
                  borderRadius: 999,
                  heading: "Pin Code",
                  hindText: "Enter pin code",
                  keyboardType: TextInputType.number,
                ),
              ),
              sizedBoxWidth(width: 12),
              Expanded(
                child: AppTextFieldWithHeading(
                  controller: authController.countryController,
                  borderRadius: 999,
                  heading: "Country",
                  hindText: "India",
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
