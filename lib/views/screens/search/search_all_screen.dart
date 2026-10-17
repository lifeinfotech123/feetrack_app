import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/permission_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/widget/text_box/app_text_box.dart';
import '../../../data/models/category_model/listing_model.dart';
import '../dashboard/home_screen/All_home/gym_home/widget/gym_home_details_screen.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/views/screens/room_section/pg_profile/pg_profile_screen.dart';

class SearchAllScreen extends StatefulWidget {
  const SearchAllScreen({super.key});

  @override
  State<SearchAllScreen> createState() => _SearchAllScreenState();
}

class _SearchAllScreenState extends State<SearchAllScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    final homeController = Get.find<HomeController>();
    final permissionController = Get.find<PermissionController>();
    if (value.isNotEmpty) {
      homeController.searchListings(
        search: value,
        latitude: permissionController.latitude,
        longitude: permissionController.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 20),
          onPressed: () => pop(context),
        ),
        title: Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: AppTextFieldWithHeading(
            controller: _searchController,
            hindText: "Search gyms, PGs, dance centers...",
            textInputAction: TextInputAction.search,
            onFieldSubmitted: _onSearch,
            onChanged: (val) {
              if (val.isEmpty) {
                Get.find<HomeController>().searchResultList.clear();
                Get.find<HomeController>().update();
              }
            },
            preFixWidget: Icon(
              Icons.search_sharp,
              color: primaryColor,
              size: 20.sp,
            ),
            bgColor: const Color(0xFFF3F6FC),
            borderColor: Colors.transparent,
            borderRadius: 24,
          ),
        ),
      ),
      body: GetBuilder<HomeController>(
        builder: (homeController) {
          if (homeController.isSearchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (homeController.searchResultList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 60.sp, color: greyText3),
                  SizedBox(height: 16.h),
                  Text(
                    _searchController.text.isEmpty
                        ? "Start searching for something..."
                        : "No results found for \"${_searchController.text}\"",
                    style: TextStyle(color: greyText3, fontSize: 14.sp),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: homeController.searchResultList.length,
            separatorBuilder: (_, __) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final listing = homeController.searchResultList[index];
              return _SearchListingCard(listing: listing);
            },
          );
        },
      ),
    );
  }
}

class _SearchListingCard extends StatelessWidget {
  final ListingModel listing;
  const _SearchListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final String imagePath = (listing.images?.isNotEmpty ?? false)
        ? listing.images!.first.imagePath ??
            listing.image ??
            Assets.imagesGymBanner
        : listing.image ?? Assets.imagesGymBanner;

    return GestureDetector(
      onTap: () {
        Get.find<HomeController>().updateSelectListingModel(value: listing);
        final bool isRoom = (listing.category?.hasRooms ?? false) ||
            (listing.categoryId == "3") ||
            (listing.category?.name?.toLowerCase().contains("pg") ?? false) ||
            (listing.category?.name?.toLowerCase().contains("hostel") ?? false);

        if (isRoom) {
          final listingId = listing.id ?? "";
          if (listingId.isNotEmpty) {
            Get.find<RoomController>().fetchPgListingDetails(listingId);
          }
          Get.find<RoomController>().selectedListingDetails = listing;
          navigate(
            context: context,
            page: PgProfileScreen(
              listingId: listing.id,
              initialModel: listing,
            ),
          );
        } else {
          navigate(context: context, page: const GymHomeDetailsScreen());
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                bottomLeft: Radius.circular(16.r),
              ),
              child: CustomImage(
                path: imagePath,
                width: 100.w,
                height: 100.h,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title ?? 'Elite Location',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: blackText1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 12.sp, color: greyText3),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            listing.address ??
                                listing.landmark ??
                                'Active Street, Noida',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: greyText3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (listing.startingPrice != null &&
                            listing.startingPrice! > 0)
                          Text(
                            "Starts ₹${listing.startingPrice}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          )
                        else
                          const SizedBox(),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.orange, size: 14),
                            SizedBox(width: 2.w),
                            Text(
                              listing.rating?.average?.toStringAsFixed(1) ??
                                  "0.0",
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: blackText1,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
