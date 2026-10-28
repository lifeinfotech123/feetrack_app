import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/dashboard_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/gym_home/gym_home_screen.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/room_home/room_home_screen.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/gym_home/widget/home_top_section.dart';
import 'package:vlr/views/screens/dashboard/profile/profile_screen/profile_screen.dart';
import 'package:vlr/views/screens/notification/notification_screen.dart';

class CommonHomeScreen extends StatefulWidget {
  const CommonHomeScreen({super.key});

  @override
  State<CommonHomeScreen> createState() => _CommonHomeScreenState();
}

class _CommonHomeScreenState extends State<CommonHomeScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<DashBoardController>();
    _pageController = PageController(initialPage: controller.homeServiceIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildHomeContent(HomeServiceType serviceType) {
    switch (serviceType) {
      case HomeServiceType.gym:
        return const GymHomeScreen();
      case HomeServiceType.room:
        return const RoomHomeScreen();
      // case HomeServiceType.pg:
      //   return PgHomeScreen();
    }
  }

  void _syncToControllerPage(int pageIndex) {
    if (!_pageController.hasClients) {
      return;
    }

    final currentPage = _pageController.page?.round();
    if (currentPage == pageIndex) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onDoubleTap: () {
                navigate(context: context, page: const ProfileScreen());
              },
              child: const CustomImage(
                path: "",
                isProfile: true,
                height: 40,
                width: 40,
              ),
            ),
            sizedBoxWidth(width: 12),
            Text(
              "Feetrack",
              style: Helper(context).textTheme.titleSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryText2,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              navigate(context: context, page: const NotificationScreen());
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: Padding(
        padding: AppConstants.screenPadding,
        child: Column(
          children: [
            const HomeTopSection(),
            Expanded(
              child: GetBuilder<DashBoardController>(
                id: 'home_content',
                builder: (controller) {
                  _syncToControllerPage(controller.homeServiceIndex);

                  return PageView(
                    controller: _pageController,
                    onPageChanged: controller.selectHomeServiceByIndex,
                    children: HomeServiceType.values
                        .map(_buildHomeContent)
                        .toList(growable: false),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
