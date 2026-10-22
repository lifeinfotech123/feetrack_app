import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/book_appoint_controller.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/visit_controller.dart';
import 'package:vlr/data/models/category_model/listing_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';
import 'package:vlr/hospital/features/appointments/presentation/screen/booking_succsess_screen.dart';
import 'package:vlr/views/screens/gym/gym_book_visit_success/gym_book_visit_success_screen.dart';

import 'widget/gym_book_visit_gym_profile_section.dart';
import 'widget/gym_book_visit_select_date_section.dart';
import 'widget/gym_book_visit_select_time_section.dart';

class GymBookVisitScreen extends StatefulWidget {
  final ListingModel? listingModel;
  final String? listingId;

  const GymBookVisitScreen({
    super.key,
    this.listingModel,
    this.listingId,
  });

  @override
  State<GymBookVisitScreen> createState() => _GymBookVisitScreenState();
}

class _GymBookVisitScreenState extends State<GymBookVisitScreen> {
  final TextEditingController _noteController = TextEditingController();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  /// Flag to prevent duplicate booking submissions
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();

    final authController = Get.find<AuthController>();
    final user = authController.userModel;

    _nameController = TextEditingController(
      text: (user?.name?.isNotEmpty == true)
          ? user!.name!
          : (authController.fullNameController.text.isNotEmpty
              ? authController.fullNameController.text
              : ""),
    );

    _phoneController = TextEditingController(
      text: (user?.mobile?.isNotEmpty == true)
          ? user!.mobile!
          : (authController.mobileNoController.text.isNotEmpty
              ? authController.mobileNoController.text
              : ""),
    );

