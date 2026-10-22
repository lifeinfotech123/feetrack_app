import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/coupons_controller.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/hospital/features/appointments/presentation/screen/booking_succsess_screen.dart';
import 'package:vlr/views/screens/gym/gym_book_visit_success/gym_book_visit_success_screen.dart';
import 'package:vlr/views/screens/gym/gym_final_step_screen/widget/gym_final_mid_section/month_auth_pay_benefty_row.dart';
import 'package:vlr/views/base/web_view.dart';
import '../../../../../../generated/assets.dart';

class GYMFinalOneTimePaymentSection extends StatelessWidget {
  const GYMFinalOneTimePaymentSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(builder: (subscriptionController) {
      return ExpandablePaymentCard(
        title: "One-Time Payment",
        subtitle: "Perfect for flexible travelers or those testing the elite waters.",
        imagePath: Assets.imagesCashCirlce,
        price: PriceConverter.convertRound(subscriptionController.billingPreviewModel?.total?.toString() ?? "0"),
        priceSuffix: "/total",
        benefits: gymOneTimePaymentList,
        actionButton: CustomButton(
          isLoading: subscriptionController.isLoading,
          onTap: () {
            final bool isLoggedIn = Get.isRegistered<AuthController>() &&
                Get.find<AuthController>().isLoggedIn();
            if (!isLoggedIn) {
              showLoginRequiredDialog(
                context: context,
                title: "Login Required",
                message:
                    "Please login to your account first before confirming the booking.",
              );
              return;
            }

            final homeController = Get.find<HomeController>();
            final gymController = Get.find<GymController>();
            final couponsController = Get.find<CouponsController>();

            subscriptionController.createSubscription(
              listingId: homeController.selectListingModel?.id ?? "",
              planId: subscriptionController.selectedPlan?.id ?? "",
              durationId: subscriptionController.selectedDuration?.type ?? "",
              paymentMode: "online",
              couponCode: couponsController.selectCouponsCodeModel?.code,
              staffId: gymController.selectGymTrainerModel?.id,
              roomId: subscriptionController.selectedRoomId,
              bedsBooked: subscriptionController.selectedBedsCount,
            ).then((value) {
              if (value.isSuccess) {
                String? paymentLink;
                try {
                  paymentLink = value.data['payment_info']['payment_link'];
                } catch (e) {
                  paymentLink = null;
                }

                if (paymentLink != null && paymentLink.isNotEmpty) {
                  navigate(
                    context: context,
                    page: CustomWebView(url: paymentLink, title: "Payment"),
                  );
                } else {
                  navigate(
                    context: context,
                    page: BookingSuccsessScreen(
                      bookingType: 'gym',
                      isMembership: true,
                      bookingId: value.data?['booking_number']?.toString() ??
                          value.data?['visit_id']?.toString(),
                      gymTitle: homeController.selectListingModel?.title,
                      packageName: subscriptionController.selectedPlan?.name,
                      amount: subscriptionController.billingPreviewModel?.total
                          ?.toString(),
                      paymentMethod: 'online',
                      status: 'confirmed',
                      bookingData: value.data is Map<String, dynamic>
                          ? value.data
                          : null,
                    ),
                    isRemoveUntil: true,
                  );
                }
              } else {
                showToast(message: value.message, toastType: ToastType.error);
              }
            });
          },
          height: 54,
          radius: 12,
          color: primaryText1,
          borderColor: primaryText1,
          title: "Pay One-Time",
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

List<MonthlyAuthPayModel> gymOneTimePaymentList = [
  MonthlyAuthPayModel(
      title: "Fixed-Term Access",
      subTitle: "Full 30-day validity for every payment cycle."),
  MonthlyAuthPayModel(
      title: "Total Payment Control",
      subTitle: "No hidden auto-debits; manual renewal is always required."),
  MonthlyAuthPayModel(
      title: "Dependable Scheduling",
      subTitle:
          "Standard priority processing for consistent and reliable transactions.")
];
