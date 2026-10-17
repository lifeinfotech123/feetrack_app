import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/common_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/screens/room_section/room/room_booking/room_booking_screen.dart';
import 'package:vlr/views/screens/room_section/term_and_condition/widget/term_and_condition_iagree_widget.dart';
import 'package:vlr/views/screens/room_section/term_and_condition/widget/term_and_condition_med_section.dart';
import 'package:vlr/views/screens/room_section/term_and_condition/widget/term_and_condition_top_section.dart';

class TermAndConditionScreen extends StatefulWidget {
  const TermAndConditionScreen({super.key});

  @override
  State<TermAndConditionScreen> createState() => _TermAndConditionScreenState();
}

class _TermAndConditionScreenState extends State<TermAndConditionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CommonController>().setIsTermAndConditionToFalse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Terms & Conditions",
          style: Helper(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: blackText3,
              ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: white.withValues(alpha: 0.95),
          border: Border.all(width: 1, color: greyLight),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: AppConstants.screenPadding,
              child: GetBuilder<CommonController>(builder: (commonController) {
                return CustomButton(
                  height: 56,
                  radius: 999,
                  color: commonController.isTermAndConditions
                      ? primaryText1
                      : greyText5,
                  borderColor: commonController.isTermAndConditions
                      ? primaryText1
                      : greyText5,
                  onTap: () {
                    if (!commonController.isTermAndConditions) {
                      return showToast(
                          message: "Select Term and Condition",
                          toastType: ToastType.info);
                    }
                    navigate(context: context, page: const RoomBookingScreen());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Accept & Continue",
                        style: Helper(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: white,
                              letterSpacing: 1.4,
                            ),
                      ),
                      sizedBoxWidth(width: 4),
                      Icon(
                        size: 20,
                        Icons.arrow_forward_ios,
                        color: white,
                      )
                    ],
                  ),
                );
              }),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          children: [
            const TermAndConditionTopSection(),
            sizedBoxHeight(height: 24),
            const TermConditionMedSection(),
            sizedBoxHeight(height: 24),
            const TermConditionIAgreeWidget(),
          ],
        ),
      ),
    );
  }
}
