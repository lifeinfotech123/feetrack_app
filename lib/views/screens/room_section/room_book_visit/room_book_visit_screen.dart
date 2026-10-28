import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/book_appoint_controller.dart';
import 'package:vlr/controllers/common_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/category_model/listing_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/room_section/room_book_visit/widget/instructionc_widget.dart';
import 'package:vlr/views/screens/room_section/room_book_visit/widget/room_book_visit_select_share_type_section.dart';
import 'package:vlr/views/screens/room_section/room_book_visit/widget/room_visit_select_date_section.dart';
import 'package:vlr/views/screens/room_section/room_book_visit/widget/select_room_profile_widget.dart';

import 'package:vlr/controllers/visit_controller.dart';
import 'package:vlr/views/screens/room_section/room_book_visit/widget/select_visit_select_time_section.dart';
import 'package:vlr/views/screens/room_section/room_booking_confirmed/room_booking_confirmed_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/room_bottom_nav_bar_screen.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';

class RoomBookVisitScreen extends StatefulWidget {
  final ListingModel? listingModel;
  final String? listingId;

  const RoomBookVisitScreen({
    super.key,
    this.listingModel,
    this.listingId,
  });

  @override
  State<RoomBookVisitScreen> createState() => _RoomBookVisitScreenState();
}

class _RoomBookVisitScreenState extends State<RoomBookVisitScreen> {
  @override
  void initState() {
    super.initState();
    // Always start fresh from today with no slot pre-selected
    final bookController = Get.find<BookAppointController>();
    bookController.reset();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final roomController = Get.find<RoomController>();
      final listing = widget.listingModel ??
          roomController.selectedListingDetails ??
          Get.find<HomeController>().selectListingModel;

      if (listing != null) {
        bookController.setBusinessHours(
          open: listing.openingTime,
          close: listing.closingTime,
        );
      } else {
        bookController.generateTimeSlots();
      }
    });
  }

  @override
  void dispose() {
    if (Get.isRegistered<BookAppointController>()) {
      Get.find<BookAppointController>().reset();
    }
    super.dispose();
  }

  Future<void> _handleBookVisit() async {
    final bool isLoggedIn = Get.isRegistered<AuthController>() &&
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

    final bookController = Get.find<BookAppointController>();
    final roomController = Get.find<RoomController>();
    final homeController = Get.find<HomeController>();
    final visitController = Get.find<VisitController>();

    if (bookController.selectedTime.isEmpty) {
      showToast(
        message: "Please select a visit time slot",
        typeCheck: false,
      );
      return;
    }

    // Resolve listing ID from all available sources
    final listingId = widget.listingId ??
        widget.listingModel?.id ??
        roomController.selectedListingDetails?.id ??
        roomController.selectedRoomDetails?.listingId ??
        homeController.selectListingModel?.id ??
        "";

    if (listingId.isEmpty) {
      showToast(
        message: "Listing ID not found. Please re-select the property.",
        typeCheck: false,
      );
      return;
    }

    // Format date as DD-MM-YYYY (e.g. 14-10-2026)
    final date = bookController.selectedDate;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final visitDate = "$day-$month-$year";

    final visitTime = bookController.selectedTime;

    final ResponseModel res = await visitController.schedulePgVisit(
      listingId: listingId,
      visitDate: visitDate,
      visitTime: visitTime,
    );

    if (!mounted) return;

    if (res.isSuccess) {
      bookController.reset();

      showToast(
        message: res.message.isNotEmpty
            ? res.message
            : "Property visit scheduled successfully!",
        toastType: ToastType.success,
      );

      navigate(
        context: context,
        isReplace: true,
        page: RoomBookingConfirmedScreen(
          visitData: res.data is Map ? Map<String, dynamic>.from(res.data) : null,
          visitModel: visitController.selectedVisit,
        ),
      );
    } else {
      showToast(
        message: res.message.isNotEmpty
            ? res.message
            : "Error while booking visit. Please try again.",
        typeCheck: false,
      );
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, -4),
            blurRadius: 18,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status/Summary chip
            GetBuilder<BookAppointController>(
              id: "time_slot",
              builder: (bookController) {
                final hasTime = bookController.selectedTime.isNotEmpty;
                final date = bookController.selectedDate;
                final dateStr = "${date.day}/${date.month}/${date.year}";

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A)
                                  .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Free Property Visit",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hasTime
                              ? "$dateStr • ${bookController.selectedTime}"
                              : "$dateStr • Slot not selected",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hasTime
                                ? const Color(0xFF002060)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Main Book Visit Button
            GetBuilder<VisitController>(
              builder: (visitController) {
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002060),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor:
                          const Color(0xFF002060).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed:
                        visitController.isLoading ? null : _handleBookVisit,
                    child: visitController.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_month_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Schedule Visit",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Schedule a Visit",
          style: Helper(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: blackText3,
              ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: AppConstants.screenPadding,
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SelectRoomProfileWidget(),
                  sizedBoxHeight(height: 32),
                  GetBuilder<CommonController>(
                    builder: (commonController) {
                      return commonController.currentSelectService ==
                              SelectTypeService.pg
                          ? Column(
                              children: [
                                const RoomBookVisitSelectShareType(),
                                sizedBoxHeight(height: 32),
                              ],
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                  const RoomVisitSelectDateSection(),
                  sizedBoxHeight(height: 32),
                  const RoomVisitSelectTimeSection(),
                  sizedBoxHeight(height: 32),
                  const InstructionWidget(),
                ],
                addAutomaticKeepAlives: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
