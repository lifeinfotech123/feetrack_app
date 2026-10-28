import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/common_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/room_home/widget/room_profile_widget.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/views/screens/room_section/room/room_booking/room_booking_screen.dart';

import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/data/models/category_model/room_detail_model.dart';

class RoomRecommendedSection extends StatelessWidget {
  final bool isRoom;
  const RoomRecommendedSection({
    super.key,
    required this.isRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GetBuilder<SubscriptionController>(builder: (subController) {
          if (subController.isLoading) {
            return const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (subController.roomDetailList.isEmpty) {
            return SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  "No Rooms Available",
                  style: Helper(context).textTheme.bodySmall,
                ),
              ),
            );
          }
          return SizedBox(
            height: 230,
            child: ListView.separated(
                padding: const EdgeInsets.all(20),
                scrollDirection: Axis.horizontal,
                itemCount: subController.roomDetailList.length,
                separatorBuilder: (_, __) => sizedBoxWidth(width: 24),
                itemBuilder: (context, index) {
                  final roomDetail = subController.roomDetailList[index];
                  return GetBuilder<CommonController>(
                      builder: (commonController) {
                    return GestureDetector(
                        onTap: () {
                          commonController.updateSelectedServiceType(
                              value: isRoom
                                  ? SelectTypeService.room
                                  : SelectTypeService.pg);

                          if (roomDetail.id != null) {
                            Get.find<RoomController>()
                                .fetchPgRoomDetails(roomDetail.id!);
                          }
                          navigate(
                            context: context,
                            page: const RoomBookingScreen(),
                          );
                        },
                        child: RoomProfileWidget(roomDetail: roomDetail));
                  });
                }),
          );
        }),
      ],
    );
  }
}
