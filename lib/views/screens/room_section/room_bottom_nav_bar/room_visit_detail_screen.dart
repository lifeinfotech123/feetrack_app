import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vlr/controllers/visit_controller.dart';
import 'package:vlr/data/models/visit_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/lanch_helper.dart';

class RoomVisitDetailScreen extends StatefulWidget {
  final String visitId;
  final VisitModel? initialVisit;

  const RoomVisitDetailScreen({
    super.key,
    required this.visitId,
    this.initialVisit,
  });

  @override
  State<RoomVisitDetailScreen> createState() => _RoomVisitDetailScreenState();
}

class _RoomVisitDetailScreenState extends State<RoomVisitDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<VisitController>().fetchPgVisitDetail(id: widget.visitId);
    });
  }

  Color _getStatusColor(String? status) {
    final s = (status ?? "").toLowerCase();
    if (s == 'approved' || s == 'confirmed') {
      return const Color(0xFF16A34A);
    }
    if (s == 'pending') {
      return const Color(0xFFD97706);
    }
    if (s == 'cancelled' || s == 'rejected') {
      return const Color(0xFFDC2626);
    }
    if (s == 'completed' || s == 'visited') {
      return const Color(0xFF2563EB);
    }
    return const Color(0xFF64748B);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return "";
    try {
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return "${date.day} ${months[date.month - 1]} ${date.year}";
      }
    } catch (_) {}
    return dateStr;
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return "";
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

  void _shareVisit(VisitModel visit) {
    final title = visit.listing?.title ?? "";
    final address = [
      visit.listing?.address,
      visit.listing?.city,
    ].where((e) => e != null && e.toString().trim().isNotEmpty).join(", ");
    final date = _formatDate(visit.visitDate);
    final time = _formatTime(visit.visitTime);
    final status = (visit.status ?? "").toUpperCase();

    final buffer = StringBuffer("Property Visit Details:\n\n");
    if (title.isNotEmpty) buffer.writeln("Property: $title");
    if (address.isNotEmpty) buffer.writeln("Location: $address");
    if (date.isNotEmpty) buffer.writeln("Date: $date");
    if (time.isNotEmpty) buffer.writeln("Time: $time");
    if (status.isNotEmpty) buffer.writeln("Status: $status");
    buffer.writeln("Visit ID: ${widget.visitId}\n");
    buffer.writeln("Shared via ${AppConstants.appName}");

    SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  void _confirmCancel(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Cancel Scheduled Visit?",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: const Text(
          "Are you sure you want to cancel this visit? This action cannot be undone.",
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              "Keep Visit",
              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final visitController = Get.find<VisitController>();
              final res = await visitController.cancelPgVisit(id: id);
              if (res.isSuccess) {
                showToast(
                  message: res.message.isNotEmpty
                      ? res.message
                      : "Visit request has been cancelled.",
                  toastType: ToastType.success,
                );
                await visitController.fetchPgVisitDetail(id: id);
                await visitController.fetchPgVisits();
              } else {
                showToast(message: res.message, typeCheck: false);
              }
            },
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Visit Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          GetBuilder<VisitController>(
            builder: (visitController) {
              final visit = visitController.selectedPgVisit ?? widget.initialVisit;
              if (visit == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.share_outlined,
                    size: 20, color: Color(0xFF002060)),
                onPressed: () => _shareVisit(visit),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GetBuilder<VisitController>(
        builder: (visitController) {
          final visit = visitController.selectedPgVisit ?? widget.initialVisit;

          if (visitController.isPgVisitDetailLoading && visit == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (visit == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 48, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 12),
                    const Text(
                      "Visit details not found",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Could not retrieve visit information. Please check your connection and try again.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF002060),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        visitController.fetchPgVisitDetail(id: widget.visitId);
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          }

          final status = (visit.status ?? "").toUpperCase();
          final statusColor = _getStatusColor(visit.status);
          final statusLower = (visit.status ?? "").toLowerCase();
          final canCancel = (visit.id ?? widget.visitId).isNotEmpty &&
              statusLower != 'cancelled' &&
              statusLower != 'rejected' &&
              statusLower != 'completed' &&
              statusLower != 'visited';
          final propertyTitle = visit.listing?.title ?? "";
          final fullAddress = [
            visit.listing?.address,
            visit.listing?.city,
          ].where((e) => e != null && e.toString().trim().isNotEmpty).join(", ");

          final visitDate = _formatDate(visit.visitDate);
          final visitTime = _formatTime(visit.visitTime);

          final partnerObj = visit.partner;
          final listingPartner = visit.listing?.partner;
          final pgContact = visit.pgContact;
          String pgName = partnerObj?.name ?? "";
          String pgMobile = visit.pgMobile ??
              visit.pgPhone ??
              pgContact?['mobile']?.toString() ??
              pgContact?['phone']?.toString() ??
              partnerObj?.mobile ??
              "";
          String pgEmail = visit.pgEmail ??
              pgContact?['email']?.toString() ??
              partnerObj?.email ??
              "";
          if (pgName.isEmpty && listingPartner is Map<String, dynamic>) {
            pgName = listingPartner['name']?.toString() ??
                listingPartner['full_name']?.toString() ??
                listingPartner['business_name']?.toString() ??
                listingPartner['owner_name']?.toString() ??
                "";
          }
          if (pgMobile.isEmpty && listingPartner is Map<String, dynamic>) {
            pgMobile = listingPartner['mobile']?.toString() ??
                listingPartner['phone']?.toString() ??
                listingPartner['contact_number']?.toString() ??
                "";
          }
          if (pgEmail.isEmpty && listingPartner is Map<String, dynamic>) {
            pgEmail = listingPartner['email']?.toString() ?? "";
          }
          if (pgName.isEmpty) pgName = visit.listing?.title ?? "";
          final visitorName = pgName;
          final visitorMobile = pgMobile;
          final visitorEmail = pgEmail;

          final addressParts = <String>[
            visit.listing?.address ?? "",
            visit.listing?.city ?? "",
            visit.listing?.state ?? "",
            visit.listing?.pincode ?? "",
          ].where((e) => e.trim().isNotEmpty).toList();
          final pgAddress = visit.listing?.fullAddress?.trim().isNotEmpty == true
              ? visit.listing!.fullAddress!.trim()
              : addressParts.join(", ");
          final pgLat = visit.listing?.lat;
          final pgLng = visit.listing?.lng;
          final hasVisitor = visitorName.isNotEmpty ||
              visitorMobile.isNotEmpty ||
              visitorEmail.isNotEmpty;

          final website = visit.website;
          final hasWebsite = website != null &&
              ((website.name?.isNotEmpty ?? false) ||
                  (website.domain?.isNotEmpty ?? false) ||
                  (website.portalUrl?.isNotEmpty ?? false));

          return RefreshIndicator(
            onRefresh: () async {
              await visitController.fetchPgVisitDetail(id: widget.visitId);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Hero Property Card
                  _buildPropertyHeroCard(
                    title: propertyTitle,
                    address: fullAddress,
                    status: status,
                    statusColor: statusColor,
                    listingPhone: visit.listing?.phone?.toString(),
                  ),

                  // Schedule Timing Card (only if date or time exists)
                  if (visitDate.isNotEmpty || visitTime.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildScheduleCard(
                      date: visitDate,
                      time: visitTime,
                    ),
                  ],

                  // Visitor Details Card (only if visitor data exists)
                  if (hasVisitor) ...[
                    const SizedBox(height: 16),
                    _buildVisitorCard(
                      name: visitorName,
                      mobile: visitorMobile,
                      email: visitorEmail,
                      address: pgAddress,
                      lat: pgLat,
                      lng: pgLng,
                    ),
                  ],

                  
                  // Notes Card (only if dynamic note exists)
                  if (visit.note != null && visit.note.toString().trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildNoteCard(visit.note.toString().trim()),
                  ],

                  const SizedBox(height: 16),

            
                  // Cancel Action Button
                  if (canCancel) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text(
                          "Cancel Scheduled Visit",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () =>
                            _confirmCancel(context, visit.id ?? widget.visitId),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyHeroCard({
    required String title,
    required String address,
    required String status,
    required Color statusColor,
    String? listingPhone,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF002060).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Color(0xFF002060),
                  size: 28,
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
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          height: 1.25,
                        ),
                      ),
                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 15, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
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
          if (status.isNotEmpty || (listingPhone != null && listingPhone.isNotEmpty)) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (status.isNotEmpty)
                  Row(
                    children: [
                      const Text(
                        "Status: ",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox.shrink(),
                if (listingPhone != null && listingPhone.isNotEmpty)
                  InkWell(
                    onTap: () {
                      LaunchHelper.callUs(number: listingPhone);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002060),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.call_rounded, size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            "Call Host",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleCard({
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
                "Visit Schedule",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                            fontSize: 14,
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
                          "Visit Time",
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
                            fontSize: 14,
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
    String address = "",
    String? lat,
    String? lng,
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
                "PG / Owner Information",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          if (name.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.badge_outlined,
              label: "Visitor Name",
              value: name,
            ),
          ],
          if (mobile.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.phone_android_rounded,
              label: "Mobile Number",
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
              label: "Email Address",
              value: email,
              actionWidget: IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.mail_outline_rounded,
                    size: 18, color: Color(0xFF002060)),
                onPressed: () => LaunchHelper.emailUs(email: email),
              ),
            ),
          ],
          if (address.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              label: "PG Address",
              value: address,
              actionWidget: IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.directions_rounded,
                    size: 18, color: Color(0xFF002060)),
                onPressed: () async {
                  final hasLatLng = lat != null &&
                      lng != null &&
                      lat!.toString().trim().isNotEmpty &&
                      lng!.toString().trim().isNotEmpty;
                  if (hasLatLng) {
                    await LaunchHelper.openGoogleMap(
                      lat: lat!.toString(),
                      lng: lng!.toString(),
                    );
                  } else {
                    final query = Uri.encodeComponent(address);
                    await LaunchHelper.launchInBrowser(
                      Uri.parse(
                          "https://www.google.com/maps/search/?api=1&query=$query"),
                    );
                  }
                },
              ),
            ),
          ],
          if (widget.visitId.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.confirmation_number_outlined, size: 16, color: Color(0xFF94A3B8)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Visit ID",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        widget.visitId,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildNoteCard(String note) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notes_rounded, size: 20, color: Color(0xFFD97706)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Special Instructions / Note",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF78350F),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
