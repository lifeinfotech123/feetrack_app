import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/controllers/attendance_controller.dart';
import 'package:vlr/data/models/attendance_model.dart';
import 'package:vlr/data/models/gym_attendance_model.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final String? listingId;
  final String? gymTitle;

  const AttendanceHistoryScreen({
    super.key,
    this.listingId,
    this.gymTitle,
  });

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isFilterApplied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
  }

  Future<void> _fetchHistory() async {
    final controller = Get.find<AttendanceController>();
    await Future.wait([
      controller.fetchGymAttendanceHistory(),
      controller.getAttendanceHistory(listingId: widget.listingId),
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
    if (dateStr == null || dateStr.isEmpty) return "Attendance";
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat("EEEE, dd MMM yyyy").format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  DateTime? _parseGymAttendanceDate(GymAttendanceLogItem item) {
    if (item.date != null && item.date!.trim().isNotEmpty) {
      final d = DateTime.tryParse(item.date!.trim());
      if (d != null) return d;
    }
    if (item.punchInAt != null && item.punchInAt!.trim().isNotEmpty) {
      final d = DateTime.tryParse(item.punchInAt!.trim());
      if (d != null) return d;
    }
    return null;
  }

  DateTime? _parseLegacyAttendanceDate(AttendanceModel item) {
    if (item.date != null && item.date!.trim().isNotEmpty) {
      final d = DateTime.tryParse(item.date!.trim());
      if (d != null) return d;
    }
    if (item.punchInAt != null && item.punchInAt!.trim().isNotEmpty) {
      final d = DateTime.tryParse(item.punchInAt!.trim());
      if (d != null) return d;
    }
    return null;
  }

  List<GymAttendanceLogItem> _getFilteredGymLogs(
      List<GymAttendanceLogItem> logs) {
    if (!_isFilterApplied || (_fromDate == null && _toDate == null)) {
      return logs;
    }

    return logs.where((item) {
      final itemDate = _parseGymAttendanceDate(item);
      if (itemDate == null) return true;

      final day = DateTime(itemDate.year, itemDate.month, itemDate.day);

      if (_fromDate != null) {
        final from =
            DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
        if (day.isBefore(from)) return false;
      }

      if (_toDate != null) {
        final to = DateTime(_toDate!.year, _toDate!.month, _toDate!.day);
        if (day.isAfter(to)) return false;
      }

      return true;
    }).toList();
  }

  List<AttendanceModel> _getFilteredLegacyLogs(List<AttendanceModel> logs) {
    if (!_isFilterApplied || (_fromDate == null && _toDate == null)) {
      return logs;
    }

    return logs.where((item) {
      final itemDate = _parseLegacyAttendanceDate(item);
      if (itemDate == null) return true;

      final day = DateTime(itemDate.year, itemDate.month, itemDate.day);

      if (_fromDate != null) {
        final from =
            DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
        if (day.isBefore(from)) return false;
      }

      if (_toDate != null) {
        final to = DateTime(_toDate!.year, _toDate!.month, _toDate!.day);
        if (day.isAfter(to)) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _pickDate({required bool isFromDate}) async {
    final now = DateTime.now();
    final initialDate = isFromDate
        ? (_fromDate ?? _toDate ?? now)
        : (_toDate ?? _fromDate ?? now);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? now : initialDate,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF002060),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
          if (_toDate != null && _fromDate!.isAfter(_toDate!)) {
            _toDate = _fromDate;
          }
        } else {
          _toDate = picked;
          if (_fromDate != null && _toDate!.isBefore(_fromDate!)) {
            _fromDate = _toDate;
          }
        }
      });
    }
  }

  Future<void> _applyFilter() async {
    if (_fromDate == null && _toDate == null) {
      Get.snackbar(
        "Select Date",
        "Please select at least one date to apply filter",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isFilterApplied = true;
    });

    final controller = Get.find<AttendanceController>();
    String? monthParam;
    if (_fromDate != null) {
      monthParam = DateFormat('yyyy-MM').format(_fromDate!);
    }
    await controller.fetchGymAttendanceHistory(month: monthParam);
  }

  Future<void> _clearFilter() async {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _isFilterApplied = false;
    });

    await _fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.gymTitle ?? "Attendance History",
          style: const TextStyle(
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
      ),
      body: GetBuilder<AttendanceController>(
        builder: (controller) {
          final isInitialLoading = controller.isHistoryLoading &&
              controller.gymLogs.isEmpty &&
              controller.attendanceHistoryList.isEmpty;

          if (isInitialLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF002060),
              ),
            );
          }

          final bool hasGymLogs = controller.gymLogs.isNotEmpty;
          final displayGymLogs = _getFilteredGymLogs(controller.gymLogs);
          final displayLegacyLogs =
              _getFilteredLegacyLogs(controller.attendanceHistoryList);

          final summary = controller.historySummary;
          final totalCount =
              hasGymLogs ? displayGymLogs.length : displayLegacyLogs.length;

          return RefreshIndicator(
            color: const Color(0xFF002060),
            onRefresh: () async {
              await _fetchHistory();
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              children: [
                // 1. Top Date Filter Card
                _buildFilterCard(controller),

                if (controller.isHistoryLoading) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF002060),
                      ),
                    ),
                  ),
                ] else ...[
                  // 2. Summary Card
                  if (summary != null)
                    _buildApiSummaryCard(summary)
                  else if (_isFilterApplied)
                    _buildFilteredSummaryCard(totalCount)
                  else
                    _buildFallbackSummaryCard(
                        controller.attendanceHistoryList),

                  const SizedBox(height: 18),

                  // 3. Logs Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isFilterApplied
                            ? "Filtered Workout Logs ($totalCount)"
                            : "All Workout Logs ($totalCount)",
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (_isFilterApplied)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF002060)
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Filtered",
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF002060),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 4. Log Cards or Empty State
                  if (totalCount == 0)
                    _buildEmptyState()
                  else if (hasGymLogs)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayGymLogs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = displayGymLogs[index];
                        return _buildGymLogTile(item);
                      },
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayLegacyLogs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = displayLegacyLogs[index];
                        return _buildLegacyLogTile(item);
                      },
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildApiSummaryCard(GymAttendanceHistorySummary summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                summary.monthLabel ?? "Monthly Workout Summary",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF002060).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${summary.currentStreakDays} Day Streak 🔥",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF002060),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildHeaderMetric(
                  "Workouts",
                  "${summary.totalDaysAttended} Days",
                  const Color(0xFF16A34A),
                ),
              ),
              Expanded(
                child: _buildHeaderMetric(
                  "Total Time",
                  summary.totalWorkoutHoursFormatted ??
                      "${summary.totalWorkoutMinutes}m",
                  const Color(0xFF2563EB),
                ),
              ),
              Expanded(
                child: _buildHeaderMetric(
                  "Avg Session",
                  "${summary.avgSessionMinutes} mins",
                  const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackSummaryCard(List<AttendanceModel> allLogs) {
    final now = DateTime.now();
    final thisMonthLogs = allLogs.where((item) {
      final d = _parseLegacyAttendanceDate(item);
      return d != null && d.month == now.month && d.year == now.year;
    }).toList();

    final presentDaysCount = thisMonthLogs
        .map((l) => l.date ?? (l.punchInAt?.split(' ').first ?? ''))
        .where((d) => d.isNotEmpty)
        .toSet()
        .length;

    final completedCount = thisMonthLogs
        .where((l) => l.punchOutAt != null && l.punchOutAt!.isNotEmpty)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly Workout Summary",
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHeaderMetric(
                  "Present Days",
                  "$presentDaysCount Days",
                  const Color(0xFF16A34A),
                ),
              ),
              Expanded(
                child: _buildHeaderMetric(
                  "Completed",
                  "$completedCount Sessions",
                  const Color(0xFFEA580C),
                ),
              ),
              Expanded(
                child: _buildHeaderMetric(
                  "Total Logs",
                  "${allLogs.length} Records",
                  const Color(0xFF002060),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredSummaryCard(int total) {
    final fromStr = _fromDate != null
        ? DateFormat('dd MMM yyyy').format(_fromDate!)
        : "Start";
    final toStr = _toDate != null
        ? DateFormat('dd MMM yyyy').format(_toDate!)
        : "Today";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF002060).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF002060).withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filter Date Range",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "$fromStr - $toStr",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF002060),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "$total Records",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGymLogTile(GymAttendanceLogItem item) {
    final title = item.gym?.title ?? widget.gymTitle ?? "Fitness Center";
    final city = item.gym?.city;
    final subtitle =
        [title, city].where((s) => s != null && s.isNotEmpty).join(" • ");

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: item.isCompleted
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFEA580C),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.formattedDate ?? item.date ?? "Workout Session",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.note != null && item.note!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.isCompleted
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.isCompleted ? "COMPLETED" : "INCOMPLETE",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: item.isCompleted
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "${item.punchInTime ?? '--:--'} - ${item.punchOutTime ?? '--:--'}",
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.durationFormatted ??
                    (item.durationMinutes != null && item.durationMinutes! > 0
                        ? "${item.durationMinutes} mins"
                        : (item.isCompleted ? "Completed" : "--")),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF002060),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegacyLogTile(AttendanceModel attendance) {
    final hasOut = attendance.punchOutAt != null &&
        attendance.punchOutAt!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: hasOut
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFEA580C),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDateOnly(attendance.date ?? attendance.punchInAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  attendance.listing ??
                      widget.gymTitle ??
                      "Fitness Center",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: hasOut
                      ? const Color(0xFF16A34A).withValues(alpha: 0.1)
                      : const Color(0xFFEA580C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hasOut ? "COMPLETED" : "OPEN",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: hasOut
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFEA580C),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "${_formatTimeOnly(attendance.punchInAt)} - ${_formatTimeOnly(attendance.punchOutAt)}",
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              if (attendance.durationMinutes != null &&
                  attendance.durationMinutes! > 0) ...[
                const SizedBox(height: 2),
                Text(
                  "${attendance.durationMinutes} mins",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF002060),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard(AttendanceController controller) {
    final fromText = _fromDate != null
        ? DateFormat('dd MMM yyyy').format(_fromDate!)
        : "Start Date";
    final toText = _toDate != null
        ? DateFormat('dd MMM yyyy').format(_toDate!)
        : "End Date";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.tune_rounded,
                      size: 16, color: Color(0xFF002060)),
                  SizedBox(width: 6),
                  Text(
                    "Filter Attendance",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              if (_isFilterApplied)
                InkWell(
                  onTap: _clearFilter,
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      "Reset",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDatePickerButton(
                  label: "FROM",
                  value: fromText,
                  hasValue: _fromDate != null,
                  onTap: () => _pickDate(isFromDate: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDatePickerButton(
                  label: "TO",
                  value: toText,
                  hasValue: _toDate != null,
                  onTap: () => _pickDate(isFromDate: false),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: controller.isHistoryLoading ? null : _applyFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002060),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Icon(Icons.arrow_forward_rounded, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerButton({
    required String label,
    required String value,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: hasValue
              ? const Color(0xFF002060).withValues(alpha: 0.05)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? const Color(0xFF002060).withValues(alpha: 0.3)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: hasValue
                    ? const Color(0xFF002060)
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: hasValue
                      ? const Color(0xFF002060)
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: hasValue
                          ? const Color(0xFF002060)
                          : const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF002060).withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "No Attendance Logs Found",
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isFilterApplied
                ? "Try selecting a different date range to view your workout records."
                : "Your daily gym punch-in and punch-out history will be listed here.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
