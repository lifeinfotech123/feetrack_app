import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/base/image_picker_sheet.dart';
import 'package:vlr/views/screens/dashboard/profile/profile_edit_screen/widget/personal_infor_section.dart';
import 'package:vlr/views/screens/dashboard/profile/profile_edit_screen/widget/profile_billing_address_section.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthController auth = Get.find<AuthController>();
      auth.populateProfileControllers();
      auth.fetchProfile().then((_) {
        auth.populateProfileControllers();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: AppConstants.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                  spreadRadius: -4,
                  color: primaryText1.withValues(alpha: 0.20),
                ),
                BoxShadow(
                  offset: const Offset(0, 10),
                  blurRadius: 15,
                  spreadRadius: -3,
                  color: primaryText1.withValues(alpha: 0.20),
                )
              ]),
              child: GetBuilder<AuthController>(builder: (authController) {
                return CustomButton(
                  isLoading: authController.updateProfileLoading ||
                      authController.isLoading,
                  onTap: () {
                    authController.updateProfile().then((value) {
                      showToast(
                          message: value.message, typeCheck: value.isSuccess);
                      if (value.isSuccess) {
                        Get.back();
                      }
                    });
                  },
                  height: 50,
                  radius: 20,
                  color: primaryColor,
                  borderColor: primaryColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Save Changes",
                        style: Helper(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: white,
                            ),
                      ),
                      sizedBoxWidth(width: 12),
                      Icon(
                        Icons.check_circle_outline_outlined,
                        color: white,
                      )
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        shadowColor: black.withValues(alpha: 0.05),
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: primaryText1,
                letterSpacing: 1.4,
              ),
        ),
      ),
      body: GetBuilder<AuthController>(builder: (authController) {
        if (authController.isProfileLoading &&
            authController.userModel == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await authController.fetchProfile();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppConstants.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: _buildProfileImage(authController, context),
                ),
                sizedBoxHeight(height: 12),
                Center(
                  child: Column(
                    children: [
                      Text(
                        authController.userModel?.name ?? "",
                        style: Helper(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: primaryText1,
                            ),
                      ),
                      if (authController.userModel?.email != null &&
                          authController.userModel!.email!.isNotEmpty)
                        Text(
                          authController.userModel!.email!,
                          style: Helper(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: greyText3,
                              ),
                        ),
                    ],
                  ),
                ),
                sizedBoxHeight(height: 24),
                const PersonalInforSection(),
                sizedBoxHeight(height: 16),
                const ProfileBillingAddressSection(),
                sizedBoxHeight(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileImage(
      AuthController authController, BuildContext context) {
    bool hasLocalImage = authController.profileImage != null;

    return InkWell(
      onTap: () async {
        final file = await getImageBottomSheet(context);
        if (file != null) {
          authController.updateImages(file);
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: white, width: 4),
              boxShadow: [
                BoxShadow(
                    color: black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2)
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: hasLocalImage
                  ? Image.file(
                      authController.profileImage!,
                      height: 110,
                      width: 110,
                      fit: BoxFit.cover,
                    )
                  : CustomImage(
                      color: white,
                      isProfile: true,
                      path: authController.userModel?.image ?? "",
                      height: 110,
                      width: 110,
                      fit: BoxFit.cover,
                      radius: 100,
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration:
                  BoxDecoration(color: primaryText1, shape: BoxShape.circle),
              child: Icon(
                Icons.camera_alt,
                color: white,
                size: 18,
              ),
            ),
          )
        ],
      ),
    );
  }
}
