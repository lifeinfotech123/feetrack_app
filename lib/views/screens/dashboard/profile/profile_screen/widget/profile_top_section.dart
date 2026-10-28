import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/dashboard/profile/profile_edit_screen/profile_edit_screen.dart';

class ProfileTopSection extends StatelessWidget {
  const ProfileTopSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GetBuilder<AuthController>(builder: (authController) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryText1,
                    greenDark,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: white,
                  shape: BoxShape.circle,
                ),
                child: const CustomImage(
                  path: Assets.imagesReview1,
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                  isProfile: true,
                  radius: 999,
                ),
              ),
            ),
            sizedBoxHeight(height: 16),
            Text(
              capitalize(authController.userModel?.name ?? ""),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Helper(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                    color: primaryText1,
                  ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                authController.userModel?.email ?? "",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: greyText2,
                    ),
              ),
            ),

            (authController.userModel?.emailVerifiedAt == true) &&
                    authController.userModel?.emailVerifiedAt == true
                ? Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF86F2E4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: Color(0xFF006F66),
                          size: 16,
                        ),
                        sizedBoxWidth(width: 8),
                        Text(
                          "VERIFIED MEMBER",
                          style: Helper(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: const Color(0xFF006F66),
                              ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(
                    height: 12,
                  ),
            // sizedBoxHeight(height: 12),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: CustomButton(
                onTap: () {
                  navigate(context: context, page: const ProfileEditScreen());
                },
                color: primaryText1,
                borderColor: primaryText1,
                height: 40,
                radius: 32,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mode_edit_outline_outlined,
                      color: white,
                      size: 20,
                    ),
                    sizedBoxWidth(width: 12),
                    Text(
                      "Edit Profile",
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: white,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
