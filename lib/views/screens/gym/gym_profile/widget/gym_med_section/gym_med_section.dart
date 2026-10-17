import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/generated/assets.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/lanch_helper.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';
import 'package:vlr/views/screens/gym/gym_book_visit/gym_book_visit_screen.dart';
import 'package:vlr/views/screens/gym/gym_select_plan_screen.dart/gym_select_plan_screen.dart';

class GymProfileMedSection extends StatelessWidget {
  const GymProfileMedSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          sizedBoxHeight(height: 20),
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 6,
                spreadRadius: -4,
                color: black.withValues(alpha: 0.010),
              ),
              BoxShadow(
                offset: const Offset(0, 10),
                blurRadius: 15,
                spreadRadius: -3,
                color: black.withValues(alpha: 0.010),
              ),
            ]),
            child: CustomButton(
              height: 48,
              radius: 999,
              onTap: () {
                final bool isLoggedIn = Get.isRegistered<AuthController>() &&
                    Get.find<AuthController>().isLoggedIn();
                if (!isLoggedIn) {
                  showLoginRequiredDialog(
                    context: context,
                    title: "Login Required",
                    message:
                        "Please login to your account first before booking.",
                  );
                  return;
                }
                navigate(context: context, page: GymSelectPlanScreen());
              },
              color: const Color(0xFF022C7F),
              borderColor: const Color(0xFF022C7F),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Book Now",
                    style: Helper(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: white,
                        ),
                  ),
                  sizedBoxWidth(width: 8),
                  Icon(
                    Icons.arrow_forward_outlined,
                    color: white,
                    size: 20,
                  )
                ],
              ),
            ),
          ),
          sizedBoxHeight(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  onTap: () {
                    final bool isLoggedIn =
                        Get.isRegistered<AuthController>() &&
                            Get.find<AuthController>().isLoggedIn();
                    if (!isLoggedIn) {
                      showLoginRequiredDialog(
                        context: context,
                        title: "Login Required",
                        message:
                            "Please login to your account first before booking a visit.",
                      );
                      return;
                    }
                    navigate(
                      context: context,
                      page: const GymBookVisitScreen(),
                    );
                  },
                  height: 48,
                  color: white,
                  radius: 999,
                  borderColor: const Color(0xFF00206033).withValues(alpha: 0.20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        Assets.svgsCalender,
                        height: 18,
                        width: 20,
                      ),
                      sizedBoxWidth(width: 8),
                      Text(
                        "Book Visit",
                        style: Helper(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: primaryText1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              GetBuilder<HomeController>(
                builder: (homeController) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomButton(
                        radius: 999,
                        height: 48,
                        minWidth: 48,
                        color: greyText4,
                        borderColor: greyText4,
                        onTap: () {
                          LaunchHelper.callUs(
                            number:
                            homeController.selectListingModel?.phone ?? "",
                          );
                        },
                        child: SvgPicture.asset(
                          Assets.svgsCall,
                          height: 16,
                          width: 16,
                        ),
                      ),

                      const SizedBox(width: 8),

                      CustomButton(
                        radius: 999,
                        height: 48,
                        minWidth: 48,
                        color: greyText4,
                        borderColor: greyText4,
                        onTap: () {
                          if (homeController.isLoading) return;

                          LaunchHelper.openGoogleMap(
                            lat: homeController.selectListingModel?.lat ?? "",
                            lng: homeController.selectListingModel?.lng ?? "",
                          );
                        },
                        child: SvgPicture.asset(
                          Assets.svgsDirectionMap,
                          height: 18,
                          width: 18,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
