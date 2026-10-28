import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/permission_controller.dart';
import 'package:vlr/data/models/category_model/category_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/gym/gym_bottom_nav_bar/gym_bottom_nav_bar_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/room_bottom_nav_bar_screen.dart';
import 'package:vlr/views/screens/dashboard/job/job_screen.dart';
import 'package:vlr/hospital/features/dashboard/presentation/screen/dashboard_screen.dart' as hospital;

class ExploreByCategoryWidget extends StatefulWidget {
  const ExploreByCategoryWidget({super.key});

  @override
  State<ExploreByCategoryWidget> createState() => _ExploreByCategoryWidgetState();
}

class _ExploreByCategoryWidgetState extends State<ExploreByCategoryWidget> {
  int _selectedTabIndex = 0;

  // High-quality public network images related to Gym, Hostel, Dance, and Home Services
  final Map<String, List<Map<String, String>>> _tabItems = {
    "Gym": [
      {
        "title": "Elite Cardio",
        "subtitle": "Boost your heart health",
        "image": "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=600&auto=format&fit=crop",
      },
      {
        "title": "Strength Arena",
        "subtitle": "Power & bodybuilding",
        "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600&auto=format&fit=crop",
      },
      {
        "title": "Yoga & Balance",
        "subtitle": "Relax your mind & body",
        "image": "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=600&auto=format&fit=crop",
      },
      {
        "title": "Crossfit Studio",
        "subtitle": "Intense group training",
        "image": "https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=600&auto=format&fit=crop",
      },
    ],
    "PG / Hostel": [
      {
        "title": "Single Room PG",
        "subtitle": "Quiet & personal stay",
        "image": "https://images.unsplash.com/photo-1505691938895-1758d7feb511?q=80&w=600&auto=format&fit=crop",
      },
      {
        "title": "Premium Hostels",
        "subtitle": "Co-living with amenities",
        "image": "https://images.unsplash.com/photo-1555854877-bab0e564b8d5?q=80&w=600&auto=format&fit=crop",
      },
      {
        "title": "Luxury Co-living",
        "subtitle": "Modern lifestyle spaces",
        "image": "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?q=80&w=600&auto=format&fit=crop",
      },
      {
        "title": "Double Sharing PG",
        "subtitle": "Affordable shared living",
        "image": "https://images.unsplash.com/photo-1598928506311-c55ded91a20c?q=80&w=600&auto=format&fit=crop",
      },
    ],
    "Dance Center": [
      {
        "title": "Zumba Studio",
        "subtitle": "Dance your way to fitness",
        "image": "https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=600&auto=format&fit=crop",
      },
      {
        "title": "Salsa & Bachata",
        "subtitle": "Learn couple dancing",
        "image": "https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?q=80&w=600&auto=format&fit=crop",
      },
      {
        "title": "Hip Hop Centre",
        "subtitle": "Expressive street styles",
        "image": "https://images.unsplash.com/photo-1547153760-18fc86324498?q=80&w=600&auto=format&fit=crop",
      },
      {
        "title": "Classical Beats",
        "subtitle": "Traditional expressions",
        "image": "https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?q=80&w=600&auto=format&fit=crop",
      },
    ],
    "Default": [
      {
        "title": "Deep Cleaners",
        "subtitle": "Spotless and tidy spaces",
        "image": "https://images.unsplash.com/photo-1581578731548-c64695cc6952?q=80&w=600&auto=format&fit=crop",
      },
      {
        "title": "Appliance Fix",
        "subtitle": "AC, TV, Fridge repairs",
        "image": "https://images.unsplash.com/photo-1581092921461-eab62e97a780?q=80&w=600&auto=format&fit=crop",
      },
      {
        "title": "Plumbing Experts",
        "subtitle": "Leakage & pipe fittings",
        "image": "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=600&auto=format&fit=crop",
      },
      {
        "title": "Wall Painting",
        "subtitle": "Fresh colors for your home",
        "image": "https://images.unsplash.com/photo-1562259949-e8e7689d7828?q=80&w=600&auto=format&fit=crop",
      },
    ],
  };

