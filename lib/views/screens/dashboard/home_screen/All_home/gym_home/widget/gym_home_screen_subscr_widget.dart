import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/gym_home/widget/row_of_subsc_widget.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/gym_home/widget/subscription_status_widget.dart';

class GymHomeScreenMySubscrWidget extends StatelessWidget {
  const GymHomeScreenMySubscrWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 32),
            blurRadius: 32,
            spreadRadius: 0,
            color: primaryText1.withValues(alpha: 0.06),
          )
        ],
        border: Border.all(
          width: 1,
          color: const Color(0xFFC3C6D11A).withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MY SUBSCRIPTION",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: greyText2,
                    ),
              ),
              const SubscriptionStatusWidget(
                isActive: false,
              )
            ],
          ),
          sizedBoxHeight(height: 24),
          RichText(
            text: TextSpan(
                text: "189.00",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: primaryText1,
                    ),
                children: [
                  TextSpan(
                    text: " /month",
                    style: Helper(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: greyText2,
                        ),
                  ),
                ]),
          ),
          sizedBoxHeight(height: 24),
          const RowOfSubscWidget(
            title: "Next Billing",
            subTitle: "Oct 24, 2024",
          ),
          sizedBoxHeight(height: 28),
          const RowOfSubscWidget(
            title: "Plan Type",
            subTitle: "All-Access Elite",
          ),
          sizedBoxHeight(height: 24),
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 6,
                spreadRadius: -4,
                color: primaryText1.withValues(alpha: 0.20),
              ),
              BoxShadow(
                offset: Offset(0, 10),
                blurRadius: 15,
                spreadRadius: -3,
                color: primaryText1.withValues(alpha: 0.20),
              )
            ]),
            child: CustomButton(
              onTap: () {
                // navigate(context: context, page: GymFinalStepScreen());
              },
              height: 68,
              radius: 999,
              color: primaryText1,
              borderColor: primaryText1,
              child: Text(
                "Renew Subscription",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
