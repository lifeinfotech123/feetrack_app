import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/data/models/category_model/staff_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/shimmer.dart';
import 'package:vlr/views/screens/gym/gym_profile/widget/gym_profile_trainer_section/gym_profile_trainer_profile_widget.dart';

import 'package:vlr/views/screens/gym/gym_select_trainer_screen/gym_select_trainer_screen.dart';

class GYMProfileTrainerSection extends StatelessWidget {
  final String? listingId;
  const GYMProfileTrainerSection({
    super.key,
    this.listingId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GymController>(builder: (gymController) {
      final trainers = gymController.gymTrainerModelList;
      final bool isLoading = gymController.isGymTrainersLoading;

      // If finished loading and no trainers for this gym, do not display anything
      if (!isLoading && trainers.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sizedBoxHeight(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Expert Trainers",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: blackText1,
                    ),
              ),
              if (trainers.length > 2)
                GestureDetector(
                  onTap: () {
                    navigate(
                      context: context,
                      page: const GymSelectTrainerScreen(),
                    );
                  },
                  child: Text(
                    "View All",
                    style: Helper(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryText1,
                        ),
                  ),
                ),
            ],
          ),
          sizedBoxHeight(height: 14),
          SizedBox(
            height: 275,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemBuilder: (context, index) {
                final staff = isLoading ? StaffModel() : trainers[index];
                return CustomShimmer(
                  isLoading: isLoading,
                  child: GYmProfileTrainerProfileWidget(
                    staffModel: staff,
                  ),
                );
              },
              separatorBuilder: (_, __) => sizedBoxWidth(width: 14),
              itemCount: isLoading ? 3 : trainers.length,
            ),
          ),
          sizedBoxHeight(height: 8),
        ],
      );
    });
  }
}
