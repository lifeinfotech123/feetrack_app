import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/data/models/category_model/staff_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';
import 'package:vlr/views/screens/gym/gym_book_visit_success/gym_book_visit_success_screen.dart';
import 'package:vlr/main.dart';
import 'package:vlr/services/route_helper.dart';

class GymBookingScreen extends StatefulWidget {
  final StaffModel staffModel;
  final String? gymTitle;
  final String? gymAddress;
  final int sessionPrice;

  const GymBookingScreen({
    super.key,
    required this.staffModel,
    this.gymTitle,
    this.gymAddress,
    this.sessionPrice = 500,
  });

  static Future<void> show({
    required BuildContext context,
    required StaffModel staffModel,
    String? gymTitle,
    String? gymAddress,
    int sessionPrice = 500,
  }) {
    final bool isLoggedIn = Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().isLoggedIn();
    if (!isLoggedIn) {
      showLoginRequiredDialog(
        context: context,
        title: "Login Required",
        message: "Please login to your account first before booking a trainer.",
      );
      return Future.value();
    }

    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => GymBookingScreen(
          staffModel: staffModel,
          gymTitle: gymTitle,
          gymAddress: gymAddress,
          sessionPrice: sessionPrice,
        ),
      ),
    );
  }

  @override
  State<GymBookingScreen> createState() => _GymBookingScreenState();
}

class _GymBookingScreenState extends State<GymBookingScreen> {
  late final Razorpay _razorpay;
  String _selectedPaymentMethod = "razorpay"; // "razorpay" or "cash"
  DateTime _selectedDate = DateTime.now();
  String _selectedSlot = "Morning (06:00 AM - 08:00 AM)";

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _noteController;

  List<String> _availableSlots = [
    "Morning (06:00 AM - 08:00 AM)",
    "Evening (06:00 PM - 08:00 PM)",
  ];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    final authController = Get.find<AuthController>();
    final user = authController.userModel;

