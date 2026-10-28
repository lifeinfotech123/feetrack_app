import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';

class GYmCheckOutMidSection extends StatelessWidget {
  const GYmCheckOutMidSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(builder: (subscriptionController) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: InkWell(
              onTap: () {
             //   navigate(context: context, page: const CouponCodeScreen());
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: greyLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: greyLight2.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_offer_outlined, color: primaryText1, size: 22),
                    sizedBoxWidth(width: 12),
                    Expanded(
                      child: Text(
                        "Have a coupon code?",
                        style: Helper(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: blackText1,
                            ),
                      ),
                    ),
                    Text(
                      "Apply",
                      style: Helper(context).textTheme.titleSmall?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryText1,
                          ),
                    ),
                    Icon(Icons.chevron_right, color: primaryText1, size: 18),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: 1,
                color: greyLight2.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Order Summary",
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: blackText1,
                          ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.security, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          "Secure",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Amount",
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: greyText2,
                          ),
                    ),
                    Text(
                      PriceConverter.convertToNumberFormat(
                          subscriptionController.billingPreviewModel?.total ?? 0),
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: primaryText1,
                          ),
                    ),
                  ],
                ),
                sizedBoxHeight(height: 20),
                CustomButton(
                  onTap: () {
                    final bool isLoggedIn = Get.isRegistered<AuthController>() &&
                        Get.find<AuthController>().isLoggedIn();
                    if (!isLoggedIn) {
                      showLoginRequiredDialog(
                        context: context,
                        title: "Login Required",
                        message:
                            "Please login to your account first before proceeding to pay.",
                      );
                      return;
                    }
                    // navigate(context: context, page: const GymFinalStepScreen());
                  },
                  height: 50,
                  radius: 12,
                  color: primaryText1,
                  borderColor: primaryText1,
                  title: "Proceed to Pay",
                  textStyle: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: white,
                      ),
                ),
                sizedBoxHeight(height: 16),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        "By proceeding, you agree to our ",
                        style: Helper(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: greyText2,
                            ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          "Terms",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: primaryText1,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        " & ",
                        style: TextStyle(fontSize: 10, color: greyText2),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          "Policy",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: primaryText1,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
