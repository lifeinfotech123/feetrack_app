import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/data/models/category_model/staff_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class SelectGYMTrainerProfileWidget extends StatelessWidget {
  final StaffModel staffModel;
  const SelectGYMTrainerProfileWidget({
    super.key,
    required this.staffModel,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GymController>(builder: (gymController) {
      return Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(48),
            color: white,
            border: staffModel.id == gymController.selectGymTrainerModel?.id
                ? Border.all(
                    width: 3,
                    color: primaryText1,
                  )
                : null),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomImage(
              path: staffModel.photoUrl ?? "",
              height: 292,
              width: double.infinity,
              fit: BoxFit.contain,
              radius: 32,
            ),
            sizedBoxHeight(height: 24),
            Text(
              staffModel.name ?? "",
              style: Helper(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: blackText1,
                  ),
            ),
            sizedBoxHeight(height: 4),
            Text(
              staffModel.specialization ?? "",
              style: Helper(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: greyText2,
                  ),
            ),
            sizedBoxHeight(height: 16),
            Divider(
              color: greyLight,
            ),
            sizedBoxHeight(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  staffModel.experienceYears ?? "",
                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryText1,
                      ),
                ),
                GestureDetector(
                  onTap: () {
                    if (gymController.selectGymTrainerModel?.id ==
                        staffModel.id) {
                      gymController.selectGymTrainerModel = null;
                    } else {
                      gymController.selectGymTrainerModel = staffModel;
                    }
                    gymController.update();
                  },
                  child:
                      staffModel.id == gymController.selectGymTrainerModel?.id
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                  color: blueDark,
                                  borderRadius: BorderRadius.circular(999)),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: white,
                                    size: 16,
                                  ),
                                  sizedBoxWidth(width: 8),
                                  Text(
                                    "Selected",
                                    style: Helper(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: white,
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.add,
                                color: primaryText1,
                                size: 28,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: primaryText1,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                )
              ],
            ),
          ],
        ),
      );
    });
  }
}
