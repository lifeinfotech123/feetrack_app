import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../appointments/data/repositories/appointment_repo.dart';
import '../../data/live_consultation_model.dart';

class OnlineConsultationScreen extends StatefulWidget {
  const OnlineConsultationScreen({super.key});

  @override
  State<OnlineConsultationScreen> createState() =>
      _OnlineConsultationScreenState();
}

class _OnlineConsultationScreenState extends State<OnlineConsultationScreen> {
  final AppointmentRepo _repository = Get.isRegistered<AppointmentRepo>()
      ? Get.find<AppointmentRepo>()
      : Get.put(AppointmentRepo());

  late Future<List<LiveConsultation>> _consultationsFuture;

  @override
  void initState() {
    super.initState();
    _consultationsFuture = _loadConsultations();
  }

  Future<List<LiveConsultation>> _loadConsultations() async {
    final response = await _repository.getMyLiveConsultations();
    if (response['status'] != true) {
      throw Exception(
        response['message']?.toString() ?? 'Unable to load consultations.',
      );
    }

    final rawData = response['data'];
    final rawConsultations =
        rawData is Map ? rawData['consultations'] : null;
    if (rawConsultations is! List) {
      throw const FormatException(
        'The server returned an invalid consultation list.',
      );
    }
    return rawConsultations
        .map((item) =>
            LiveConsultation.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  void _reload() {
    setState(() => _consultationsFuture = _loadConsultations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Live Consultations'),
        backgroundColor: colorWhite,
        foregroundColor: textDark,
        elevation: 0,
      ),
      body: FutureBuilder<List<LiveConsultation>>(
        future: _consultationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _LoadError(
              message: snapshot.error.toString(),
              onRetry: _reload,
            );
          }

          final consultations = snapshot.data ?? [];
          if (consultations.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => _reload(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Icon(Icons.video_call_outlined,
                      size: 56, color: Colors.black38),
                  SizedBox(height: 12),
                  Center(child: Text('No live consultations found.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: consultations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final consultation = consultations[index];
                return _ConsultationCard(
                  consultation: consultation,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LiveConsultationDetailScreen(
                        consultation: consultation,
                        repository: _repository,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class LiveConsultationDetailScreen extends StatefulWidget {
  final LiveConsultation consultation;
  final AppointmentRepo repository;

  const LiveConsultationDetailScreen({
    super.key,
    required this.consultation,
    required this.repository,
  });

  @override
  State<LiveConsultationDetailScreen> createState() =>
      _LiveConsultationDetailScreenState();
}

class _LiveConsultationDetailScreenState
    extends State<LiveConsultationDetailScreen> {
  late Future<LiveConsultation> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetail();
  }

  Future<LiveConsultation> _loadDetail() async {
    final response = await widget.repository
        .getMyLiveConsultationDetail(widget.consultation.id);
    if (response['status'] != true || response['data'] is! Map) {
      throw Exception(
        response['message']?.toString() ??
            'Unable to load consultation details.',
      );
    }
    return LiveConsultation.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<void> _joinMeeting(LiveConsultation consultation) async {
    final link = consultation.joinUrl;
    final uri = link == null ? null : Uri.tryParse(link);
    if (!consultation.canJoin ||
        uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This Zoom meeting is not available yet.')),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the Zoom meeting link.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to open Zoom: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Consultation Details'),
        backgroundColor: colorWhite,
        foregroundColor: textDark,
        elevation: 0,
      ),
      body: FutureBuilder<LiveConsultation>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _LoadError(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _detailFuture = _loadDetail()),
            );
          }

          final consultation = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ConsultationCard(
                consultation: consultation,
                onTap: () {},
                showArrow: false,
              ),
              const SizedBox(height: 16),
              _DetailSection(
                title: 'Appointment',
                rows: {
                  'Booking number': consultation.appointmentNo,
                  'Date': consultation.formattedAppointmentDate,
                  'Time': consultation.slot,
                  'Consultation status': consultation.timeStatus,
                  'Payment status': consultation.paymentStatus,
                  if (consultation.message?.isNotEmpty == true)
                    'Message': consultation.message!,
                },
              ),
              const SizedBox(height: 12),
              _DetailSection(
                title: 'Zoom meeting',
                rows: {
                  'Meeting ID': consultation.meetingId ?? 'Not available',
                  'Meeting password':
                      consultation.meetingPassword ?? 'Not available',
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                
                child: ElevatedButton.icon(
                  onPressed: consultation.canJoin
                      ? () => _joinMeeting(consultation)
                      : null,
                  icon: const Icon(Icons.video_call),
                  label: const Text('Join Zoom Meeting'),
                ),
              ),
              if (!consultation.canJoin) ...[
                const SizedBox(height: 8),
                const Text(
                  'The meeting is not available to join right now.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  final LiveConsultation consultation;
  final VoidCallback onTap;
  final bool showArrow;

  const _ConsultationCard({
    required this.consultation,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final photo = consultation.doctorPhoto;
    return Card(
      color: colorWhite,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                child: photo.isEmpty
                    ? const Icon(Icons.person, color: primaryColor)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consultation.doctorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    if (consultation.doctorSpecialization.isNotEmpty)
                      Text(
                        consultation.doctorSpecialization,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      '${consultation.formattedAppointmentDate}  •  ${consultation.slot}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${consultation.appointmentNo}  •  ${consultation.timeStatus.isEmpty ? consultation.status : consultation.timeStatus}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (showArrow)
                const Icon(Icons.chevron_right, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Map<String, String> rows;

  const _DetailSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colorWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE8EAF0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textDark,
              ),
            ),
            const SizedBox(height: 10),
            for (final row in rows.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(row.key,
                          style: const TextStyle(color: Colors.black54)),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        row.value,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: textDark,
                          fontWeight: FontWeight.w600,
                        ),
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
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
