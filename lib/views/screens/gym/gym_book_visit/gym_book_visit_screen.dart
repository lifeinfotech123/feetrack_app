import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
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
  late final Razorpay _razorpay;
  String _selectedPaymentMethod = "razorpay"; // "razorpay" or "cash"

  final TextEditingController _noteController = TextEditingController();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorpayPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorpayPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorpayExternalWallet);

    final authController = Get.find<AuthController>();
    final user = authController.userModel;

    _nameController = TextEditingController(
      text: (user?.name?.isNotEmpty == true)
          ? user!.name!
          : (authController.fullNameController.text.isNotEmpty
              ? authController.fullNameController.text
              : "Rahul Sharma"),
    );

    _phoneController = TextEditingController(
      text: (user?.mobile?.isNotEmpty == true)
          ? user!.mobile!
          : (authController.mobileNoController.text.isNotEmpty
              ? authController.mobileNoController.text
              : "9876543210"),
    );

    _emailController = TextEditingController(
      text: (user?.email?.isNotEmpty == true)
          ? user!.email!
          : (authController.emailController.text.isNotEmpty
              ? authController.emailController.text
              : "rahul@example.com"),
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
    _razorpay.clear();
    _noteController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  int _getVisitFee(ListingModel? gym) {
    if (gym?.startingPrice != null && gym!.startingPrice! > 0) {
      return gym.startingPrice!;
    }
    return 199;
  }

  void _handleRazorpayPaymentSuccess(PaymentSuccessResponse response) {
    final homeController = Get.find<HomeController>();
    final visitController = Get.find<VisitController>();
    final bookController = Get.find<BookAppointController>();

    final gym = widget.listingModel ?? homeController.selectListingModel;
    final listingId = widget.listingId ??
        gym?.id ??
        homeController.selectListingModel?.id ??
        "";
    final gymTitle = gym?.title ?? "Gym Sanctuary";
    final visitFee = _getVisitFee(gym);

    final String apiDate =
        "${bookController.selectedDate.year}-${bookController.selectedDate.month.toString().padLeft(2, '0')}-${bookController.selectedDate.day.toString().padLeft(2, '0')}";

    final authController = Get.find<AuthController>();
    final user = authController.userModel;
    final appUserId = int.tryParse(user?.id ?? "") ?? 5;

    showToast(
      message: "Payment received! Scheduling gym visit...",
      toastType: ToastType.success,
    );

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
      if (value.isSuccess) {
        final data = value.data is Map ? value.data : null;
        final visitId = data?['visit_id']?.toString() ?? "";

        // Verify payment booking if GymController is registered
        try {
          if (Get.isRegistered<GymController>() && visitId.isNotEmpty) {
            Get.find<GymController>().verifyPaymentBooking(
              bookingId: visitId,
              invoiceId: "INV-${DateTime.now().millisecondsSinceEpoch}",
              razorpayOrderId: response.orderId ?? "",
              razorpayPaymentId: response.paymentId ?? "",
              razorpaySignature: response.signature ?? "",
            );
          }
        } catch (_) {}

        Get.off(() => GymBookVisitSuccessScreen(
              isMembership: false,
              gymTitle: data?['gym_title'] ?? gymTitle,
              visitId: visitId.isNotEmpty ? visitId : null,
              visitDate: data?['visit_date'] ?? apiDate,
              visitTime: data?['slot_label'] ??
                  data?['visit_time'] ??
                  bookController.selectedTime,
              status: "completed",
              finalAmount: visitFee,
              message:
                  "🎉 Payment of ₹$visitFee via Razorpay successful (ID: ${response.paymentId})! Visit scheduled.",
            ));
      } else {
        showToast(
          message: value.message,
          toastType: ToastType.error,
        );
      }
    });
  }

  void _handleRazorpayPaymentError(PaymentFailureResponse response) {
    showToast(
      message: response.message != null && response.message!.isNotEmpty
          ? "Payment Failed: ${response.message}"
          : "Payment was cancelled.",
      toastType: ToastType.error,
    );
  }

  void _handleRazorpayExternalWallet(ExternalWalletResponse response) {
    showToast(
      message: "External Wallet: ${response.walletName}",
      toastType: ToastType.info,
    );
  }

  void _openRazorpayCheckout({
    required String gymTitle,
    required dynamic visitFee,
  }) {
    final num feeNum = num.tryParse(visitFee.toString()) ?? 199;
    final int amountInPaise = (feeNum * 100).toInt();

    final options = {
      'key': 'rzp_test_TWIAoYszpcVthe',
      'amount': amountInPaise > 0 ? amountInPaise : 19900,
      'name': gymTitle.isNotEmpty ? gymTitle : 'Feetrack Gym',
      'description': 'Gym Visit Pass Booking',
      'prefill': {
        'name': _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : 'Visitor',
        'contact': _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : '9876543210',
        'email': _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : 'visitor@feetrack.com',
      },
      'theme': {
        'color': '#002060',
      },
    };

    try {
      debugPrint('Opening Razorpay options: $options');
      _razorpay.open(options);
    } catch (e) {
      debugPrint(
          'Razorpay native open failed (unsupported environment/desktop): $e');
      _showRazorpaySimulatedDialog(
        gymTitle: gymTitle,
        visitFee: visitFee,
      );
    }
  }

  void _showRazorpaySimulatedDialog({
    required String gymTitle,
    required dynamic visitFee,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF002060).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.payment_rounded,
                  color: Color(0xFF002060), size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Razorpay Gateway',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gymTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Type: Gym Visit Day Pass',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '₹$visitFee',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Simulate Razorpay payment on this platform / test environment:',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleRazorpayPaymentError(
                PaymentFailureResponse(
                    Razorpay.PAYMENT_CANCELLED, 'Payment cancelled', null),
              );
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF002060),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final simPayId = 'pay_${DateTime.now().millisecondsSinceEpoch}';
              final simOrderId =
                  'order_${DateTime.now().millisecondsSinceEpoch}';
              _handleRazorpayPaymentSuccess(
                PaymentSuccessResponse(
                    simPayId, simOrderId, 'sig_simulated', null),
              );
            },
            child: const Text('Pay Success',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      final currentGym =
          homeController.selectListingModel ?? widget.listingModel;
      final visitFee = _getVisitFee(currentGym);

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

              // Payment Method Selection Section (Razorpay vs Cash)
              _buildPaymentMethodSection(visitFee),
              sizedBoxHeight(height: 18),

              // Optional Visit Note
              _buildVisitNoteSection(),
              sizedBoxHeight(height: 30),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(
          gym: currentGym,
          visitFee: visitFee,
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

  Widget _buildPaymentMethodSection(int visitFee) {
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
          const Row(
            children: [
              Icon(Icons.payment_rounded, size: 18, color: primaryColor),
              SizedBox(width: 8),
              Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Option 1: Razorpay Online
          InkWell(
            onTap: () => setState(() => _selectedPaymentMethod = "razorpay"),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _selectedPaymentMethod == "razorpay"
                    ? const Color(0xFF002060).withValues(alpha: 0.08)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selectedPaymentMethod == "razorpay"
                      ? const Color(0xFF002060)
                      : Colors.grey.shade200,
                  width: _selectedPaymentMethod == "razorpay" ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _selectedPaymentMethod == "razorpay"
                          ? const Color(0xFF002060)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bolt_rounded,
                      size: 18,
                      color: _selectedPaymentMethod == "razorpay"
                          ? Colors.white
                          : greyText3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Pay Online",
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "Instant",
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "UPI, Credit/Debit Cards, NetBanking, Wallets",
                          style: TextStyle(
                            fontSize: 11,
                            color: greyText3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _selectedPaymentMethod == "razorpay"
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: _selectedPaymentMethod == "razorpay"
                        ? const Color(0xFF002060)
                        : Colors.grey.shade300,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Option 2: Cash on Visit
          InkWell(
            onTap: () => setState(() => _selectedPaymentMethod = "cash"),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _selectedPaymentMethod == "cash"
                    ? const Color(0xFF00897B).withValues(alpha: 0.08)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selectedPaymentMethod == "cash"
                      ? const Color(0xFF00897B)
                      : Colors.grey.shade200,
                  width: _selectedPaymentMethod == "cash" ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _selectedPaymentMethod == "cash"
                          ? const Color(0xFF00897B)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.payments_rounded,
                      size: 18,
                      color: _selectedPaymentMethod == "cash"
                          ? Colors.white
                          : greyText3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pay Cash on Visit",
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Pay directly at gym reception counter",
                          style: TextStyle(
                            fontSize: 11,
                            color: greyText3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _selectedPaymentMethod == "cash"
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: _selectedPaymentMethod == "cash"
                        ? const Color(0xFF00897B)
                        : Colors.grey.shade300,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
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
    required int visitFee,
  }) {
    return GetBuilder<VisitController>(builder: (visitController) {
      return GetBuilder<BookAppointController>(builder: (bookController) {
        final hasSelectedTime = bookController.selectedTime.isNotEmpty;
        final isRazorpay = _selectedPaymentMethod == "razorpay";
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
                  // Schedule Preview & Amount Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRazorpay
                                ? "Total Payable (Razorpay)"
                                : "Total Payable (Pay on Visit)",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: greyText3,
                            ),
                          ),
                          Text(
                            "₹$visitFee",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
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

                  // Confirm & Pay Button
                  CustomButton(
                    height: 52,
                    radius: 14,
                    isLoading: visitController.isLoading,
                    color: const Color(0xFF002060),
                    borderColor: const Color(0xFF002060),
                    onTap: () {
                      if (bookController.selectedTime.isEmpty) {
                        showToast(
                          message: "Please choose a time slot to continue",
                          toastType: ToastType.error,
                        );
                        return;
                      }

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

                      if (isRazorpay) {
                        _openRazorpayCheckout(
                          gymTitle: gymTitle,
                          visitFee: visitFee,
                        );
                        return;
                      }

                      final String apiDate =
                          "${bookController.selectedDate.year}-${bookController.selectedDate.month.toString().padLeft(2, '0')}-${bookController.selectedDate.day.toString().padLeft(2, '0')}";

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
                      final user = authController.userModel;
                      final appUserId = int.tryParse(user?.id ?? "") ?? 5;

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
                        if (value.isSuccess) {
                          showToast(
                            message: value.message,
                            toastType: ToastType.success,
                          );
                          final data = value.data is Map ? value.data : null;
                          Get.off(() => GymBookVisitSuccessScreen(
                                isMembership: false,
                                gymTitle: data?['gym_title'] ?? gymTitle,
                                visitId: data?['visit_id']?.toString(),
                                visitDate: data?['visit_date'] ?? apiDate,
                                visitTime: data?['slot_label'] ??
                                    data?['visit_time'] ??
                                    bookController.selectedTime,
                                status: data?['status'] ?? "pending",
                                finalAmount: visitFee,
                                message: data?['message'] ?? value.message,
                              ));
                        } else {
                          showToast(
                            message: value.message,
                            toastType: ToastType.error,
                          );
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isRazorpay
                              ? "PAY VIA RAZORPAY & CONFIRM"
                              : "CONFIRM & BOOK VISIT (CASH)",
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
