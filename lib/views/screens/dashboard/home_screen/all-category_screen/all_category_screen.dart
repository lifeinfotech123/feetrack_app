import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/permission_controller.dart';
import 'package:vlr/data/models/category_model/category_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/base/shimmer.dart';
import 'package:vlr/views/screens/gym/gym_bottom_nav_bar/gym_bottom_nav_bar_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/room_bottom_nav_bar_screen.dart';
import 'package:vlr/views/screens/dashboard/job/job_screen.dart';
import 'package:vlr/hospital/features/dashboard/presentation/screen/dashboard_screen.dart'
    as hospital;
import 'package:vlr/views/screens/dashboard/home_screen/all_category_home/widget/category_widget_all_home.dart';
import 'package:vlr/views/screens/dashboard/home_screen/service_appbar/service_appbar.dart';

class AllCategoryScreen extends StatefulWidget {
  const AllCategoryScreen({super.key});

  @override
  State<AllCategoryScreen> createState() => _AllCategoryScreenState();
}

class _AllCategoryScreenState extends State<AllCategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authController = Get.find<AuthController>();
      final permissionController = Get.find<PermissionController>();

      if (authController.isLoggedIn()) {
        authController.fetchProfile();
      }

      Get.find<HomeController>().fetchCategories();
      await fetchLocation(permissionController);
    });
  }

  Future<void> fetchLocation(PermissionController permissionController) async {
    if (!permissionController.locationFetched) {
      await permissionController.requestLocationPermissionAndFetch(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ServiceAppbar(
        title: "Feetrack all service",
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sizedBoxHeight(height: 12),
              GetBuilder<PermissionController>(builder: (permissionController) {
                return GetBuilder<HomeController>(
                  builder: (homeController) {
                    if (!homeController.isLoading &&
                        homeController.categoryModelList.isEmpty) {
                      return const Center(
                        child: Text("No Categories Found"),
                      );
                    }

                    return GridView.builder(
                      itemCount: homeController.isLoading
                          ? 4
                          : homeController.categoryModelList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        final CategoryModel categoryModel =
                            homeController.isLoading
                                ? CategoryModel()
                                : homeController.categoryModelList[index];

                        return CustomShimmer(
                          isLoading: homeController.isLoading,
                          child: GestureDetector(
                            onTap: () async {
                              if (homeController.isLoading) {
                                return;
                              }
                              homeController
                                  .updateSelectCategoryModel(categoryModel);

                              await fetchLocation(permissionController);
                              if (!context.mounted) return;

                              final String name =
                                  (categoryModel.name ?? '').toLowerCase();
                              final String slug =
                                  (categoryModel.slug ?? '').toLowerCase();
                              final String catId =
                                  categoryModel.id?.toString() ?? '';

                              // 1. Gym / Fitness Category
                              final bool isGymCategory = catId == "11" ||
                                  catId == "1" ||
                                  name.contains("gym") ||
                                  slug.contains("gym") ||
                                  name.contains("fitness") ||
                                  slug.contains("fitness") ||
                                  name.contains("workout") ||
                                  slug.contains("workout");
                              if (isGymCategory) {
                                navigate(
                                  context: context,
                                  page: const GymBottomNavBarScreen(),
                                );
                                return;
                              }

                              // 2. Hospital Category
                              if (catId == "2" ||
                                  name.contains("hospital") ||
                                  slug.contains("hospital") ||
                                  name.contains("doctor") ||
                                  slug.contains("doctor") ||
                                  name.contains("clinic") ||
                                  slug.contains("clinic") ||
                                  name.contains("medical") ||
                                  slug.contains("medical") ||
                                  name.contains("health") ||
                                  slug.contains("health")) {
                                navigate(
                                  context: context,
                                  page:
                                      const hospital.HospitalDashboardScreen(),
                                );
                                return;
                              }

                              // 3. Room Booking / PG / Room / Hostel Category
                              final bool isRoomCategory = catId == "12" ||
                                  catId == "3" ||
                                  (categoryModel.hasRooms ?? false) ||
                                  name.contains("room") ||
                                  slug.contains("room") ||
                                  name.contains("pg") ||
                                  slug.contains("pg") ||
                                  name.contains("hostel") ||
                                  slug.contains("hostel") ||
                                  name.contains("booking") ||
                                  slug.contains("booking");
                              if (isRoomCategory) {
                                navigate(
                                  context: context,
                                  page: const RoomBottomNavBarScreen(),
                                );
                                return;
                              }

                              // 4. HRMS / Job Category
                              if (catId == "10" ||
                                  name.contains("hrms") ||
                                  slug.contains("hrms") ||
                                  name.contains("job") ||
                                  slug.contains("job") ||
                                  name.contains("career") ||
                                  slug.contains("career") ||
                                  name.contains("naukri") ||
                                  slug.contains("naukri") ||
                                  name.contains("recruitment") ||
                                  slug.contains("recruitment") ||
                                  name.contains("employment") ||
                                  slug.contains("employment") ||
                                  name.contains("work") ||
                                  slug.contains("work")) {
                                navigate(
                                  context: context,
                                  page: const JobScreen(),
                                );
                                return;
                              }

                              // 5. Default Fallback
                              navigate(
                                  context: context,
                                  page: const GymBottomNavBarScreen());
                            },
                            child: homeController.isLoading
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  )
                                : CategoryWidgetHome(
                                    categoryModel: categoryModel,
                                  ),
                          ),
                        );
                      },
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
