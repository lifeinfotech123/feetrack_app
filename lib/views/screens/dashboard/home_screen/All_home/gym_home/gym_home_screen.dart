import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/permission_controller.dart';
import 'package:vlr/services/constants.dart';
import 'widget/gym_city_selector_section.dart';
import 'widget/gym_home_nearby_section.dart';
import 'widget/gym_home_search_bar.dart';
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
    Get.find<HomeController>().gymSearchQuery = '';
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
          if (homeController.gymErrorMessage != null &&
              homeController.gymList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 42, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      homeController.gymErrorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: homeController.isGymLoading
                          ? null
                          : () => homeController.fetchGyms(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("Retry"),
                    ),
                  ],
                ),
              ),
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
                const GymHomeSearchBar(),
                const GymHomeNearbySection(),
              ],
            ),
          );
        },
      ),
    );
  }
}
