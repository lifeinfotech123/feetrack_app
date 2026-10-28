import 'package:flutter/material.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/state_manager.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/data/models/category_model/plan_during_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/shimmer.dart';
import 'package:vlr/views/screens/gym/gym_select_plan_screen.dart/widget/select_duration_widget.dart';


class SelectDurationSection extends StatelessWidget {
  const SelectDurationSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CHOOSE DURATION",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: greyText3,
            letterSpacing: 1.2,
          ),
        ),
        sizedBoxHeight(height: 16),
        GetBuilder<SubscriptionController>(builder: (subscriptionController) {
          return SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final model = subscriptionController.isLoading
                    ? PlanDurationModel()
                    : subscriptionController.planDurationList[index];

                return CustomShimmer(
                  isLoading: subscriptionController.isLoading,
                  child: GestureDetector(
                    onTap: () {
                      if (subscriptionController.isLoading) {
                        return;
                      }
                      final homeController = Get.find<HomeController>();
                      final listingId = homeController.selectListingModel?.id ?? "";
                      subscriptionController.selectDuration(index, listingId);
                    },
                    child: SelectDurationWidget(
                      planDurationModel: model,
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => sizedBoxWidth(width: 12),
              itemCount: subscriptionController.isLoading
                  ? 4
                  : subscriptionController.planDurationList.length,
              shrinkWrap: true,
            ),
          );
        })
      ],
    );
  }
}
