import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/generated/assets.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/shimmer.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';
import 'package:vlr/views/base/dialogs/logout_dialog.dart';
import 'package:vlr/services/app_router.dart';
import 'package:vlr/views/screens/dashboard/profile/profile_screen/widget/row_security_widget.dart';

class ProfileSecurityAndAccount extends StatelessWidget {
  const ProfileSecurityAndAccount({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sizedBoxHeight(height: 36),
        Text(
          "SECURITY & ACCOUNT",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: greyText2,
              letterSpacing: 1.4),
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
          child: GetBuilder<AuthController>(builder: (authController) {
            final _profileInfoRowModelList = profileInfoRowModelList(
              authController,
              context,
            );
            return ListView.separated(
              itemBuilder: (context, index) {
                final _model = _profileInfoRowModelList[index];
                return CustomShimmer(
                  isLoading: authController.isLoading,
                  child: RowOfSecurityWidget(
                    profileInfoRowModel: _model,
                  ),
                );
              },
              separatorBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(
                  color: greyLight4.withValues(alpha: 0.10),
                ),
              ),
              itemCount: _profileInfoRowModelList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            );
          }),
        ),
        sizedBoxHeight(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          decoration: BoxDecoration(
            color: redDark.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              width: 1,
              color: greyLight4.withValues(alpha: 0.30),
            ),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.delete_forever_sharp,
                  color: redDark,
                ),
              ),
              sizedBoxWidth(width: 16),
              Expanded(
                child: Text(
                  "Delete Account",
                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: redDark,
                      ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_outlined,
                color: redDark,
              )
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileInfoRowModel {
  final String icon;
  final String? title;
  final Function()? onTap;

  ProfileInfoRowModel(
      {required this.icon, required this.title, required this.onTap});
}

List<ProfileInfoRowModel> profileInfoRowModelList(
        AuthController authController, BuildContext context) =>
    [
      ProfileInfoRowModel(
          icon: Assets.svgsLaws, title: "Terms & Conditions", onTap: () {}),
      ProfileInfoRowModel(
          icon: Assets.svgsPrivacyPolicy,
          title: "Privacy Policy",
          onTap: () {}),
      ProfileInfoRowModel(
          icon: Assets.svgsCash, title: "Refund Policy", onTap: () {}),
      ProfileInfoRowModel(
          icon: Assets.svgsHelpAndSupport,
          title: "Help & Support",
          onTap: () {}),
      ProfileInfoRowModel(
          icon: Assets.svgsLogout,
          title: "Logout",
          onTap: () async {
            bool? logout = await showLogoutDialogue(context: context);
            if (logout == true) {
              final value = await authController.logout();
              showToast(
                  message: value.message.isNotEmpty
                      ? value.message
                      : "Logged out successfully",
                  typeCheck: true);
              if (context.mounted) {
                navigate(
                    context: context,
                    isRemoveUntil: true,
                    page: const LoginScreen());
              }
              AppRouter.goToLogin();
            }
          }),
    ];
