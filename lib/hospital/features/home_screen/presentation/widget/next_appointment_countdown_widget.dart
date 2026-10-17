import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../appointments/data/model/appointment_model.dart';
import '../../../appointments/logics/appointment_controller.dart';
import '../../../appointments/presentation/screen/appointments_screen.dart';

class NextAppointmentCountdownWidget extends StatefulWidget {
  const NextAppointmentCountdownWidget({super.key});

  @override
  State<NextAppointmentCountdownWidget> createState() =>
      _NextAppointmentCountdownWidgetState();
}

class _NextAppointmentCountdownWidgetState
    extends State<NextAppointmentCountdownWidget> {
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    // Live update every second
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  void _navigateToAppointments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AppointmentsScreen(userId: ''),
      ),
    ).then((_) {
      if (Get.isRegistered<AppointmentController>()) {
        Get.find<AppointmentController>().fetchAppointments();
      }
    });
  }

  DateTime? _parseAppointmentDateTime(AppointmentModel appointment) {
    final dateStr = appointment.date;
    if (dateStr == null || dateStr.trim().isEmpty) return null;

    String cleanDate = dateStr.trim();
    String? embeddedTime;

    // Handle ISO formats e.g. "2026-10-17T10:00:00.000Z"
    if (cleanDate.contains('T')) {
      final parts = cleanDate.split('T');
      cleanDate = parts[0].trim();
      if (parts.length > 1) {
        embeddedTime = parts[1].replaceAll('Z', '').split('.').first.trim();
      }
    } else {
      // Check if there is an embedded time (e.g. "17-10-2026 10:00:00" or "2026-10-17 10:00 AM")
      final timeMatch = RegExp(
        r'\s+(\d{1,2}:\d{2}(?::\d{2})?(?:\s*(?:AM|PM|am|pm))?)',
        caseSensitive: false,
      ).firstMatch(cleanDate);
      if (timeMatch != null) {
        embeddedTime = timeMatch.group(1);
        cleanDate = cleanDate.substring(0, timeMatch.start).trim();
      }
    }

    // 1. Parse date component
    DateTime? parsedDate = DateTime.tryParse(cleanDate);

    if (parsedDate == null) {
      final parts = cleanDate.split(RegExp(r'[-/]'));
      if (parts.length >= 3) {
        int? y, m, d;
        if (parts[0].length == 4) {
          y = int.tryParse(parts[0]);
          m = int.tryParse(parts[1]);
          d = int.tryParse(parts[2]);
        } else if (parts[2].length >= 4) {
          d = int.tryParse(parts[0]);
          m = int.tryParse(parts[1]);
          y = int.tryParse(parts[2].substring(0, 4));
        }
        if (y != null && m != null && d != null) {
          try {
            parsedDate = DateTime(y, m, d);
          } catch (_) {}
        }
      }
    }

    if (parsedDate == null) {
      final formats = [
        'yyyy-MM-dd',
        'dd-MM-yyyy',
        'dd/MM/yyyy',
        'yyyy/MM/dd',
        'd MMM yyyy',
        'dd MMM yyyy',
        'd-MMM-yyyy',
        'dd-MMM-yyyy',
        'MMMM d, yyyy',
        'd MMMM yyyy',
      ];
      for (final fmt in formats) {
        try {
          parsedDate = DateFormat(fmt).parseLoose(cleanDate);
          break;
        } catch (_) {}
      }
    }

    if (parsedDate == null) return null;
    if (parsedDate.isUtc) parsedDate = parsedDate.toLocal();

    // 2. Parse time component (checks slotStartTime, slot, time, then embeddedTime)
    final rawTimeStr = appointment.slotStartTime ??
        appointment.slot ??
        appointment.time ??
        embeddedTime;

    int hour = 0;
    int minute = 0;
    int second = 0;
    bool hasExplicitTime = false;

    if (rawTimeStr != null && rawTimeStr.trim().isNotEmpty) {
      String t = rawTimeStr.split('-').first.trim();
      t = t.split('to').first.trim();

      final isPm = RegExp(r'pm', caseSensitive: false).hasMatch(t);
      final isAm = RegExp(r'am', caseSensitive: false).hasMatch(t);

      final match =
          RegExp(r'(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?').firstMatch(t);
      if (match != null) {
        hour = int.tryParse(match.group(1)!) ?? 0;
        minute = int.tryParse(match.group(2)!) ?? 0;
        if (match.group(3) != null) {
          second = int.tryParse(match.group(3)!) ?? 0;
        }
        hasExplicitTime = true;
      } else {
        final hourMatch = RegExp(r'(\d{1,2})').firstMatch(t);
        if (hourMatch != null) {
          hour = int.tryParse(hourMatch.group(1)!) ?? 0;
          hasExplicitTime = true;
        }
      }

      if (isPm && hour < 12) {
        hour += 12;
      } else if (isAm && hour == 12) {
        hour = 0;
      }
    }

    // If no explicit time was provided and parsedDate was at midnight, default to end of that day (23:59:59)
    if (!hasExplicitTime && parsedDate.hour == 0 && parsedDate.minute == 0) {
      hour = 23;
      minute = 59;
      second = 59;
    } else if (!hasExplicitTime) {
      hour = parsedDate.hour;
      minute = parsedDate.minute;
      second = parsedDate.second;
    }

    return DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      hour,
      minute,
      second,
    );
  }

  AppointmentModel? _getNearestAppointment(List<AppointmentModel> list) {
    if (list.isEmpty) return null;

    final now = DateTime.now();

    final valid = list.where((a) {
      final s = (a.status ?? '').toLowerCase();
      final p = (a.paymentStatus ?? '').toLowerCase();
      if (s.contains('cancel') ||
          s.contains('reject') ||
          s.contains('finish') ||
          s.contains('complete') ||
          p.contains('cancel') ||
          p.contains('fail')) {
        return false;
      }
      return true;
    }).toList();

    if (valid.isEmpty) return null;

    final upcomingList = <MapEntry<AppointmentModel, DateTime>>[];
    for (final a in valid) {
      final dt = _parseAppointmentDateTime(a);
      // Strict rule: As soon as current time exceeds or reaches the appointment time,
      // that appointment is removed and the next upcoming appointment takes over.
      if (dt != null && dt.isAfter(now)) {
        upcomingList.add(MapEntry(a, dt));
      }
    }

    if (upcomingList.isEmpty) return null;

    // Sort chronologically ascending (earliest upcoming appointment first)
    upcomingList.sort((a, b) => a.value.compareTo(b.value));
    return upcomingList.first.key;
  }

  @override
  Widget build(BuildContext context) {
    final appointmentController = Get.isRegistered<AppointmentController>()
        ? Get.find<AppointmentController>()
        : Get.put(AppointmentController());

    return Obx(() {
      final appointments = appointmentController.appointments;
      final nextAppointment = _getNearestAppointment(appointments);

      final targetDateTime = nextAppointment != null
          ? _parseAppointmentDateTime(nextAppointment)
          : null;

      final now = DateTime.now();

      final Duration remaining = targetDateTime != null
          ? targetDateTime.difference(now)
          : Duration.zero;

      final bool hasAppointment = nextAppointment != null &&
          targetDateTime != null &&
          targetDateTime.isAfter(now) &&
          remaining.inSeconds > 0;

      final days = remaining.inDays > 0 ? remaining.inDays : 0;
      final hours = (remaining.inHours % 24) > 0 ? (remaining.inHours % 24) : 0;
      final minutes =
          (remaining.inMinutes % 60) > 0 ? (remaining.inMinutes % 60) : 0;
      final seconds =
          (remaining.inSeconds % 60) > 0 ? (remaining.inSeconds % 60) : 0;

      const List<Color> gradientColors = [
        Color(0xFF002060),
        Color(0xFF0B3B8A),
      ];

      final Color borderColor =
          const Color(0xFF93C5FD).withValues(alpha: 0.35);

      final Color badgeBg = Colors.white.withValues(alpha: 0.16);
      const Color badgeText = Colors.white;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _navigateToAppointments(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF002060).withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header: Status + Tap action hint (Overflow Safe)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 11,
                                  color: badgeText,
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    !hasAppointment
                                        ? "NEXT APPOINTMENT"
                                        : "NEXT APPOINTMENT IN",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: badgeText,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "View",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 9,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                // Main Focus: The Live Countdown Timer (Switches automatically when time passes)
                if (!hasAppointment)
                  _buildNoAppointmentTimerRow()
                else
                  _buildTimerBoxesRow(
                    days: days,
                    hours: hours,
                    minutes: minutes,
                    seconds: seconds,
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Compact Digital Timer Boxes Row (Days, Hours, Minutes, Seconds)
  Widget _buildTimerBoxesRow({
    required int days,
    required int hours,
    required int minutes,
    required int seconds,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (days > 0) ...[
          _buildMiniTimerCapsule(
            value: days.toString().padLeft(2, '0'),
            unit: "d",
          ),
          _buildColon(),
        ],
        _buildMiniTimerCapsule(
          value: hours.toString().padLeft(2, '0'),
          unit: "h",
        ),
        _buildColon(),
        _buildMiniTimerCapsule(
          value: minutes.toString().padLeft(2, '0'),
          unit: "m",
        ),
        _buildColon(),
        _buildMiniTimerCapsule(
          value: seconds.toString().padLeft(2, '0'),
          unit: "s",
          isLiveSec: true,
        ),
      ],
    );
  }

  /// Compact Individual Capsule
  Widget _buildMiniTimerCapsule({
    required String value,
    required String unit,
    bool isLiveSec = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isLiveSec
            ? Colors.white.withValues(alpha: 0.24)
            : Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: isLiveSec
              ? Colors.white.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 1.5),
          Text(
            unit,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Text(
        ":",
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }


  /// Clean compact timer row when no appointment is scheduled yet
  Widget _buildNoAppointmentTimerRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_rounded,
            color: Colors.white,
            size: 14,
          ),
          SizedBox(width: 5),
          Flexible(
            child: Text(
              "No Active Appointment • Tap to Book",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
