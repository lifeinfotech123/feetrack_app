import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/screens/gym/gym_billing_screen/gym_billing_screen.dart';
import 'package:vlr/views/screens/gym/gym_select_trainer_screen/widget/select_room_med_section.dart';
import 'package:vlr/views/screens/gym/gym_select_trainer_screen/widget/select_trainer_med_section.dart';
import 'package:vlr/views/screens/gym/gym_select_trainer_screen/widget/select_trainer_top_section.dart';


class GymSelectTrainerScreen extends StatefulWidget {
  const GymSelectTrainerScreen({super.key});

  @override
  State<GymSelectTrainerScreen> createState() => _GymSelectTrainerScreenState();
}

class _GymSelectTrainerScreenState extends State<GymSelectTrainerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeController = Get.find<HomeController>();
      final listingId = homeController.selectListingModel?.id ?? "";
      final hasTrainers =
          homeController.selectListingModel?.category?.hasTrainers ?? false;
      final hasRooms =
          homeController.selectListingModel?.category?.hasRooms ?? false;

      if (hasTrainers) {
        Get.find<GymController>().fetchGymTrainers(
          listingId: listingId,
        );
      }
      if (hasRooms) {
        final subscriptionController = Get.find<SubscriptionController>();
        subscriptionController.fetchPlanListingById(
          id: listingId,
          roomId: subscriptionController.selectedPlan?.roomId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      final hasTrainers =
          homeController.selectListingModel?.category?.hasTrainers ?? false;
      final hasRooms =
          homeController.selectListingModel?.category?.hasRooms ?? false;

      return Scaffold(
        appBar: AppBar(
          shadowColor: black.withValues(alpha: 0.05),
          title: Text(
            hasRooms ? "Choose your Room" : "Choose your Trainer",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: primaryText1,
                ),
          ),
        ),
        // bottomNavigationBar: Padding(
        //   padding: const EdgeInsets.all(20),
        //   child:
        // ),
        body: SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SelectTrainerTopSection(),
              sizedBoxHeight(height: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: CustomButton(
                  onTap: () {
                    navigate(context: context, page: const GymBillingScreen());
                  },
                  radius: 999,
                  color: white,
                  borderColor: const Color(0xFF73778133),
                  child: Text(
                    hasRooms ? "Skip Room" : "Skip Trainer",
                    style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: blackText1),
                  ),
                ),
              ),
              if (hasTrainers) const SelectTrainerMedSection(),
              if (hasRooms) const SelectRoomMedSection(),
              CustomButton(
                height: 54,
                radius: 100,
                color: const Color(0xFF002060),
                borderColor: const Color(0xFF002060),
                onTap: () {
                  navigate(context: context, page: const GymBillingScreen());
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Billing Summary",
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: white,
                      ),
                    ),
                    sizedBoxWidth(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
