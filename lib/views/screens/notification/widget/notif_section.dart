import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/notification_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/notification/widget/notif_widget.dart';

class NotifiSection extends StatelessWidget {
  const NotifiSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 16.0),
        //   child: Text(
        //     "RECENT ACTIVITIES",
        //     style: Helper(context).textTheme.titleMedium?.copyWith(
        //           fontSize: 12,
        //           color: greyText2,
        //         ),
        //   ),
        // ),

        Expanded(
          child: GetBuilder<NotificationController>(builder: (controller) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.notificationList.isEmpty) {
              return const Center(child: Text("No Notifications Found"));
            }
            return ListView.separated(
              itemBuilder: (context, index) {
                return NotifWidget(
                  notification: controller.notificationList[index],
                );
              },
              separatorBuilder: (_, __) => sizedBoxHeight(height: 16),
              itemCount: controller.notificationList.length,
              shrinkWrap: true,
            );
          }),
        )
        //
      ],
    );
  }
}
