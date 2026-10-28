// import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/common_controller.dart';
import 'package:vlr/controllers/dashboard_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/notification_controller.dart';
import 'package:vlr/controllers/permission_controller.dart';
import 'package:vlr/data/models/category_model/category_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/base/shimmer.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/gym_home/gym_home_screen.dart';
import 'package:vlr/views/screens/gym/gym_bottom_nav_bar/gym_bottom_nav_bar_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/room_bottom_nav_bar_screen.dart';
import 'package:vlr/views/screens/room_section/pg_profile/pg_profile_screen.dart';
import 'package:vlr/views/screens/dashboard/job/job_screen.dart';
import 'package:vlr/hospital/features/dashboard/presentation/screen/dashboard_screen.dart'
    as hospital;
import 'package:vlr/ecomerce/entry_point.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/views/screens/dashboard/home_screen/all-category_screen/all_category_screen.dart';
import 'package:vlr/views/screens/dashboard/home_screen/all_category_home/slider_card/slider_card.dart';
import 'package:vlr/views/screens/dashboard/home_screen/all_category_home/widget/recent_paymant_section.dart';
import 'package:vlr/views/screens/dashboard/home_screen/all_category_home/widget/waving_hand_animation.dart';
import 'package:vlr/views/screens/notification/notification_screen.dart';
import 'package:vlr/views/screens/dashboard/wallet_screen/wallet_screen.dart';
import 'package:vlr/views/screens/subscriptions/screens/subscriptions_screen.dart';
import 'package:vlr/views/screens/gym/attendance/attendance_checkin_checkout_screen.dart';
import 'package:vlr/views/widget/bootstrap_Icon/bootstrap_icon.dart';
import 'package:vlr/views/widget/home_screen_widget/small_card_widget.dart';
import 'package:vlr/views/widget/home_screen_widget/gym_listing_section_widget.dart';
import 'package:vlr/views/widget/home_screen_widget/dance_centre_section_widget.dart';
import 'package:vlr/views/widget/home_screen_widget/pg_section_widget.dart';
import 'package:vlr/views/widget/home_screen_widget/explore_by_category_widget.dart';
import 'package:vlr/controllers/wallet_controller.dart';

import '../../../../../controllers/transaction_controller.dart';
import '../All_home/gym_home/widget/gym_home_details_screen.dart';
import '../../../search/search_all_screen.dart';

class AllCategoryHomeScreen extends StatefulWidget {
  const AllCategoryHomeScreen({super.key});

  @override
  State<AllCategoryHomeScreen> createState() => _AllCategoryHomeScreenState();
}

class _AllCategoryHomeScreenState extends State<AllCategoryHomeScreen> {
  // Unsplash fallback network images for Gym and PG/Hostel carousel
  final List<String> _gymImages = [
    "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1540206276907-fbd7c145c6f3?q=80&w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600&auto=format&fit=crop"
  ];

