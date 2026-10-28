import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/notification_controller.dart';
import 'package:vlr/data/models/notification_models/notification_model.dart';
import 'package:vlr/generated/assets.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class NotifWidget extends StatelessWidget {
  final NotificationModel notification;
  const NotifWidget({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    bool isRead = notification.readAt != null;

    return Dismissible(
      key: Key(notification.id ?? ""),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: red,
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        Get.find<NotificationController>()
            .deleteNotification(notification.id ?? "")
            .then((response) {
          if (response.isSuccess) {
            showToast(message: response.message, toastType: ToastType.success);
          } else {
            showToast(message: response.message, toastType: ToastType.error);
          }
        });
      },
      child: GestureDetector(
        onTap: () {
          if (!isRead) {
            Get.find<NotificationController>().markAsRead(notification.id ?? "");
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                width: 1,
                color: isRead
                    ? greyLight2.withValues(alpha: 0.10)
                    : primaryColor.withValues(alpha: 0.2),
              ),
              color: isRead ? white : primaryColor.withValues(alpha: 0.05),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 12,
                  spreadRadius: 0,
                  color: black.withValues(alpha: 0.02),
                )
              ]),
          child: Row(
            children: [
              CustomImage(
                path: Assets.imagesSuccessfully,
                height: 48,
                width: 48,
                fit: BoxFit.cover,
                color: isRead ? greyText3 : primaryColor,
              ),
              sizedBoxWidth(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title ?? "Notification",
                            style: Helper(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 14,
                                  color: isRead ? blackText1 : primaryColor,
                                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                ),
                          ),
                        ),
                        Text(
                          notification.createdAt != null
                              ? notification.createdAt!.substring(0, 10)
                              : "",
                          style: Helper(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 10,
                                color: greyText3,
                              ),
                        ),
                      ],
                    ),
                    Text(
                      notification.message ?? "",
                      style: Helper(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: greyText2,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
