import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/gym/gym_billing_screen/widget/gym_checkout_top_section/gym_checkout_billing_widget.dart';

class GYMCheckoutTopSection extends StatelessWidget {
  const GYMCheckoutTopSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(builder: (subscriptionController) {
      final billing = subscriptionController.billingPreviewModel;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Billing Summary",
            style: Helper(context).textTheme.titleSmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: blackText1,
                ),
          ),
          sizedBoxHeight(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: white,
              border: Border.all(color: greyLight2.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: primaryText1,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    sizedBoxWidth(width: 8),
                    Text(
                      "Order Details",
                      style: Helper(context).textTheme.titleSmall?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: blackText1,
                          ),
                    ),
                  ],
                ),
                sizedBoxHeight(height: 20),
                GYMCheckoutBillingWidget(
                  title: billing?.planName ?? "Elite Membership",
                  subTitle: billing?.duration ?? "Annual Access Plan",
                  price: PriceConverter.convertToNumberFormat(billing?.subtotal ?? 0),
                ),
                if (billing?.room != null) ...[
                  const Divider(height: 32, thickness: 0.5),
                  GYMCheckoutBillingWidget(
                    title: "Room ${billing?.room['room_number'] ?? ""}",
                    subTitle: "${billing?.room['room_type'] ?? ""} Room",
                    price: "",
                  ),
                ],
                if (billing?.bedsBooked != null && billing!.bedsBooked! > 1) ...[
                  const Divider(height: 32, thickness: 0.5),
                  GYMCheckoutBillingWidget(
                    title: "Beds Booked",
                    subTitle: "${billing.bedsBooked} beds",
                    price: "",
                  ),
                ],
                if (billing?.shiftFee != null && billing!.shiftFee! > 0) ...[
                  const Divider(height: 32, thickness: 0.5),
                  GYMCheckoutBillingWidget(
                    title: "Shift Fee",
                    subTitle: "Selected Shift Charge",
                    price: PriceConverter.convertToNumberFormat(billing.shiftFee!),
                  ),
                ],
                if (billing?.trainerFee != null && billing!.trainerFee! > 0) ...[
                  const Divider(height: 32, thickness: 0.5),
                  GYMCheckoutBillingWidget(
                    title: "Trainer Fee",
                    subTitle: "Expert Trainer Charge",
                    price: PriceConverter.convertToNumberFormat(billing.trainerFee!),
                  ),
                ],
                if (billing?.discount != null && billing!.discount! > 0) ...[
                  const Divider(height: 32, thickness: 0.5),
                  GYMCheckoutBillingWidget(
                    title: "Discount",
                    subTitle: "Coupon Applied",
                    price: "- ${PriceConverter.convertToNumberFormat(billing.discount!)}",
                    isNegative: true,
                  ),
                ],
                if (billing?.tax != null && billing!.tax! > 0) ...[
                  const Divider(height: 32, thickness: 0.5),
                  GYMCheckoutBillingWidget(
                    title: "Estimated Taxes",
                    subTitle: "VAT applied",
                    price: PriceConverter.convertToNumberFormat(billing.tax!),
                  ),
                ],
                if (billing?.securityDeposit != null && billing!.securityDeposit! > 0) ...[
                  const Divider(height: 32, thickness: 0.5),
                  GYMCheckoutBillingWidget(
                    title: "Security Deposit",
                    subTitle: "Refundable Amount",
                    price: PriceConverter.convertToNumberFormat(billing.securityDeposit!),
                  ),
                ],
              ],
            ),
          )
        ],
      );
    });
  }
}
