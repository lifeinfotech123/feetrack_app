import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../appointments/logics/appointment_controller.dart';
import '../../../doctor/presentation/screens/doctor_search_screen.dart';
import '../../../emergency_assistance/presentation/screen/emergency_assistance_screen.dart';
import '../../../lab_reports/controller/lab_controller.dart';
import '../../../lab_reports/presentation/screen/lab_report_detail_screen.dart';
import '../../../lab_reports/presentation/screen/lab_reports_screen.dart';
import '../widget/banner_widget.dart';
import '../widget/doctor_list_section.dart';
import '../widget/home_action_widget.dart';
import '../widget/home_appbar_widget.dart';
import '../widget/home_specialites_widget.dart';
import '../widget/next_appointment_countdown_widget.dart';
import 'all_services_screen.dart';

class HospitalHomeScreen extends StatefulWidget {
  const HospitalHomeScreen({super.key});

  @override
  State<HospitalHomeScreen> createState() => _HospitalHomeScreenState();
}

class _HospitalHomeScreenState extends State<HospitalHomeScreen> {
  late final AppointmentController _appointmentController;
  late final LabController _labController;

  @override
  void initState() {
    super.initState();
    _appointmentController = Get.isRegistered<AppointmentController>()
        ? Get.find<AppointmentController>()
        : Get.put(AppointmentController());

    _labController = Get.isRegistered<LabController>()
        ? Get.find<LabController>()
        : Get.put(LabController());

    _appointmentController.fetchAppointments();
    _labController.initLabData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const HomeAppbarWidget(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _appointmentController.fetchAppointments(),
            _labController.initLabData(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Interactive Search Bar leading to Doctor & Service Search
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DoctorSearchScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderGrey),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: primaryColor, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Search doctor, hospital, specialty, tests...',
                            style: TextStyle(fontSize: 13, color: textMuted),
                          ),
                        ),
                        Icon(Icons.tune, color: primaryColor, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Emergency SOS Pulse Banner (Feature 15)
                ModernCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  color: emergencyRedBg,
                  border:
                      Border.all(color: emergencyRed.withValues(alpha: 0.3)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EmergencyAssistanceScreen()),
                    );
                  },
                  child: Row(
                    children: [
                      PulseEffectWidget(
                        pulseColor: emergencyRed,
                        maxRadius: 1.25,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: emergencyRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.emergency,
                              color: colorWhite, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency SOS & Ambulance (24/7)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: emergencyRed),
                            ),
                            Text(
                              'Tap for 1-click GPS ambulance dispatch & trauma team',
                              style: TextStyle(fontSize: 10, color: textDark),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: emergencyRed),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Promotional Banner Slider
                const BannerWidget(),
                const SizedBox(height: 20),

                // Next Upcoming Appointment Live Countdown Card (Before Specialties)
                const NextAppointmentCountdownWidget(),
                const SizedBox(height: 20),

                // Medical Specialties Carousel
                const HomeSpecialitesWidget(),
                const SizedBox(height: 20),

                // Action Hub & All 35 Services Grid
                SectionHeader(
                  title: 'Healthcare Services',
                  actionLabel: 'All 35',
                  onAction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AllServicesScreen()),
                    );
                  },
                ),

                const HomeActionWidget(),

                const SizedBox(height: 20),

                // Top Rated Doctors Section
                const DoctorListSection(),
                const SizedBox(height: 16),

                // Recent Diagnostic Report Section (Dynamic from API)
                Obx(() {
                  final lastBooking = _labController.lastBooking.value;
                  final tests = _labController.tests;
                  final labs = _labController.diagnosticLabs;
                  final hasDynamicReport = lastBooking != null ||
                      tests.isNotEmpty ||
                      labs.isNotEmpty;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Recent Diagnostic Report',
                        actionLabel: 'View all',
                        onAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LabReportsScreen(),
                            ),
                          ).then((_) => _labController.initLabData());
                        },
                      ),
                      if ((_labController.isLoading.value ||
                              _labController.isPatientBookingsLoading.value) &&
                          !hasDynamicReport)
                        Container(
                          height: 75,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: colorWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderGrey),
                          ),
                          child: const Center(
                            child:
                                CircularProgressIndicator(color: primaryColor),
                          ),
                        )
                      else if (_labController.patientLabBookings.isNotEmpty)
                        // Dynamic Patient Lab Booking from API
                        Builder(builder: (context) {
                          final booking =
                              _labController.patientLabBookings.first;
                          final testTitle = booking.primaryTestName;
                          final labName = booking.labName ??
                              booking.hospital?.name ??
                              'Hospital Diagnostic Lab';
                          final dateStr = booking.bookingDate ?? 'Recent';
                          final timeSlot = (booking.timeSlot != null &&
                                  booking.timeSlot!.isNotEmpty)
                              ? ' • ${booking.timeSlot}'
                              : '';
                          final status = booking.bookingStatus ?? 'Confirmed';
                          final formattedStatus = status.isNotEmpty
                              ? '${status[0].toUpperCase()}${status.substring(1)}'
                              : 'Confirmed';

                          return ModernCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LabReportDetailScreen(
                                    testName: testTitle,
                                    date: booking.bookingDate,
                                    labName: labName,
                                    bookingNo: booking.bookingNo,
                                    bookingId: booking.bookingId,
                                  ),
                                ),
                              ).then((_) =>
                                  _labController.fetchPatientLabBookings());
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: fillColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.science_rounded,
                                      color: primaryColor, size: 26),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        testTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$labName • $dateStr$timeSlot',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 11, color: textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadgeWidget(
                                  label: formattedStatus,
                                  textColor: primaryColor,
                                  bgColor: fillColor,
                                ),
                              ],
                            ),
                          );
                        })
                      else if (lastBooking != null)
                        ModernCard(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LabReportDetailScreen(
                                  testName: lastBooking.testName,
                                  date: lastBooking.bookingDate,
                                  labName: lastBooking.labName,
                                  bookingNo: lastBooking.bookingNo,
                                  bookingId: lastBooking.bookingId,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: fillColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.science_rounded,
                                    color: primaryColor, size: 26),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lastBooking.testName ??
                                          'Diagnostic Pathology',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${lastBooking.labName ?? "Hospital Lab"} • ${lastBooking.bookingDate ?? "Recent"}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 11, color: textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              StatusBadgeWidget(
                                label: lastBooking.bookingStatus ?? 'Ready',
                                textColor: primaryColor,
                                bgColor: fillColor,
                              ),
                            ],
                          ),
                        )
                      else if (tests.isNotEmpty)
                        Builder(builder: (context) {
                          final test = tests.first;
                          final labName = test.hospital?.name ??
                              (test.labs.isNotEmpty
                                  ? test.labs.first.labName
                                  : 'Hospital Diagnostic Center');
                          final timeStr = test.reportTime ??
                              'Report in ${test.reportDays} day${test.reportDays > 1 ? "s" : ""}';

                          return ModernCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LabReportDetailScreen(
                                    testName: test.testName,
                                    labName: labName,
                                    date: timeStr,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: fillColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.biotech_rounded,
                                      color: primaryColor, size: 26),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        test.testName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$labName • $timeStr',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 11, color: textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadgeWidget(
                                  label: '₹${test.basePrice}',
                                  textColor: primaryColor,
                                  bgColor: fillColor,
                                ),
                              ],
                            ),
                          );
                        })
                      else if (labs.isNotEmpty)
                        Builder(builder: (context) {
                          final lab = labs.first;
                          return ModernCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LabReportsScreen(),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: fillColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.science_rounded,
                                      color: primaryColor, size: 26),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lab.labName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${lab.category ?? "Diagnostic Center"} • ${lab.city ?? "Active Center"}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 11, color: textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadgeWidget(
                                  label: lab.status.isNotEmpty
                                      ? lab.status
                                      : 'Ready',
                                  textColor: primaryColor,
                                  bgColor: fillColor,
                                ),
                              ],
                            ),
                          );
                        })
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderGrey),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: fillColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.science_rounded,
                                    color: primaryColor, size: 24),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No Diagnostic Reports',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: textDark,
                                      ),
                                    ),
                                    Text(
                                      'Explore lab tests & pathology packages',
                                      style: TextStyle(
                                          fontSize: 11, color: textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const LabReportsScreen()),
                                  );
                                },
                                child: const Text('Explore',
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
