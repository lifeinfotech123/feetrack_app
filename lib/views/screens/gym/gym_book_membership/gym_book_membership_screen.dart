import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/data/models/category_model/listing_model.dart';
import 'package:vlr/data/models/category_model/plan_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';
import 'package:vlr/views/screens/gym/gym_book_visit_success/gym_book_visit_success_screen.dart';

class GymBookMembershipScreen extends StatefulWidget {
  final PlanModel? planModel;
  final ListingModel? listingModel;
  final String? packageId;
  final String? listingId;

  const GymBookMembershipScreen({
    super.key,
    this.planModel,
    this.listingModel,
    this.packageId,
    this.listingId,
  });

  @override
  State<GymBookMembershipScreen> createState() =>
      _GymBookMembershipScreenState();
}

class _GymBookMembershipScreenState extends State<GymBookMembershipScreen> {
  late final Razorpay _razorpay;
  String _selectedPaymentMethod = "razorpay"; // "razorpay" or "cash"

  DateTime _selectedDate = DateTime.now();
  String _selectedTime = "";

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _noteController;

  final List<Map<String, dynamic>> _preferredSlots = [];

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

    _noteController = TextEditingController();

    _populateShifts();

    final homeController = Get.find<HomeController>();
    final targetGymId = widget.listingId ??
        widget.listingModel?.id ??
        homeController.selectListingModel?.id ??
        "";

