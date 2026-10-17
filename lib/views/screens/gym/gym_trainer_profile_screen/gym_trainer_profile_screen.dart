import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/data/models/category_model/staff_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/screens/gym/gym_trainer_profile_screen/widget/gym_trainer_profile_mid_section.dart';
import 'package:vlr/views/screens/gym/gym_trainer_profile_screen/widget/gym_trainer_profile_top_section.dart';
import 'package:vlr/views/screens/gym/widget/gym_book_trainer_bottom_sheet.dart';

class GymTrainerProfileScreen extends StatefulWidget {
  final String? staffId;
  const GymTrainerProfileScreen({super.key, this.staffId});

  @override
  State<GymTrainerProfileScreen> createState() =>
      _GymTrainerProfileScreenState();
}

class _GymTrainerProfileScreenState extends State<GymTrainerProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeController = Get.find<HomeController>();
      final gymController = Get.find<GymController>();

      if (widget.staffId != null && widget.staffId!.isNotEmpty) {
        gymController.fetchTrainerDetails(trainerId: widget.staffId!);
      }

      homeController.fetchStaffProfileById(
        id: homeController.selectListingModel?.id,
        staffId: widget.staffId,
      );
    });
  }

  StaffModel? _resolveStaff(
      HomeController homeController, GymController gymController) {
    if (homeController.selectedStaffProfile != null) {
      return homeController.selectedStaffProfile;
    }
    if (widget.staffId != null) {
      final match = gymController.gymTrainerModelList.firstWhereOrNull(
        (t) => t.id?.toString() == widget.staffId,
      );
      if (match != null) return match;
    }
    if (gymController.selectedTrainerDetails != null) {
      return StaffModel.fromJson(gymController.selectedTrainerDetails!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GymController>(builder: (gymController) {
      return GetBuilder<HomeController>(builder: (homeController) {
        final staff = _resolveStaff(homeController, gymController);
        final isLoading = homeController.isLoading && staff == null;

        return Scaffold(
          appBar: AppBar(
            shadowColor: black.withValues(alpha: 0.05),
            title: Text(
              "Trainer Profile",
              style: Helper(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: primaryText1,
                    letterSpacing: 1.4,
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
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Session Rate",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            "₹500",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF002060),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          height: 48,
                          radius: 14,
                          color: const Color(0xFF002060),
                          borderColor: const Color(0xFF002060),
                          onTap: () {
                            GymBookTrainerBottomSheet.show(
                              context: context,
                              staffModel: staff,
                              gymTitle: homeController.selectListingModel?.title,
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bookmark_add_rounded,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text(
                                "BOOK TRAINER (RAZORPAY)",
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
                          const GYMTrainerProfileTopSection(),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const GYMTrainerProfileMidSection(),
                                sizedBoxHeight(height: 30),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
        );
      });
    });
  }
}
