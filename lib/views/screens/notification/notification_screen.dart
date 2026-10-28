import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/notification_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/notification/widget/notif_section.dart';
import 'package:vlr/views/screens/notification/widget/payment_overdue_section_notf.dart';
import 'package:vlr/views/screens/notification/widget/row_option_nof_section.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<NotificationController>().getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Feetrack",
          style: Helper(context).textTheme.titleMedium?.copyWith(
                fontSize: 24,
                color: primaryText2,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.find<NotificationController>().markAllRead().then((response) {
                if (response.isSuccess) {
                  showToast(
                      message: response.message, toastType: ToastType.success);
                } else {
                  showToast(
                      message: response.message, toastType: ToastType.error);
                }
              });
            },
            icon: const Icon(Icons.mark_email_read_outlined),
            tooltip: "Mark all as read",
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete All Notifications"),
                  content: const Text(
                      "Are you sure you want to delete all notifications?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Get.find<NotificationController>()
                            .deleteAllNotifications()
                            .then((response) {
                          if (response.isSuccess) {
                            showToast(
                                message: response.message,
                                toastType: ToastType.success);
                          } else {
                            showToast(
                                message: response.message,
                                toastType: ToastType.error);
                          }
                        });
                      },
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: "Delete all notifications",
          )
        ],
      ),
      body: Padding(
        padding: AppConstants.screenPadding,
        child: Column(
          children: [
            // const RowOptionNotificationSection(),

            // const PaymentOverdueSectionNotif(),
            const Expanded(child: NotifiSection())
          ],
        ),
      ),
    );
  }
}
