import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:vlr/views/screens/dashboard/dashboard_screen.dart';
import 'package:vlr/views/screens/gym/gym_bottom_nav_bar/gym_bottom_nav_bar_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/room_bottom_nav_bar_screen.dart';
import '../../../dashboard/presentation/screen/dashboard_screen.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';

class BookingSuccsessScreen extends StatefulWidget {
  final String? bookingId;
  final String? title;
  final String? doctorName;
  final String? date;
  final String? time;
  final String? amount;
  final Map<String, dynamic>? bookingData;
  final Map<String, dynamic>? doctorData;

  // Additional fields for Gym, PG/Room, and General bookings
  final String? bookingType; // 'gym', 'pg', 'hospital', 'lab', etc.
  final String? gymTitle;
  final String? packageName;
  final String? propertyName;
  final String? roomNumber;
  final String? floorName;
  final String? sharingType;
  final String? moveInDate;
  final String? otp;
  final String? paymentMethod; // 'cash', 'offline', 'online', 'pay_at_property', 'razorpay'
  final String? address;
  final String? phone;
  final String? email;
  final String? status;
  final String? message;
  final bool isMembership;
  final VoidCallback? onBackToDashboard;

  const BookingSuccsessScreen({
    Key? key,
    this.bookingId,
    this.title,
    this.doctorName,
    this.date,
    this.time,
    this.amount,
    this.bookingData,
    this.doctorData,
    this.bookingType,
    this.gymTitle,
    this.packageName,
    this.propertyName,
    this.roomNumber,
    this.floorName,
    this.sharingType,
    this.moveInDate,
    this.otp,
    this.paymentMethod,
    this.address,
    this.phone,
    this.email,
    this.status,
    this.message,
    this.isMembership = false,
    this.onBackToDashboard,
  }) : super(key: key);

  @override
  State<BookingSuccsessScreen> createState() => _BookingSuccsessScreenState();
}

