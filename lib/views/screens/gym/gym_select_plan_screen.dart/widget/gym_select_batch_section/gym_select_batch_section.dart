import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/data/models/category_model/batch_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/shimmer.dart';
import 'package:vlr/views/screens/gym/gym_select_plan_screen.dart/widget/gym_select_batch_section/gym_batch_widget.dart';

class SelectBatchTimingSelection extends StatelessWidget {
  const SelectBatchTimingSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GymController>(
      builder: (gymController) {
        return GetBuilder<SubscriptionController>(
          builder: (subscriptionController) {
            final hasSubBatches =
                subscriptionController.batchModelList.isNotEmpty;
            final hasGymShifts = gymController.gymShiftsList.isNotEmpty;

            if (subscriptionController.hasRooms) {
              return const SizedBox.shrink();
            }

            if (!hasSubBatches &&
                !hasGymShifts &&
                !gymController.isGymShiftsLoading &&
                !subscriptionController.isLoading) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sizedBoxHeight(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "GYM SHIFT / BATCH TIMING",
                      style: Helper(context).textTheme.titleSmall?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: greyText3,
                            letterSpacing: 1.2,
                          ),
                    ),
                    if (gymController.selectedGymShift != null)
                      Text(
                        gymController.selectedGymShift!.shiftName ?? "",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF022C7F),
                        ),
                      ),
                  ],
                ),
                sizedBoxHeight(height: 12),

                // If GymController has real shifts from v1/gym/gyms/{gym_id}/shifts
                if (hasGymShifts)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: gymController.isGymShiftsLoading
                        ? 2
                        : gymController.gymShiftsList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.15,
                    ),
                    itemBuilder: (context, index) {
                      if (gymController.isGymShiftsLoading) {
                        return CustomShimmer(
                          isLoading: true,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        );
                      }
                      final shift = gymController.gymShiftsList[index];
                      final isSelected =
                          gymController.selectedGymShift?.id == shift.id;

                      return GestureDetector(
                        onTap: () {
                          gymController.selectGymShift(shift);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryText1.withValues(alpha: 0.06)
                                : greyLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              width: isSelected ? 1.5 : 1,
                              color: isSelected ? primaryText1 : greyLight6,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    shift.icon,
                                    size: 14,
                                    color: isSelected
                                        ? primaryText1
                                        : greyText3,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      shift.shiftName ?? "",
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Helper(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? primaryText1
                                                : greyText3,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${shift.startTime ?? ''} - ${shift.endTime ?? ''}",
                                textAlign: TextAlign.center,
                                style: Helper(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: primaryText1,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.people_alt_outlined,
                                    size: 12,
                                    color: greenDark,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${shift.maxMembers ?? 30}",
                                    style: Helper(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: greenDark,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    shift.formattedFee,
                                    style: Helper(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: primaryText1,
                                        ),
                                  ),
                                ],
                              ),
                              if (isSelected) ...[
                                const SizedBox(height: 4),
                                Icon(
                                  Icons.check_circle,
                                  color: primaryText1,
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  )
                else if (hasSubBatches)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subscriptionController.isLoading
                        ? 4
                        : subscriptionController.batchModelList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.15,
                    ),
                    itemBuilder: (context, index) {
                      final batchModel = subscriptionController.isLoading
                          ? BatchModel()
                          : subscriptionController.batchModelList[index];

                      return CustomShimmer(
                        isLoading: subscriptionController.isLoading,
                        child: GYMBatchWidget(
                          batchModel: batchModel,
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
