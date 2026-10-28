import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/dashboard_controller.dart';
import 'package:vlr/controllers/notification_controller.dart';
import 'package:vlr/generated/assets.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/notification/notification_screen.dart';

class ServiceAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isAllServiceHomeScreen;
  final bool centerTitle;
  const ServiceAppbar({
    super.key,
    required this.title,
    this.isAllServiceHomeScreen = false,
    this.centerTitle = false,
  });
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Helper(context).textTheme.titleMedium?.copyWith(
              fontSize: 18,
              color: blueLight3,
            ),
      ),
      centerTitle: centerTitle,
      elevation: 2,
      actions: isAllServiceHomeScreen
          ? [
              GetBuilder<NotificationController>(
                  builder: (notificationController) {
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        navigate(
                            context: context, page: const NotificationScreen());
                      },
                      icon: Icon(
                        Icons.notifications_none_outlined,
                        color: greyDart2,
                      ),
                    ),
                    if (notificationController.unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            notificationController.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              }),
              sizedBoxWidth(width: 16),
              GetBuilder<DashBoardController>(builder: (dashBoardController) {
                return GestureDetector(
                  onTap: () {
                    dashBoardController.dashPage = 2;
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: AssetImage(
                            Assets.imagesReview1,
                          ),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(width: 2, color: blueLight3)),
                  ),
                );
              }),
              sizedBoxWidth(width: 16)
            ]
          : [],
    );
  }
}