  final List<String> _pgImages = [
    "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?q=80&w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1555854877-bab0e564b8d5?q=80&w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1598928506311-c55ded91a20c?q=80&w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=600&auto=format&fit=crop"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authController = Get.find<AuthController>();
      final permissionController = Get.find<PermissionController>();
      final homeController = Get.find<HomeController>();
      final commonController = Get.find<CommonController>();
      final transactionController = Get.find<TransactionController>();
      if (authController.isLoggedIn()) {
        authController.fetchProfile();
        transactionController.fetchRecentTransactions();
        if (Get.isRegistered<WalletController>()) {
          final walletController = Get.find<WalletController>();
          walletController.fetchWalletSummary();
          walletController.fetchReserveHistory();
        }
      }
      commonController.fetchBanner();

      await homeController.fetchCategories();
      await fetchLocation(permissionController);

      // Fetch Gym listings (category_id = 1)
      await homeController.fetchGymListing(
        latitude: permissionController.latitude,
        longitude: permissionController.longitude,
      );

      // Fetch Dance Centre listings (category_id = 2)
      await homeController.fetchDanceListing(
        latitude: permissionController.latitude,
        longitude: permissionController.longitude,
      );

      // Fetch Pg/Hostel listings (category_id = 3)
      await homeController.fetchPgHostelListing(
        latitude: permissionController.latitude,
        longitude: permissionController.longitude,
      );

      if (Get.isRegistered<RoomController>()) {
        Get.find<RoomController>().fetchPgListings();
      }
    });
  }

  Future<void> fetchLocation(PermissionController permissionController) async {
    bool success =
        await permissionController.requestLocationPermissionAndFetch(context);

    if (success && permissionController.locationFetched) {
      final homeController = Get.find<HomeController>();

      // Refresh listings with the new location coordinates
      homeController.fetchGymListing(
        latitude: permissionController.latitude,
        longitude: permissionController.longitude,
      );
      homeController.fetchDanceListing(
        latitude: permissionController.latitude,
        longitude: permissionController.longitude,
      );
      homeController.fetchPgHostelListing(
        latitude: permissionController.latitude,
        longitude: permissionController.longitude,
      );
    }
  }

  // Find category matching dynamic ID (Gym is "1", Dance is "2", PG is "3", etc.)
  void _onCategorySelected(String categoryId, [CategoryModel? model]) async {
    final homeController = Get.find<HomeController>();
    final permissionController = Get.find<PermissionController>();

    final category = model ??
        homeController.categoryModelList.firstWhere(
          (element) => element.id.toString() == categoryId,
          orElse: () => CategoryModel(
            id: int.tryParse(categoryId),
            name: categoryId == "1"
                ? "Gym"
                : (categoryId == "3"
                    ? "PG / Hostel"
                    : (categoryId == "2" ? "Dance Center" : "Services")),
          ),
        );

    homeController.updateSelectCategoryModel(category);
    await fetchLocation(permissionController);

    if (!mounted) return;

    final String name = (category.name ?? '').toLowerCase();
    final String slug = (category.slug ?? '').toLowerCase();
    final String catId = category.id?.toString() ?? categoryId;

    // 1. Hospital Category
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
        page: const hospital.HospitalDashboardScreen(),
      );
      return;
    }

    // 2. Gym / Fitness Category
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

    // 5. E-Commerce / Shopping Category
    final bool isEcomCategory = catId == "5" ||
        name.contains("e-commerce") ||
        slug.contains("e-commerce") ||
        name.contains("ecommerce") ||
        slug.contains("ecommerce") ||
        name.contains("commerce") ||
        slug.contains("commerce") ||
        name.contains("shopping") ||
        slug.contains("shopping");
    if (isEcomCategory) {
      navigate(
        context: context,
        page: const EntryPoint(),
      );
      return;
    }

    // 6. Default Fallback
    navigate(context: context, page: const GymHomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC), // Soft, high-end background
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160.h),
        child:
            GetBuilder<PermissionController>(builder: (permissionController) {
          return AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 180.h,
            title: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section (Greeting + Actions)
                  GetBuilder<AuthController>(builder: (authController) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const WavingHand(size: 20),
                                  SizedBox(width: 6.w),
                                  Flexible(
                                    child: CustomShimmer(
                                      isLoading: authController.isLoading,
                                      child: Text(
                                        "Hii, ${authController.isLoggedIn() ? capitalize(authController.userModel?.name ?? 'Guest') : 'Guest'}",
                                        style: Helper(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w800,
                                              color: primaryColor,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              //! --
                              SizedBox(height: 7.h),

                              // Location Selector Row
                              InkWell(
                                onTap: () =>
                                    fetchLocation(permissionController),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        color: primaryColor,
                                        size: 18.sp,
                                      ),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: Text(
                                          permissionController.address ??
                                              (permissionController
                                                      .locationFetched
                                                  ? "Location Found"
                                                  : "Select Location"),
                                          style: Helper(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w700,
                                                color: blackText1,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: greyText3,
                                        size: 16.sp,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            // Notification Button
                            GetBuilder<NotificationController>(
                                builder: (notificationController) {
                              return Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        navigate(
                                            context: context,
                                            page: const NotificationScreen());
                                      },
                                      icon: Icon(
                                        Icons.notifications_none_outlined,
                                        color: greyDart2,
                                        size: 22.sp,
                                      ),
                                    ),
                                  ),
                                  if (notificationController.unreadCount > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          notificationController.unreadCount
                                              .toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),
                            sizedBoxWidth(width: 10.w),
                            // Profile Image
                            GetBuilder<DashBoardController>(
                                builder: (dashBoardController) {
                              return GestureDetector(
                                onTap: () {
                                  dashBoardController.dashPage = 4;
                                },
                                child: Container(
                                  height: 38.h,
                                  width: 38.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 1.5.w,
                                      color: primaryColor,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: CustomImage(
                                      path: authController.isLoggedIn()
                                          ? (authController.userModel?.image ?? "")
                                          : "",
                                      isProfile: true,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            })
                          ],
                        ),
                      ],
                    );
                  }),

                  sizedBoxHeight(height: 14.h),

                  // Search bar
                  GetBuilder<HomeController>(builder: (homeController) {
                    return GestureDetector(
                      onTap: () {
                        navigate(
                            context: context, page: const SearchAllScreen());
                      },
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: 12.h, horizontal: 18.w),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(99.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: primaryColor,
                              ),
                              sizedBoxWidth(width: 12.w),
                              AnimatedTextKit(
                                repeatForever: true,
                                pause: const Duration(milliseconds: 800),
                                animatedTexts: [
                                  TyperAnimatedText(
                                    'Search gyms...',
                                    speed: const Duration(milliseconds: 100),
                                    textStyle: Helper(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: greyText3,
                                        ),
                                  ),
                                  TyperAnimatedText(
                                    'Search PGs...',
                                    speed: const Duration(milliseconds: 100),
                                    textStyle: Helper(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: greyText3,
                                        ),
                                  ),
                                ],
                              )
                            ],
                          )),
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //! Slider section top
            const GymPgSlider(),
            sizedBoxHeight(height: 14.h),

            // Categories Section with a modern layout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pay & Book Services",
                  style: Helper(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16.sp,
                        color: blackText1,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                CustomButton(
                  type: ButtonType.tertiary,
                  onTap: () {
                    navigate(context: context, page: const AllCategoryScreen());
                  },
                  child: Row(
                    children: [
                      Text(
                        "View All",
                        style: Helper(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13.sp,
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right_rounded,
                        color: primaryColor,
                        size: 16.sp,
                      ),
                    ],
                  ),
                )
              ],
            ),

            sizedBoxHeight(height: 10),

            // Grid of categories
            GetBuilder<PermissionController>(builder: (permissionController) {
              return GetBuilder<HomeController>(
                builder: (homeController) {
                  if (!homeController.isLoading &&
                      homeController.categoryModelList.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      alignment: Alignment.center,
                      child: Text(
                        "No Categories Found",
                        style: TextStyle(color: greyText3),
                      ),
                    );
                  }

                  final int itemCount = homeController.isLoading
                      ? 4
                      : homeController.categoryModelList.length;

                  return GridView.builder(
                    itemCount: itemCount,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 96,
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
                            if (homeController.isLoading) return;
                            _onCategorySelected(
                                categoryModel.id.toString(), categoryModel);
                          },
                          child: homeController.isLoading
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                )
                              : _buildCategoryGridItem(categoryModel),
                        ),
                      );
                    },
                  );
                },
              );
            }),

            // Gym Section
            GetBuilder<HomeController>(builder: (homeController) {
              return GymListingSection(
                gymList: homeController.gymList,
                isLoading: homeController.isGymLoading,
                fallbackImages: _gymImages,
                onViewAll: () => _onCategorySelected(
                  homeController.gymList.isNotEmpty
                      ? homeController.gymList.first.categoryId ?? "1"
                      : "1",
                ),
                onListingTap: (listingModel) {
                  homeController.updateSelectListingModel(value: listingModel);
                  if (homeController.selectListingModel != null) {
                    navigate(
                        context: context, page: const GymHomeDetailsScreen());
                  }
                },
              );
            }),
            sizedBoxHeight(height: 20),

            // Gym Section
            GetBuilder<HomeController>(builder: (homeController) {
              return DanceCentreSectionWidget(
                danceList: homeController.danceList,
                isLoading: homeController.isDanceLoading,
                fallbackImages: _gymImages,
                onViewAll: () => _onCategorySelected(
                  homeController.danceList.isNotEmpty
                      ? homeController.danceList.first.categoryId ?? "2"
                      : "2",
                ),
                onListingTap: (listingModel) {
                  homeController.updateSelectListingModel(value: listingModel);
                  if (homeController.selectListingModel != null) {
                    navigate(
                        context: context, page: const GymHomeDetailsScreen());
                  }
                },
              );
            }),
            sizedBoxHeight(height: 20),

            // PG/Hostel Section — mirrors Gym module flow: goes to PgProfileScreen
            GetBuilder<RoomController>(builder: (roomController) {
              return GetBuilder<HomeController>(builder: (homeController) {
                final displayList = roomController.pgListingList.isNotEmpty
                    ? roomController.pgListingList
                    : homeController.pgHostelList;
                final bool isPgLoading = roomController.pgListingList.isNotEmpty
                    ? false
                    : (roomController.isListingsLoading ||
                        homeController.isPgHostelLoading);

                return PgSectionWidget(
                  pgList: displayList,
                  isLoading: isPgLoading,
                  fallbackImages: _pgImages,
                  onViewAll: () {
                    navigate(
                        context: context, page: const RoomBottomNavBarScreen());
                  },
                  onListingTap: (listingModel) {
                    homeController.updateSelectListingModel(
                        value: listingModel);
                    roomController.selectedListingDetails = listingModel;
                    if (listingModel.id != null &&
                        listingModel.id!.isNotEmpty) {
                      roomController.fetchPgListingDetails(listingModel.id!);
                    }
                    navigate(
                      context: context,
                      page: PgProfileScreen(
                        listingId: listingModel.id,
                        initialModel: listingModel,
                      ),
                    );
                  },
                );
              });
            }),
            sizedBoxHeight(height: 20),

            // Find Services by lifestyle tabs (Redesigned matching "Find doctors by speciality")
            const ExploreByCategoryWidget(),
            sizedBoxHeight(height: 24),

            // Community Expert Q&A Section (Matching the Reference Q&A visually)
            _buildCommunityFeedSection(),
            sizedBoxHeight(height: 20),

            // Recent Transactions Widget
            const RecentPaymentSection(),
            sizedBoxHeight(height: 50),
          ],
        ),
      ),
    );
  }

  // Quick Access Section (Wallet, Subscriptions, Attendance, More)
  Widget _buildQuickAccessSection() {
    final List<Map<String, dynamic>> items = [
      {
        "title": "Wallet",
        "icon": Icons.account_balance_wallet_rounded,
        "color": const Color(0xFF6366F1),
        "onTap": () => navigate(context: context, page: const WalletScreen()),
      },
      {
        "title": "Subscriptions",
        "icon": Icons.card_membership_rounded,
        "color": const Color(0xFFEC4899),
        "onTap": () =>
            navigate(context: context, page: const SubscriptionsScreen()),
      },
      {
        "title": "Attendance",
        "icon": Icons.fingerprint_rounded,
        "color": const Color(0xFF10B981),
        "onTap": () => navigate(
            context: context, page: const AttendanceCheckinCheckoutScreen()),
      },
      {
        "title": "More",
        "icon": Icons.grid_view_rounded,
        "color": const Color(0xFFF59E0B),
        "onTap": () {
          navigate(context: context, page: const AllCategoryScreen());
        },
      },
    ];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          return SmallCardWidget(
            title: item["title"],
            onTap: item["onTap"],
            bgColor: item["color"].withValues(alpha: 0.1),
            size: 50.w,
            image: Icon(
              item["icon"],
              color: item["color"],
              size: 24.sp,
            ),
          );
        }).toList(),
      ),
    );
  }

  // Visual grid item for categories
  Widget _buildCategoryGridItem(CategoryModel categoryModel) {
    final Color itemColor = categoryModel.colorValue;
    final String? imgUrl = categoryModel.imageUrl;
    return SmallCardWidget(
      title: categoryModel.name ?? "",
      onTap: () async {
        _onCategorySelected(categoryModel.id.toString(), categoryModel);
      },
      bgColor: itemColor.withValues(alpha: 0.08),
      size: 48.w,
      image: (imgUrl != null && imgUrl.isNotEmpty)
          ? Container(
              width: 48.w,
              height: 48.w,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: CachedNetworkImage(
                imageUrl: imgUrl,
                width: 48.w,
                height: 48.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: 14.sp,
                    height: 14.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: itemColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Icon(
                    getBootstrapIcon(categoryModel.icon),
                    color: itemColor,
                    size: 20.sp,
                  ),
                ),
              ),
            )
          : Center(
              child: Icon(
                getBootstrapIcon(categoryModel.icon),
                color: itemColor,
                size: 20.sp,
              ),
            ),
    );
  }

  Widget _buildWalletInfo({
    required IconData icon,
    required double amount,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            PriceConverter.convertRound(amount),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Quick Action Split Cards (Gym/Workouts vs PG Hostels)
  Widget _buildQuickActionCards() {
    return Row(
      children: [
        // Gym Card
        Expanded(
          child: GestureDetector(
            onTap: () => _onCategorySelected("1"),
            child: Container(
              height: 110.h,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEAF5FF), Color(0xFFCBE3FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0052D9).withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
                border: Border.all(
                  color: const Color(0xFF0052D9).withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: -10.h,
                    right: -10.w,
                    child: Opacity(
                      opacity: 0.15,
                      child: Icon(
                        Icons.fitness_center_rounded,
                        size: 70.sp,
                        color: const Color(0xFF0052D9),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Elite Gyms",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0038A6),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            "Get shape & build muscles",
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFF0052D9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0052D9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Book Workout",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // PG / Hostels Card
        Expanded(
          child: GestureDetector(
            onTap: () => _onCategorySelected("3"),
            child: Container(
              height: 110.h,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEAF9F5), Color(0xFFCEF2EA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
                border: Border.all(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: -10.h,
                    right: -10.w,
                    child: Opacity(
                      opacity: 0.15,
                      child: Icon(
                        Icons.home_work_rounded,
                        size: 70.sp,
                        color: const Color(0xFF0D9488),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PG / Hostels",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0B6960),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            "Cozy & smart stays nearby",
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFF0D9488),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Book Rooms",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Community Tips Feed (Matching reference layout "Free Expert Q&A")
  Widget _buildCommunityFeedSection() {
    final List<Map<String, String>> queries = [
      {
        "days": "2d ago",
        "question":
            "Which gym package is better for beginners: annual membership or monthly subscription?",
        "views": "154"
      },
      {
        "days": "5d ago",
        "question":
            "What security points should girls check before booking an accommodation or PG?",
        "views": "98"
      },
      {
        "days": "1w ago",
        "question":
            "Is routine dance center practice helpful for active cardio weight loss?",
        "views": "212"
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Expert Fitness & Living Q&A",
              style: Helper(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    color: blackText1,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Row(
              children: [
                Text(
                  "Explore all",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: primaryColor,
                  size: 16.sp,
                )
              ],
            )
          ],
        ),
        sizedBoxHeight(height: 10),

        // Horizontal scrolling card list of Q&A
        SizedBox(
          height: 170.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: queries.length,
            separatorBuilder: (_, __) => sizedBoxWidth(width: 14.w),
            itemBuilder: (context, index) {
              final q = queries[index];
              return Container(
                width: 280.w,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.06),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Question Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14.r,
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          child: Icon(Icons.people_alt_rounded,
                              size: 14.sp, color: primaryColor),
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Community Question",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: blackText1,
                              ),
                            ),
                            Text(
                              q["days"]!,
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: greyText3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Core question text
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Text(
                        q["question"]!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: greyText2,
                          height: 1.3,
                        ),
                      ),
                    ),

                    // Expert status line
                    Text(
                      "Expert Answered →",
                      style: TextStyle(
                        color: Colors.teal.shade700,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Divider(height: 12, color: Colors.black12),

                    // Social footer (views & shares)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.remove_red_eye_outlined,
                                size: 14.sp, color: greyText3),
                            SizedBox(width: 4.w),
                            Text(
                              "${q["views"]} Views",
                              style:
                                  TextStyle(fontSize: 10.sp, color: greyText3),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.share_outlined,
                                size: 14.sp, color: greyText3),
                            SizedBox(width: 4.w),
                            Text(
                              "Share",
                              style:
                                  TextStyle(fontSize: 10.sp, color: greyText3),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
