import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/data/models/category_model/plan_model.dart';
import 'package:vlr/views/screens/room_section/room/room_booking/room_booking_screen.dart';
import 'package:vlr/views/screens/room_section/room/room_profile_screen/widge/room_profile_med_section.dart';
import 'package:vlr/views/screens/room_section/room/room_profile_screen/widge/room_profile_top_section.dart';

import '../../../../../controllers/home_controller.dart';
import '../../../../../controllers/room_controller.dart';

import 'package:vlr/views/screens/room_section/room_book_visit/room_book_visit_screen.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';

class RoomProfileScreen extends StatefulWidget {
  const RoomProfileScreen({
    super.key,
  });

  @override
  State<RoomProfileScreen> createState() => _RoomProfileScreenState();
}

class _RoomProfileScreenState extends State<RoomProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Room Profile",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryText1,
                ),
          ),
        ),
        bottomNavigationBar: _buildBottomBookingBar(context),
        body: GetBuilder<RoomController>(builder: (roomController) {
          if (roomController.isLoading &&
              roomController.selectedRoomDetails == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (roomController.selectedRoomDetails == null) {
            return const Center(child: Text("Room details not found"));
          }

          return SingleChildScrollView(
            padding: AppConstants.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RoomProfileTopSection(),
                const RoomProfileMedSection(),
                const _ListingPlansSection(),
                sizedBoxHeight(height: 20)
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBookingBar(BuildContext context) {
    return GetBuilder<RoomController>(
      builder: (roomController) {
        final room = roomController.selectedRoomDetails;
        if (room == null) return const SizedBox.shrink();

        final dynamic rent =
            room.perBedRent ?? room.startingPrice ?? room.fullRent;
        final String rentUnit = room.perBedRent != null
            ? "/ bed"
            : (room.fullRent != null ? "/ full room" : "/ month");

        return Container(
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, -4),
              )
            ],
          ),
          child: Row(
            children: [
              // Left: Rent & Deposit
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (rent != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "₹$rent",
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF002060),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              rentUnit,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (room.securityDeposit != null)
                      Text(
                        "Deposit: ₹${room.securityDeposit}",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE11D48),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        room.roomType ?? "Available",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Action 1: Visit Button
              OutlinedButton(
                onPressed: () {
                  final bool isLoggedIn =
                      Get.isRegistered<AuthController>() &&
                          Get.find<AuthController>().isLoggedIn();
                  if (!isLoggedIn) {
                    showLoginRequiredDialog(
                      context: context,
                      title: "Login Required",
                      message:
                          "Please login to your account first before scheduling a property visit.",
                    );
                    return;
                  }

                  navigate(
                    context: context,
                    page: RoomBookVisitScreen(
                      listingModel: room.listing,
                      listingId: room.listing?.id ?? room.listingId,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  side: const BorderSide(color: Color(0xFF002060), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Visit",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF002060),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Action 2: Book Now Button (Primary)
              Expanded(
                flex: 4,
                child: ElevatedButton(
                  onPressed: () {
                    final bool isLoggedIn =
                        Get.isRegistered<AuthController>() &&
                            Get.find<AuthController>().isLoggedIn();
                    if (!isLoggedIn) {
                      showLoginRequiredDialog(
                        context: context,
                        title: "Login Required",
                        message:
                            "Please login to your account first before booking this room.",
                      );
                      return;
                    }

                    navigate(
                      context: context,
                      page: RoomBookingScreen(
                        roomModel: room,
                        listingModel: room.listing,
                        roomId: room.id,
                        listingId: room.listing?.id ?? room.listingId,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002060),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Book Now",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ListingPlansSection extends StatelessWidget {
  const _ListingPlansSection();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(builder: (subController) {
      if (subController.isLoading && subController.allPlanList.isEmpty) {
        return const Center(
            child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ));
      }

      if (subController.allPlanList.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sizedBoxHeight(height: 32),
          Text(
            "Property Plans",
            style: Helper(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  color: blackText3,
                ),
          ),
          sizedBoxHeight(height: 16),
          ...subController.allPlanList
              .map((plan) => _DetailedPlanCard(plan: plan)),
        ],
      );
    });
  }
}

class _DetailedPlanCard extends StatelessWidget {
  final PlanModel plan;
  const _DetailedPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: greyLight1.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          childrenPadding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name ?? "Plan",
                      style: Helper(context).textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: blackText3,
                          ),
                    ),
                    if (plan.roomType != null)
                      Text(
                        plan.roomType!,
                        style: Helper(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: blueLight4,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  plan.durationLabel ?? plan.type ?? "",
                  style: const TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: greyDart2),
                const SizedBox(width: 4),
                Text(
                  "Occupancy: ${plan.occupancyType?.replaceAll('_', ' ').capitalizeFirst ?? ''}",
                  style: Helper(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: greyDart2, fontSize: 12),
                ),
              ],
            ),
          ),
          children: [
            const Divider(),
            sizedBoxHeight(height: 12),

            // Details Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DetailItem(label: "Price", value: "₹${plan.price}"),
                _DetailItem(
                    label: "Duration",
                    value: "${plan.durationDays ?? '--'} Days"),
              ],
            ),

            sizedBoxHeight(height: 16),

            // Features Section
            if (plan.features != null && plan.features!.isNotEmpty) ...[
              Text(
                "Features & Inclusions",
                style: Helper(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              sizedBoxHeight(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    plan.features!.map((f) => _FeatureChip(label: f)).toList(),
              ),
              sizedBoxHeight(height: 16),
            ],

            // Meal Plan Section
            if (plan.mealPlans != null) ...[
              Text(
                "Meal Plan Details",
                style: Helper(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              sizedBoxHeight(height: 8),
              Row(
                children: [
                  if (plan.mealPlans!.hasBreakfast ?? false)
                    const _MealTag(label: "Breakfast"),
                  if (plan.mealPlans!.hasLunch ?? false)
                    const _MealTag(label: "Lunch"),
                  if (plan.mealPlans!.hasDinner ?? false)
                    const _MealTag(label: "Dinner"),
                ],
              ),
              sizedBoxHeight(height: 4),
              Text(
                "Meal Type: ${plan.mealPlans!.mealType?.capitalizeFirst ?? 'Standard'}",
                style:
                    Helper(context).textTheme.bodySmall?.copyWith(fontSize: 12),
              ),
              sizedBoxHeight(height: 16),
            ],

            // Select Button
            CustomButton(
              height: 48,
              minWidth: double.infinity,
              radius: 12,
              onTap: () {
                final subController = Get.find<SubscriptionController>();
                final roomController = Get.find<RoomController>();
                final homeController = Get.find<HomeController>();

                subController.updateSelectPlan(plan);

                final effectiveListingId =
                    homeController.selectListingModel?.id ??
                        roomController.selectedListingDetails?.id ??
                        "";

                navigate(
                  context: context,
                  page: RoomBookingScreen(
                    roomModel: roomController.selectedRoomDetails,
                    listingModel: homeController.selectListingModel ??
                        roomController.selectedListingDetails,
                    listingId: effectiveListingId,
                    roomId: roomController.selectedRoomDetails?.id,
                  ),
                );
              },
              child: Text("Select This Plan",
                  style: TextStyle(color: white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: greyText2)),
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor)),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  const _FeatureChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: greyLight5,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: greyLight1.withValues(alpha: 0.2)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: greyDart2)),
    );
  }
}

class _MealTag extends StatelessWidget {
  final String label;
  const _MealTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: greenDark.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.restaurant_menu, size: 10, color: greenDark),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: greenDark, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
