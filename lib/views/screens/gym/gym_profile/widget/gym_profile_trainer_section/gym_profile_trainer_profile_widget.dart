import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/data/models/category_model/plan_model.dart';
import 'package:vlr/data/models/category_model/staff_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/gym/gym_book_membership/gym_book_membership_screen.dart';

class GYmProfileTrainerProfileWidget extends StatelessWidget {
  final StaffModel staffModel;
  final String? listingId;

  const GYmProfileTrainerProfileWidget({
    super.key,
    required this.staffModel,
    this.listingId,
  });

  void _onBookTrainer(BuildContext context) {
    if (Get.isRegistered<GymController>()) {
      final gymController = Get.find<GymController>();
      gymController.selectGymTrainerModel = staffModel;
      gymController.update();
    }

    HomeController? homeController;
    if (Get.isRegistered<HomeController>()) {
      homeController = Get.find<HomeController>();
    }

    final listing = homeController?.selectListingModel;
    final effectiveListingId =
        listing?.id ?? listingId ?? staffModel.gymId ?? "";

    SubscriptionController? subscriptionController;
    if (Get.isRegistered<SubscriptionController>()) {
      subscriptionController = Get.find<SubscriptionController>();
    }

    PlanModel? plan = subscriptionController?.selectedPlan;
    if (plan == null &&
        subscriptionController != null &&
        subscriptionController.planModelList.isNotEmpty) {
      plan = subscriptionController.planModelList.first;
      subscriptionController.selectedPlan = plan;
      subscriptionController.update();
    }

    navigate(
      context: context,
      page: GymBookMembershipScreen(
        planModel: plan,
        listingModel: listing,
        listingId: effectiveListingId,
        packageId: plan?.id,
        selectedTrainer: staffModel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _onBookTrainer(context),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Trainer Image ──────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CustomImage(
                    path: staffModel.photoUrl ?? "",
                    width: double.infinity,
                    height: 135,
                    radius: 14,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Trainer Name ───────────────────────────────────
                Text(
                  staffModel.name ?? "Trainer",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),

                // ── Specialization & Experience ─────────────────────
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        staffModel.specialization?.isNotEmpty == true
                            ? staffModel.specialization!
                            : "Fitness Coach",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: greyText2,
                        ),
                      ),
                    ),
                    if (staffModel.experienceYears != null &&
                        staffModel.experienceYears!.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.circle,
                        size: 3.5,
                        color: greyText2,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          staffModel.experienceYears!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const Spacer(),

                // ── Book Trainer Button ─────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () => _onBookTrainer(context),
                    icon: const Icon(
                      Icons.fitness_center_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Book Trainer",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002060),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