  void _onCategorySelected(CategoryModel category) async {
    final homeController = Get.find<HomeController>();
    final permissionController = Get.find<PermissionController>();

    homeController.updateSelectCategoryModel(category);
    
    // Trigger location fetch if needed or just navigate
    if (permissionController.latitude == null) {
        await permissionController.requestLocationPermissionAndFetch(context);
    }

    if (!mounted) return;

    final String name = (category.name ?? '').toLowerCase();
    final String slug = (category.slug ?? '').toLowerCase();
    final String catId = category.id?.toString() ?? '';

    // 1. Gym / Fitness Category
    final bool isGymCategory = name.contains("gym") ||
        slug.contains("gym") ||
        name.contains("fitness") ||
        slug.contains("fitness") ||
        name.contains("workout") ||
        slug.contains("workout") ||
        catId == "11" ||
        catId == "1";
    if (isGymCategory) {
      navigate(
        context: context,
        page: const GymBottomNavBarScreen(),
      );
      return;
    }

    // 2. Hospital / Doctor Category
    if (name.contains("hospital") ||
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
        page: const hospital.HospitalDashboardScreen(),
      );
      return;
    }

    // 3. Room Booking / PG / Room / Hostel Category
    final bool isRoomCategory = catId == "12" ||
        catId == "3" ||
        (category.hasRooms ?? false) ||
        name.contains("room") ||
        slug.contains("room") ||
        name.contains("pg") ||
        slug.contains("pg") ||
        name.contains("hostel") ||
        slug.contains("hostel") ||
        name.contains("booking") ||
        slug.contains("booking");

    if (isRoomCategory) {
      navigate(context: context, page: const RoomBottomNavBarScreen());
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
    navigate(context: context, page: const GymBottomNavBarScreen());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeController) {
        if (homeController.isLoading || homeController.categoryModelList.isEmpty) {
          return const SizedBox.shrink();
        }

        final categories = homeController.categoryModelList;
        // Adjust index if it goes out of bounds
        if (_selectedTabIndex >= categories.length) {
          _selectedTabIndex = 0;
        }

        final selectedCategory = categories[_selectedTabIndex];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Explore by Category Speciality",
              style: Helper(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    color: blackText1,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            sizedBoxHeight(height: 12),

            // Horizontal pill selector tabs
            SizedBox(
              height: 36.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => sizedBoxWidth(width: 10.w),
                itemBuilder: (context, index) {
                  final bool isSelected = _selectedTabIndex == index;
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category.name ?? "",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : greyText3,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            sizedBoxHeight(height: 14),

            // Visual Grid of specialities
            GridView.builder(
              itemCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              itemBuilder: (context, index) {
                // Determine which items to show based on category name
                String lookupKey = "Default";
                if (selectedCategory.name?.contains("Gym") ?? false) {
                  lookupKey = "Gym";
                } else if ((selectedCategory.name?.contains("PG") ?? false) ||
                    (selectedCategory.name?.contains("Hostel") ?? false)) {
                  lookupKey = "PG / Hostel";
                } else if (selectedCategory.name?.contains("Dance") ?? false) {
                  lookupKey = "Dance Center";
                }

                final items = _tabItems[lookupKey] ?? _tabItems["Default"]!;
                final item = items[index];

                return GestureDetector(
                  onTap: () => _onCategorySelected(selectedCategory),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Backdrop Network image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CustomImage(
                            path: item["image"]!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Soft black linear gradient scrim overlay
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.75),
                              ],
                            ),
                          ),
                        ),

                        // Heading/Subtitle texts
                        Positioned(
                          bottom: 12.h,
                          left: 12.w,
                          right: 12.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["title"]!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                item["subtitle"]!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }
}
