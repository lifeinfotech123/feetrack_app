import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vlr/controllers/book_appoint_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/visit_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/lanch_helper.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/my_room_visit_list_screen.dart';
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
      page: const MyRoomVisitListScreen(),
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
    String propertyTitle = visitModel?.listing?.title ?? "";
    String address = "";
    if (visitModel?.listing?.address != null) {
      address = visitModel!.listing!.address!;
    }
    if (address.isEmpty && visitModel?.listing?.city != null) {
      address = visitModel!.listing!.city!;
    }

    if (propertyTitle.isEmpty) {
      propertyTitle =
          Get.find<RoomController>().selectedListingDetails?.title ??
              Get.find<HomeController>().selectListingModel?.title ??
              visitData?['listing']?['title']?.toString() ??
              "";
    }

    if (address.isEmpty) {
      address = Get.find<RoomController>().selectedListingDetails?.address ??
          Get.find<HomeController>().selectListingModel?.address ??
          visitData?['listing']?['address']?.toString() ??
          "";
    }

    String rawDate =
        visitModel?.visitDate ?? visitData?['visit_date']?.toString() ?? "";
    String rawTime =
        visitModel?.visitTime ?? visitData?['visit_time']?.toString() ?? "";

    if (rawDate.isEmpty && Get.isRegistered<BookAppointController>()) {
      final appoint = Get.find<BookAppointController>();
      if (appoint.selectedDate.toString().isNotEmpty) {
        rawDate = DateFormat("yyyy-MM-dd").format(appoint.selectedDate);
      }
    }

    if (rawTime.isEmpty && Get.isRegistered<BookAppointController>()) {
      rawTime = Get.find<BookAppointController>().selectedTime;
    }

    final date = _formatDate(rawDate);
    final time = _formatTime(rawTime);
    final visitId = visitModel?.id ?? visitData?['id']?.toString() ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(),
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: Colors.green, size: 56),
              ),
              const SizedBox(height: 20),
              Text(
                "Visit Scheduled Successfully",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your property visit has been confirmed.\nWe look forward to seeing you there.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (propertyTitle.isNotEmpty) ...[
                      Text(
                        propertyTitle,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (address.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 18, color: Colors.black54),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              address,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (date.isNotEmpty || time.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 18, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            date.isNotEmpty && time.isNotEmpty
                                ? "$date • $time"
                                : date.isNotEmpty
                                    ? date
                                    : time,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (visitId.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.confirmation_number_outlined,
                              size: 18, color: Colors.black54),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Visit ID: $visitId",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.black54),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _goToVisits(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002060),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    "View My Visits",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => _goToExplore(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF002060)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(
                        color: Color(0xFF002060), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _shareDetails(
                  propertyTitle: propertyTitle,
                  address: address,
                  date: date,
                  time: time,
                  visitId: visitId,
                ),
                icon:
                    const Icon(Icons.share_outlined, color: Color(0xFF002060)),
                label: const Text(
                  "Share Details",
                  style: TextStyle(
                      color: Color(0xFF002060), fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
