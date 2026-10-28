import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/dashboard/profile/profile_screen/widget/row_personal_details_widget.dart';

class UserProfilePersonalDetailsSection extends StatelessWidget {
  const UserProfilePersonalDetailsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sizedBoxHeight(height: 32),
          Text(
            "PERSONAL DETAILS",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: greyText2,
                ),
          ),
          sizedBoxHeight(height: 16),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                width: 1,
                color: greyLight4.withValues(alpha: 0.30),
              ),
            ),
            child: Column(
              children: [
                const RowOfPersonalDetailsWidget(
                  icon: Icons.location_on_outlined,
                  title: "RESIDENTIAL ADDRESS",
                  subTitle: "124 Wall Street, Financial District, NY",
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(
                    color: greyLight4.withValues(alpha: 0.10),
                  ),
                ),
                RowOfPersonalDetailsWidget(
                  icon: Icons.phone_iphone_rounded,
                  title: "MOBILE NUMBER",
                  subTitle: "+91 ${authController.userModel?.mobile ?? ""}",
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
