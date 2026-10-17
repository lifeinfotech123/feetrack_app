import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../data/model/appointment_model.dart';
import '../../logics/appointment_controller.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final int appointmentId;
  final AppointmentModel? initialAppointment;

  const AppointmentDetailScreen({
    super.key,
    required this.appointmentId,
    this.initialAppointment,
  });

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  final AppointmentController _controller =
      Get.isRegistered<AppointmentController>()
          ? Get.find<AppointmentController>()
          : Get.put(AppointmentController());

  AppointmentModel? _currentAppointment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentAppointment = widget.initialAppointment;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = _currentAppointment == null;
    });

    final data = await _controller.fetchAppointmentDetail(widget.appointmentId);
    if (mounted) {
      setState(() {
        if (data != null) {
          _currentAppointment = data;
        }
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Color _getStatusBgColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('cancel')) {
      return const Color(0xFFFEE2E2);
    } else if (lower.contains('approved') ||
        lower.contains('confirm') ||
        lower.contains('complete') ||
        lower.contains('finish')) {
      return const Color(0xFFDCFCE7);
    }
    return const Color(0xFFEEF2FF);
  }

  Color _getStatusTextColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('cancel')) {
      return const Color(0xFFDC2626);
    } else if (lower.contains('approved') ||
        lower.contains('confirm') ||
        lower.contains('complete') ||
        lower.contains('finish')) {
      return const Color(0xFF16A34A);
    }
    return const Color(0xFF4F46E5);
  }

  @override
  Widget build(BuildContext context) {
    final app = _currentAppointment;

    final appointmentNo = app?.appointmentNo ?? 'APT-${widget.appointmentId}';
    final status = app?.status ?? 'Booked';
    final doctorName = app?.doctorName ?? 'Doctor';
    final qualification = app?.doctor?['qualification']?.toString() ??
        app?.designation ??
        'MBBS Specialist';
    final doctorPhone = app?.doctor?['phone']?.toString() ?? '6655223311';
    final doctorEmail = app?.doctor?['email']?.toString() ?? 'doctor@hospital.com';

    final formattedDate = app?.formattedDate;
    final date = (formattedDate != null && formattedDate.isNotEmpty)
        ? formattedDate
        : (app?.date ?? 'N/A');
    final slot = app?.slot ?? app?.time ?? 'N/A';
    final shift = app?.shift ?? 'General';

    final fees = app?.fees != null ? '₹${app!.fees}' : '₹0';
    final paymentMode = app?.paymentMode ?? 'Online';
    final paymentStatus = app?.paymentStatus ?? 'Pending';
    final isPaid = paymentStatus.toLowerCase() == 'paid';

    final hospitalName = app?.hospital?['name']?.toString() ?? 'Hospital Care';
    final hospitalDomain = app?.hospital?['domain']?.toString();
    final address = app?.address ?? 'Main Medical Campus';
    final priority = app?.appointmentPriority ?? 'Normal';
    final message = app?.message;
    final createdAt = app?.createdAt;

    final liveConsultation =
        app?.liveConsultation?.toLowerCase() == 'yes' ||
            app?.zoomJoinUrl != null;

    final patientName = app?.patient?['name']?.toString() ?? 'Self';
    final patientPhone = app?.patient?['phone']?.toString();
    final patientEmail = app?.patient?['email']?.toString();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: colorWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appointment Details',
              style: TextStyle(
                color: textDark,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () => _copyToClipboard(appointmentNo, 'Booking ID'),
              child: Row(
                children: [
                  Text(
                    appointmentNo,
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.copy_rounded, size: 12, color: primaryColor),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: textDark, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment details shared!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: textDark, size: 22),
            onPressed: _fetchDetail,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading && app == null
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: primaryColor,
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchDetail,
              color: primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hero Booking Banner (Dark Modern Card)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusBgColor(status),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          status.toLowerCase().contains('cancel')
                                              ? Icons.cancel
                                              : Icons.check_circle_rounded,
                                          size: 13,
                                          color: _getStatusTextColor(status),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            color: _getStatusTextColor(status),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$priority Priority',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Amount Tag
                              Text(
                                fees,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded,
                                  color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  date,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded,
                                  color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$slot • $shift Shift',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const Divider(color: Colors.white12, height: 1),
                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.account_balance_wallet_outlined,
                                      size: 15, color: Colors.white60),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Payment: $paymentMode',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isPaid
                                      ? Colors.green.withValues(alpha: 0.25)
                                      : Colors.amber.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  paymentStatus.toUpperCase(),
                                  style: TextStyle(
                                    color: isPaid
                                        ? Colors.greenAccent
                                        : Colors.amberAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2. Doctor Information Card
                    _buildSectionCard(
                      title: 'Doctor Profile',
                      icon: Icons.medical_services_outlined,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  const CircleAvatar(
                                    radius: 32,
                                    backgroundColor: fillColor,
                                    child: Icon(Icons.person,
                                        color: primaryColor, size: 36),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: wellnessGreen,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check,
                                          size: 11, color: colorWhite),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dr. $doctorName',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      qualification,
                                      style: const TextStyle(
                                        color: primaryColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Row(
                                      children: [
                                        Icon(Icons.star_rounded,
                                            size: 15, color: Colors.amber),
                                        SizedBox(width: 3),
                                        Text(
                                          '4.9 (120+ reviews)',
                                          style: TextStyle(
                                              fontSize: 11, color: textMuted),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          const Divider(height: 1, color: borderGrey),
                          const SizedBox(height: 12),

                          // Quick Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () =>
                                      _copyToClipboard(doctorPhone, 'Phone number'),
                                  icon: const Icon(Icons.phone_rounded,
                                      size: 16, color: colorWhite),
                                  label: const Text(
                                    'Call Doctor',
                                    style: TextStyle(
                                        color: colorWhite,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: borderGrey),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () =>
                                      _copyToClipboard(doctorEmail, 'Doctor email'),
                                  icon: const Icon(Icons.email_outlined,
                                      size: 16, color: textDark),
                                  label: const Text(
                                    'Email',
                                    style: TextStyle(
                                        color: textDark,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 3. Live Online Video Consultation Card (Zoom)
                    if (liveConsultation) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.videocam_rounded,
                                    color: colorWhite, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Live Tele-Consultation',
                                  style: TextStyle(
                                    color: colorWhite,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Join your high-definition video call with the specialist at the scheduled slot time.',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorWhite,
                                  foregroundColor: const Color(0xFF1E3A8A),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  final zoomUrl = app?.zoomJoinUrl;
                                  if (zoomUrl != null && zoomUrl.isNotEmpty) {
                                    // Launch URL or notify
                                    _copyToClipboard(zoomUrl, 'Meeting Link');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Meeting link will unlock at scheduled time.'),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.video_call_rounded,
                                    color: Color(0xFF1E3A8A)),
                                label: const Text(
                                  'Join Video Call',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // 4. Appointment Schedule & Hospital Info Card
                    _buildSectionCard(
                      title: 'Clinic & Hospital Location',
                      icon: Icons.local_hospital_rounded,
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.apartment_rounded,
                            label: 'Hospital Name',
                            value: hospitalName,
                            valueStyle: const TextStyle(
                              color: textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (hospitalDomain != null &&
                              hospitalDomain.isNotEmpty) ...[
                            const Divider(height: 20, color: borderGrey),
                            _buildDetailRow(
                              icon: Icons.domain_rounded,
                              label: 'Hospital Domain',
                              value: hospitalDomain,
                            ),
                          ],
                          const Divider(height: 20, color: borderGrey),
                          _buildDetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'Campus Address',
                            value: address,
                          ),
                          if (createdAt != null && createdAt.isNotEmpty) ...[
                            const Divider(height: 20, color: borderGrey),
                            _buildDetailRow(
                              icon: Icons.history_toggle_off_rounded,
                              label: 'Booked On',
                              value: createdAt,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 5. Patient Information Card
                    _buildSectionCard(
                      title: 'Patient Profile',
                      icon: Icons.badge_outlined,
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Patient ID',
                            value: '#${app?.patientId ?? 'N/A'}',
                          ),
                          if (patientName.isNotEmpty && patientName != 'Self') ...[
                            const Divider(height: 20, color: borderGrey),
                            _buildDetailRow(
                              icon: Icons.account_circle_outlined,
                              label: 'Patient Name',
                              value: patientName,
                            ),
                          ],
                          if (patientPhone != null &&
                              patientPhone.isNotEmpty) ...[
                            const Divider(height: 20, color: borderGrey),
                            _buildDetailRow(
                              icon: Icons.phone_android_rounded,
                              label: 'Registered Mobile',
                              value: patientPhone,
                            ),
                          ],
                          if (patientEmail != null &&
                              patientEmail.isNotEmpty) ...[
                            const Divider(height: 20, color: borderGrey),
                            _buildDetailRow(
                              icon: Icons.email_outlined,
                              label: 'Email ID',
                              value: patientEmail,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // 6. Reason / Note Card
                    if (message != null && message.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'Appointment Reason & Notes',
                        icon: Icons.chat_bubble_outline_rounded,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: fillColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderGrey),
                          ),
                          child: Text(
                            '"$message"',
                            style: const TextStyle(
                              color: textDark,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // 7. Payment & Invoice Breakdown
                    _buildSectionCard(
                      title: 'Payment Summary',
                      icon: Icons.receipt_long_rounded,
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.currency_rupee_rounded,
                            label: 'Doctor Consultation Fee',
                            value: fees,
                          ),
                          const Divider(height: 18, color: borderGrey),
                          _buildDetailRow(
                            icon: Icons.verified_user_outlined,
                            label: 'Digital Service Fee',
                            value: 'Free (₹0)',
                          ),
                          const Divider(height: 18, color: borderGrey),
                          _buildDetailRow(
                            icon: Icons.account_balance_wallet_rounded,
                            label: 'Total Payable',
                            value: fees,
                            valueStyle: const TextStyle(
                              color: primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: primaryColor),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Downloading digital receipt...'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.download_rounded,
                                  size: 16, color: primaryColor),
                              label: const Text(
                                'Download E-Invoice Slip',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bottom Finish Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Back to Appointments',
                          style: TextStyle(
                            color: colorWhite,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: primaryColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: textMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: textMuted, fontSize: 13),
            ),
          ],
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: valueStyle ??
                const TextStyle(
                  color: textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
