import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/basic_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/notification/widget/notif_option_widget.dart';

class RowOptionNotificationSection extends StatelessWidget {
  const RowOptionNotificationSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BasicController>(builder: (basicController) {
      return SizedBox(
        height: 36,
        child: ListView.separated(
          itemBuilder: (context, index) {
            final _notificationOptionModel =
                basicController.notificationOptionModelList[index];
            return GestureDetector(
              onTap: () {
                if (basicController.isLoading) {
                  return;
                }
                basicController
                    .updateNotificationOptionModel(_notificationOptionModel);
              },
              child: NotifOptionWidget(
                notificationOptionModel: _notificationOptionModel,
              ),
            );
          },
          separatorBuilder: (_, __) => sizedBoxWidth(width: 8),
          itemCount: basicController.notificationOptionModelList.length,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
        ),
      );
    });
  }
}
