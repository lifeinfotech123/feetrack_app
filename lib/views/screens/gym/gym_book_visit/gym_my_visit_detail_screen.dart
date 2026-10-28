import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/lanch_helper.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class GymMyVisitDetailScreen extends StatefulWidget {
  final String visitId;
  final Map<String, dynamic>? initialData;

  const GymMyVisitDetailScreen({
    super.key,
    required this.visitId,
    this.initialData,
  });

  @override
  State<GymMyVisitDetailScreen> createState() => _GymMyVisitDetailScreenState();
}

class _GymMyVisitDetailScreenState extends State<GymMyVisitDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.visitId.isNotEmpty) {
        Get.find<GymController>()
            .fetchMyGymVisitDetails(visitId: widget.visitId);
      }
    });
  }

  void _openMap({required String gymTitle, required String address, required String city}) {
    final List<String> parts = [gymTitle, address, city]
        .where((p) => p.trim().isNotEmpty)
        .toList();
    final fullAddress = parts.isNotEmpty ? parts.join(", ") : "Gym";
    LaunchHelper.openMapAddress(address: fullAddress);
  }

  void _callPhone(String phone) {
    if (phone.trim().isEmpty) {
      showToast(message: "Phone number not available");
      return;
    }
    LaunchHelper.callUs(number: phone);
  }

  void _sendEmail(String email, String gymTitle) {
    if (email.trim().isEmpty) {
      showToast(message: "Email address not available");
      return;
    }
    LaunchHelper.emailUs(
      email: email,
      subject: "Gym Visit Enquiry - $gymTitle",
    );
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains("confirm") || s.contains("approved") || s.contains("active")) {
      return const Color(0xFF10B981);
    }
    if (s.contains("pending")) {
      return const Color(0xFFF59E0B);
    }
    if (s.contains("cancel") || s.contains("reject")) {
      return const Color(0xFFEF4444);
    }
    if (s.contains("complete")) {
      return const Color(0xFF3B82F6);
    }
    return primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GymController>(builder: (gymController) {
      final data = gymController.selectedVisitDetails ?? widget.initialData;
      final bool isLoading =
          gymController.isVisitDetailsLoading && data == null;

      final gym = data?['gym'] is Map ? data!['gym'] as Map : null;
      final customer =
          data?['customer'] is Map ? data!['customer'] as Map : null;
      final website = data?['website'] is Map ? data!['website'] as Map : null;

      final gymTitle = gym?['title']?.toString() ??
          data?['gym_name']?.toString() ??
          "Gym Sanctuary";
      final gymAddress = gym?['address']?.toString() ??
          data?['gym_address']?.toString() ??
          "";
      final gymCity = gym?['city']?.toString() ?? "";
      final gymPhone = gym?['phone']?.toString() ?? "";

      final fullGymLocation = [gymAddress, gymCity]
          .where((p) => p.trim().isNotEmpty)
          .join(", ");

      final customerName = customer?['name']?.toString() ?? "";
      final customerPhone = customer?['phone']?.toString() ?? "";
      final customerEmail = customer?['email']?.toString() ?? "";

      final visitDate = data?['formatted_date']?.toString() ??
          data?['visit_date']?.toString() ??
          "";
      final visitTime = data?['slot_label']?.toString() ??
          data?['visit_time']?.toString() ??
          "";
      final statusLabel = data?['status_label']?.toString() ??
          data?['status']
              ?.toString()
              .replaceAll("_", " ")
              .toUpperCase() ??
          "PENDING";
      final note = data?['note']?.toString() ?? "";
      final bookingId = data?['id']?.toString() ??
          data?['booking_number']?.toString() ??
          widget.visitId;
      final createdAt = data?['created_at']?.toString() ?? "";
      final bookingType =
          data?['booking_type']?.toString().toUpperCase() ?? "VISIT";

      final gymImages = gym?['images'] is List ? (gym?['images'] as List) : [];
      final gymImageUrl =
          gymImages.isNotEmpty ? gymImages.first.toString() : null;

      final statusColor = _getStatusColor(statusLabel);

      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          shadowColor: black.withValues(alpha: 0.05),
          centerTitle: false,
          title: Text(
            "Visit Details",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: blackText1,
                ),
          ),
          actions: [
            if (data != null)
              IconButton(
                tooltip: "Share Details",
                icon: const Icon(Icons.share_outlined, color: primaryColor),
                onPressed: () {
                  final text = "Gym Visit Details:\n\n"
                      "Gym: $gymTitle\n"
                      "Location: ${fullGymLocation.isNotEmpty ? fullGymLocation : 'N/A'}\n"
                      "Date: $visitDate\n"
                      "Time: $visitTime\n"
                      "Status: $statusLabel\n"
                      "Visit ID: $bookingId\n\n"
                      "Shared via ${AppConstants.appName}";
                  // ignore: deprecated_member_use
                  Share.share(text);
                },
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : data == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          gymController.visitDetailsError ??
                              "Visit detail not found",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => gymController.fetchMyGymVisitDetails(
                              visitId: widget.visitId),
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text("Retry"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002060),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => gymController
                        .fetchMyGymVisitDetails(visitId: widget.visitId),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── 1. Status & Booking ID Header Card ──────────
                          _buildStatusHeaderCard(
                            bookingId: bookingId,
                            statusLabel: statusLabel,
                            statusColor: statusColor,
                            bookingType: bookingType,
                            createdAt: createdAt,
                          ),

                          const SizedBox(height: 16),

                          // ── 2. Clickable Gym Location Card (Opens Map) ──
                          _buildGymLocationCard(
                            gymTitle: gymTitle,
                            fullLocation: fullGymLocation,
                            gymPhone: gymPhone,
                            imageUrl: gymImageUrl,
                            onMapTap: () => _openMap(
                              gymTitle: gymTitle,
                              address: gymAddress,
                              city: gymCity,
                            ),
                            onPhoneTap: gymPhone.isNotEmpty
                                ? () => _callPhone(gymPhone)
                                : null,
                          ),

                          const SizedBox(height: 16),

                          // ── 3. Schedule & Timing Card ───────────────────
                          _buildScheduleCard(
                            visitDate: visitDate,
                            visitTime: visitTime,
                            note: note,
                          ),

                          const SizedBox(height: 16),

                          // ── 4. Customer Contact Details (Clickable Call/Email) ──
                          _buildCustomerContactCard(
                            customerName: customerName,
                            customerPhone: customerPhone,
                            customerEmail: customerEmail,
                            gymTitle: gymTitle,
                          ),

                          if (website != null &&
                              website['portal_url'] != null) ...[
                            const SizedBox(height: 16),
                            _buildWebsiteCard(website),
                          ],

                          const SizedBox(height: 24),

                          // ── 5. Quick Actions Bar ────────────────────────
                          _buildQuickActionsBar(
                            gymTitle: gymTitle,
                            gymAddress: gymAddress,
                            gymCity: gymCity,
                            phoneToCall: customerPhone.isNotEmpty
                                ? customerPhone
                                : gymPhone,
                            emailToSend: customerEmail,
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
      );
    });
  }

  // ── Header Card ───────────────────────────────────────────────────────────
  Widget _buildStatusHeaderCard({
    required String bookingId,
    required String statusLabel,
    required Color statusColor,
    required String bookingType,
    required String createdAt,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bookingType == "VISIT" ? "FREE GYM VISIT" : bookingType,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: primaryColor,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Booking ID",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bookingId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: bookingId));
                  showToast(message: "Booking ID copied to clipboard!");
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.copy_rounded,
                          size: 13, color: Color(0xFF4B5563)),
                      SizedBox(width: 4),
                      Text(
                        "Copy",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (createdAt.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              "Booked on: $createdAt",
              style: TextStyle(
                fontSize: 11,
                color: greyText3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Gym Location Card (Tap -> Direct to Google Maps) ───────────────────────
  Widget _buildGymLocationCard({
    required String gymTitle,
    required String fullLocation,
    required String gymPhone,
    required String? imageUrl,
    required VoidCallback onMapTap,
    required VoidCallback? onPhoneTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onMapTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Gym Location",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002060).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.directions_rounded,
                              size: 13, color: Color(0xFF002060)),
                          SizedBox(width: 4),
                          Text(
                            "Open in Maps",
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF002060),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF002060).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? CustomImage(
                                path: imageUrl,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.fitness_center_rounded,
                                color: Color(0xFF002060),
                                size: 26,
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gymTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 15,
                                color: Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  fullLocation.isNotEmpty
                                      ? fullLocation
                                      : "Address available on map",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: greyText2,
                                    height: 1.3,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (gymPhone.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: onPhoneTap,
                              borderRadius: BorderRadius.circular(6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.phone_rounded,
                                    size: 13,
                                    color: Color(0xFF10B981),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    gymPhone,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Tap notice banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.touch_app_rounded,
                          size: 14, color: Color(0xFF4B5563)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Tap this card to get direct route navigation on Google Maps",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 11, color: Color(0xFF9CA3AF)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Schedule & Timing Card ────────────────────────────────────────────────
  Widget _buildScheduleCard({
    required String visitDate,
    required String visitTime,
    required String note,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
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
          const Text(
            "Visit Schedule & Timing",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calendar_month_rounded,
                            size: 18, color: primaryColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Date",
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              visitDate.isNotEmpty ? visitDate : "Pending",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.access_time_filled_rounded,
                            size: 18, color: Color(0xFF059669)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Time / Slot",
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              visitTime.isNotEmpty ? visitTime : "Anytime",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded,
                      size: 16, color: Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Customer Contact Card (Clickable Call & Email) ────────────────────────
  Widget _buildCustomerContactCard({
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required String gymTitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
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
          const Text(
            "Customer Details",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 14),
          if (customerName.isNotEmpty) ...[
            _buildContactRow(
              icon: Icons.person_rounded,
              iconColor: const Color(0xFF002060),
              label: "Name",
              value: customerName,
              onTap: null,
            ),
            const Divider(height: 18),
          ],
          _buildContactRow(
            icon: Icons.phone_rounded,
            iconColor: const Color(0xFF10B981),
            label: "Phone",
            value: customerPhone.isNotEmpty
                ? customerPhone
                : "No phone registered",
            actionLabel: customerPhone.isNotEmpty ? "Call" : null,
            onTap: customerPhone.isNotEmpty
                ? () => _callPhone(customerPhone)
                : null,
          ),
          const Divider(height: 18),
          _buildContactRow(
            icon: Icons.email_rounded,
            iconColor: const Color(0xFF3B82F6),
            label: "Email",
            value: customerEmail.isNotEmpty
                ? customerEmail
                : "No email registered",
            actionLabel: customerEmail.isNotEmpty ? "Email" : null,
            onTap: customerEmail.isNotEmpty
                ? () => _sendEmail(customerEmail, gymTitle)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? actionLabel,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null && onTap != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      actionLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 9, color: iconColor),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Website Card ──────────────────────────────────────────────────────────
  Widget _buildWebsiteCard(Map website) {
    final portalUrl = website['portal_url']?.toString() ?? "";
    final siteName = website['name']?.toString() ?? "Gym Portal";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF002060).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.language_rounded,
                color: Color(0xFF002060), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siteName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                if (portalUrl.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    portalUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: greyText3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (portalUrl.isNotEmpty)
            InkWell(
              onTap: () {
                final uri = Uri.tryParse(portalUrl);
                if (uri != null) LaunchHelper.launchInBrowser(uri);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF002060),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Visit",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Quick Action Bar ──────────────────────────────────────────────────────
  Widget _buildQuickActionsBar({
    required String gymTitle,
    required String gymAddress,
    required String gymCity,
    required String phoneToCall,
    required String emailToSend,
  }) {
    return Row(
      children: [
        // Direct Map Navigation
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _openMap(
                gymTitle: gymTitle,
                address: gymAddress,
                city: gymCity,
              ),
              icon: const Icon(Icons.map_rounded,
                  color: Colors.white, size: 18),
              label: const Text(
                "Directions",
                style: TextStyle(
                  fontSize: 13.5,
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
        ),
        if (phoneToCall.isNotEmpty) ...[
          const SizedBox(width: 10),
          SizedBox(
            height: 48,
            width: 52,
            child: OutlinedButton(
              onPressed: () => _callPhone(phoneToCall),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.call_rounded,
                  color: Color(0xFF10B981), size: 20),
            ),
          ),
        ],
        if (emailToSend.isNotEmpty) ...[
          const SizedBox(width: 10),
          SizedBox(
            height: 48,
            width: 52,
            child: OutlinedButton(
              onPressed: () => _sendEmail(emailToSend, gymTitle),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.mail_outline_rounded,
                  color: Color(0xFF3B82F6), size: 20),
            ),
          ),
        ],
      ],
    );
  }
}
