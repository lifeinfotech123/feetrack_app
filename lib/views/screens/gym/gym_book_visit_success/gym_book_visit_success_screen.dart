import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/dashboard_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/dashboard/dashboard_screen.dart';
import 'package:vlr/views/screens/gym/gym_book_visit/gym_my_visit_list_screen.dart';
import 'package:vlr/views/screens/gym/gym_bottom_nav_bar/gym_bottom_nav_bar_screen.dart';

class GymBookVisitSuccessScreen extends StatelessWidget {
  final bool isMembership;
  final String? otp;
  final String? bookingNumber;
  final String? invoiceNumber;
  final String? visitId;
  final String? gymTitle;
  final String? packageName;
  final dynamic finalAmount;
  final String? visitDate;
  final String? visitTime;
  final String? status;
  final String? message;

  const GymBookVisitSuccessScreen({
    super.key,
    this.isMembership = false,
    this.otp,
    this.bookingNumber,
    this.invoiceNumber,
    this.visitId,
    this.gymTitle,
    this.packageName,
    this.finalAmount,
    this.visitDate,
    this.visitTime,
    this.status,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final titleText =
        isMembership ? "Membership Booked!" : "Visit Scheduled!";
    final defaultMsg = isMembership
        ? (message ??
            "Booking placed successfully! Share the activation OTP with gym staff to start.")
        : (message ??
            "Gym visit scheduled successfully! The partner team has been notified.");

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: black.withValues(alpha: 0.05),
        centerTitle: true,
        title: Text(
          isMembership ? "Membership Confirmed" : "Visit Booking Confirmed",
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
            // Celebratory Top Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 64,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              titleText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
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
            const SizedBox(height: 24),

            // OTP Box (Prominent for membership bookings)
            if (otp != null && otp!.isNotEmpty) ...[
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
                          otp!,
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
                            Clipboard.setData(ClipboardData(text: otp!));
                            showToast(
                              message: "OTP copied to clipboard: $otp",
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
                    isMembership ? "Membership Details" : "Visit Details",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (gymTitle != null && gymTitle!.isNotEmpty)
                    _buildDetailRow(
                        Icons.fitness_center_rounded, "Gym", gymTitle!),
                  if (packageName != null && packageName!.isNotEmpty)
                    _buildDetailRow(
                        Icons.card_membership_rounded, "Package", packageName!),
                  if (finalAmount != null)
                    _buildDetailRow(Icons.payments_rounded, "Amount",
                        "₹$finalAmount (Cash on Visit)"),
                  if (visitDate != null && visitDate!.isNotEmpty)
                    _buildDetailRow(Icons.calendar_today_rounded, "Visit Date",
                        visitDate!),
                  if (visitTime != null && visitTime!.isNotEmpty)
                    _buildDetailRow(Icons.access_time_rounded,
                        "Preferred Time", visitTime!),
                  if (bookingNumber != null && bookingNumber!.isNotEmpty)
                    _buildDetailRow(Icons.confirmation_number_rounded,
                        "Booking No.", bookingNumber!),
                  if (invoiceNumber != null && invoiceNumber!.isNotEmpty)
                    _buildDetailRow(Icons.receipt_long_rounded, "Invoice No.",
                        invoiceNumber!),
                  if (visitId != null && visitId!.isNotEmpty)
                    _buildDetailRow(
                        Icons.tag_rounded, "Visit ID", visitId!),
                  if (status != null && status!.isNotEmpty)
                    _buildDetailRow(
                      Icons.info_outline_rounded,
                      "Status",
                      status!.toUpperCase(),
                      isBadge: true,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.offAll(() => const GymBottomNavBarScreen(
                        initialIndex: 1,
                      ));
                },
                icon: Icon(
                  isMembership
                      ? Icons.card_membership_rounded
                      : Icons.list_alt_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  isMembership ? "VIEW MY MEMBERSHIPS" : "VIEW MY VISITS",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMembership ? const Color(0xFF002060) : primaryColor,
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
