import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/room_home/widget/room_profile_widget.dart';
import 'package:vlr/views/screens/gym/gym_billing_screen/gym_billing_screen.dart';

class SelectRoomMedSection extends StatelessWidget {
  const SelectRoomMedSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(builder: (subscriptionController) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sizedBoxHeight(height: 30),
          if (!subscriptionController.isLoading && subscriptionController.roomDetailList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("No Rooms Available"),
              ),
            ),
          ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                if (subscriptionController.isLoading) {
                  return const RoomProfileWidget(width: double.infinity);
                }
                final roomDetail = subscriptionController.roomDetailList[index];
                final isSelected = subscriptionController.selectedRoomDetail?.id == roomDetail.id;
                
                return Column(
                  children: [
                    RoomProfileWidget(
                      width: double.infinity,
                      roomDetail: roomDetail,
                      isSelected: isSelected,
                      onTap: () {
                        if (isSelected) {
                          subscriptionController.updateSelectRoomDetail(value: null);
                        } else {
                          subscriptionController.updateSelectRoomDetail(value: roomDetail);
                          subscriptionController.updateSelectBedsCount(1); // Reset beds count
                        }
                      },
                    ),
                    if (isSelected && subscriptionController.selectedPlan?.occupancyType == 'per_bed')
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: greyDart2.withValues(alpha: 0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Select Beds",
                                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: blackText1,
                                      ),
                                ),
                                sizedBoxHeight(height: 4),
                                Text(
                                  "${roomDetail.availableBeds ?? '0'} Beds Available",
                                  style: Helper(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: primaryColor,
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (subscriptionController.selectedBedsCount > 1) {
                                      subscriptionController.updateSelectBedsCount(
                                        subscriptionController.selectedBedsCount - 1,
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: subscriptionController.selectedBedsCount > 1
                                          ? primaryColor.withValues(alpha: 0.1)
                                          : greyLight5,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      size: 20,
                                      color: subscriptionController.selectedBedsCount > 1
                                          ? primaryColor
                                          : greyDart2,
                                    ),
                                  ),
                                ),
                                sizedBoxWidth(width: 16),
                                Text(
                                  "${subscriptionController.selectedBedsCount}",
                                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: blackText1,
                                      ),
                                ),
                                sizedBoxWidth(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    final maxBeds = int.tryParse(roomDetail.availableBeds ?? '0') ?? 0;
                                    if (subscriptionController.selectedBedsCount < maxBeds) {
                                      subscriptionController.updateSelectBedsCount(
                                        subscriptionController.selectedBedsCount + 1,
                                      );
                                    } else {
                                      showToast(message: "Maximum available beds reached");
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child:  Icon(Icons.add, size: 20, color: white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
              separatorBuilder: (_, __) => sizedBoxHeight(height: 24),
              itemCount: subscriptionController.isLoading
                  ? 3
                  : subscriptionController.roomDetailList.length),
        ],
      );
    });
  }
}
