import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/common_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/permission_controller.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/category_model/listing_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/room_home/widget/pg_category_selector_section.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/room_home/widget/room_home_search_section.dart';
import 'package:vlr/views/screens/dashboard/home_screen/service_appbar/service_appbar.dart';
import 'package:vlr/views/screens/room_section/all_rooms/all_rooms_screen.dart';
import 'package:vlr/views/screens/room_section/pg_profile/pg_profile_screen.dart';
import 'package:vlr/views/screens/room_section/rooms_floor/rooms_and_floor_screen.dart';

class RoomHomeScreen extends StatefulWidget {
  const RoomHomeScreen({
    super.key,
  });

  @override
  State<RoomHomeScreen> createState() => _RoomHomeScreenState();
}

class _RoomHomeScreenState extends State<RoomHomeScreen> {
  Future<void> _fetchLocationAndData() async {
    final homeController = Get.find<HomeController>();
    final permissionController = Get.find<PermissionController>();
    final roomController = Get.find<RoomController>();

    await permissionController.requestLocationPermissionAndFetch(context);

    Get.find<CommonController>().fetchBanner();
    homeController.fetchBannerCategoriesListingById();

    // 1. Fetch PG Accommodation categories (api/v1/pg/categories)
    await roomController.fetchPgCategories();

    // 2. Fetch PG Accommodation listings (api/v1/pg/listings)
    await roomController.fetchPgListings(
      latitude: permissionController.latitude,
      longitude: permissionController.longitude,
    );

    // Sync legacy/shared category listings
    await homeController.fetchCategoriesListing(
      latitude: permissionController.latitude,
      longitude: permissionController.longitude,
      categoryId: homeController.selectCategoryModel?.id?.toString(),
    );
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
            title:
                "Feetrack ${homeController.selectCategoryModel?.name ?? 'PG & Hostels'}",
          ),
        ),
      ),
      body: GetBuilder<RoomController>(
        builder: (roomController) {
          final isInitialLoading = roomController.isListingsLoading &&
              roomController.pgListingList.isEmpty;

          if (isInitialLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: _fetchLocationAndData,
            child: SingleChildScrollView(
              padding: AppConstants.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Location Selector
                  GetBuilder<PermissionController>(
                      builder: (permissionController) {
                    return InkWell(
                      onTap: _fetchLocationAndData,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
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
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                permissionController.address ??
                                    (permissionController.locationFetched
                                        ? "Location Found"
                                        : "Select Location"),
                                style: Helper(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: blackText1,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: greyText3,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // PG Categories Filter Chips (Boys, Girls, Co-living, Hostels, etc.)
                  const PgCategorySelectorSection(),
                  const SizedBox(height: 16),

                  // Search Bar
                  RoomHomeSearchBar(
                    hindText: "Search PG, Hostels, location, area...",
                    onTap: () {
                      Get.find<CommonController>().updateSelectedServiceType(
                          value: SelectTypeService.room);
                      // navigate(
                      //     context: context, page: const SearchRoomScreen());
                    },
                  ),
                  sizedBoxHeight(height: 16),

                  // Browse All Rooms Banner (api/v1/pg/rooms)
                  _buildExploreRoomsBanner(),
                  sizedBoxHeight(height: 12),

                  // Explore PG Floors & Rooms Banner (api/v1/pg/floors)
                  _buildExploreFloorsBanner(),
                  sizedBoxHeight(height: 20),

                  // Nearby PG Accommodation Listings
                  _buildNearbyRoomSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExploreFloorsBanner() {
    return InkWell(
      onTap: () {
        navigate(context: context, page: const RoomsAndFloorScreen());
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F766E), Color(0xFF115E59)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F766E).withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.layers_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Explore Floors & Available Rooms",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "View Ground floor, 1st floor & live room availability",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreRoomsBanner() {
    return InkWell(
      onTap: () {
        navigate(context: context, page: const AllPgRoomsScreen());
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF002060), Color(0xFF1E3A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF002060).withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.meeting_room_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Browse All PG Rooms",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Explore single, double & triple sharing AC rooms",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  /// Nearby PG/Room listings grid — tapping opens PgProfileScreen
  Widget _buildNearbyRoomSection() {
    return GetBuilder<RoomController>(builder: (roomController) {
      return GetBuilder<HomeController>(builder: (homeController) {
        final bool isListLoading = roomController.isListingsLoading;
        final listings = roomController.filteredListingList.isNotEmpty
            ? roomController.filteredListingList
            : (roomController.pgListingList.isNotEmpty
                ? roomController.pgListingList
                : homeController.listingModelList);

        final int itemCount = isListLoading ? 4 : listings.length;
        final selectedCatName = roomController.selectedCategory?.name;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedCatName != null
                      ? "$selectedCatName Stays"
                      : "Verified PG & Hostels",
                  style: Helper(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: blackText1,
                      ),
                ),
                if (!isListLoading && listings.isNotEmpty)
                  Text(
                    "${listings.length} found",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: greyText3,
                    ),
                  ),
              ],
            ),
            sizedBoxHeight(height: 16),
            if (!isListLoading && listings.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.home_work_outlined,
                          size: 48, color: greyText3),
                      const SizedBox(height: 10),
                      Text(
                        "No PG accommodations found in this category",
                        style: TextStyle(color: greyText3, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  mainAxisExtent: 255,
                ),
                itemBuilder: (context, index) {
                  final listingModel = isListLoading ? null : listings[index];

                  if (isListLoading) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  return GestureDetector(
                    onTap: () {
                      final item = listingModel!;
                      homeController.updateSelectListingModel(value: item);
                      roomController.selectedListingDetails = item;
                      if (item.id != null) {
                        roomController.fetchPgListingDetails(item.id!);
                      }
                      navigate(
                        context: context,
                        page: PgProfileScreen(
                          listingId: item.id,
                          initialModel: item,
                        ),
                      );
                    },
                    child: _buildRoomGridCard(listingModel!),
                  );
                },
              ),
          ],
        );
      });
    });
  }

  Widget _buildRoomGridCard(ListingModel listingModel) {
    String imagePath = listingModel.image ?? "";
    if (imagePath.isEmpty && (listingModel.images?.isNotEmpty ?? false)) {
      imagePath = listingModel.images!.first.url ??
          listingModel.images!.first.imagePath ??
          "";
    }

    final gender = listingModel.genderType ?? "boys";
    Color badgeBg = const Color(0xFFEFF6FF);
    Color badgeFg = const Color(0xFF2563EB);
    String badgeText = "Boys PG";
    String fallbackImg =
        "https://images.unsplash.com/photo-1555854877-bab0e564b8d5?q=80&w=600&auto=format&fit=crop";

    if (gender.toLowerCase().contains("girl") ||
        gender.toLowerCase().contains("female")) {
      badgeBg = const Color(0xFFFDF2F8);
      badgeFg = const Color(0xFFDB2777);
      badgeText = "Girls PG";
      fallbackImg =
          "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?q=80&w=600&auto=format&fit=crop";
    } else if (gender.toLowerCase().contains("coliving") ||
        gender.toLowerCase().contains("unisex")) {
      badgeBg = const Color(0xFFF0FDF4);
      badgeFg = const Color(0xFF16A34A);
      badgeText = "Co-living";
      fallbackImg =
          "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=600&auto=format&fit=crop";
    }

    final String displayImage = imagePath.isNotEmpty ? imagePath : fallbackImg;
    final price = listingModel.startingPrice ?? 7000;
    final beds = listingModel.availableBedsCount ?? 3;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                child: Image.network(
                  displayImage,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Image.network(
                    fallbackImg,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (c2, e2, s2) => Container(
                      width: double.infinity,
                      height: 120,
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.home_work_rounded,
                          color: Colors.grey, size: 36),
                    ),
                  ),
                ),
              ),
              // Gender Badge Overlay
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeFg.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: badgeFg,
                    ),
                  ),
                ),
              ),
              // Available Beds Badge
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "$beds beds left",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listingModel.title ?? 'PG Residency',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 11, color: Color(0xFF2563EB)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              listingModel.landmark ??
                                  listingModel.address ??
                                  listingModel.city ??
                                  '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Rent / mo",
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "₹$price",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF002060),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "View",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 9,
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