    _nameController = TextEditingController(
      text: (user?.name?.isNotEmpty == true)
          ? user!.name!
          : (authController.fullNameController.text.isNotEmpty
              ? authController.fullNameController.text
              : "Fitness Member"),
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
              : "member@feetrack.com"),
    );

    _noteController = TextEditingController();

    // Check if gym controller or API has specific shifts for this trainer
    final gymController = Get.find<GymController>();
    if (widget.staffModel.id != null) {
      gymController
          .fetchTrainerDetails(trainerId: widget.staffModel.id.toString())
          .then((_) {
        if (mounted && gymController.selectedTrainerDetails != null) {
          final shifts = gymController.selectedTrainerDetails!['shifts'];
          if (shifts is List && shifts.isNotEmpty) {
            final parsedSlots = <String>[];
            for (var s in shifts) {
              if (s is Map) {
                final name = s['shift_name'] ?? '';
                final time = s['time_label'] ?? '';
                parsedSlots.add("$name ($time)".trim());
              }
            }
            if (parsedSlots.isNotEmpty) {
              setState(() {
                _availableSlots = parsedSlots;
                _selectedSlot = parsedSlots.first;
              });
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Navigator.of(context).pop();

    final formattedDate = DateFormat('dd MMM yyyy').format(_selectedDate);
    final bookingNum =
        "TRN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";

    final successPage = GymBookVisitSuccessScreen(
      isMembership: false,
      otp: "PAID",
      bookingNumber: bookingNum,
      gymTitle: widget.gymTitle ?? "Gym Sanctuary",
      packageName:
          "Personal Training Session with ${widget.staffModel.name ?? 'Trainer'}",
      trainerName: widget.staffModel.name ?? "Trainer",
      trainerSchedule: _selectedSlot,
      registeredMobile: _phoneController.text.trim(),
      finalAmount: widget.sessionPrice,
      visitDate: formattedDate,
      visitTime: _selectedSlot,
      status: "confirmed",
      message:
          "🎉 Session Booked with ${widget.staffModel.name ?? 'Trainer'}! Razorpay Payment Successful (ID: ${response.paymentId}).",
      paymentMethod: "razorpay",
    );

    try {
      navigate(context: context, page: successPage);
    } catch (_) {
      navigatorKey.currentState?.push(getCustomRoute(child: successPage));
    }

    showToast(
      message: "Trainer booked successfully!",
      toastType: ToastType.success,
    );
  }

  void _handleCashBooking() {
    Navigator.of(context).pop();

    final formattedDate = DateFormat('dd MMM yyyy').format(_selectedDate);
    final bookingNum =
        "TRN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";

    final successPage = GymBookVisitSuccessScreen(
      isMembership: false,
      otp: "CASH",
      bookingNumber: bookingNum,
      gymTitle: widget.gymTitle ?? "Gym Sanctuary",
      packageName:
          "Personal Training Session with ${widget.staffModel.name ?? 'Trainer'}",
      trainerName: widget.staffModel.name ?? "Trainer",
      trainerSchedule: _selectedSlot,
      registeredMobile: _phoneController.text.trim(),
      finalAmount: widget.sessionPrice,
      visitDate: formattedDate,
      visitTime: _selectedSlot,
      status: "confirmed",
      message:
          "🎉 Session Booked with ${widget.staffModel.name ?? 'Trainer'}! Please pay the trainer at the gym on your visit.",
      paymentMethod: "cash",
    );

    try {
      navigate(context: context, page: successPage);
    } catch (_) {
      navigatorKey.currentState?.push(getCustomRoute(child: successPage));
    }

    showToast(
      message: "Trainer session booked successfully!",
      toastType: ToastType.success,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showToast(
      message: response.message != null && response.message!.isNotEmpty
          ? "Payment Cancelled: ${response.message}"
          : "Payment was not completed.",
      toastType: ToastType.error,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    showToast(
      message: "External Wallet: ${response.walletName}",
      toastType: ToastType.info,
    );
  }

  void _startRazorpayPayment() {
    final bool isLoggedIn = Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().isLoggedIn();
    if (!isLoggedIn) {
      showLoginRequiredDialog(
        context: context,
        title: "Login Required",
        message:
            "Please login to your account first before completing the booking.",
      );
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      showToast(message: "Please enter your name", toastType: ToastType.error);
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      showToast(
          message: "Please enter your phone number",
          toastType: ToastType.error);
      return;
    }

    final int amountInPaise = widget.sessionPrice * 100;
    final options = {
      'key': 'rzp_test_TWIAoYszpcVthe',
      'amount': amountInPaise > 0 ? amountInPaise : 50000,
      'name': widget.gymTitle?.isNotEmpty == true
          ? widget.gymTitle!
          : 'Feetrack Gym',
      'description':
          'Trainer Session - ${widget.staffModel.name ?? "Trainer"} ($_selectedSlot)',
      'prefill': {
        'name': _nameController.text.trim(),
        'contact': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      },
      'theme': {
        'color': '#002060',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      showToast(
        message: "Failed to open Razorpay: $e",
        toastType: ToastType.error,
      );
    }
  }

  void _handleBookingSubmit() {
    if (_selectedPaymentMethod == "cash") {
      _handleCashBooking();
      return;
    }

    _startRazorpayPayment();
  }

  @override
  Widget build(BuildContext context) {
    final trainer = widget.staffModel;
    final gymName = widget.gymTitle ??
        Get.find<HomeController>().selectListingModel?.title ??
        "Gym Sanctuary";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Text(
          "Book Trainer Session",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Trainer Profile Card ───────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CustomImage(
                              path: trainer.photoUrl ?? "",
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trainer.name ?? "Trainer",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF002060)
                                            .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        trainer.specialization ??
                                            "Fitness Coach",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF002060),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (trainer.experienceYears != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          trainer.experienceYears!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF059669),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.fitness_center_rounded,
                                        size: 13, color: greyText3),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        gymName,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: greyText3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── 2. Select Date ────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month_rounded,
                                size: 18, color: primaryColor),
                            const SizedBox(width: 8),
                            const Text(
                              "Select Session Date",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 60)),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          icon:
                              const Icon(Icons.edit_calendar_rounded, size: 14),
                          label: const Text(
                            "Pick Date",
                            style: TextStyle(
                                fontSize: 11.5, fontWeight: FontWeight.w700),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(50, 28),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 60,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 14,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final date =
                              DateTime.now().add(Duration(days: index));
                          final isSelected = _selectedDate.year == date.year &&
                              _selectedDate.month == date.month &&
                              _selectedDate.day == date.day;

                          return InkWell(
                            onTap: () => setState(() => _selectedDate = date),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 56,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF002060)
                                    : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF002060)
                                      : Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('EEE')
                                        .format(date)
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white70
                                          : greyText3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('dd').format(date),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── 3. Select Shift / Slot ────────────────────────────
                    Row(
                      children: [
                        Icon(Icons.access_time_filled_rounded,
                            size: 18, color: primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          "Trainer Shift / Slot",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: _availableSlots.map((slot) {
                        final isSelected = _selectedSlot == slot;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => setState(() => _selectedSlot = slot),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF002060)
                                        .withValues(alpha: 0.08)
                                    : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF002060)
                                      : Colors.grey.shade200,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 16,
                                    color: isSelected
                                        ? const Color(0xFF002060)
                                        : greyText3,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      slot,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? const Color(0xFF002060)
                                            : blackText1,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: isSelected
                                        ? const Color(0xFF002060)
                                        : Colors.grey.shade300,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // ── 4. Member Details ─────────────────────────────────
                    Row(
                      children: [
                        Icon(Icons.person_rounded,
                            size: 18, color: primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          "Member Details",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(
                      controller: _nameController,
                      label: "Your Name",
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _phoneController,
                      label: "Phone Number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _emailController,
                      label: "Email Address",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _noteController,
                      label: "Goal / Special Focus (Optional)",
                      icon: Icons.notes_rounded,
                      hint:
                          "e.g., Focus on cardio, posture correction, weight loss",
                    ),

                    const SizedBox(height: 18),

                    // ── 5. Payment Method Selection ─────────────────────
                    const Text(
                      "Choose Payment Option",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 10),

                    InkWell(
                      onTap: () =>
                          setState(() => _selectedPaymentMethod = "razorpay"),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedPaymentMethod == "razorpay"
                              ? const Color(0xFF002060).withValues(alpha: 0.06)
                              : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedPaymentMethod == "razorpay"
                                ? const Color(0xFF002060)
                                : Colors.grey.shade200,
                            width:
                                _selectedPaymentMethod == "razorpay" ? 1.5 : 1,
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
                                Icons.payment_rounded,
                                size: 16,
                                color: _selectedPaymentMethod == "razorpay"
                                    ? Colors.white
                                    : greyText3,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Online Payment",
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF002060),
                                    ),
                                  ),
                                  Text(
                                    "UPI, Cards, NetBanking via Razorpay",
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: greyText3,
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
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    InkWell(
                      onTap: () =>
                          setState(() => _selectedPaymentMethod = "cash"),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedPaymentMethod == "cash"
                              ? const Color(0xFF00897B).withValues(alpha: 0.06)
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
                                size: 16,
                                color: _selectedPaymentMethod == "cash"
                                    ? Colors.white
                                    : greyText3,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Cash on Gym Visit",
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  Text(
                                    "Pay at the gym after getting confirmed",
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: greyText3,
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
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Action Bar ─────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Session Fee",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: greyText3,
                        ),
                      ),
                      Text(
                        "₹${widget.sessionPrice}",
                        style: const TextStyle(
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
                      height: 50,
                      radius: 14,
                      color: const Color(0xFF002060),
                      borderColor: const Color(0xFF002060),
                      onTap: _handleBookingSubmit,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _selectedPaymentMethod == "cash"
                                ? "CONFIRM & BOOK TRAINER"
                                : "PAY & BOOK TRAINER",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: greyText3),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 11.5, color: greyText3),
        prefixIcon: Icon(icon, size: 17, color: greyText3),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          borderSide: const BorderSide(color: Color(0xFF002060), width: 1.2),
        ),
      ),
    );
  }
}