    final gymController = Get.find<GymController>();
    if (gymController.gymShiftsList.isEmpty && targetGymId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        gymController.fetchGymShifts(gymId: targetGymId).then((_) {
          if (mounted) {
            setState(() {
              _populateShifts();
            });
          }
        });
      });
    }
  }

  void _populateShifts() {
    final gymController = Get.find<GymController>();
    final homeController = Get.find<HomeController>();
    final gym = widget.listingModel ?? homeController.selectListingModel;

    // Check gymController.gymShiftsList first
    if (gymController.gymShiftsList.isNotEmpty) {
      _preferredSlots.clear();
      for (var shift in gymController.gymShiftsList) {
        final label = shift.shiftLabel ??
            (shift.startTime != null && shift.endTime != null
                ? "${shift.shiftName} (${shift.startTime} - ${shift.endTime})"
                : (shift.shiftName ?? "Shift"));
        _preferredSlots.add({
          "id": shift.id,
          "label": label,
          "title": shift.shiftName ?? "Shift",
          "time": "${shift.startTime ?? ''} - ${shift.endTime ?? ''}",
          "icon": shift.icon,
          "fee": shift.formattedFee,
          "max_members": shift.maxMembers,
        });
      }
      if (gymController.selectedGymShift != null) {
        final match = _preferredSlots.firstWhereOrNull(
            (slot) => slot["id"] == gymController.selectedGymShift!.id);
        if (match != null) {
          _selectedTime = match["label"] as String;
        } else if (_preferredSlots.isNotEmpty) {
          _selectedTime = _preferredSlots.first["label"] as String;
        }
      } else if (_preferredSlots.isNotEmpty && _selectedTime.isEmpty) {
        _selectedTime = _preferredSlots.first["label"] as String;
      }
      return;
    }

    // Fallback: listing.shifts
    final shifts = gym?.shifts;
    if (shifts != null && shifts.isNotEmpty) {
      _preferredSlots.clear();
      for (var s in shifts) {
        final map =
            s is Map ? Map<String, dynamic>.from(s) : <String, dynamic>{};
        final shiftName =
            (map['shift_label'] ?? map['shift_name'] ?? 'Shift').toString();
        final startTime = map['start_time']?.toString() ?? '';
        final endTime = map['end_time']?.toString() ?? '';
        final timeLabel = (map['time_label'] != null &&
                map['time_label'].toString().isNotEmpty)
            ? map['time_label'].toString()
            : (startTime.isNotEmpty && endTime.isNotEmpty
                ? "$startTime - $endTime"
                : '');

        final lower = shiftName.toLowerCase();
        IconData icon = Icons.access_time_filled_rounded;
        if (lower.contains('morning')) {
          icon = Icons.wb_sunny_rounded;
        } else if (lower.contains('afternoon')) {
          icon = Icons.wb_twilight_rounded;
        } else if (lower.contains('evening') || lower.contains('night')) {
          icon = Icons.nights_stay_rounded;
        }

        final fullLabel =
            timeLabel.isNotEmpty ? "$shiftName ($timeLabel)" : shiftName;

        _preferredSlots.add({
          "id": map['id']?.toString(),
          "label": fullLabel,
          "title": shiftName,
          "time": timeLabel,
          "icon": icon,
          "fee": map['formatted_fee'] ??
              (map['fee'] == 0 ? 'Included in Plan' : null),
          "max_members": map['max_members'],
        });
      }
      if (_preferredSlots.isNotEmpty && _selectedTime.isEmpty) {
        _selectedTime = _preferredSlots.first["label"] as String;
      }
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

  void _handleRazorpayPaymentSuccess(PaymentSuccessResponse response) {
    final homeController = Get.find<HomeController>();
    final subController = Get.find<SubscriptionController>();
    final gymController = Get.find<GymController>();
    final gym = widget.listingModel ?? homeController.selectListingModel;
    final plan = widget.planModel ?? subController.selectedPlan;
    final listingId = widget.listingId ??
        gym?.id ??
        homeController.selectListingModel?.id ??
        "";
    final packageId =
        widget.packageId ?? plan?.id ?? subController.selectedPlan?.id ?? "";
    final planPrice = plan?.price ?? 0;
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final authController = Get.find<AuthController>();
    final user = authController.userModel;
    final appUserId = int.tryParse(user?.id ?? "") ?? 5;

    showToast(
      message: "Payment received! Confirming membership...",
      toastType: ToastType.success,
    );

    gymController
        .bookGymMembership(
      packageId: packageId,
      listingId: listingId,
      visitDate: formattedDate,
      preferredTime: _selectedTime,
      note: _noteController.text.trim(),
      appUserId: appUserId,
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      customerEmail: _emailController.text.trim(),
      paymentMethod: "razorpay",
      paymentId: response.paymentId,
    )
        .then((value) {
      final data = value.data is Map ? value.data : null;
      final bookingId = data?['booking_id']?.toString() ?? "";
      final invoiceId = data?['invoice_id']?.toString() ?? "";

      // Also trigger payment verification if signature / IDs available
      if (bookingId.isNotEmpty &&
          invoiceId.isNotEmpty &&
          (response.signature != null && response.signature!.isNotEmpty)) {
        gymController.verifyPaymentBooking(
          bookingId: bookingId,
          invoiceId: invoiceId,
          razorpayOrderId: response.orderId ?? "",
          razorpayPaymentId: response.paymentId ?? "",
          razorpaySignature: response.signature ?? "",
        );
      }

      Get.off(() => GymBookVisitSuccessScreen(
            isMembership: true,
            otp: data?['otp']?.toString() ?? "ONLINE",
            bookingNumber: data?['booking_number']?.toString() ??
                "BKG-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}",
            invoiceNumber: data?['invoice_number']?.toString() ??
                "INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}",
            visitId: data?['visit_id']?.toString(),
            gymTitle:
                data?['gym_title']?.toString() ?? gym?.title ?? "Gym Sanctuary",
            packageName: data?['package_name']?.toString() ??
                plan?.name ??
                "Membership Package",
            finalAmount: data?['final_amount'] ?? planPrice,
            visitDate: formattedDate,
            visitTime: _selectedTime,
            status: "completed",
            message:
                "🎉 Payment of ₹$planPrice via Razorpay successful (ID: ${response.paymentId})! Membership booked.",
          ));
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
    required String planName,
    required dynamic planPrice,
  }) {
    final num priceNum = num.tryParse(planPrice.toString()) ?? 1200;
    final int amountInPaise = (priceNum * 100).toInt();

    final options = {
      'key': 'rzp_test_TWIAoYszpcVthe',
      'amount': amountInPaise > 0 ? amountInPaise : 120000,
      'name': gymTitle.isNotEmpty ? gymTitle : 'Feetrack Gym',
      'description': 'Membership: $planName',
      'prefill': {
        'name': _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : 'Member',
        'contact': _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : '9876543210',
        'email': _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : 'member@feetrack.com',
      },
      'theme': {
        'color': '#002060',
      },
    };

    try {
      debugPrint('Opening Razorpay options: $options');
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay native open failed: $e');
      _showRazorpaySimulatedDialog(
        gymTitle: gymTitle,
        planName: planName,
        planPrice: planPrice,
      );
    }
  }

  void _showRazorpaySimulatedDialog({
    required String gymTitle,
    required String planName,
    required dynamic planPrice,
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
              'Membership: $planName',
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
                    '₹$planPrice',
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
    final homeController = Get.find<HomeController>();
    final subController = Get.find<SubscriptionController>();

    final gym = widget.listingModel ?? homeController.selectListingModel;
    final plan = widget.planModel ?? subController.selectedPlan;

    final gymTitle = gym?.title ?? "Gym Sanctuary";
    //  final gymAddress = gym?.fullAddress ?? gym?.address ?? "Location";
    final planName = plan?.name ?? "Membership Package";
    final planPrice = plan?.price ?? 0;
    final planDuration = plan?.durationLabel ?? "Month";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: black.withValues(alpha: 0.05),
        centerTitle: false,
        title: Text(
          "Book Membership",
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
            // ── 1. Selected Package & Gym Card ──────────────────────────────
            Container(
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF002060).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: Color(0xFF002060),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gymTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              planName,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF002060),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Duration: $planDuration",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: greyText3,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "₹$planPrice",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF002060),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── 2. Select Visit / Start Date ────────────────────────────────
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.calendar_month_rounded,
                              size: 18, color: primaryColor),
                          SizedBox(width: 8),
                          Text(
                            "Select Visit Date",
                            style: TextStyle(
                              fontSize: 14.5,
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
                                DateTime.now().add(const Duration(days: 90)),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        icon: const Icon(Icons.edit_calendar_rounded, size: 14),
                        label: const Text(
                          "Pick Date",
                          style: TextStyle(
                              fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(50, 30),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Horizontal 7-Day Quick Strip
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 14,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final date = DateTime.now().add(Duration(days: index));
                        final isSelected = _selectedDate.year == date.year &&
                            _selectedDate.month == date.month &&
                            _selectedDate.day == date.day;

                        return InkWell(
                          onTap: () => setState(() => _selectedDate = date),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 58,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('EEE').format(date).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isSelected ? Colors.white : greyText3,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  DateFormat('dd').format(date),
                                  style: TextStyle(
                                    fontSize: 16,
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
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── 3. Select Preferred Time Slot ──────────────────────────────
            Container(
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
                      Icon(Icons.access_time_filled_rounded,
                          size: 18, color: primaryColor),
                      SizedBox(width: 8),
                      Text(
                        "Preferred Time Slot",
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                  if (_preferredSlots.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.all_inclusive_rounded,
                              size: 16, color: primaryColor),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Open Access (No specific shift required)",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF555555),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: _preferredSlots.map((slot) {
                        final isSelected = _selectedTime == slot["label"];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() =>
                                  _selectedTime = slot["label"] as String);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor.withValues(alpha: 0.08)
                                    : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.grey.shade200,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? primaryColor
                                          : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      slot["icon"] as IconData,
                                      size: 16,
                                      color:
                                          isSelected ? Colors.white : greyText3,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          slot["title"] as String,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? primaryColor
                                                : blackText1,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Wrap(
                                          spacing: 6,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              slot["time"] as String,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: isSelected
                                                    ? primaryColor.withValues(
                                                        alpha: 0.8)
                                                    : greyText3,
                                              ),
                                            ),
                                            if (slot["fee"] != null)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withValues(alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  "${slot["fee"]}",
                                                  style: const TextStyle(
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),
                                            if (slot["max_members"] != null)
                                              Text(
                                                "• Cap: ${slot["max_members"]} members",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: greyText3,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.grey.shade300,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── 4. Customer Details ────────────────────────────────────────
            Container(
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
                      Icon(Icons.person_rounded, size: 18, color: primaryColor),
                      SizedBox(width: 8),
                      Text(
                        "Member Details",
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _nameController,
                    label: "Customer Name",
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    controller: _phoneController,
                    label: "Phone Number",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    controller: _emailController,
                    label: "Email Address",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    controller: _noteController,
                    label: "Note / Special Request (Optional)",
                    icon: Icons.notes_rounded,
                    hint: "e.g., Want to check CrossFit Olympic equipment",
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── 5. Payment Options (Razorpay & Cash) ─────────────────────
            Container(
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
                      Icon(Icons.payment_rounded,
                          size: 18, color: primaryColor),
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
                  const SizedBox(height: 12),

                  // Option 1: Razorpay Online Payment
                  InkWell(
                    onTap: () =>
                        setState(() => _selectedPaymentMethod = "razorpay"),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _selectedPaymentMethod == "razorpay"
                            ? const Color(0xFF002060).withValues(alpha: 0.06)
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
                                      "Online Payment (Razorpay)",
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
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        "INSTANT",
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
                    onTap: () =>
                        setState(() => _selectedPaymentMethod = "cash"),
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
                                  "Pay at gym counter via OTP verification",
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

                  if (_selectedPaymentMethod == "cash") ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00897B).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 16, color: Color(0xFF00897B)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "You will receive an activation OTP to show the gym staff upon your visit.",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(
        listingId: widget.listingId ??
            gym?.id ??
            homeController.selectListingModel?.id ??
            "",
        packageId: widget.packageId ??
            plan?.id ??
            subController.selectedPlan?.id ??
            "",
        planPrice: planPrice,
        gymTitle: gymTitle,
        planName: planName,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: greyText3),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 11.5, color: greyText3),
        prefixIcon: Icon(icon, size: 18, color: greyText3),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

  Widget _buildBottomBar({
    required String listingId,
    required String packageId,
    required dynamic planPrice,
    required String gymTitle,
    required String planName,
  }) {
    return GetBuilder<GymController>(builder: (gymController) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final isRazorpay = _selectedPaymentMethod == "razorpay";

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRazorpay
                              ? "Total Payable (Razorpay)"
                              : "Total Payable (Cash)",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: greyText3,
                          ),
                        ),
                        Text(
                          "₹$planPrice",
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
                        color: primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomButton(
                  height: 52,
                  radius: 14,
                  isLoading: gymController.isLoading,
                  color: const Color(0xFF002060),
                  borderColor: const Color(0xFF002060),
                  onTap: () {
                    final authController = Get.find<AuthController>();
                    if (!authController.isLoggedIn()) {
                      showLoginRequiredDialog(
                        context: context,
                        title: "Login Required",
                        message:
                            "Please login to your account first before purchasing a gym membership.",
                      );
                      return;
                    }

                    if (listingId.isEmpty) {
                      showToast(
                        message: "Listing details not found",
                        toastType: ToastType.error,
                      );
                      return;
                    }
                    if (packageId.isEmpty) {
                      showToast(
                        message: "Please choose a membership package",
                        toastType: ToastType.error,
                      );
                      return;
                    }

                    if (isRazorpay) {
                      _openRazorpayCheckout(
                        gymTitle: gymTitle,
                        planName: planName,
                        planPrice: planPrice,
                      );
                      return;
                    }

                    final user = authController.userModel;
                    final appUserId = int.tryParse(user?.id ?? "") ?? 5;

                    gymController
                        .bookGymMembership(
                      packageId: packageId,
                      listingId: listingId,
                      visitDate: formattedDate,
                      preferredTime: _selectedTime,
                      note: _noteController.text.trim(),
                      appUserId: appUserId,
                      customerName: _nameController.text.trim(),
                      customerPhone: _phoneController.text.trim(),
                      customerEmail: _emailController.text.trim(),
                      paymentMethod: "cash",
                    )
                        .then((value) {
                      if (value.isSuccess) {
                        showToast(
                          message: value.message,
                          toastType: ToastType.success,
                        );
                        final data = value.data is Map ? value.data : null;
                        Get.off(() => GymBookVisitSuccessScreen(
                              isMembership: true,
                              otp: data?['otp']?.toString() ?? "538899",
                              bookingNumber:
                                  data?['booking_number']?.toString(),
                              invoiceNumber:
                                  data?['invoice_number']?.toString(),
                              visitId: data?['visit_id']?.toString(),
                              gymTitle: data?['gym_title']?.toString(),
                              packageName: data?['package_name']?.toString(),
                              finalAmount: data?['final_amount'] ?? planPrice,
                              visitDate: formattedDate,
                              visitTime: _selectedTime,
                              status:
                                  data?['status']?.toString() ?? "completed",
                              message:
                                  data?['message']?.toString() ?? value.message,
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
                            ? "PAY ₹$planPrice VIA RAZORPAY"
                            : "CONFIRM & BOOK MEMBERSHIP (CASH)",
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isRazorpay
                            ? Icons.payment_rounded
                            : Icons.arrow_forward_rounded,
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
  }
}
