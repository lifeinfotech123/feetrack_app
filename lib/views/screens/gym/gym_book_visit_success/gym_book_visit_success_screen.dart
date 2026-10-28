import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/dashboard_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/dashboard/dashboard_screen.dart';
import 'package:vlr/views/screens/gym/gym_book_visit/gym_my_visit_screen.dart';
import 'package:vlr/views/screens/gym/gym_bottom_nav_bar/gym_bottom_nav_bar_screen.dart';
import 'package:vlr/views/screens/gym/gym_book_visit_success/gym_membership_activation_screen.dart';

class GymBookVisitSuccessScreen extends StatefulWidget {
  final bool isMembership;
  final String? otp;
  final String? bookingNumber;
  final String? invoiceNumber;
  final String? visitId;
  final String? membershipId;
  final String? gymTitle;
  final String? gymAddress;
  final String? packageName;
  final String? trainerName;
  final String? trainerSchedule;
  final String? registeredMobile;
  final dynamic finalAmount;
  final String? visitDate;
  final String? visitTime;
  final String? status;
  final String? message;
  final String? paymentMethod;

  const GymBookVisitSuccessScreen({
    super.key,
    this.isMembership = false,
    this.otp,
    this.bookingNumber,
    this.invoiceNumber,
    this.visitId,
    this.membershipId,
    this.gymTitle,
    this.gymAddress,
    this.packageName,
    this.trainerName,
    this.trainerSchedule,
    this.registeredMobile,
    this.finalAmount,
    this.visitDate,
    this.visitTime,
    this.status,
    this.message,
    this.paymentMethod,
  });

  @override
  State<GymBookVisitSuccessScreen> createState() =>
      _GymBookVisitSuccessScreenState();
}

