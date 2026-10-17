import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/data/models/category_model/staff_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/shimmer.dart';
import 'package:vlr/views/screens/gym/gym_profile/widget/gym_profile_trainer_section/gym_profile_trainer_profile_widget.dart';

class GYMProfileTrainerSection extends StatelessWidget {
  const GYMProfileTrainerSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sizedBoxHeight(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Expert Trainers",
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
        GetBuilder<GymController>(builder: (gymController) {
          return GetBuilder<HomeController>(builder: (homeController) {
            List<StaffModel> trainers = [];
            if (gymController.gymTrainerModelList.isNotEmpty) {
              trainers = gymController.gymTrainerModelList;
            } else if (homeController.staffList.isNotEmpty) {
              trainers = homeController.staffList;
            } else if (homeController.selectListingModel?.trainers != null &&
                homeController.selectListingModel!.trainers!.isNotEmpty) {
              try {
                trainers = homeController.selectListingModel!.trainers!
                    .map((e) =>
                        StaffModel.fromJson(Map<String, dynamic>.from(e)))
                    .toList();
              } catch (_) {}
            }

            final bool isLoading =
                (gymController.isLoading || homeController.isStaffLoading) &&
                    trainers.isEmpty;

            if (!isLoading && trainers.isEmpty) {
              return SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    "No Expert Trainers Available",
                    style: Helper(context).textTheme.bodySmall,
                  ),
                ),
              );
            }

            return SizedBox(
              height: 285,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final staff = isLoading ? StaffModel() : trainers[index];
                  return CustomShimmer(
                    isLoading: isLoading,
                    child: GYmProfileTrainerProfileWidget(
                      staffModel: staff,
                    ),
                  );
                },
                separatorBuilder: (_, __) => sizedBoxWidth(width: 16),
                itemCount: isLoading ? 3 : trainers.length,
              ),
            );
          });
        })
      ],
    );
  }
}
