import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/data/models/category_model/staff_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class SelectTrainerMedSection extends StatelessWidget {
  const SelectTrainerMedSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GymController>(builder: (gymController) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sizedBoxHeight(height: 30),
          if (!gymController.isGymTrainersLoading &&
              gymController.gymTrainerModelList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("No Trainers Available"),
              ),
            ),
          ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final trainModel = gymController.isGymTrainersLoading
                    ? StaffModel()
                    : gymController.gymTrainerModelList[index];
                return GestureDetector(
                  onTap: () {
                    if (gymController.selectGymTrainerModel?.id ==
                        trainModel.id) {
                      gymController.selectGymTrainerModel = null;
                    } else {
                      gymController.selectGymTrainerModel = trainModel;
                    }
                    gymController.update();
                  },
                  child: SelectGYMTrainerProfileWidget(staffModel: trainModel),
                );
              },
              separatorBuilder: (_, __) => sizedBoxHeight(height: 24),
              itemCount: gymController.isGymTrainersLoading
                  ? 3
                  : gymController.gymTrainerModelList.length),
        ],
      );
    });
  }
}

class SelectGYMTrainerProfileWidget extends StatelessWidget {
  final StaffModel staffModel;
  const SelectGYMTrainerProfileWidget({
    super.key,
    required this.staffModel,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GymController>(builder: (gymController) {
      final bool isSelected = staffModel.id != null &&
          staffModel.id == gymController.selectGymTrainerModel?.id;
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: white,
          border: isSelected ? Border.all(width: 2, color: primaryColor) : null,
          boxShadow: [
            BoxShadow(
              color: black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  child: CustomImage(
                    path: staffModel.photoUrl ?? "",
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: white, size: 20),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              staffModel.name ?? "",
                              style: Helper(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: blackText1,
                                  ),
                            ),
                            sizedBoxHeight(height: 4),
                            Text(
                              staffModel.specialization ?? "",
                              style: Helper(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: greyText3,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: blueLight5.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${staffModel.experienceYears ?? "0"} Yrs Exp",
                          style: Helper(context).textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                        ),
                      ),
                    ],
                  ),
                  sizedBoxHeight(height: 20),
                  Divider(color: greyLight, height: 1),
                  sizedBoxHeight(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Available Today",
                            style:
                                Helper(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                      color: greyText3,
                                    ),
                          ),
                          Text(
                            "9:00 AM - 6:00 PM",
                            style:
                                Helper(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: blackText1,
                                    ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            gymController.selectGymTrainerModel = null;
                          } else {
                            gymController.selectGymTrainerModel = staffModel;
                          }
                          gymController.update();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : white,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? null
                                : Border.all(color: primaryColor),
                          ),
                          child: Text(
                            isSelected ? "Selected" : "Select",
                            style:
                                Helper(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? white : primaryColor,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
