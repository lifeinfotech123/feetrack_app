import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/data/models/category_model/plan_model.dart';
import 'package:vlr/data/models/category_model/staff_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';
import 'package:vlr/views/screens/gym/gym_book_membership/gym_book_membership_screen.dart';
import 'package:vlr/views/screens/gym/gym_trainer_profile_screen/widget/gym_trainer_profile_mid_section.dart';
import 'package:vlr/views/screens/gym/gym_trainer_profile_screen/widget/gym_trainer_profile_top_section.dart';

class GymTrainerProfileScreen extends StatefulWidget {
  final String? staffId;
  final StaffModel? initialStaff;

  const GymTrainerProfileScreen({
    super.key,
    this.staffId,
    this.initialStaff,
  });

  @override
  State<GymTrainerProfileScreen> createState() =>
      _GymTrainerProfileScreenState();
}

class _GymTrainerProfileScreenState extends State<GymTrainerProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gymController = Get.find<GymController>();
      final trainerId = widget.staffId ??
          widget.initialStaff?.stringId ??
          widget.initialStaff?.id?.toString();

      if (trainerId != null && trainerId.isNotEmpty) {
        gymController.fetchTrainerDetails(trainerId: trainerId);
      }
    });
  }

  StaffModel? _resolveStaff(GymController gymController) {
    if (gymController.selectedTrainerDetails != null) {
      return StaffModel.fromJson(gymController.selectedTrainerDetails!);
    }
    if (widget.initialStaff != null) {
      return widget.initialStaff;
    }
    if (widget.staffId != null) {
      final match = gymController.gymTrainerModelList.firstWhereOrNull(
        (t) =>
            t.stringId == widget.staffId || t.id?.toString() == widget.staffId,
      );
      if (match != null) return match;
    }
    return null;
  }

  void _onBookMembership(StaffModel staff) {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn()) {
      showLoginRequiredDialog(
        context: context,
        title: "Login Required",
        message:
            "Please login to your account first before booking gym membership.",
      );
      return;
    }

    final gymController = Get.find<GymController>();
    final homeController = Get.find<HomeController>();
    final subscriptionController = Get.find<SubscriptionController>();

    gymController.selectGymTrainerModel = staff;
    gymController.update();

    final listing = homeController.selectListingModel;
    final listingId = listing?.id ?? staff.gymId ?? "";

    PlanModel? plan = subscriptionController.selectedPlan;
    if (plan == null && subscriptionController.planModelList.isNotEmpty) {
      plan = subscriptionController.planModelList.first;
      subscriptionController.selectedPlan = plan;
      subscriptionController.update();
    }

    navigate(
      context: context,
      page: GymBookMembershipScreen(
        planModel: plan,
        listingModel: listing,
        listingId: listingId,
        packageId: plan?.id,
        selectedTrainer: staff,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GymController>(builder: (gymController) {
      final staff = _resolveStaff(gymController);
      final isLoading = gymController.isTrainerDetailsLoading && staff == null;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          shadowColor: black.withValues(alpha: 0.05),
          title: Text(
            staff?.name ?? "Trainer Details",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: primaryText1,
                  letterSpacing: 0.5,
                ),
          ),
        ),
        bottomNavigationBar: staff != null
            ? Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  MediaQuery.of(context).padding.bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Selected Trainer",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            staff.name ?? "Trainer",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF002060),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 170,
                      child: CustomButton(
                        height: 48,
                        radius: 14,
                        color: const Color(0xFF002060),
                        borderColor: const Color(0xFF002060),
                        onTap: () => _onBookMembership(staff),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.card_membership_rounded,
                                color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              "BOOK NOW",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : staff == null
                ? const Center(child: Text("Trainer details not found"))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        GYMTrainerProfileTopSection(staff: staff),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GYMTrainerProfileMidSection(staff: staff),
                              sizedBoxHeight(height: 30),
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