class _GymBookVisitSuccessScreenState extends State<GymBookVisitSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membershipStatus = widget.status?.toLowerCase().replaceAll('-', '_');
    final membershipIsActive = membershipStatus == 'active';
    final titleText = widget.isMembership
        ? (membershipIsActive
            ? "Membership Activated Successfully"
            : widget.paymentMethod == "cash"
                ? "Membership Booking Confirmed"
                : "Membership Booking Received")
        : "Visit Booking Confirmed";
    final defaultMsg = widget.isMembership
        ? (widget.message ??
            (membershipIsActive
                ? "Your membership is active."
                : "Your membership is pending activation. It will become active only after the gym verifies the required payment and activation details."))
        : (widget.message ??
            "Your gym visit has been scheduled successfully! The partner team has been notified.");

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: black.withValues(alpha: 0.05),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          widget.isMembership
              ? (membershipIsActive
                  ? "Membership Active"
                  : widget.paymentMethod == "cash"
                      ? "Booking Confirmed"
                      : "Pending Activation")
              : "Visit Booking Confirmed",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: blackText1,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Animated Celebratory Top Icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 72,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    titleText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      defaultMsg,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: greyText3,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // OTP Box (Prominent for membership bookings)
            if (!widget.isMembership &&
                widget.otp != null &&
                widget.otp!.isNotEmpty) ...[
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
                          "GYM STAFF ACTIVATION OTP",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
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
                        Text(
                          widget.otp!,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          tooltip: "Copy OTP",
                          icon: const Icon(Icons.copy_rounded,
                              color: Colors.white, size: 22),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: widget.otp!));
                            showToast(
                              message: "OTP copied to clipboard: ${widget.otp}",
                              toastType: ToastType.success,
                            );
                          },
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
                        "Please share this OTP with the gym staff on your visit to activate your membership.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
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
                  Text(
                    widget.isMembership
                        ? "Membership Details"
                        : "Visit Details",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (widget.gymTitle != null && widget.gymTitle!.isNotEmpty)
                    _buildDetailRow(
                        Icons.fitness_center_rounded, "Gym", widget.gymTitle!),
                  if (widget.gymAddress != null &&
                      widget.gymAddress!.isNotEmpty)
                    _buildDetailRow(
                      Icons.location_on_outlined,
                      "Address",
                      widget.gymAddress!,
                    ),
                  if (widget.packageName != null &&
                      widget.packageName!.isNotEmpty)
                    _buildDetailRow(Icons.card_membership_rounded, "Package",
                        widget.packageName!),
                  if (widget.trainerName != null &&
                      widget.trainerName!.isNotEmpty)
                    _buildDetailRow(
                      Icons.sports_gymnastics_rounded,
                      "Trainer",
                      widget.trainerName!,
                    ),
                  if (widget.trainerSchedule != null &&
                      widget.trainerSchedule!.isNotEmpty)
                    _buildDetailRow(
                      Icons.access_time_rounded,
                      "Schedule",
                      widget.trainerSchedule!,
                    ),
                  if (widget.finalAmount != null)
                    _buildDetailRow(Icons.payments_rounded, "Amount",
                        "₹${widget.finalAmount}"),
                  if (widget.paymentMethod?.isNotEmpty == true)
                    _buildDetailRow(
                      Icons.payment_rounded,
                      "Payment Method",
                      widget.paymentMethod!.toUpperCase(),
                    ),
                  if (widget.visitDate != null && widget.visitDate!.isNotEmpty)
                    _buildDetailRow(Icons.calendar_today_rounded, "Visit Date",
                        widget.visitDate!),
                  if (widget.visitTime != null && widget.visitTime!.isNotEmpty)
                    _buildDetailRow(Icons.access_time_rounded, "Preferred Time",
                        widget.visitTime!),
                  if (widget.bookingNumber != null &&
                      widget.bookingNumber!.isNotEmpty)
                    _buildDetailRow(Icons.confirmation_number_rounded,
                        "Booking No.", widget.bookingNumber!),
                  if (widget.invoiceNumber != null &&
                      widget.invoiceNumber!.isNotEmpty)
                    _buildDetailRow(Icons.receipt_long_rounded, "Invoice No.",
                        widget.invoiceNumber!),
                  if (widget.visitId != null && widget.visitId!.isNotEmpty)
                    _buildDetailRow(
                        Icons.tag_rounded, "Booking ID", widget.visitId!),
                  if (widget.membershipId != null &&
                      widget.membershipId!.isNotEmpty)
                    _buildDetailRow(
                      Icons.card_membership_rounded,
                      "Membership ID",
                      widget.membershipId!,
                    ),
                  if (widget.status != null && widget.status!.isNotEmpty)
                    _buildDetailRow(
                      Icons.info_outline_rounded,
                      "Status",
                      widget.status!.toUpperCase(),
                      isBadge: true,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Action Buttons
            if (widget.isMembership &&
                widget.paymentMethod == "razorpay" &&
                widget.membershipId?.isNotEmpty == true) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    navigate(
                      context: context,
                      page: GymMembershipActivationScreen(
                        membershipId: widget.membershipId!,
                        gymTitle: widget.gymTitle ?? "Gym Sanctuary",
                        gymAddress: widget.gymAddress ?? "",
                        packageName: widget.packageName ?? "Membership Package",
                        trainerName: widget.trainerName ?? "",
                        trainerSchedule: widget.trainerSchedule ?? "",
                        registeredMobile: widget.registeredMobile ?? "",
                        initialStatus: widget.status ?? "pending_activation",
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified_user_rounded,
                      color: Colors.white),
                  label: const Text(
                    "ACTIVATE MEMBERSHIP",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002060),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  navigate(
                      context: context,
                      isRemoveUntil: true,
                      page: const GymMembershipsScreen());
                },
                icon: Icon(
                  widget.isMembership
                      ? Icons.card_membership_rounded
                      : Icons.list_alt_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  widget.isMembership
                      ? "VIEW MY MEMBERSHIPS"
                      : "VIEW MY VISITS",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isMembership
                      ? const Color(0xFF002060)
                      : primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  final dashBoardController = Get.find<DashBoardController>();
                  dashBoardController.dashPage = 0;
                  navigate(
                    context: context,
                    isRemoveUntil: true,
                    page: const DashboardScreen(),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "BACK TO HOME",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value,
      {bool isBadge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: primaryColor),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: greyText3,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: isBadge
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.orange,
                      ),
                    ),
                  )
                : Text(
                    value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
