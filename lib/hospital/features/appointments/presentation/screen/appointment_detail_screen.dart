import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';
import '../../../doctor/logics/doctor_controller.dart';
import '../../data/model/appointment_model.dart';
import '../../logics/appointment_controller.dart';
import '../../../doctor/data/model/doctor_model.dart';

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

    final initialAppointment = widget.initialAppointment;
    var hospitalDomain = _resolveHospitalDomain(initialAppointment);
    if (hospitalDomain == null) {
      for (final item in _controller.appointments) {
        if (item.id == widget.appointmentId) {
          hospitalDomain = _resolveHospitalDomain(item);
          if (hospitalDomain != null) break;
        }
      }
    }

    final data = hospitalDomain == null
        ? null
        : await _controller.fetchAppointmentDetail(
            widget.appointmentId,
            hospitalDomain: hospitalDomain,
          );
    var appointment = data ?? initialAppointment;
    if (data != null && initialAppointment != null) {
      final merged = initialAppointment.toJson();
      for (final entry in data.toJson().entries) {
        if (entry.value != null) merged[entry.key] = entry.value;
      }
      merged['doctor'] = {
        ...?initialAppointment.doctor,
        ...?data.doctor,
      };
      merged['image_url'] = data.imageUrl ?? initialAppointment.imageUrl;
      appointment = AppointmentModel.fromJson(merged);
    }

    final doctorId = appointment?.doctorId;
    hospitalDomain ??= _resolveHospitalDomain(appointment);

    if (appointment != null &&
        doctorId != null &&
        hospitalDomain != null &&
        hospitalDomain.isNotEmpty) {
      final doctorController = Get.isRegistered<DoctorController>()
          ? Get.find<DoctorController>()
          : Get.put(DoctorController());
      final hasExactDoctor = doctorController.findDoctorForHospital(
            id: doctorId,
            hospitalDomain: hospitalDomain,
          ) !=
          null;
      if (!hasExactDoctor) {
        await doctorController.fetchDoctors();
      }
      final doctor = await doctorController.fetchDoctorDetails(
        doctorId,
        hospitalDomain: hospitalDomain,
      );

      if (doctor != null) {
        appointment = AppointmentModel.fromJson({
          ...appointment.toJson(),
          'doctor': {
            ...?appointment.doctor,
            ...doctor.rawJson,
          },
          'doctor_id': doctor.id ?? appointment.doctorId,
          'doctor_name': doctor.name,
          'image_url': doctor.photo ?? appointment.imageUrl,
          'hospital_domain': hospitalDomain,
        });
      }
    }

    if (mounted) {
      setState(() {
        _currentAppointment = appointment;
        _isLoading = false;
      });
    }
  }

  String? _resolveHospitalDomain(AppointmentModel? appointment) {
    if (appointment == null) return null;
    final doctorHospital = appointment.doctor?['hospital'];
    final domain = appointment.hospitalDomain ??
        appointment.hospital?['domain']?.toString() ??
        appointment.hospital?['hospital_domain']?.toString() ??
        appointment.hospital?['domain_name']?.toString() ??
        (doctorHospital is Map
            ? (doctorHospital['domain'] ??
                    doctorHospital['hospital_domain'] ??
                    doctorHospital['domain_name'])
                ?.toString()
            : null);
    final trimmed = domain?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  List<MapEntry<String, String>> _doctorDetails(Map<String, dynamic>? doctor) {
    if (doctor == null) return const [];
    final details = <MapEntry<String, String>>[];
    const hiddenKeys = {
      'id',
      'doctor_id',
      'name',
      'photo',
      'photo_url',
      'image',
      'image_url',
      'doctor_image',
      'profile_photo',
      'avatar',
      'profile_image',
      'profile_image_url',
      'profile_url',
      'doctor_profile_url',
      'doctor_photo',
      'qualification',
      'rating',
      'reviews_count',
    };
    const coordinateFields = {'lat', 'latitude', 'lng', 'longitude'};

    void collect(Map<String, dynamic> values, {String prefix = ''}) {
      for (final entry in values.entries) {
        final key = entry.key;
        final value = entry.value;
        final normalizedKey = key.toLowerCase();
        final hospitalContext = prefix.toLowerCase().contains('hospital') ||
            normalizedKey.contains('hospital');
        if (normalizedKey.contains('password') ||
            normalizedKey.contains('token') ||
            normalizedKey.contains('secret') ||
            hiddenKeys.contains(normalizedKey) ||
            coordinateFields.contains(normalizedKey) ||
            (hospitalContext &&
                (normalizedKey.contains('domain') ||
                    normalizedKey.contains('portal') ||
                    normalizedKey.contains('logo') ||
                    normalizedKey.contains('url') ||
                    normalizedKey.contains('website') ||
                    normalizedKey.contains('address') ||
                    normalizedKey == 'location'))) {
          continue;
        }
        final label = _formatDoctorFieldName(key);
        final path = prefix.isEmpty ? label : '$prefix • $label';
        if (value is Map) {
          collect(Map<String, dynamic>.from(value), prefix: path);
        } else if (value is List) {
          final items = <String>[];
          for (var index = 0; index < value.length; index++) {
            final item = value[index];
            if (item is Map) {
              collect(
                Map<String, dynamic>.from(item),
                prefix: '$path ${index + 1}',
              );
            } else if (item != null && item.toString().trim().isNotEmpty) {
              items.add(item.toString().trim());
            }
          }
          if (items.isNotEmpty) {
            details.add(MapEntry(path, items.join(', ')));
          }
        } else if (value != null && value.toString().trim().isNotEmpty) {
          details.add(MapEntry(path, value.toString().trim()));
        }
      }
    }

    collect(doctor);
    return details;
  }

  String _formatDoctorFieldName(String field) {
    return field
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
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

  Future<void> _openHospitalDirections(Map<String, dynamic>? hospital) async {
    if (hospital == null) return;
    final location = hospital['location'];
    final lat = hospital['latitude'] ??
        hospital['lat'] ??
        (location is Map ? location['lat'] ?? location['latitude'] : null);
    final lng = hospital['longitude'] ??
        hospital['lng'] ??
        (location is Map ? location['lng'] ?? location['longitude'] : null);
    final address = (hospital['full_address'] ?? hospital['address'] ?? '')
        .toString()
        .trim();
    final name = hospital['name']?.toString().trim() ?? '';
    final destination = lat != null && lng != null
        ? '${lat.toString().trim()},${lng.toString().trim()}'
        : (address.isNotEmpty ? address : name);
    if (destination.isEmpty) return;
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': destination,
    });
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open hospital directions.')),
      );
    }
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
    final qualification =
        app?.doctor?['qualification']?.toString() ?? app?.designation;
    final doctorPhone = app?.doctor?['phone']?.toString();
    final doctorEmail = app?.doctor?['email']?.toString();
    final doctorPhoto = app?.imageUrl?.trim().isNotEmpty == true
        ? DoctorModel.resolveDoctorPhoto(
            photo: app!.imageUrl,
            domain: app.doctor?['hospital'] is Map
                ? app.doctor!['hospital']['domain']?.toString()
                : app.hospital?['domain']?.toString(),
          )
        : null;
    final dynamic rating = app?.doctor?['rating'];
    final dynamic reviewsCount = app?.doctor?['reviews_count'];
    final doctorDetails = _doctorDetails(app?.doctor);

    final formattedDate = app?.formattedDate;
    final date = (formattedDate != null && formattedDate.isNotEmpty)
        ? formattedDate
        : (app?.date ?? 'N/A');
    final slot = app?.slot ?? app?.time ?? 'N/A';
    final shift = app?.shift;

    final fees = app?.fees == null ? null : '₹${app!.fees}';
    final paymentMode = app?.paymentMode;
    final paymentStatus = app?.paymentStatus;
    final isPaid = paymentStatus?.toLowerCase() == 'paid';

    final hospital = app?.hospital;
    final hospitalName = hospital?['name']?.toString();
    final address =
        (hospital?['full_address'] ?? hospital?['address'])?.toString();
    final priority = app?.appointmentPriority;
    final message = app?.message;
    final createdAt = app?.createdAt;

    final liveConsultation = app?.liveConsultation?.toLowerCase() == 'yes' ||
        (app?.zoomJoinUrl?.isNotEmpty ?? false);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: colorWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: colorWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: textDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appointment Details',
              style: TextStyle(
                color: textDark,
                fontSize: 16,
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
                      fontSize: 11,
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Appointment overview
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF123B68), Color(0xFF176BB3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryDark.withValues(alpha: 0.18),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildStatusBadge(status),
                                    if (priority?.trim().isNotEmpty ?? false)
                                      _buildHeroTag('$priority priority',
                                          Icons.flag_outlined),
                                  ],
                                ),
                              ),
                              if (fees != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  fees,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Appointment schedule',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildHeroInfo(
                                  icon: Icons.calendar_month_rounded,
                                  label: 'DATE',
                                  value: date,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildHeroInfo(
                                  icon: Icons.schedule_rounded,
                                  label: 'TIME',
                                  value: shift == null || shift.trim().isEmpty
                                      ? slot
                                      : '$slot · $shift',
                                ),
                              ),
                            ],
                          ),
                          if (paymentMode != null || paymentStatus != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.only(top: 13),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.white24),
                                ),
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (paymentMode != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.account_balance_wallet_outlined,
                                          size: 15,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          paymentMode,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (paymentStatus != null)
                                    _buildPaymentBadge(
                                      paymentStatus,
                                      isPaid,
                                    ),
                                ],
                              ),
                            ),
                          ],
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
                              ClipOval(
                                child: doctorPhoto == null
                                    ? Container(
                                        width: 64,
                                        height: 64,
                                        color: fillColor,
                                        child: const Icon(Icons.person,
                                            color: primaryColor, size: 36),
                                      )
                                    : Image.network(
                                        doctorPhoto,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 64,
                                          height: 64,
                                          color: fillColor,
                                          child: const Icon(Icons.person,
                                              color: primaryColor, size: 36),
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctorName.toLowerCase().startsWith('dr.')
                                          ? doctorName
                                          : 'Dr. $doctorName',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    if (qualification != null &&
                                        qualification.trim().isNotEmpty)
                                      Text(
                                        qualification,
                                        style: const TextStyle(
                                          color: primaryColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    if (rating != null ||
                                        reviewsCount != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          if (rating != null) ...[
                                            const Icon(Icons.star_rounded,
                                                size: 15, color: Colors.amber),
                                            const SizedBox(width: 3),
                                            Text(
                                              rating.toString(),
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: textMuted),
                                            ),
                                          ],
                                          if (reviewsCount != null) ...[
                                            if (rating != null)
                                              const SizedBox(width: 4),
                                            Text(
                                              '$reviewsCount reviews',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: textMuted),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (doctorDetails.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            const Divider(height: 1, color: borderGrey),
                            const SizedBox(height: 4),
                            ...doctorDetails.map((detail) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 7),
                                  child: _buildDetailRow(
                                    icon: Icons.info_outline_rounded,
                                    label: detail.key,
                                    value: detail.value,
                                  ),
                                )),
                          ],
                          if ((doctorPhone?.trim().isNotEmpty ?? false) ||
                              (doctorEmail?.trim().isNotEmpty ?? false)) ...[
                            const SizedBox(height: 14),
                            const Divider(height: 1, color: borderGrey),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (doctorPhone?.trim().isNotEmpty ?? false)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () => _copyToClipboard(
                                          doctorPhone!, 'Phone number'),
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
                                if ((doctorPhone?.trim().isNotEmpty ?? false) &&
                                    (doctorEmail?.trim().isNotEmpty ?? false))
                                  const SizedBox(width: 10),
                                if (doctorEmail?.trim().isNotEmpty ?? false)
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side:
                                            const BorderSide(color: borderGrey),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () => _copyToClipboard(
                                          doctorEmail!, 'Doctor email'),
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
                              color: const Color(0xFF2563EB)
                                  .withValues(alpha: 0.3),
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
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorWhite,
                                  foregroundColor: const Color(0xFF1E3A8A),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () async {
                                  final zoomUrl = app?.zoomJoinUrl;
                                  if (zoomUrl != null && zoomUrl.isNotEmpty) {
                                    final uri = Uri.tryParse(zoomUrl);
                                    if (uri == null ||
                                        (uri.scheme != 'https' &&
                                            uri.scheme != 'http')) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'The Zoom meeting link is invalid.'),
                                        ),
                                      );
                                      return;
                                    }
                                    final launched = await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                    if (!context.mounted) return;
                                    if (!launched) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Unable to open the Zoom meeting link.'),
                                        ),
                                      );
                                    }
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
                    if (hospital != null ||
                        (createdAt?.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'Clinic & Hospital Location',
                        icon: Icons.local_hospital_rounded,
                        child: Column(
                          children: [
                            if (hospitalName?.trim().isNotEmpty == true)
                              _buildDetailRow(
                                icon: Icons.apartment_rounded,
                                label: 'Hospital Name',
                                value: hospitalName!,
                                valueStyle: const TextStyle(
                                  color: textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (hospitalName?.trim().isNotEmpty == true &&
                                address?.trim().isNotEmpty == true)
                              const Divider(height: 20, color: borderGrey),
                            if (address?.trim().isNotEmpty == true)
                              _buildDetailRow(
                                icon: Icons.location_on_outlined,
                                label: 'Campus Address',
                                value: address!,
                              ),
                            if (hospital != null) ...[
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () =>
                                      _openHospitalDirections(hospital),
                                  icon: const Icon(Icons.directions_rounded,
                                      size: 16),
                                  label: const Text('Get Directions'),
                                ),
                              ),
                            ],
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
                    ],

                    // 5. Reason / Note Card
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

                    // 6. Payment Summary
                    if (fees != null ||
                        paymentMode != null ||
                        paymentStatus != null)
                      _buildSectionCard(
                        title: 'Payment Summary',
                        icon: Icons.receipt_long_rounded,
                        child: Column(
                          children: [
                            if (fees != null)
                              _buildDetailRow(
                                icon: Icons.currency_rupee_rounded,
                                label: 'Consultation Fee',
                                value: fees,
                              ),
                            if (paymentMode != null) ...[
                              if (fees != null)
                                const Divider(height: 18, color: borderGrey),
                              _buildDetailRow(
                                icon: Icons.payment_rounded,
                                label: 'Payment Mode',
                                value: paymentMode,
                              ),
                            ],
                            if (paymentStatus != null) ...[
                              if (fees != null || paymentMode != null)
                                const Divider(height: 18, color: borderGrey),
                              _buildDetailRow(
                                icon: Icons.verified_user_outlined,
                                label: 'Payment Status',
                                value: paymentStatus,
                              ),
                            ],
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EDF4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF19324D).withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: primaryDark),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                    letterSpacing: -0.15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildHeroInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: colorWhite,
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _getStatusBgColor(status),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.toLowerCase().contains('cancel')
                ? Icons.cancel_rounded
                : Icons.check_circle_rounded,
            size: 14,
            color: _getStatusTextColor(status),
          ),
          const SizedBox(width: 5),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: _getStatusTextColor(status),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white70),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(String status, bool isPaid) {
    final color = isPaid ? const Color(0xFFB8F3CF) : const Color(0xFFFFE4A8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.verified_rounded : Icons.pending_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.35,
            ),
          ),
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
      children: [
        Icon(icon, size: 16, color: textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: textMuted, fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
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