class _BookingSuccsessScreenState extends State<BookingSuccsessScreen>
    with TickerProviderStateMixin {
  late AnimationController _badgeController;
  late AnimationController _contentController;
  late AnimationController _confettiController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _checkRotationAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  final List<_ConfettiParticle> _particles = List.generate(
    35,
    (index) => _ConfettiParticle.generate(),
  );

  String get _resolvedType {
    if (widget.bookingType != null && widget.bookingType!.isNotEmpty) {
      return widget.bookingType!.toLowerCase();
    }
    if (widget.gymTitle != null ||
        widget.packageName != null ||
        widget.isMembership ||
        widget.bookingData?['gym_title'] != null ||
        widget.bookingData?['package_name'] != null) {
      return 'gym';
    }
    if (widget.propertyName != null ||
        widget.roomNumber != null ||
        widget.moveInDate != null ||
        widget.sharingType != null) {
      return 'pg';
    }
    return 'hospital';
  }

  bool get _isCashBooking {
    final method = (widget.paymentMethod ??
            widget.bookingData?['payment_mode'] ??
            widget.bookingData?['payment_method'] ??
            '')
        .toString()
        .toLowerCase();
    return method.contains('cash') ||
        method.contains('offline') ||
        method.contains('property') ||
        method.contains('center');
  }

  Map<String, dynamic>? get _hospital {
    final bookingHospital = widget.bookingData?['hospital'];
    if (bookingHospital is Map) {
      return Map<String, dynamic>.from(bookingHospital);
    }
    final doctorHospital = widget.doctorData?['hospital'];
    if (doctorHospital is Map) {
      return Map<String, dynamic>.from(doctorHospital);
    }
    return null;
  }

  String get _hospitalName => _hospital?['name']?.toString().trim() ?? '';

  String _hospitalContactValue(List<String> keys) {
    final hospital = _hospital;
    if (hospital == null) return '';
    for (final key in keys) {
      final value = hospital[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    final contact = hospital['contact'];
    if (contact is Map) {
      for (final key in keys) {
        final value = contact[key]?.toString().trim() ?? '';
        if (value.isNotEmpty) return value;
      }
    }
    return '';
  }

  String get _doctorAddress =>
      widget.doctorData?['address']?.toString().trim() ?? '';

  String get _hospitalAddress {
    final hospital = _hospital;
    if (hospital == null) return '';
    final direct = hospital['full_address'] ??
        hospital['address'] ??
        hospital['location_address'];
    if (direct != null && direct.toString().trim().isNotEmpty) {
      return direct.toString().trim();
    }
    return [
      hospital['landmark'],
      hospital['city'],
      hospital['state'],
      hospital['pincode']
    ]
        .where((value) => value != null && value.toString().trim().isNotEmpty)
        .map((value) => value.toString().trim())
        .join(', ');
  }

  String get _displayProviderName {
    if (widget.gymTitle != null && widget.gymTitle!.isNotEmpty) {
      return widget.gymTitle!;
    }
    if (widget.propertyName != null && widget.propertyName!.isNotEmpty) {
      return widget.propertyName!;
    }
    if (widget.doctorName != null && widget.doctorName!.isNotEmpty) {
      return widget.doctorName!;
    }
    if (_hospitalName.isNotEmpty) return _hospitalName;
    final bGym = widget.bookingData?['gym_title']?.toString().trim();
    if (bGym != null && bGym.isNotEmpty) return bGym;
    return 'Feetrack Partner Center';
  }

  String get _displayProviderLabel {
    final type = _resolvedType;
    if (type == 'gym') return 'Gym Center';
    if (type == 'pg' || type == 'room') return 'PG / Property';
    return 'Doctor Name';
  }

  String get _displayService {
    if (widget.title != null && widget.title!.isNotEmpty) {
      return widget.title!;
    }
    if (widget.packageName != null && widget.packageName!.isNotEmpty) {
      return widget.packageName!;
    }
    if (widget.sharingType != null && widget.sharingType!.isNotEmpty) {
      return 'PG Accommodation (${widget.sharingType})';
    }
    final bPkg = widget.bookingData?['package_name']?.toString().trim();
    if (bPkg != null && bPkg.isNotEmpty) return bPkg;
    return _resolvedType == 'gym'
        ? 'Gym Plan / Visit'
        : _resolvedType == 'pg'
            ? 'Room Stay Reservation'
            : 'General Consultation & Checkup';
  }

  String get _displayDate {
    if (widget.moveInDate != null && widget.moveInDate!.isNotEmpty) {
      return widget.moveInDate!;
    }
    if (widget.date != null && widget.date!.isNotEmpty) {
      return widget.date!;
    }
    final d = widget.bookingData?['visit_date'] ?? widget.bookingData?['date'];
    if (d != null && d.toString().trim().isNotEmpty) {
      return d.toString().trim();
    }
    return 'Confirmed Schedule';
  }

  String? get _displayTime {
    if (widget.time != null && widget.time!.isNotEmpty) {
      return widget.time!;
    }
    final t = widget.bookingData?['visit_time'] ?? widget.bookingData?['slot_label'];
    if (t != null && t.toString().trim().isNotEmpty) {
      return t.toString().trim();
    }
    return null;
  }

  String get _displayAddress {
    if (widget.address != null && widget.address!.isNotEmpty) {
      return widget.address!;
    }
    if (_doctorAddress.isNotEmpty) return _doctorAddress;
    if (_hospitalAddress.isNotEmpty) return _hospitalAddress;
    final bAddr = widget.bookingData?['hospital']?['address'] ??
        widget.bookingData?['gym']?['address'] ??
        widget.bookingData?['address'];
    if (bAddr != null && bAddr.toString().trim().isNotEmpty) {
      return bAddr.toString().trim();
    }
    return '';
  }

  String? get _otpCode {
    if (widget.otp != null && widget.otp!.isNotEmpty) {
      return widget.otp!;
    }
    final bOtp = widget.bookingData?['otp'];
    if (bOtp != null && bOtp.toString().trim().isNotEmpty) {
      return bOtp.toString().trim();
    }
    return null;
  }

  Future<void> _openDirections() async {
    final destination = _displayAddress.isNotEmpty
        ? _displayAddress
        : _displayProviderName;
    if (destination.trim().isEmpty) return;

    final url = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': destination,
    });
    if (!await launchUrl(url, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open location directions.')),
      );
    }
  }

  void _navigateBackToDashboard() {
    if (widget.onBackToDashboard != null) {
      widget.onBackToDashboard!();
      return;
    }
    final type = _resolvedType;
    if (type == 'gym') {
      Get.offAll(() => const GymBottomNavBarScreen(initialIndex: 1));
      return;
    }
    if (type == 'pg' || type == 'room') {
      Get.offAll(() => const RoomBottomNavBarScreen(initialIndex: 1));
      return;
    }
    if (type == 'hospital') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HospitalDashboardScreen(),
        ),
        (route) => route.isFirst,
      );
      return;
    }
    Get.offAll(() => const DashboardScreen());
  }

  @override
  void initState() {
    super.initState();

    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _checkRotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _rippleAnimation = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _badgeController.forward().then((_) {
      _contentController.forward();
      _confettiController.forward();
    });
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _contentController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefix = _resolvedType == 'gym'
        ? 'GYM-'
        : _resolvedType == 'pg'
            ? 'PG-'
            : 'HMS-';
    final bookingRef = widget.bookingId ??
        '$prefix${math.Random().nextInt(89999) + 10000}';
    final rawAmt = widget.amount ?? widget.bookingData?['final_amount']?.toString();
    final totalPaid = rawAmt != null
        ? (rawAmt.toString().startsWith('₹')
            ? rawAmt.toString()
            : '₹$rawAmt')
        : '₹500.00';

    final paymentStatusText = _isCashBooking
        ? (_resolvedType == 'gym'
            ? 'Confirmed, Pay at Gym'
            : _resolvedType == 'pg'
                ? 'Confirmed, Pay at Property'
                : 'Confirmed, Pay at Hospital')
        : 'Confirmed & Paid';

    final subTitleMessage = widget.message ??
        (_resolvedType == 'gym'
            ? 'Your gym booking has been placed successfully!\nShow your activation details on arrival.'
            : _resolvedType == 'pg'
                ? 'Your room reservation is confirmed!\nPlease arrive on your move-in date.'
                : 'Your appointment has been confirmed.\nA notification was sent to your registered details.');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateBackToDashboard();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            _resolvedType == 'gym'
                ? "Gym Booking Successful"
                : _resolvedType == 'pg'
                    ? "PG Booking Successful"
                    : "Booking Successful",
          ),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: _ConfettiPainter(
                      particles: _particles,
                      progress: _confettiController.value,
                    ),
                  );
                },
              ),

              SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Animated Hero Success Badge
                    Center(
                      child: AnimatedBuilder(
                        animation: _badgeController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.scale(
                                scale: _rippleAnimation.value,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: wellnessGreen.withValues(
                                      alpha: (1.3 - _rippleAnimation.value)
                                          .clamp(0.0, 0.25),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: wellnessGreenBg,
                                  boxShadow: [
                                    BoxShadow(
                                      color: wellnessGreen.withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Transform.rotate(
                                  angle: _checkRotationAnimation.value,
                                  child: Container(
                                    width: 90,
                                    height: 90,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF43A047),
                                          Color(0xFF2E7D32)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x552E7D32),
                                          blurRadius: 15,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 54,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    FadeTransition(
                      opacity: _contentOpacity,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Column(
                          children: [
                            const Text(
                              'Booking Successful!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                                letterSpacing: -0.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subTitleMessage,
                              style: const TextStyle(
                                fontSize: 13,
                                color: textMuted,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 24),

                            // Activation OTP Card (if OTP is available)
                            if (_otpCode != null && _otpCode!.isNotEmpty) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF002060), Color(0xFF0D47A1)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF002060).withValues(alpha: 0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    )
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.vpn_key_rounded,
                                            color: Color(0xFFFFD54F), size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          "ACTIVATION OTP",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            _otpCode!,
                                            style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 4,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(
                                              ClipboardData(text: _otpCode!),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'OTP copied: $_otpCode',
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: const Padding(
                                            padding: EdgeInsets.all(6.0),
                                            child: Icon(
                                              Icons.copy_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        "Please share this OTP with staff upon arrival to activate your booking.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Booking Details Card
                            ModernCard(
                              padding: const EdgeInsets.all(20),
                              borderRadius: 20,
                              shadows: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Card Top Bar
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: fillColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'BOOKING REFERENCE',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryDark,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                bookingRef,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: textDark,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(
                                              ClipboardData(text: bookingRef),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Booking reference copied to clipboard!',
                                                ),
                                                duration: Duration(seconds: 2),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: const Padding(
                                            padding: EdgeInsets.all(6.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.copy_rounded,
                                                  size: 16,
                                                  color: primaryColor,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Copy',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                  const Divider(height: 1, color: borderGrey),
                                  const SizedBox(height: 16),

                                  _buildDetailRow(
                                    icon: _resolvedType == 'gym'
                                        ? Icons.fitness_center_rounded
                                        : _resolvedType == 'pg'
                                            ? Icons.bed_rounded
                                            : Icons.medical_services_outlined,
                                    iconColor: primaryColor,
                                    label: 'Service / Plan',
                                    value: _displayService,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildDetailRow(
                                    icon: _resolvedType == 'gym'
                                        ? Icons.fitness_center_outlined
                                        : _resolvedType == 'pg'
                                            ? Icons.apartment_rounded
                                            : Icons.person_outline_rounded,
                                    iconColor: diagnosticViolet,
                                    label: _displayProviderLabel,
                                    value: _displayProviderName,
                                  ),
                                  if (widget.roomNumber != null &&
                                      widget.roomNumber!.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    _buildDetailRow(
                                      icon: Icons.meeting_room_outlined,
                                      iconColor: pharmacyTeal,
                                      label: 'Room & Floor',
                                      value:
                                          'Room ${widget.roomNumber}${widget.floorName != null ? " • ${widget.floorName}" : ""}',
                                    ),
                                  ],
                                  const SizedBox(height: 14),
                                  _buildDetailRow(
                                    icon: Icons.calendar_today_outlined,
                                    iconColor: pharmacyTeal,
                                    label: _resolvedType == 'pg'
                                        ? 'Move-in Date'
                                        : 'Date & Time',
                                    value: _displayTime != null
                                        ? '$_displayDate, $_displayTime'
                                        : _displayDate,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildDetailRow(
                                    icon: Icons.payment_outlined,
                                    iconColor: wellnessGreen,
                                    label: _isCashBooking
                                        ? 'Total Amount'
                                        : 'Amount Paid',
                                    value: totalPaid,
                                    valueColor: wellnessGreen,
                                    isBold: true,
                                  ),

                                  const SizedBox(height: 16),
                                  const Divider(height: 1, color: borderGrey),
                                  const SizedBox(height: 16),

                                  // Status Badge
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Payment Status',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textMuted,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: wellnessGreenBg,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: wellnessGreen
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.check_circle_rounded,
                                                size: 14,
                                                color: wellnessGreen,
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  paymentStatusText,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: wellnessGreen,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            if (_displayAddress.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              ModernCard(
                                padding: const EdgeInsets.all(20),
                                borderRadius: 20,
                                shadows: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                                child: InkWell(
                                  onTap: _openDirections,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.location_on_rounded,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Location Address',
                                              style: TextStyle(
                                                color: textMuted,
                                                fontSize: 11,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _displayAddress,
                                              style: const TextStyle(
                                                color: textDark,
                                                fontSize: 13,
                                                height: 1.4,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Row(
                                              children: [
                                                Icon(Icons.map_outlined,
                                                    size: 15,
                                                    color: primaryColor),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Open Location / Directions',
                                                  style: TextStyle(
                                                    color: primaryColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
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
                              ),
                            ],

                            const SizedBox(height: 32),

                            // Action Buttons
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _navigateBackToDashboard,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                  shadowColor: primaryColor.withValues(alpha: 0.4),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.home_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Back to Dashboard',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Downloading digital receipt...',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: const BorderSide(color: primaryColor),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.download_rounded, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Download E-Receipt',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
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
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: valueColor ?? textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Helper model for confetti particles
class _ConfettiParticle {
  final double xRatio;
  final double startY;
  final double size;
  final Color color;
  final double speed;
  final double swaySpeed;

  _ConfettiParticle({
    required this.xRatio,
    required this.startY,
    required this.size,
    required this.color,
    required this.speed,
    required this.swaySpeed,
  });

  factory _ConfettiParticle.generate() {
    final rand = math.Random();
    final colors = [
      const Color(0xFF1E88E5),
      const Color(0xFF43A047),
      const Color(0xFF7E57C2),
      const Color(0xFFFF7043),
      const Color(0xFFFFA000),
      const Color(0xFF00897B),
    ];
    return _ConfettiParticle(
      xRatio: rand.nextDouble(),
      startY: -20 - rand.nextDouble() * 100,
      size: 6 + rand.nextDouble() * 8,
      color: colors[rand.nextInt(colors.length)],
      speed: 0.8 + rand.nextDouble() * 1.2,
      swaySpeed: 2 + rand.nextDouble() * 4,
    );
  }
}

/// Custom painter for rendering lightweight animated confetti
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    for (var p in particles) {
      final y = p.startY + (size.height + 150) * (progress * p.speed);
      if (y < 0 || y > size.height + 20) continue;

      final sway = math.sin(progress * math.pi * p.swaySpeed) * 20;
      final x = (p.xRatio * size.width) + sway;

      final opacity = (1.0 - (progress * 0.8)).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * p.swaySpeed);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.7,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
