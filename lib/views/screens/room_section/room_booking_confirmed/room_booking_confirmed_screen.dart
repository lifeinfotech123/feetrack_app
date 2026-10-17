import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vlr/controllers/book_appoint_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/visit_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/lanch_helper.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/room_bottom_nav_bar_screen.dart';

class RoomBookingConfirmedScreen extends StatelessWidget {
  final Map<String, dynamic>? visitData;
  final VisitModel? visitModel;

  const RoomBookingConfirmedScreen({
    super.key,
    this.visitData,
    this.visitModel,
  });

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return "";
    try {
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        return DateFormat("EEEE, dd MMM yyyy").format(date);
      }
    } catch (_) {}
    return dateStr;
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return "";
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        final period = hour >= 12 ? 'PM' : 'AM';
        hour = hour % 12;
        if (hour == 0) hour = 12;
        final minuteStr = minute.toString().padLeft(2, '0');
        return "$hour:$minuteStr $period";
      }
    } catch (_) {}
    return timeStr;
  }

  void _shareDetails({
    required String propertyTitle,
    required String address,
    required String date,
    required String time,
    required String visitId,
  }) {
    final buffer = StringBuffer("Property Visit Confirmed!\n\n");
    if (propertyTitle.isNotEmpty) buffer.writeln("Property: $propertyTitle");
    if (address.isNotEmpty) buffer.writeln("Address: $address");
    if (date.isNotEmpty) buffer.writeln("Date: $date");
    if (time.isNotEmpty) buffer.writeln("Time: $time");
    if (visitId.isNotEmpty) buffer.writeln("Visit ID: $visitId");
    buffer.writeln("\nBooked via ${AppConstants.appName}");

    SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  void _goToVisits(BuildContext context) {
    navigate(
      context: context,
      isRemoveUntil: true,
      page: const RoomBottomNavBarScreen(initialIndex: 2),
    );
  }

  void _goToExplore(BuildContext context) {
    navigate(
      context: context,
      isRemoveUntil: true,
      page: const RoomBottomNavBarScreen(initialIndex: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String visitId = visitModel?.id ??
        visitData?['visit_id']?.toString() ??
        visitData?['id']?.toString() ??
        "";

    final listingMap = visitData?['listing'] is Map
        ? Map<String, dynamic>.from(visitData!['listing'])
        : null;

    final visitorMap = visitData?['visitor'] is Map
        ? Map<String, dynamic>.from(visitData!['visitor'])
        : null;

    final websiteMap = visitData?['website'] is Map
        ? Map<String, dynamic>.from(visitData!['website'])
        : null;

    final String propertyTitle = visitModel?.listing?.title ??
        listingMap?['title']?.toString() ??
        Get.find<RoomController>().selectedListingDetails?.title ??
        Get.find<HomeController>().selectListingModel?.title ??
        "";

    final String propertyAddress = [
      visitModel?.listing?.address ??
          listingMap?['address']?.toString() ??
          Get.find<RoomController>().selectedListingDetails?.address,
      visitModel?.listing?.city ??
          listingMap?['city']?.toString() ??
          Get.find<RoomController>().selectedListingDetails?.city,
    ].where((e) => e != null && e.toString().trim().isNotEmpty).join(", ");

    final String propertyImage =
        (visitModel?.listing?.images?.isNotEmpty ?? false)
            ? visitModel!.listing!.images!.first.imagePath ?? ""
            : visitModel?.listing?.image ??
                Get.find<RoomController>().selectedListingDetails?.image ??
                "";

    // Date & Time from data or appointment controller
    String rawDate =
        visitModel?.visitDate ?? visitData?['visit_date']?.toString() ?? "";
    if (rawDate.isEmpty && Get.isRegistered<BookAppointController>()) {
      final appoint = Get.find<BookAppointController>();
      rawDate =
          "${appoint.selectedDate.year}-${appoint.selectedDate.month.toString().padLeft(2, '0')}-${appoint.selectedDate.day.toString().padLeft(2, '0')}";
    }

    String rawTime =
        visitModel?.visitTime ?? visitData?['visit_time']?.toString() ?? "";
    if (rawTime.isEmpty && Get.isRegistered<BookAppointController>()) {
      rawTime = Get.find<BookAppointController>().selectedTime;
    }

    final formattedDate = _formatDate(rawDate);
    final formattedTime = _formatTime(rawTime);

    // Visitor info
    final String visitorName =
        visitModel?.customer?.name ?? visitorMap?['name']?.toString() ?? "";
    final String visitorMobile =
        visitModel?.customer?.mobile ?? visitorMap?['mobile']?.toString() ?? "";
    final String visitorEmail =
        visitModel?.customer?.email ?? visitorMap?['email']?.toString() ?? "";
    final bool hasVisitor = visitorName.isNotEmpty ||
        visitorMobile.isNotEmpty ||
        visitorEmail.isNotEmpty;

    // Website info
    final String websiteName =
        visitModel?.website?.name ?? websiteMap?['name']?.toString() ?? "";

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goToVisits(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 22, color: Color(0xFF0F172A)),
            onPressed: () => _goToVisits(context),
          ),
          centerTitle: true,
          title: const Text(
            "Booking Confirmed",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined,
                  size: 20, color: Color(0xFF002060)),
              onPressed: () => _shareDetails(
                propertyTitle: propertyTitle,
                address: propertyAddress,
                date: formattedDate,
                time: formattedTime,
                visitId: visitId,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Animation / Icon Banner
              _buildSuccessBanner(visitId: visitId, context: context),

              const SizedBox(height: 24),

              // Property Information Card
              if (propertyTitle.isNotEmpty || propertyAddress.isNotEmpty)
                _buildPropertyCard(
                  title: propertyTitle,
                  address: propertyAddress,
                  image: propertyImage,
                  phone: visitModel?.listing?.phone?.toString(),
                ),

              const SizedBox(height: 16),

              // Appointment Timing Card
              if (formattedDate.isNotEmpty || formattedTime.isNotEmpty)
                _buildAppointmentCard(
                  date: formattedDate,
                  time: formattedTime,
                ),

              // Visitor Details Card (if present)
              if (hasVisitor) ...[
                const SizedBox(height: 16),
                _buildVisitorCard(
                  name: visitorName,
                  mobile: visitorMobile,
                  email: visitorEmail,
                ),
              ],

              // Partner / Portal Info (if present)
              if (websiteName.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildPortalCard(websiteName: websiteName),
              ],

              const SizedBox(height: 16),

              // Guidelines & Instructions
              _buildGuidelinesCard(),

              const SizedBox(height: 28),

              // Action Buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBanner({
    required String visitId,
    required BuildContext context,
  }) {
    return Column(
      children: [
        // Pulsing Circle Avatar with Checkmark
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
          ),
          child: Center(
            child: Container(
              width: 62,
              height: 62,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4010B981),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          "Visit Scheduled!",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 6),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Your appointment has been successfully booked. The property host has been notified.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCard({
    required String title,
    required String address,
    required String image,
    String? phone,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(
                image,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002060).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Color(0xFF002060),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title.isNotEmpty)
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          if (address.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 14, color: Color(0xFF64748B)),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    address,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF64748B),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (phone != null && phone.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => LaunchHelper.callUs(number: phone),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002060).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.call_rounded,
                              size: 16, color: Color(0xFF002060)),
                          const SizedBox(width: 8),
                          Text(
                            "Call Property ($phone)",
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF002060),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String date,
    required String time,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month_rounded,
                  size: 18, color: Color(0xFF002060)),
              SizedBox(width: 8),
              Text(
                "Appointment Details",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              Spacer(),
              Chip(
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: -2),
                backgroundColor: Color(0xFFECFDF5),
                side: BorderSide(color: Color(0xFFA7F3D0)),
                label: Text(
                  "CONFIRMED",
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF059669),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (date.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Visit Date",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (date.isNotEmpty && time.isNotEmpty) const SizedBox(width: 12),
              if (time.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Preferred Slot",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
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
    );
  }

  Widget _buildVisitorCard({
    required String name,
    required String mobile,
    required String email,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_rounded, size: 18, color: Color(0xFF002060)),
              SizedBox(width: 8),
              Text(
                "Visitor Information",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (name.isNotEmpty)
            _buildInfoRow(
              icon: Icons.badge_outlined,
              label: "Name",
              value: name,
            ),
          if (mobile.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.phone_android_rounded,
              label: "Mobile",
              value: mobile,
              actionWidget: IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.call_rounded,
                    size: 18, color: Color(0xFF002060)),
                onPressed: () => LaunchHelper.callUs(number: mobile),
              ),
            ),
          ],
          if (email.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.email_outlined,
              label: "Email",
              value: email,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPortalCard({required String websiteName}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.business_outlined,
              size: 18, color: Color(0xFF002060)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Partner Portal",
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  websiteName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelinesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  size: 18, color: Color(0xFF1D4ED8)),
              SizedBox(width: 8),
              Text(
                "Visit Guidelines",
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildGuidelineItem(
            icon: Icons.schedule_rounded,
            text: "Please arrive 10 minutes prior to your preferred time slot.",
          ),
          const SizedBox(height: 8),
          _buildGuidelineItem(
            icon: Icons.badge_rounded,
            text: "Carry a valid photo ID proof for PG/Hostel gate entry.",
          ),
          const SizedBox(height: 8),
          _buildGuidelineItem(
            icon: Icons.edit_calendar_rounded,
            text:
                "You can view or cancel this visit anytime under 'My Visits'.",
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF2563EB)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1E40AF),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary Button: View My Visits
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF002060),
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: const Color(0xFF002060).withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.calendar_month_rounded, size: 18),
            label: const Text(
              "View Scheduled Visits",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            onPressed: () => _goToVisits(context),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary Button: Explore Rooms
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF002060),
              side: const BorderSide(color: Color(0xFF002060), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.home_work_rounded, size: 18),
            label: const Text(
              "Explore More Rooms & PGs",
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () => _goToExplore(context),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? actionWidget,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        if (actionWidget != null) actionWidget,
      ],
    );
  }
}