    _emailController = TextEditingController(
      text: (user?.email?.isNotEmpty == true)
          ? user!.email!
          : (authController.emailController.text.isNotEmpty
              ? authController.emailController.text
              : ""),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final homeController = Get.find<HomeController>();
      final bookController = Get.find<BookAppointController>();

      if (widget.listingModel != null) {
        homeController.updateSelectListingModel(value: widget.listingModel!);
      } else if (widget.listingId != null &&
          widget.listingId!.isNotEmpty &&
          homeController.selectListingModel?.id != widget.listingId) {
        await homeController.fetchGymDetails(id: widget.listingId!);
      }

      final currentGym = homeController.selectListingModel;
      if (currentGym != null) {
        bookController.setBusinessHours(
          open: currentGym.openingTime,
          close: currentGym.closingTime,
        );
      } else {
        bookController.generateTimeSlots();
      }

      final targetId = widget.listingId ?? currentGym?.id ?? "";
      if (targetId.isNotEmpty) {
        Get.find<GymController>().fetchGymShifts(gymId: targetId);
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Validates that the selected date and time are in the future.
  /// Returns true if valid, false otherwise (and shows appropriate error toast).
  bool _validateDateTimeSelection(BookAppointController bookController) {
    final now = DateTime.now();
    final selectedDate = bookController.selectedDate;

    // Check if selected date is in the past
    final todayStart = DateTime(now.year, now.month, now.day);
    final selectedDayStart = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (selectedDayStart.isBefore(todayStart)) {
      showToast(
        message: "Past date selected. Please select today or a future date.",
        toastType: ToastType.error,
      );
      return false;
    }

    // Check if a time slot has been selected
    if (bookController.selectedTime.isEmpty) {
      showToast(
        message: "Please choose a time slot to continue",
        toastType: ToastType.error,
      );
      return false;
    }

    // For today's date, validate that the selected time is in the future
    if (selectedDayStart.isAtSameMomentAs(todayStart)) {
      // Try to parse the selected time to check if it's already past
      if (!bookController.canSelectTime(bookController.selectedTime)) {
        showToast(
          message: "Selected time has already passed. Please choose a future time slot.",
          toastType: ToastType.error,
        );
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          shadowColor: black.withValues(alpha: 0.05),
          centerTitle: false,
          title: Text(
            "Schedule Gym Visit",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: blackText1,
                ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic Gym Profile Summary Card
              const GYMBookingVisitGYMProfile(),
              sizedBoxHeight(height: 18),

              // Visit Perks Card
              _buildVisitPerksCard(),
              sizedBoxHeight(height: 18),

              // Step 1: Dynamic Date Selection
              const GYMBookVisiSelectDateSection(),
              sizedBoxHeight(height: 18),

              // Step 2: Dynamic Time Slot Selection
              const GYMBookVisiSelectTimeSection(),
              sizedBoxHeight(height: 18),

              // Customer Information Section
              _buildCustomerInfoSection(),
              sizedBoxHeight(height: 18),

              // Optional Visit Note
              _buildVisitNoteSection(),
              sizedBoxHeight(height: 30),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(
          gym: widget.listingModel ?? homeController.selectListingModel,
        ),
      );
    });
  }

  Widget _buildCustomerInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 16,
            color: Colors.black.withValues(alpha: 0.05),
          )
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 18, color: primaryColor),
              const SizedBox(width: 8),
              const Text(
                "Visitor Details",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _nameController,
            label: "Full Name",
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _phoneController,
            label: "Contact Number",
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _emailController,
            label: "Email Address",
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: greyText3),
        prefixIcon: Icon(icon, size: 18, color: primaryColor),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildVisitPerksCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPerkItem(
            icon: Icons.tour_rounded,
            title: "Free Tour",
            subtitle: "Facility walk",
          ),
          Container(
            height: 24,
            width: 1,
            color: primaryColor.withValues(alpha: 0.15),
          ),
          _buildPerkItem(
            icon: Icons.fitness_center_rounded,
            title: "Equipment Trial",
            subtitle: "Try machines",
          ),
          Container(
            height: 24,
            width: 1,
            color: primaryColor.withValues(alpha: 0.15),
          ),
          _buildPerkItem(
            icon: Icons.sports_kabaddi_rounded,
            title: "Trainer Meet",
            subtitle: "Consultation",
          ),
        ],
      ),
    );
  }

  Widget _buildPerkItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(height: 3),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: blackText1,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
            color: greyText3,
          ),
        ),
      ],
    );
  }

  Widget _buildVisitNoteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 18,
            color: black.withValues(alpha: 0.05),
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
          Row(
            children: [
              Icon(Icons.notes_rounded, size: 18, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                "Visit Note / Message (Optional)",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: blackText1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _noteController,
            maxLines: 2,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            decoration: InputDecoration(
              hintText:
                  "e.g., Interested in trial workout, morning slots, trainer guidance...",
              hintStyle: TextStyle(fontSize: 12, color: greyText3),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar({
    required ListingModel? gym,
  }) {
    return GetBuilder<VisitController>(builder: (visitController) {
      return GetBuilder<BookAppointController>(builder: (bookController) {
        final hasSelectedTime = bookController.selectedTime.isNotEmpty;
        final homeController = Get.find<HomeController>();
        final gymTitle = gym?.title ??
            homeController.selectListingModel?.title ??
            "Gym Sanctuary";

        return Container(
          decoration: BoxDecoration(
            color: white,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -4),
                blurRadius: 16,
                color: black.withValues(alpha: 0.06),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Schedule Preview Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Schedule Gym Visit",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: greyText3,
                            ),
                          ),
                          Text(
                            gymTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF002060),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: hasSelectedTime
                              ? primaryColor.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: hasSelectedTime ? primaryColor : greyText3,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              hasSelectedTime
                                  ? bookController.selectedTime
                                  : "Choose slot",
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color:
                                    hasSelectedTime ? primaryColor : greyText3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Confirm & Book Visit Button (No Payment)
                  CustomButton(
                    height: 52,
                    radius: 14,
                    isLoading: visitController.isLoading || _isBooking,
                    color: const Color(0xFF002060),
                    borderColor: const Color(0xFF002060),
                    onTap: () {
                      // Prevent duplicate clicks
                      if (_isBooking || visitController.isLoading) return;

                      // Validate date and time
                      if (!_validateDateTimeSelection(bookController)) return;

                      final listingId = widget.listingId ??
                          gym?.id ??
                          homeController.selectListingModel?.id ??
                          "";

                      if (listingId.isEmpty) {
                        showToast(
                          message: "Gym listing details not found",
                          toastType: ToastType.error,
                        );
                        return;
                      }

                      final authController = Get.find<AuthController>();
                      if (!authController.isLoggedIn()) {
                        showLoginRequiredDialog(
                          context: context,
                          title: "Login Required",
                          message:
                              "Please login to your account first before scheduling a gym visit.",
                        );
                        return;
                      }

                      final String apiDate =
                          "${bookController.selectedDate.year}-${bookController.selectedDate.month.toString().padLeft(2, '0')}-${bookController.selectedDate.day.toString().padLeft(2, '0')}";

                      final user = authController.userModel;
                      final appUserId = int.tryParse(user?.id ?? "");

                      setState(() => _isBooking = true);

                      visitController
                          .bookGymVisit(
                        listingId: listingId,
                        visitDate: apiDate,
                        preferredTime: bookController.selectedTime,
                        note: _noteController.text.trim(),
                        appUserId: appUserId,
                        customerName: _nameController.text.trim(),
                        customerPhone: _phoneController.text.trim(),
                        customerEmail: _emailController.text.trim(),
                      )
                          .then((value) {
                        if (!mounted) return;
                        setState(() => _isBooking = false);

                        if (value.isSuccess) {
                          showToast(
                            message: value.message,
                            toastType: ToastType.success,
                          );
                          final data = value.data is Map ? value.data : null;
                          Get.off(() => BookingSuccsessScreen(
                                bookingType: 'gym',
                                isMembership: false,
                                gymTitle: data?['gym_title'] ?? gymTitle,
                                bookingId: data?['visit_id']?.toString(),
                                date: data?['visit_date'] ?? apiDate,
                                time: data?['slot_label'] ??
                                    data?['visit_time'] ??
                                    bookController.selectedTime,
                                paymentMethod: 'offline',
                                status: data?['status'] ?? "pending",
                                message: data?['message'] ?? value.message,
                                bookingData:
                                    data is Map<String, dynamic> ? data : null,
                              ));
                        } else {
                          showToast(
                            message: value.message,
                            toastType: ToastType.error,
                          );
                        }
                      }).catchError((error) {
                        if (!mounted) return;
                        setState(() => _isBooking = false);
                        showToast(
                          message: "Something went wrong. Please try again.",
                          toastType: ToastType.error,
                        );
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "CONFIRM & BOOK VISIT",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    });
  }
}
