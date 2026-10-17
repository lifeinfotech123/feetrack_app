import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/controllers/attendance_controller.dart';
import 'package:vlr/controllers/permission_controller.dart';
import 'package:vlr/data/models/attendance_model.dart';
import 'package:vlr/data/models/booking_model.dart';
import 'package:vlr/services/constants.dart';

import 'attendance_history_screen.dart';

class AttendanceCheckinCheckoutScreen extends StatefulWidget {
  const AttendanceCheckinCheckoutScreen({super.key});

  @override
  State<AttendanceCheckinCheckoutScreen> createState() =>
      _AttendanceCheckinCheckoutScreenState();
}

class _AttendanceCheckinCheckoutScreenState
    extends State<AttendanceCheckinCheckoutScreen> {
  int _selectedBookingIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final controller = Get.find<AttendanceController>();
    await Future.wait([
      controller.getBookings(),
      controller.getTodayAttendance(),
      controller.getAttendanceHistory(),
    ]);
  }

  String _formatTimeOnly(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return "--:--";
    try {
      final dt = DateTime.parse(dateTimeStr);
      return DateFormat("hh:mm a").format(dt);
    } catch (_) {
      if (dateTimeStr.contains(':')) {
        final parts = dateTimeStr.split(':');
        if (parts.length >= 2) {
          int? hour = int.tryParse(parts[0].trim());
          int? minute = int.tryParse(parts[1].trim());
          if (hour != null && minute != null) {
            final now = DateTime.now();
            final dt = DateTime(now.year, now.month, now.day, hour, minute);
            return DateFormat("hh:mm a").format(dt);
          }
        }
      }
      return dateTimeStr;
    }
  }

  String _formatDateOnly(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Today";
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat("EEEE, dd MMM yyyy").format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Gym Attendance & Check-in",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Color(0xFF002060)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          GetBuilder<AttendanceController>(
            builder: (controller) {
              final activeBooking = controller.bookingList.isNotEmpty &&
                      _selectedBookingIndex < controller.bookingList.length
                  ? controller.bookingList[_selectedBookingIndex]
                  : (controller.bookingList.isNotEmpty
                      ? controller.bookingList.first
                      : null);

              return IconButton(
                onPressed: () {
                  navigate(
                    context: context,
                    page: AttendanceHistoryScreen(
                      listingId: activeBooking?.listing?.id,
                      gymTitle: activeBooking?.listing?.title,
                    ),
                  );
                },
                icon: const Icon(Icons.history_rounded,
                    color: Color(0xFF002060), size: 22),
                tooltip: "Attendance History",
              );
            },
          ),
        ],
      ),
      body: GetBuilder<AttendanceController>(
        builder: (controller) {
          if (controller.isLoading && controller.bookingList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF002060),
              ),
            );
          }

          if (controller.bookingList.isEmpty) {
            return RefreshIndicator(
              color: const Color(0xFF002060),
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
                child: Column(
                  children: [
                    _buildTodayBanner("Active Gym Membership"),
                    const SizedBox(height: 30),
                    _buildEmptyState("No active gym bookings found"),
                  ],
                ),
              ),
            );
          }

          if (_selectedBookingIndex >= controller.bookingList.length) {
            _selectedBookingIndex = 0;
          }

          final selectedBooking = controller.bookingList[_selectedBookingIndex];
          final gymTitle =
              selectedBooking.listing?.title ?? "Fitness Center";

          // Lookup today's attendance for the selected booking
          final todayAttendance = controller.todayAttendanceList.firstWhereOrNull(
            (a) => a.listingId == selectedBooking.listing?.id,
          );

          final isPunchedIn = todayAttendance != null &&
              (todayAttendance.status == 'open' ||
                  (todayAttendance.punchInAt != null &&
                      todayAttendance.punchInAt!.isNotEmpty &&
                      (todayAttendance.punchOutAt == null ||
                          todayAttendance.punchOutAt!.isEmpty)));

          final isCompleted = todayAttendance != null &&
              (todayAttendance.status == 'completed' ||
                  (todayAttendance.punchOutAt != null &&
                      todayAttendance.punchOutAt!.isNotEmpty));

          final punchInTime = todayAttendance?.punchInAt;
          final punchOutTime = todayAttendance?.punchOutAt;

          // Compute Monthly KPI Stats from attendance history
          final now = DateTime.now();
          final thisMonthLogs = controller.attendanceHistoryList.where((item) {
            if (item.date == null && item.punchInAt == null) return false;
            try {
              final d = DateTime.tryParse(item.date ?? item.punchInAt ?? "");
              if (d != null) {
                return d.month == now.month && d.year == now.year;
              }
            } catch (_) {}
            return true;
          }).toList();

          final presentDaySet = <String>{};
          for (var l in thisMonthLogs) {
            final dateKey = l.date ?? l.punchInAt?.split(' ').first;
            if (dateKey != null) presentDaySet.add(dateKey);
          }
          if (isPunchedIn || isCompleted) {
            presentDaySet.add(DateFormat('yyyy-MM-dd').format(now));
          }

          final presentCount = presentDaySet.length;
          final dayOfMonth = now.day;
          final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
          final absentCount =
              (dayOfMonth - presentCount).clamp(0, totalDaysInMonth);
          final rate = dayOfMonth > 0
              ? ((presentCount / dayOfMonth) * 100).round().clamp(0, 100)
              : 100;

          final recentLogs = controller.attendanceHistoryList;

          return RefreshIndicator(
            color: const Color(0xFF002060),
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Today Date & Gym Banner
                  _buildTodayBanner(gymTitle),

                  // If user has multiple gym bookings, show membership switcher
                  if (controller.bookingList.length > 1) ...[
                    const SizedBox(height: 14),
                    _buildBookingSwitcher(controller.bookingList),
                  ],

                  const SizedBox(height: 18),

                  // 2. Main Attendance Hub Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Gym Info & Status Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gymTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedBooking.plan?.name != null
                                        ? "${selectedBooking.plan!.name}${selectedBooking.shift != null ? ' • ${selectedBooking.shift}' : ''}"
                                        : "Daily Workout Attendance",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? const Color(0xFF16A34A)
                                        .withValues(alpha: 0.1)
                                    : isPunchedIn
                                        ? const Color(0xFFEA580C)
                                            .withValues(alpha: 0.1)
                                        : const Color(0xFF002060)
                                            .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isCompleted
                                    ? "COMPLETED"
                                    : isPunchedIn
                                        ? "ACTIVE"
                                        : "NOT MARKED",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isCompleted
                                      ? const Color(0xFF16A34A)
                                      : isPunchedIn
                                          ? const Color(0xFFEA580C)
                                          : const Color(0xFF002060),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 32, color: Color(0xFFF1F5F9)),

                        // Circular Punch Hub (Main Feature)
                        _buildCircularPunchButton(
                          isPunchedIn: isPunchedIn,
                          isCompleted: isCompleted,
                          isPunching: controller.isLoading,
                          punchInTimeStr: punchInTime,
                          onTap: () => _handlePunchTap(
                            context: context,
                            attendanceCtrl: controller,
                            booking: selectedBooking,
                            isPunchedIn: isPunchedIn,
                            isCompleted: isCompleted,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Status hint text
                        _buildStatusHint(
                          isPunchedIn: isPunchedIn,
                          isCompleted: isCompleted,
                        ),

                        const SizedBox(height: 22),

                        // Check-in & Check-out Time Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeInfo(
                                label: "CHECK IN",
                                time: _formatTimeOnly(punchInTime),
                                icon: Icons.login_rounded,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTimeInfo(
                                label: "CHECK OUT",
                                time: _formatTimeOnly(punchOutTime),
                                icon: Icons.logout_rounded,
                                color: const Color(0xFFEA580C),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Monthly Attendance Stats (4 KPI Cards)
                  const Text(
                    "This Month's Summary",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatTile(
                          title: "Workouts",
                          value: "$presentCount Days",
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF16A34A),
                          bgColor: const Color(0xFFF0FDF4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatTile(
                          title: "Missed",
                          value: "$absentCount Days",
                          icon: Icons.cancel_rounded,
                          color: const Color(0xFFDC2626),
                          bgColor: const Color(0xFFFEF2F2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatTile(
                          title: "Attendance Rate",
                          value: "$rate%",
                          icon: Icons.pie_chart_rounded,
                          color: const Color(0xFF2563EB),
                          bgColor: const Color(0xFFEFF6FF),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatTile(
                          title: "Days Elapsed",
                          value: "$dayOfMonth Days",
                          icon: Icons.calendar_month_rounded,
                          color: const Color(0xFF7C3AED),
                          bgColor: const Color(0xFFFAF5FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Recent Workout Attendance Logs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Workout Logs",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          navigate(
                            context: context,
                            page: AttendanceHistoryScreen(
                              listingId: selectedBooking.listing?.id,
                              gymTitle: selectedBooking.listing?.title,
                            ),
                          );
                        },
                        child: const Text(
                          "View All",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF002060),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (recentLogs.isEmpty)
                    _buildEmptyLogsCard()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentLogs.length > 5 ? 5 : recentLogs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final logItem = recentLogs[index];
                        return _buildLogCard(logItem, gymTitle);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Horizontal switcher when user has multiple active gym memberships
  Widget _buildBookingSwitcher(List<BookingModel> bookings) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedBookingIndex;
          final item = bookings[index];
          final title = item.listing?.title ?? "Gym #${index + 1}";

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBookingIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF002060) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF002060)
                      : const Color(0xFFCBD5E1),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF002060).withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayBanner(String propertyTitle) {
    final now = DateTime.now();
    final formattedDate = DateFormat("EEEE, dd MMMM yyyy").format(now);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF002060),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002060).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fingerprint_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Daily Gym Attendance",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Circular Punch Button with 3 states:
  /// 1. PUNCH IN (Blue / Navy gradient) -> 1st tap
  /// 2. PUNCH OUT (Orange gradient) -> 2nd tap
  /// 3. TODAY COMPLETE (Green gradient) -> Finished
  Widget _buildCircularPunchButton({
    required bool isPunchedIn,
    required bool isCompleted,
    required bool isPunching,
    required String? punchInTimeStr,
    required VoidCallback onTap,
  }) {
    Color primaryColor;
    List<Color> gradientColors;
    IconData icon;
    String title;
    String subtitle;

    if (isCompleted) {
      primaryColor = const Color(0xFF16A34A);
      gradientColors = [
        const Color(0xFF22C55E),
        const Color(0xFF15803D),
      ];
      icon = Icons.check_circle_rounded;
      title = "TODAY COMPLETE";
      subtitle = "Workout Done";
    } else if (isPunchedIn) {
      primaryColor = const Color(0xFFEA580C);
      gradientColors = [
        const Color(0xFFF97316),
        const Color(0xFFC2410C),
      ];
      icon = Icons.power_settings_new_rounded;
      title = "PUNCH OUT";
      subtitle = punchInTimeStr != null
          ? "In: ${_formatTimeOnly(punchInTimeStr)}"
          : "Tap to Exit";
    } else {
      primaryColor = const Color(0xFF002060);
      gradientColors = [
        const Color(0xFF003399),
        const Color(0xFF001744),
      ];
      icon = Icons.fingerprint_rounded;
      title = "PUNCH IN";
      subtitle = "Tap to Check In";
    }

    return Center(
      child: InkWell(
        onTap: isPunching ? null : onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          width: 154,
          height: 154,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withValues(alpha: 0.08),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.25),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.12),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.38),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: isPunching
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Processing...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: Colors.white,
                        size: 34,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHint({
    required bool isPunchedIn,
    required bool isCompleted,
  }) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF16A34A).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded,
                size: 13, color: Color(0xFF16A34A)),
            SizedBox(width: 5),
            Text(
              "Today's workout session completed successfully",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF16A34A),
              ),
            ),
          ],
        ),
      );
    } else if (isPunchedIn) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFEA580C).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 13, color: Color(0xFFEA580C)),
            SizedBox(width: 5),
            Text(
              "Workout Active • Tap circle to Punch Out (Exit)",
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEA580C),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF002060).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_rounded, size: 13, color: Color(0xFF002060)),
            SizedBox(width: 5),
            Text(
              "Tap circle to Punch In (Entry)",
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF002060),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTimeInfo({
    required String label,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            time,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(AttendanceModel item, String fallbackTitle) {
    final hasOut = item.punchOutAt != null && item.punchOutAt!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: hasOut ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDateOnly(item.date ?? item.punchInAt),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.listing ?? fallbackTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${_formatTimeOnly(item.punchInAt)} - ${_formatTimeOnly(item.punchOutAt)}",
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.durationMinutes != null && item.durationMinutes! > 0
                    ? "${item.durationMinutes} mins"
                    : (hasOut ? "Completed" : "Active"),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: hasOut ? const Color(0xFF002060) : const Color(0xFFEA580C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLogsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_note_rounded, size: 36, color: Color(0xFFCBD5E1)),
          SizedBox(height: 8),
          Text(
            "No workout logs recorded yet",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF002060).withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Book an active gym membership to start tracking your daily workout attendance.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePunchTap({
    required BuildContext context,
    required AttendanceController attendanceCtrl,
    required BookingModel? booking,
    required bool isPunchedIn,
    required bool isCompleted,
  }) async {
    if (booking == null) {
      showToast(
        message: "No active gym booking found",
        toastType: ToastType.error,
      );
      return;
    }

    if (isCompleted) {
      showToast(
        message: "Today's workout attendance has already been completed!",
        toastType: ToastType.success,
      );
      return;
    }

    try {
      final permissionController = Get.find<PermissionController>();

      // Fetch location
      bool locationSuccess =
          await permissionController.requestLocationPermissionAndFetch(context);
      if (!locationSuccess ||
          permissionController.latitude == null ||
          permissionController.longitude == null) {
        showToast(
          message: "Location is required for Gym attendance verification",
          toastType: ToastType.error,
        );
        return;
      }

      final listingId = booking.listing?.id ?? "";

      if (isPunchedIn) {
        // Punch Out
        final result = await attendanceCtrl.punchOut(
          listingId,
          permissionController.latitude!,
          permissionController.longitude!,
        );
        showToast(
          message: result.message,
          toastType: result.isSuccess ? ToastType.success : ToastType.error,
        );
        if (result.isSuccess) {
          await attendanceCtrl.getAttendanceHistory(listingId: listingId);
        }
      } else {
        // Punch In
        final result = await attendanceCtrl.punchIn(
          listingId,
          permissionController.latitude!,
          permissionController.longitude!,
        );
        showToast(
          message: result.message,
          toastType: result.isSuccess ? ToastType.success : ToastType.error,
        );
        if (result.isSuccess) {
          await attendanceCtrl.getAttendanceHistory(listingId: listingId);
        }
      }
    } catch (e) {
      showToast(
        message: "Attendance error: $e",
        toastType: ToastType.error,
      );
    }
  }
}
