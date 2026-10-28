import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/controllers/attendance_controller.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/permission_controller.dart';
import 'package:vlr/data/models/attendance_model.dart';
import 'package:vlr/data/models/booking_model.dart';
import 'package:vlr/data/models/gym_attendance_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';

import 'attendance_history_screen.dart';
import 'gym_invoice_list_screen.dart';
import '../gym_reviews/gym_reviews_screen.dart';

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
    final authController =
        Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    if (authController == null || !authController.isLoggedIn()) {
      if (Get.isRegistered<AttendanceController>()) {
        Get.find<AttendanceController>().clearGymAttendanceData();
      }
      return;
    }
    final controller = Get.find<AttendanceController>();
    await Future.wait([
      controller.fetchGymAttendanceStatus(),
      controller.fetchGymAttendanceHistory(),
      controller.getBookings(),
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

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF002060).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: Color(0xFF002060),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "You are browsing as Guest",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please log in to track your gym attendance, view active memberships, and punch in/out.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                if (mounted &&
                    Get.isRegistered<AuthController>() &&
                    Get.find<AuthController>().isLoggedIn()) {
                  _loadData();
                  setState(() {});
                }
              },
              icon: const Icon(Icons.login_rounded,
                  color: Colors.white, size: 18),
              label: const Text(
                "Log In Now",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002060),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        final bool isLoggedIn = authController.isLoggedIn();

        if (!isLoggedIn) {
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
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xFF002060),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: _buildGuestView(context),
          );
        }

        // If logged in, ensure data is loaded if empty
        final attendanceCtrl = Get.find<AttendanceController>();
        if (!attendanceCtrl.isStatusLoading &&
            attendanceCtrl.attendanceStatusData == null &&
            attendanceCtrl.bookingList.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadData();
          });
        }

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
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Color(0xFF002060),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GymInvoiceListScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFF002060),
                  size: 22,
                ),
                tooltip: "Invoices & Billing",
              ),
              GetBuilder<AttendanceController>(
                builder: (controller) {
                  final activeBooking = controller.bookingList.isNotEmpty &&
                          _selectedBookingIndex < controller.bookingList.length
                      ? controller.bookingList[_selectedBookingIndex]
                      : (controller.bookingList.isNotEmpty
                          ? controller.bookingList.first
                          : null);

                  final gymTitle =
                      controller.attendanceStatusData?.gym?.title ??
                          activeBooking?.listing?.title;
                  final listingId = activeBooking?.listing?.id ??
                      controller.attendanceStatusData?.gym?.id;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GymReviewsScreen(
                                gymId: listingId,
                                gymTitle: gymTitle,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.star_outline_rounded,
                          color: Color(0xFF002060),
                          size: 22,
                        ),
                        tooltip: "Reviews & Ratings",
                      ),
                      IconButton(
                        onPressed: () {
                          navigate(
                            context: context,
                            page: AttendanceHistoryScreen(
                              listingId: listingId,
                              gymTitle: gymTitle,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.history_rounded,
                          color: Color(0xFF002060),
                          size: 22,
                        ),
                        tooltip: "Attendance History",
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: GetBuilder<AttendanceController>(
            builder: (controller) {
              final statusData = controller.attendanceStatusData;
              final isInitialLoading = controller.isStatusLoading &&
                  statusData == null &&
                  controller.isLoading;

              if (isInitialLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF002060),
                  ),
                );
              }

              // Booking fallback
              BookingModel? selectedBooking;
              if (controller.bookingList.isNotEmpty) {
                if (_selectedBookingIndex >= controller.bookingList.length) {
                  _selectedBookingIndex = 0;
                }
                selectedBooking = controller.bookingList[_selectedBookingIndex];
              }

              // Gym Title & Details
              final gymTitle = statusData?.gym?.title ??
                  selectedBooking?.listing?.title ??
                  "Fitness Center";

              final gymSubtitle = statusData?.gym?.city != null
                  ? "${statusData!.gym!.city}${statusData.gym?.address != null ? ' • ${statusData.gym!.address}' : ''}"
                  : (selectedBooking?.plan?.name != null
                      ? "${selectedBooking!.plan!.name}${selectedBooking.shift != null ? ' • ${selectedBooking.shift}' : ''}"
                      : "Daily Workout Attendance");

              // Status & Punch Capability
              final canPunchIn = statusData?.canPunchIn ?? true;
              final canPunchOut = statusData?.canPunchOut ?? false;
              final isCompleted = statusData != null
                  ? (statusData.status == 'punched_out' &&
                      !canPunchIn &&
                      !canPunchOut)
                  : false;
              final isPunchedIn = statusData != null
                  ? (statusData.status == 'punched_in' || canPunchOut)
                  : false;

              final statusLabel = statusData?.statusLabel ??
                  (isCompleted
                      ? "Workout Completed"
                      : isPunchedIn
                          ? "Active Session"
                          : "Not Marked");

              // Session punch times
              final currentSession = statusData?.currentSession;
              final lastSession = statusData?.todaySessions.isNotEmpty == true
                  ? statusData!.todaySessions.last
                  : null;

              final String checkInDisplay = currentSession?.punchInTime ??
                  lastSession?.punchInTime ??
                  (statusData?.todaySessions.isNotEmpty == true
                      ? (statusData!.todaySessions.first.punchInTime ?? "--:--")
                      : "--:--");

              final String checkOutDisplay = currentSession?.punchOutTime ??
                  lastSession?.punchOutTime ??
                  "--:--";

              final totalWorkoutMinutes = statusData?.totalTodayMinutes ?? 0;

              // KPI stats (use API summary if available, else compute)
              final historySummary = controller.historySummary;
              final workoutsCount = historySummary?.totalDaysAttended ??
                  controller.attendanceHistoryList.length;
              final totalTimeFormatted =
                  historySummary?.totalWorkoutHoursFormatted ??
                      (historySummary != null
                          ? "${historySummary.totalWorkoutMinutes}m"
                          : "${totalWorkoutMinutes}m");
              final avgSessionFormatted = historySummary != null
                  ? "${historySummary.avgSessionMinutes}m"
                  : "--";
              final streakDays = historySummary?.currentStreakDays ?? 1;

              final recentGymLogs = controller.gymLogs;
              final todaySessions = statusData?.todaySessions ?? [];

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
                      _buildTodayBanner(
                        gymTitle: gymTitle,
                        statusData: statusData,
                      ),

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        gymSubtitle,
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
                                    statusLabel.toUpperCase(),
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

                            // Membership Pill if available
                            if (statusData?.membership != null) ...[
                              const SizedBox(height: 10),
                              _buildMembershipPill(statusData!.membership!),
                            ],

                            const Divider(height: 30, color: Color(0xFFF1F5F9)),

                            // Circular Punch Hub (Main Feature)
                            _buildCircularPunchButton(
                              canPunchIn: canPunchIn,
                              canPunchOut: canPunchOut,
                              isPunchedIn: isPunchedIn,
                              isCompleted: isCompleted,
                              isPunching:
                                  controller.isPunching || controller.isLoading,
                              punchInTimeStr: checkInDisplay != "--:--"
                                  ? checkInDisplay
                                  : null,
                              onTap: () => _handlePunchTap(
                                context: context,
                                controller: controller,
                                canPunchIn: canPunchIn,
                                canPunchOut: canPunchOut,
                                statusData: statusData,
                                gymId: selectedBooking?.listing?.id ??
                                    statusData?.gym?.id,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Status hint text
                            _buildStatusHint(
                              canPunchIn: canPunchIn,
                              canPunchOut: canPunchOut,
                              isPunchedIn: isPunchedIn,
                              isCompleted: isCompleted,
                              statusLabel: statusLabel,
                            ),

                            const SizedBox(height: 22),

                            // Check-in, Check-out & Today Total Time Cards
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimeInfo(
                                    label: "CHECK IN",
                                    time: checkInDisplay,
                                    icon: Icons.login_rounded,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildTimeInfo(
                                    label: "CHECK OUT",
                                    time: checkOutDisplay,
                                    icon: Icons.logout_rounded,
                                    color: const Color(0xFFEA580C),
                                  ),
                                ),
                                if (totalWorkoutMinutes > 0) ...[
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildTimeInfo(
                                      label: "TOTAL DURATION",
                                      time: "$totalWorkoutMinutes m",
                                      icon: Icons.timer_outlined,
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 3. Today's Sessions Section (if sessions recorded)
                      if (todaySessions.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildTodaySessionsSection(todaySessions),
                      ],

                      const SizedBox(height: 20),

                      // 4. Monthly Attendance Stats (4 KPI Cards)
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
                              value: "$workoutsCount Days",
                              icon: Icons.fitness_center_rounded,
                              color: const Color(0xFF16A34A),
                              bgColor: const Color(0xFFF0FDF4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatTile(
                              title: "Total Time",
                              value: totalTimeFormatted,
                              icon: Icons.access_time_rounded,
                              color: const Color(0xFF2563EB),
                              bgColor: const Color(0xFFEFF6FF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatTile(
                              title: "Avg Session",
                              value: avgSessionFormatted,
                              icon: Icons.speed_rounded,
                              color: const Color(0xFF7C3AED),
                              bgColor: const Color(0xFFFAF5FF),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatTile(
                              title: "Current Streak",
                              value: "$streakDays Days",
                              icon: Icons.local_fire_department_rounded,
                              color: const Color(0xFFEA580C),
                              bgColor: const Color(0xFFFFF7ED),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 5. Recent Workout Attendance Logs
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
                                  listingId: statusData?.gym?.id ??
                                      selectedBooking?.listing?.id,
                                  gymTitle: gymTitle,
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

                      if (recentGymLogs.isEmpty &&
                          controller.attendanceHistoryList.isEmpty)
                        _buildEmptyLogsCard()
                      else if (recentGymLogs.isNotEmpty)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentGymLogs.length > 5
                              ? 5
                              : recentGymLogs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final logItem = recentGymLogs[index];
                            return _buildGymLogCard(logItem, gymTitle);
                          },
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.attendanceHistoryList.length > 5
                              ? 5
                              : controller.attendanceHistoryList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final logItem =
                                controller.attendanceHistoryList[index];
                            return _buildLegacyLogCard(logItem, gymTitle);
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMembershipPill(GymAttendanceMembership membership) {
    final status = (membership.status ?? "active").toUpperCase();
    final expires = membership.expiresAt ?? "";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF002060).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF002060).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.card_membership_rounded,
            size: 16,
            color: Color(0xFF002060),
          ),
          const SizedBox(width: 8),
          Text(
            "Membership: $status",
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF002060),
            ),
          ),
          if (expires.isNotEmpty) ...[
            const Spacer(),
            Text(
              "Expires: $expires",
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTodaySessionsSection(List<GymAttendanceSessionItem> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Workout Sessions",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sessions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final s = sessions[index];
            final isIn = s.punchInTime ?? "--:--";
            final isOut = s.punchOutTime ?? "In Progress";
            final duration = s.durationFormatted ??
                (s.durationMinutes != null && s.durationMinutes! > 0
                    ? "${s.durationMinutes} mins"
                    : "--");

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF002060).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "#${index + 1}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF002060),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$isIn → $isOut",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Duration: $duration",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: s.isCompleted
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      s.isCompleted ? "Completed" : "Active",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: s.isCompleted
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
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

  Widget _buildTodayBanner({
    required String gymTitle,
    GymAttendanceStatusData? statusData,
  }) {
    final now = DateTime.now();
    final formattedDate = statusData?.todayFormatted ??
        DateFormat("EEEE, dd MMMM yyyy").format(now);
    final customerName = statusData?.customer?.name;

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
              Icons.fitness_center_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName != null && customerName.isNotEmpty
                      ? "Hi, $customerName 👋"
                      : "Daily Gym Attendance",
                  style: const TextStyle(
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
  /// 1. PUNCH IN (Blue / Navy gradient) -> can_punch_in == true
  /// 2. PUNCH OUT (Orange gradient) -> can_punch_out == true
  /// 3. TODAY COMPLETE (Green gradient) -> Finished
  Widget _buildCircularPunchButton({
    required bool canPunchIn,
    required bool canPunchOut,
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

    if (canPunchOut) {
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
    } else if (canPunchIn) {
      primaryColor = const Color(0xFF002060);
      gradientColors = [
        const Color(0xFF003399),
        const Color(0xFF001744),
      ];
      icon = Icons.fingerprint_rounded;
      title = isCompleted ? "RE-OPEN" : "PUNCH IN";
      subtitle = isCompleted ? "Tap to Workout Again" : "Tap to Check In";
    } else {
      primaryColor = const Color(0xFF16A34A);
      gradientColors = [
        const Color(0xFF22C55E),
        const Color(0xFF15803D),
      ];
      icon = Icons.check_circle_rounded;
      title = "TODAY COMPLETE";
      subtitle = "Workout Done";
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
    required bool canPunchIn,
    required bool canPunchOut,
    required bool isPunchedIn,
    required bool isCompleted,
    required String statusLabel,
  }) {
    if (canPunchOut) {
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
    } else if (canPunchIn) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF002060).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.touch_app_rounded,
                size: 13, color: Color(0xFF002060)),
            const SizedBox(width: 5),
            Text(
              isCompleted
                  ? "Re-open session • Tap circle to Punch In"
                  : "Tap circle to Punch In (Entry)",
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF002060),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF16A34A).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                size: 13, color: Color(0xFF16A34A)),
            const SizedBox(width: 5),
            Text(
              statusLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF16A34A),
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

  Widget _buildGymLogCard(GymAttendanceLogItem item, String fallbackTitle) {
    final title = item.gym?.title ?? fallbackTitle;
    final city = item.gym?.city;
    final subtitle =
        [title, city].where((s) => s != null && s.isNotEmpty).join(" • ");

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
              color: item.isCompleted
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFEA580C),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.formattedDate ?? item.date ?? "Workout Session",
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                if (item.note != null && item.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${item.punchInTime ?? '--:--'} - ${item.punchOutTime ?? '--:--'}",
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.durationFormatted ??
                    (item.durationMinutes != null && item.durationMinutes! > 0
                        ? "${item.durationMinutes} mins"
                        : (item.isCompleted ? "Completed" : "Active")),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: item.isCompleted
                      ? const Color(0xFF002060)
                      : const Color(0xFFEA580C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegacyLogCard(AttendanceModel item, String fallbackTitle) {
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
                  color: hasOut
                      ? const Color(0xFF002060)
                      : const Color(0xFFEA580C),
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

  Future<void> _handlePunchTap({
    required BuildContext context,
    required AttendanceController controller,
    required bool canPunchIn,
    required bool canPunchOut,
    GymAttendanceStatusData? statusData,
    String? gymId,
  }) async {
    if (controller.isPunching) return;

    if (!canPunchIn && !canPunchOut) {
      showToast(
        message: "Today's workout session has already been completed!",
        toastType: ToastType.success,
      );
      return;
    }

    try {
      if (canPunchOut) {
        // Punch Out
        final result = await controller.punchOutGym();
        showToast(
          message: result.message,
          toastType: result.isSuccess ? ToastType.success : ToastType.error,
        );
        if (result.isSuccess) {
          await controller.fetchGymAttendanceHistory();
        }
      } else if (canPunchIn) {
        // Punch In
        final permissionController = Get.find<PermissionController>();
        final locationSuccess = await permissionController
            .requestLocationPermissionAndFetch(context);

        String locationName = "gym";
        if (locationSuccess &&
            permissionController.latitude != null &&
            permissionController.longitude != null) {
          locationName =
              "${permissionController.latitude},${permissionController.longitude}";
        }

        String? resolvedGymIdTap = gymId ?? statusData?.gym?.id;
        if ((resolvedGymIdTap == null || resolvedGymIdTap.isEmpty) &&
            controller.bookingList.isNotEmpty) {
          resolvedGymIdTap = controller.bookingList.first.listing?.id;
        }
        if ((resolvedGymIdTap == null || resolvedGymIdTap.isEmpty) &&
            controller.attendanceStatusData?.gym?.id != null) {
          resolvedGymIdTap = controller.attendanceStatusData!.gym!.id;
        }
        final result = await controller.punchInGym(
          gymId: resolvedGymIdTap,
          location: locationName,
          note: "Workout session",
        );
        showToast(
          message: result.message,
          toastType: result.isSuccess ? ToastType.success : ToastType.error,
        );
        if (result.isSuccess) {
          await controller.fetchGymAttendanceHistory();
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
