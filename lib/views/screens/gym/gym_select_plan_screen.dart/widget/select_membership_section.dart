import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/data/models/category_model/plan_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/shimmer.dart';
import 'package:vlr/views/screens/gym/gym_select_plan_screen.dart/widget/gym_plackage_widget.dart';
class SelectMemberShipSection extends StatelessWidget {
  const SelectMemberShipSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sizedBoxHeight(height: 40),
        Text(
          "SELECT MEMBERSHIP",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: greyText3,
            letterSpacing: 1.2,
          ),
        ),
        sizedBoxHeight(height: 16),
        GetBuilder<SubscriptionController>(builder: (subscriptionController) {
          if (!subscriptionController.isLoading &&
              subscriptionController.planModelList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/plannotfound.png',
                      height: 150,
                    ),
                    sizedBoxHeight(height: 20),
                    Text(
                      "No plan found",
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: greyText3,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            itemBuilder: (context, index) {
              final planModel = subscriptionController.isLoading
                  ? PlanModel()
                  : subscriptionController.planModelList[index];

              return GestureDetector(
                onTap: () {
                  subscriptionController.selectPlan(index);
                },
                child: CustomShimmer(
                  isLoading: subscriptionController.isLoading,
                  child: GYMPackageWidget(
                    planModel: planModel,
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => sizedBoxHeight(height: 16),
            itemCount: subscriptionController.isLoading
                ? 4
                : subscriptionController.planModelList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          );
        }),
      ],
    );
  }
}
