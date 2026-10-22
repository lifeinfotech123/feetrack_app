import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/permission_controller.dart';
import 'package:vlr/services/constants.dart';
import 'widget/gym_city_selector_section.dart';
import 'widget/gym_home_nearby_section.dart';
import '../room_home/widget/room_home_search_section.dart';
import '../../service_appbar/service_appbar.dart';

import '../../../../../../controllers/common_controller.dart';

class GymHomeScreen extends StatefulWidget {
  const GymHomeScreen({
    super.key,
  });

  @override
  State<GymHomeScreen> createState() => _GymHomeScreenState();
}

class _GymHomeScreenState extends State<GymHomeScreen> {
  Future<void> _fetchLocationAndData() async {
    final homeController = Get.find<HomeController>();
    final permissionController = Get.find<PermissionController>();

    Get.find<CommonController>().fetchBanner();
    homeController.fetchGymCities();

    // The gym directory endpoint is a public, unfiltered list. Keep this
    // request identical to `GET /v1/gym/gyms` so guests see every gym the API
    // returns, even when location permission is denied or unavailable.
    await homeController.fetchGyms();

    // Fetching location is optional for this public directory; it must never
    // replace the already-rendered guest list with a location-filtered result.
    if (mounted) {
      permissionController.requestLocationPermissionAndFetch(context);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _fetchLocationAndData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GetBuilder<HomeController>(
          builder: (homeController) => ServiceAppbar(
            title: "Feetrack ${homeController.selectCategoryModel?.name ?? ''}",
          ),
        ),
      ),
      body: GetBuilder<HomeController>(
        builder: (homeController) {
          if (homeController.isGymLoading && homeController.gymList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: AppConstants.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GymCitySelectorSection(
                  onRefreshLocation: _fetchLocationAndData,
                ),
                GetBuilder<HomeController>(
                  builder: (homeController) {
                    return RoomHomeSearchBar(
                      hindText:
                          "Search by ${homeController.selectCategoryModel?.name ?? ""}...",
                      onTap: () {},
                    );
                  },
                ),
                const GymHomeNearbySection(),
              ],
            ),
          );
        },
      ),
    );
  }
}
