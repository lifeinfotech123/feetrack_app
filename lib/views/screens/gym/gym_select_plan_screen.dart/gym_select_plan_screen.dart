import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/data/models/category_model/listing_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/screens/gym/gym_billing_screen/gym_billing_screen.dart';
import 'package:vlr/views/screens/gym/gym_select_plan_screen.dart/widget/select_duration_section.dart';
import 'package:vlr/views/screens/gym/gym_select_plan_screen.dart/widget/select_membership_section.dart';
import 'package:vlr/views/screens/gym/gym_select_plan_screen.dart/widget/gym_select_batch_section/gym_select_batch_section.dart';
import 'package:vlr/views/screens/gym/gym_book_membership/gym_book_membership_screen.dart';
import '../../../../controllers/room_controller.dart';
import 'package:vlr/controllers/gym_controller.dart';

class GymSelectPlanScreen extends StatefulWidget {
  final ListingModel? listingModel;
  final String? listingId;

  const GymSelectPlanScreen({
    super.key,
    this.listingModel,
    this.listingId,
  });

  @override
  State<GymSelectPlanScreen> createState() => _GymSelectPlanScreenState();
}

class _GymSelectPlanScreenState extends State<GymSelectPlanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final homeController = Get.find<HomeController>();
      final subscriptionController = Get.find<SubscriptionController>();
      final roomController = Get.find<RoomController>();

      if (widget.listingModel != null) {
        homeController.updateSelectListingModel(value: widget.listingModel!);
      } else if (widget.listingId != null &&
          widget.listingId!.isNotEmpty &&
          homeController.selectListingModel?.id != widget.listingId) {
        await homeController.fetchGymDetails(id: widget.listingId!);
      }

      final listingId = widget.listingId ??
          widget.listingModel?.id ??
          homeController.selectListingModel?.id ??
          "";
      final roomId = roomController.selectedRoomDetails?.id;
      final floorId = roomController.selectedRoomDetails?.floorId;

      print(
          'GymSelectPlanScreen: listingId=$listingId, roomId=$roomId, floorId=$floorId');

      await subscriptionController.fetchDuringListingById(id: listingId);
      subscriptionController.fetchPlanListingById(
        id: listingId,
        roomId: roomId,
        floorId: floorId,
      );
      Get.find<GymController>().fetchGymShifts(gymId: listingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: black.withValues(alpha: 0.05),
        title: Text(
          "Choose your plan",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: primaryText1,
              ),
        ),
      ),
      body:
          GetBuilder<SubscriptionController>(builder: (subscriptionController) {
        return SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Column(
            children: [
              const SelectDurationSection(),
              const SelectMemberShipSection(),
              // const SelectRoomSection(),
              const SelectBatchTimingSelection(),
              sizedBoxHeight(height: 30),
              CustomButton(
                height: 54,
                radius: 100,
                color: const Color(0xFF002060),
                borderColor: const Color(0xFF002060),
                isLoading: subscriptionController.isLoading,
                onTap: () {
                  final bool isLoggedIn = Get.isRegistered<AuthController>() &&
                      Get.find<AuthController>().isLoggedIn();
                  if (!isLoggedIn) {
                    showLoginRequiredDialog(
                      context: context,
                      title: "Login Required",
                      message:
                          "Please login to your account first before selecting a plan.",
                    );
                    return;
                  }

                  if (subscriptionController.selectedPlan == null) {
                    showToast(message: "Please select a membership plan");
                    return;
                  }

                  final gymController = Get.find<GymController>();
                  if (gymController.gymShiftsList.isNotEmpty &&
                      gymController.selectedGymShift == null) {
                    showToast(message: "Please select a gym shift timing");
                    return;
                  }

                  if (subscriptionController.hasShifts &&
                      subscriptionController.selectedBatch == null &&
                      gymController.selectedGymShift == null) {
                    showToast(message: "Please select a batch timing");
                    return;
                  }

                  if (subscriptionController.hasRooms) {
                    final roomId =
                        Get.find<RoomController>().selectedRoomDetails?.id;
                    navigate(
                      context: context,
                      page: GymBillingScreen(roomId: roomId),
                    );
                  } else {
                    final homeController = Get.find<HomeController>();
                    navigate(
                      context: context,
                      page: GymBookMembershipScreen(
                        planModel: subscriptionController.selectedPlan,
                        listingModel: homeController.selectListingModel,
                        listingId: homeController.selectListingModel?.id,
                        packageId: subscriptionController.selectedPlan?.id,
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "PROCEED TO BOOK MEMBERSHIP",
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: white,
                            letterSpacing: 0.5,
                          ),
                    ),
                    sizedBoxWidth(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: white,
                      size: 15,
                    ),
                  ],
                ),
              ),
              sizedBoxHeight(height: 20),
            ],
          ),
        );
      }),
    );
  }
}
