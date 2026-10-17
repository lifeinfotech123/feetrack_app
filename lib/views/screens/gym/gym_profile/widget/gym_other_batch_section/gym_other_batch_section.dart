import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/data/models/gym_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/gym_home/widget/gym_home_details_screen.dart';

class GYMProfileOtherBatchSection extends StatelessWidget {
  const GYMProfileOtherBatchSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      if (homeController.otherBrandedList.isEmpty) {
        return const SizedBox();
      }
      return Column(
        children: [
          sizedBoxHeight(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Other Branches",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: blackText1,
                    ),
              ),
              Text(
                "View All",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primaryText1,
                    ),
              ),
            ],
          ),
          sizedBoxHeight(height: 16),
          SizedBox(
            height: 320,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final _gymModel = gymModelList[index];
                return GestureDetector(
                  onTap: () {
                    navigate(
                        context: context, page: const GymHomeDetailsScreen());
                  },
                  child: const SizedBox(),
                  // GymHomeScreenGymWight(
                  //   gymModel: _gymModel,
                  // ),
                );
              },
              separatorBuilder: (_, __) => sizedBoxWidth(width: 24),
              itemCount: gymModelList.length,
            ),
          )
        ],
      );
    });
  }
}
