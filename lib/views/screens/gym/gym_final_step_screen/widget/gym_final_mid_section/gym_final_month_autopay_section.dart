import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/gym/gym_auto_pay_setup_screen/gym_auto_pay_setup_screen.dart';
import 'package:vlr/views/screens/gym/gym_final_step_screen/widget/gym_final_mid_section/month_auth_pay_benefty_row.dart';

import '../../../../../../generated/assets.dart';

class GYMFinalMonthlyAutoPaySection extends StatelessWidget {
  const GYMFinalMonthlyAutoPaySection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(builder: (subscriptionController) {
      return ExpandablePaymentCard(
        title: "Monthly Auto-Pay",
        subtitle: "The most seamless way to maintain your elite fitness routine.",
        imagePath: Assets.imagesStartCirlce,
        price: PriceConverter.convertRound(subscriptionController.billingPreviewModel?.total?.toString() ?? "0"),
        priceSuffix: "/month",
        benefits: monthlyAuthPayModelList,
        isRecommended: true,
        initiallyExpanded: true,
        actionButton: CustomButton(
          onTap: () {
            final bool isLoggedIn = Get.isRegistered<AuthController>() &&
                Get.find<AuthController>().isLoggedIn();
            if (!isLoggedIn) {
              showLoginRequiredDialog(
                context: context,
                title: "Login Required",
                message:
                    "Please login to your account first before setting up auto-pay.",
              );
              return;
            }
            navigate(context: context, page: const GymAutoPaySetupScreen());
          },
          height: 54,
          radius: 12,
          color: primaryText1,
          borderColor: primaryText1,
          title: "Choose Auto-Pay",
          textStyle: Helper(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: white,
              ),
        ),
      );
    });
  }
}
