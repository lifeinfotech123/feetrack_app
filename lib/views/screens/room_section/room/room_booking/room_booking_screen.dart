import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/data/models/category_model/listing_model.dart';
import 'package:vlr/data/models/rooom/pg_room_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';
import 'package:vlr/views/screens/room_section/room/room_booking/room_booking_success_screen.dart';

class RoomBookingScreen extends StatefulWidget {
  final PgRoomModel? roomModel;
  final ListingModel? listingModel;
  final String? listingId;
  final String? roomId;

  const RoomBookingScreen({
    super.key,
    this.roomModel,
    this.listingModel,
    this.listingId,
    this.roomId,
  });

  @override
  State<RoomBookingScreen> createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  late final Razorpay _razorpay;
  PgRoomModel? _pendingRoom;
  ListingModel? _pendingListing;
  double _pendingMonthlyRent = 0;
  double _pendingTotalAmount = 0;

  DateTime _moveInDate = DateTime.now().add(const Duration(days: 1));
  int _selectedDurationMonths = 3;
  int _selectedBeds = 1;
  String _selectedPaymentMethod = 'online'; // 'online' or 'pay_at_property'
  bool _isSubmitting = false;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _notesController;

  final List<Map<String, dynamic>> _durations = [
    {
      'months': 1,
      'title': '1 Month',
      'subtitle': 'Flexible Stay',
      'discountPercent': 0,
      'badge': null,
    },
    {
      'months': 3,
      'title': '3 Months',
      'subtitle': 'Quarterly',
      'discountPercent': 5,
      'badge': '5% OFF',
    },
    {
      'months': 6,
      'title': '6 Months',
      'subtitle': 'Semester Stay',
      'discountPercent': 10,
      'badge': '10% OFF',
    },
    {
      'months': 11,
      'title': '11 Months',
      'subtitle': 'Annual Academic',
      'discountPercent': 15,
      'badge': '15% OFF',
    },
  ];

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
      text: (user?.name != null && user!.name!.isNotEmpty)
          ? user.name!
          : (authController.fullNameController.text.isNotEmpty
              ? authController.fullNameController.text
              : ""),
    );

    _phoneController = TextEditingController(
      text: (user?.mobile != null && user!.mobile!.isNotEmpty)
          ? user.mobile!
          : (authController.mobileNoController.text.isNotEmpty
              ? authController.mobileNoController.text
              : ""),
    );

    _emailController = TextEditingController(
      text: (user?.email != null && user!.email!.isNotEmpty)
          ? user.email!
          : (authController.emailController.text.isNotEmpty
              ? authController.emailController.text
              : ""),
    );

    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickMoveInDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _moveInDate.isBefore(now) ? now : _moveInDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF002060),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _moveInDate = picked;
      });
    }
  }

  double _getMonthlyRent(PgRoomModel? room, ListingModel? listing) {
    if (room?.startingPrice != null) {
      final p = double.tryParse(room!.startingPrice.toString());
      if (p != null && p > 0) return p;
    }
    if (room?.perBedRent != null) {
      final p = double.tryParse(room!.perBedRent.toString());
      if (p != null && p > 0) return p;
    }
    if (room?.fullRent != null) {
      final p = double.tryParse(room!.fullRent.toString());
      if (p != null && p > 0) return p;
    }
    if (listing?.startingPrice != null) {
      final p = double.tryParse(listing!.startingPrice.toString());
      if (p != null && p > 0) return p;
    }
    return 6500.0;
  }

  double _getSecurityDeposit(PgRoomModel? room, double monthlyRent) {
    if (room?.securityDeposit != null) {
      final d = double.tryParse(room!.securityDeposit.toString());
      if (d != null && d > 0) return d;
    }
    // Default 1 month rent as refundable security deposit
    return monthlyRent;
  }

  // ── Booking Confirmation & Razorpay Trigger ───────────────────────
  Future<void> _handleConfirmBooking({
    required PgRoomModel? room,
    required ListingModel? listing,
    required double monthlyRent,
    required double totalAmount,
  }) async {
    final bool isLoggedIn = Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().isLoggedIn();
    if (!isLoggedIn) {
      showLoginRequiredDialog(
        context: context,
        title: "Login Required",
        message:
            "Please login to your account first before booking and paying for the room.",
      );
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      showToast(
          message: "Please enter your full name", toastType: ToastType.error);
      return;
    }
    if (phone.isEmpty || phone.length < 10) {
      showToast(
          message: "Please enter a valid 10-digit mobile number",
          toastType: ToastType.error);
      return;
    }

    // Open Razorpay Checkout before confirming any booking
    _openRazorpayCheckout(
      room: room,
      listing: listing,
      monthlyRent: monthlyRent,
      totalAmount: totalAmount,
    );
  }

  void _openRazorpayCheckout({
    required PgRoomModel? room,
    required ListingModel? listing,
    required double monthlyRent,
    required double totalAmount,
  }) {
    _pendingRoom = room;
    _pendingListing = listing;
    _pendingMonthlyRent = monthlyRent;
    _pendingTotalAmount = totalAmount;

    final num feeNum = totalAmount > 0 ? totalAmount : 1000;
    final int amountInPaise = (feeNum * 100).toInt();
    final String propertyTitle =
        listing?.title ?? room?.listing?.title ?? "PG Room Stay";

    final options = {
      'key': 'rzp_test_TWIAoYszpcVthe',
      'amount': amountInPaise > 0 ? amountInPaise : 100000,
      'name': propertyTitle,
      'description': 'Room Booking & Security Deposit',
      'prefill': {
        'name': _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : 'Tenant',
        'contact': _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : '9876543210',
        'email': _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : 'tenant@feetrack.com',
      },
      'theme': {
        'color': '#002060',
      },
    };

    try {
      debugPrint('Opening Razorpay options: $options');
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay native open failed (desktop/emulator): $e');
      _showRazorpaySimulatedDialog(
        propertyTitle: propertyTitle,
        totalAmount: totalAmount,
      );
    }
  }

  void _handleRazorpayPaymentSuccess(PaymentSuccessResponse response) {
    showToast(
      message:
          "🎉 Payment of ₹${_pendingTotalAmount.toInt()} via Razorpay successful (ID: ${response.paymentId})! Confirming booking...",
      toastType: ToastType.success,
    );

    _executeBookingCreation(
      room: _pendingRoom,
      listing: _pendingListing,
      monthlyRent: _pendingMonthlyRent,
      totalAmount: _pendingTotalAmount,
      razorpayPaymentId: response.paymentId,
    );
  }

  void _handleRazorpayPaymentError(PaymentFailureResponse response) {
    setState(() {
      _isSubmitting = false;
    });
    showToast(
      message:
          "❌ Payment Cancelled or Failed. Booking was NOT confirmed. Please try again.",
      toastType: ToastType.error,
    );
  }

  void _handleRazorpayExternalWallet(ExternalWalletResponse response) {
    showToast(
      message: "External wallet selected: ${response.walletName}",
      toastType: ToastType.success,
    );
  }

  Future<void> _executeBookingCreation({
    required PgRoomModel? room,
    required ListingModel? listing,
    required double monthlyRent,
    required double totalAmount,
    required String? razorpayPaymentId,
  }) async {
    setState(() {
      _isSubmitting = true;
    });

    final subController = Get.find<SubscriptionController>();
    final listingId = widget.listingId ?? listing?.id ?? "";
    final roomId = widget.roomId ?? room?.id ?? "";

    final bookingNumber =
        "BKG-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";

    try {
      if (listingId.isNotEmpty && subController.allPlanList.isNotEmpty) {
        final planId = subController.allPlanList.first.id?.toString() ?? "";
        await subController.createSubscription(
          listingId: listingId,
          planId: planId,
          roomId: roomId.isNotEmpty ? roomId : null,
          bedsBooked: _selectedBeds,
          paymentMode: "razorpay",
        );
      }
    } catch (e) {
      debugPrint("createSubscription error: $e");
    }

    // Refresh bookings in SubscriptionController and RoomController
    try {
      await subController.fetchBookings();
      if (Get.isRegistered<RoomController>()) {
        final roomCtrl = Get.find<RoomController>();
        roomCtrl.fetchPgCustomerBookings();
        roomCtrl.fetchPgCustomerDashboard();
      }
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    Get.off(
      () => RoomBookingSuccessScreen(
        bookingNumber: bookingNumber,
        propertyName:
            listing?.title ?? room?.listing?.title ?? "Premium PG & Hostel",
        propertyAddress:
            listing?.address ?? room?.listing?.address ?? "Aliganj, Lucknow",
        roomNumber: room?.roomNumber ?? "Standard Room",
        floorName: room?.floorName ?? "1st Floor",
        roomType: room?.roomType ?? "Double Sharing",
        moveInDate: DateFormat("dd MMM yyyy").format(_moveInDate),
        durationMonths: _selectedDurationMonths,
        totalAmount: totalAmount,
        paymentMethod: "Razorpay Online (Paid)",
        tenantName: _nameController.text.trim(),
        tenantPhone: _phoneController.text.trim(),
      ),
    );
  }

  void _showRazorpaySimulatedDialog({
    required String propertyTitle,
    required double totalAmount,
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
              propertyTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Stay: $_selectedDurationMonths Months • $_selectedBeds Bed(s)',
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
                    '₹${totalAmount.toInt()}',
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
                PaymentFailureResponse(Razorpay.PAYMENT_CANCELLED,
                    'Payment cancelled by user', null),
              );
            },
            child: const Text('Cancel Payment',
                style: TextStyle(color: Colors.red)),
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
    return GetBuilder<RoomController>(
      builder: (roomController) {
        final listing = widget.listingModel ??
            roomController.selectedListingDetails ??
            (Get.isRegistered<HomeController>()
                ? Get.find<HomeController>().selectListingModel
                : null) ??
            widget.roomModel?.listing ??
            roomController.selectedRoomDetails?.listing;

        final room = widget.roomModel ?? roomController.selectedRoomDetails;

        final monthlyRent = _getMonthlyRent(room, listing);
        final selectedDurationMeta = _durations.firstWhere(
          (d) => d['months'] == _selectedDurationMonths,
          orElse: () => _durations[0],
        );
        final discountPercent =
            (selectedDurationMeta['discountPercent'] as int).toDouble();
        final baseRent = monthlyRent * _selectedDurationMonths * _selectedBeds;
        final discountAmount = (baseRent * discountPercent) / 100.0;
        final rentAfterDiscount = baseRent - discountAmount;
        final deposit = _getSecurityDeposit(room, monthlyRent) * _selectedBeds;
        final totalPayable = rentAfterDiscount + deposit;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  size: 20, color: Color(0xFF0F172A)),
              onPressed: () => Get.back(),
            ),
            centerTitle: true,
            title: const Column(
              children: [
                Text(
                  "Room Booking",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  "Direct Room Reservation",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: const Color(0xFFE2E8F0), height: 1),
            ),
          ),
          bottomNavigationBar: _buildBottomBar(
            totalAmount: totalPayable,
            monthlyRent: monthlyRent,
            room: room,
            listing: listing,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Property & Room Overview Card
                _buildPropertyCard(listing: listing, room: room),
                const SizedBox(height: 18),

                // 2. Move-in Date Selector Card
                _buildMoveInDateCard(),
                const SizedBox(height: 18),

                // 3. Stay Duration Selector Card
                _buildStayDurationCard(),
                const SizedBox(height: 18),

                // 4. Bed / Occupancy (if room has capacity)
                if ((room?.capacity ?? 2) > 1) ...[
                  _buildOccupancyCard(room: room),
                  const SizedBox(height: 18),
                ],

                // 5. Included Amenities
                _buildIncludedAmenitiesCard(),
                const SizedBox(height: 18),

                // 6. Resident Information Form
                _buildResidentInfoCard(),
                const SizedBox(height: 18),

                // 7. Payment Option Card
                _buildPaymentOptionCard(),
                const SizedBox(height: 18),

                // 8. Price Breakdown Card
                _buildPriceBreakdownCard(
                  monthlyRent: monthlyRent,
                  months: _selectedDurationMonths,
                  beds: _selectedBeds,
                  baseRent: baseRent,
                  discountAmount: discountAmount,
                  discountPercent: discountPercent.toInt(),
                  deposit: deposit,
                  totalPayable: totalPayable,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── 1. Property & Room Card ───────────────────────────────────────
  Widget _buildPropertyCard({
    required ListingModel? listing,
    required PgRoomModel? room,
  }) {
    final effectiveListing = listing ?? room?.listing;
    final title = effectiveListing?.title ?? "Shiv Shakti Premium PG";
    final address = effectiveListing?.address ??
        effectiveListing?.fullAddress ??
        effectiveListing?.landmark ??
        "Aliganj";
    final city = effectiveListing?.city ?? "Lucknow";
    final gender = effectiveListing?.genderType ?? "Boys";
    final roomNumber = room?.roomNumber ?? room?.roomNo ?? "Room 101";
    final floorName = room?.floorName ??
        (room?.floorId != null ? "Floor ${room!.floorId}" : "1st Floor");
    final roomType = room?.roomType ??
        (room?.capacity != null
            ? "${room!.capacity} Sharing"
            : "Double Sharing");

    String imagePath = "";
    if (room?.images != null && room!.images!.isNotEmpty) {
      imagePath = room.images!.first.url ?? "";
    }
    if (imagePath.isEmpty &&
        effectiveListing?.images != null &&
        effectiveListing!.images!.isNotEmpty) {
      imagePath = effectiveListing.images!.first.url ??
          effectiveListing.images!.first.imagePath ??
          "";
    }
    if (imagePath.isEmpty) {
      imagePath = effectiveListing?.image ?? "";
    }

    final isGirls = gender.toLowerCase().contains("girl");

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 82,
                  height: 82,
                  child: imagePath.isNotEmpty
                      ? CustomImage(
                          path: imagePath,
                          width: 82,
                          height: 82,
                          fit: BoxFit.cover,
                          radius: 12,
                          placeholder: Assets.imagesPlaceholder,
                        )
                      : const CustomImage(
                          path: Assets.imagesPgRoom,
                          width: 82,
                          height: 82,
                          fit: BoxFit.cover,
                          radius: 12,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gender Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isGirls
                            ? const Color(0xFFFCE7F3)
                            : const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isGirls ? "GIRLS PG" : "BOYS PG",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isGirls
                              ? const Color(0xFFBE185D)
                              : const Color(0xFF1D4ED8),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            city.isNotEmpty &&
                                    !address
                                        .toLowerCase()
                                        .contains(city.toLowerCase())
                                ? "$address, $city"
                                : address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMiniRoomPill(
                    icon: Icons.meeting_room_outlined,
                    label: "Room",
                    value: roomNumber,
                  ),
                ),
                Container(width: 1, height: 26, color: const Color(0xFFCBD5E1)),
                Expanded(
                  child: _buildMiniRoomPill(
                    icon: Icons.layers_outlined,
                    label: "Floor",
                    value: floorName,
                  ),
                ),
                Container(width: 1, height: 26, color: const Color(0xFFCBD5E1)),
                Expanded(
                  child: _buildMiniRoomPill(
                    icon: Icons.people_outline,
                    label: "Sharing",
                    value: roomType,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniRoomPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: const Color(0xFF002060)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF002060),
          ),
        ),
      ],
    );
  }

  // ── 2. Move-in Date Card ──────────────────────────────────────────
  Widget _buildMoveInDateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month_outlined,
                  size: 19, color: Color(0xFF002060)),
              SizedBox(width: 8),
              Text(
                "Move-in Date",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickMoveInDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002060),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.event_available,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat("EEEE, dd MMMM yyyy").format(_moveInDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Tap to change your joining date",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_calendar_outlined,
                      color: Color(0xFF002060), size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Stay Duration Card ─────────────────────────────────────────
  Widget _buildStayDurationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timelapse_rounded, size: 19, color: Color(0xFF002060)),
              SizedBox(width: 8),
              Text(
                "Agreement Duration",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _durations.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.1,
            ),
            itemBuilder: (context, index) {
              final d = _durations[index];
              final isSelected = _selectedDurationMonths == d['months'];
              final badge = d['badge'] as String?;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDurationMonths = d['months'] as int;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF002060).withValues(alpha: 0.06)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF002060)
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            d['title'] as String,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? const Color(0xFF002060)
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            d['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isSelected
                                  ? const Color(0xFF002060)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      if (badge != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
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
    );
  }

  // ── 4. Occupancy / Bed Selector ────────────────────────────────────
  Widget _buildOccupancyCard({required PgRoomModel? room}) {
    final maxBeds = room?.availableBeds ?? room?.capacity ?? 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Number of Beds",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Max $maxBeds beds available in this room",
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: _selectedBeds > 1
                      ? () {
                          setState(() {
                            _selectedBeds--;
                          });
                        }
                      : null,
                ),
                Text(
                  "$_selectedBeds",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF002060),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: _selectedBeds < maxBeds
                      ? () {
                          setState(() {
                            _selectedBeds++;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. Included Amenities ─────────────────────────────────────────
  Widget _buildIncludedAmenitiesCard() {
    final amenities = [
      {'icon': Icons.wifi, 'label': 'High-Speed Wi-Fi'},
      {'icon': Icons.ac_unit, 'label': 'Air Conditioner'},
      {'icon': Icons.restaurant, 'label': '3 Meals Included'},
      {'icon': Icons.cleaning_services, 'label': 'Daily Cleaning'},
      {'icon': Icons.local_laundry_service, 'label': 'Laundry Facility'},
      {'icon': Icons.security, 'label': '24/7 CCTV & Guard'},
      {'icon': Icons.water_drop, 'label': 'RO Pure Water'},
      {'icon': Icons.bolt, 'label': 'Power Backup'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_outlined, size: 19, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text(
                "All-Inclusive Amenities",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amenities.map((item) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item['icon'] as IconData,
                        size: 14, color: const Color(0xFF002060)),
                    const SizedBox(width: 6),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── 6. Resident Information Form ──────────────────────────────────
  Widget _buildResidentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_pin_outlined,
                  size: 19, color: Color(0xFF002060)),
              SizedBox(width: 8),
              Text(
                "Resident Information",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Booking agreement will be issued under this profile",
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _nameController,
            label: "Full Name",
            icon: Icons.person_outline,
            hint: "Enter resident full name",
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _phoneController,
            label: "Mobile Number",
            icon: Icons.phone_android_outlined,
            hint: "10-digit mobile number",
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _emailController,
            label: "Email Address",
            icon: Icons.mail_outline,
            hint: "email@example.com",
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _notesController,
            label: "Special Move-in Notes (Optional)",
            icon: Icons.note_alt_outlined,
            hint: "e.g., Late check-in, parking needed",
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle:
                const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF002060), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── 7. Payment Option Card ────────────────────────────────────────
  Widget _buildPaymentOptionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment_outlined, size: 19, color: Color(0xFF002060)),
              SizedBox(width: 8),
              Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPaymentRadioTile(
            value: 'online',
            title: "Online Payment (Instant Confirmation)",
            subtitle: "UPI, Cards, NetBanking via Secure Gateway",
            icon: Icons.flash_on_rounded,
          ),
          const SizedBox(height: 8),
          _buildPaymentRadioTile(
            value: 'pay_at_property',
            title: "Pay at Property on Check-in",
            subtitle: "Cash / UPI after room verification on move-in day",
            icon: Icons.storefront_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRadioTile({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF002060).withValues(alpha: 0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF002060) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? const Color(0xFF002060)
                  : const Color(0xFF94A3B8),
              size: 20,
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 20, color: const Color(0xFF002060)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF64748B),
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

  // ── 8. Price Breakdown Card ───────────────────────────────────────
  Widget _buildPriceBreakdownCard({
    required double monthlyRent,
    required int months,
    required int beds,
    required double baseRent,
    required double discountAmount,
    required int discountPercent,
    required double deposit,
    required double totalPayable,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 19, color: Color(0xFF002060)),
              SizedBox(width: 8),
              Text(
                "Price & Rent Breakdown",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildPriceRow(
            label:
                "Monthly Rent (${beds > 1 ? "$beds beds x " : ""}₹${monthlyRent.toInt()})",
            value: "₹${(monthlyRent * beds).toInt()} / mo",
          ),
          const SizedBox(height: 8),
          _buildPriceRow(
            label: "Total Duration Rent ($months Months)",
            value: "₹${baseRent.toInt()}",
          ),
          if (discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow(
              label: "Tenure Discount ($discountPercent% OFF)",
              value: "- ₹${discountAmount.toInt()}",
              valueColor: const Color(0xFF10B981),
            ),
          ],
          const SizedBox(height: 8),
          _buildPriceRow(
            label: "Security Deposit (100% Refundable)",
            value: "₹${deposit.toInt()}",
            isDeposit: true,
          ),
          const SizedBox(height: 8),
          _buildPriceRow(
            label: "Move-in Maintenance / Admission",
            value: "FREE (₹0)",
            valueColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Payable Amount",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    "Includes Rent & Refundable Deposit",
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Text(
                "₹${totalPayable.toInt()}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF002060),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isDeposit = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF475569),
              ),
            ),
            if (isDeposit)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.info_outline,
                    size: 13, color: Color(0xFF94A3B8)),
              ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  // ── Bottom Fixed Bar ──────────────────────────────────────────────
  Widget _buildBottomBar({
    required double totalAmount,
    required double monthlyRent,
    required PgRoomModel? room,
    required ListingModel? listing,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total Payable",
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "₹${totalAmount.toInt()}",
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF002060),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002060),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              onPressed: _isSubmitting
                  ? null
                  : () => _handleConfirmBooking(
                        room: room,
                        listing: listing,
                        monthlyRent: monthlyRent,
                        totalAmount: totalAmount,
                      ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Confirm & Book Room",
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
