import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/controllers/attendance_controller.dart';
import 'package:vlr/data/models/attendance_model.dart';

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
      Get.find<AttendanceController>()
          .getAttendanceHistory(listingId: widget.listingId);
    });
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

  DateTime? _parseAttendanceDate(AttendanceModel item) {
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

  List<AttendanceModel> _getFilteredLogs(List<AttendanceModel> logs) {
    if (!_isFilterApplied || (_fromDate == null && _toDate == null)) {
      return logs;
    }

    return logs.where((item) {
      final itemDate = _parseAttendanceDate(item);
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
        "Please select From Date or To Date to filter",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (_fromDate != null && _toDate != null && _fromDate!.isAfter(_toDate!)) {
      Get.snackbar(
        "Invalid Date Range",
        "From Date cannot be after To Date",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setState(() {
      _isFilterApplied = true;
    });

    final controller = Get.find<AttendanceController>();
    final fromStr =
        _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : null;
    final toStr =
        _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : null;

    await controller.getAttendanceHistory(
      listingId: widget.listingId,
      from: fromStr,
      to: toStr,
    );
  }

  Future<void> _resetFilter() async {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _isFilterApplied = false;
    });

    final controller = Get.find<AttendanceController>();
    await controller.getAttendanceHistory(listingId: widget.listingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.gymTitle != null
              ? "${widget.gymTitle} History"
              : "Gym Attendance History",
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
          if (controller.isLoading && controller.attendanceHistoryList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF002060),
              ),
            );
          }

          final allLogs = controller.attendanceHistoryList;
          final displayLogs = _getFilteredLogs(allLogs);

          // Compute Monthly stats
          final now = DateTime.now();
          final thisMonthLogs = allLogs.where((item) {
            final d = _parseAttendanceDate(item);
            return d != null && d.month == now.month && d.year == now.year;
          }).toList();

          final presentDaysCount = thisMonthLogs
              .map((l) => l.date ?? (l.punchInAt?.split(' ').first ?? ''))
              .where((d) => d.isNotEmpty)
              .toSet()
              .length;

          final completedCount =
              thisMonthLogs.where((l) => l.punchOutAt != null && l.punchOutAt!.isNotEmpty).length;

          final dayOfMonth = now.day;
          final percent = dayOfMonth > 0
              ? ((presentDaysCount / dayOfMonth) * 100).round().clamp(0, 100)
              : 100;

          return RefreshIndicator(
            color: const Color(0xFF002060),
            onRefresh: () async {
              if (_isFilterApplied && (_fromDate != null || _toDate != null)) {
                final fromStr = _fromDate != null
                    ? DateFormat('yyyy-MM-dd').format(_fromDate!)
                    : null;
                final toStr = _toDate != null
                    ? DateFormat('yyyy-MM-dd').format(_toDate!)
                    : null;
                await controller.getAttendanceHistory(
                  listingId: widget.listingId,
                  from: fromStr,
                  to: toStr,
                );
              } else {
                await controller.getAttendanceHistory(listingId: widget.listingId);
              }
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              children: [
                // 1. Top Date Filter Card
                _buildFilterCard(controller),

                if (controller.isLoading) ...[
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
                  if (_isFilterApplied)
                    _buildFilteredSummaryCard(displayLogs)
                  else ...[
                    Container(
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
                              const Text(
                                "Monthly Workout Summary",
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF002060)
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "$percent% Present",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF002060),
                                  ),
                                ),
                              ),
                            ],
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
                    ),
                    const SizedBox(height: 18),
                  ],

                  // 3. Logs Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isFilterApplied
                            ? "Filtered Attendance Logs (${displayLogs.length})"
                            : "All Attendance Logs (${displayLogs.length})",
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
                  if (displayLogs.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayLogs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final attendance = displayLogs[index];
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
                                      _formatDateOnly(attendance.date ??
                                          attendance.punchInAt),
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
                                          ? const Color(0xFF16A34A)
                                              .withValues(alpha: 0.1)
                                          : const Color(0xFFEA580C)
                                              .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      hasOut ? "PRESENT" : "PUNCHED IN",
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
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (attendance.durationMinutes != null &&
                                      attendance.durationMinutes! > 0) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      "${attendance.durationMinutes} mins workout",
                                      style: const TextStyle(
                                        color: Color(0xFF002060),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
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

  /// Top Date Filter Card with From Date, To Date & Filter Button
  Widget _buildFilterCard(AttendanceController controller) {
    final hasSelection = _fromDate != null || _toDate != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isFilterApplied
              ? const Color(0xFF002060).withValues(alpha: 0.25)
              : const Color(0xFFE2E8F0),
          width: _isFilterApplied ? 1.4 : 1.0,
        ),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002060).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      size: 16,
                      color: Color(0xFF002060),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Filter Attendance by Date",
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              if (_isFilterApplied || hasSelection)
                GestureDetector(
                  onTap: _resetFilter,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded,
                            size: 13, color: Color(0xFFDC2626)),
                        SizedBox(width: 4),
                        Text(
                          "Reset",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Date Inputs Row (From Date & To Date)
          Row(
            children: [
              Expanded(
                child: _buildDateInputBox(
                  label: "FROM DATE",
                  date: _fromDate,
                  onTap: () => _pickDate(isFromDate: true),
                  onClear: _fromDate != null
                      ? () => setState(() => _fromDate = null)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateInputBox(
                  label: "TO DATE",
                  date: _toDate,
                  onTap: () => _pickDate(isFromDate: false),
                  onClear: _toDate != null
                      ? () => setState(() => _toDate = null)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Filter Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: controller.isLoading ? null : _applyFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002060),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_alt_rounded, size: 18),
                        SizedBox(width: 6),
                        Text(
                          "Filter Attendance",
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Date picker field widget
  Widget _buildDateInputBox({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null
                ? const Color(0xFF002060).withValues(alpha: 0.5)
                : const Color(0xFFCBD5E1),
            width: date != null ? 1.2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.4,
                  ),
                ),
                if (onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: date != null
                      ? const Color(0xFF002060)
                      : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat("dd MMM yyyy").format(date)
                        : "Select date",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                          date != null ? FontWeight.w700 : FontWeight.w500,
                      color: date != null
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
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

  /// Filtered Summary Card
  Widget _buildFilteredSummaryCard(List<AttendanceModel> displayLogs) {
    final totalRecords = displayLogs.length;
    final presentRecords = displayLogs
        .where((l) =>
            (l.punchInAt != null && l.punchInAt!.isNotEmpty) ||
            (l.status?.toLowerCase() == 'present'))
        .length;
    final completedRecords = displayLogs
        .where((l) => l.punchOutAt != null && l.punchOutAt!.isNotEmpty)
        .length;
    final percent = totalRecords > 0
        ? ((presentRecords / totalRecords) * 100).round()
        : 0;

    String rangeText = "";
    if (_fromDate != null && _toDate != null) {
      rangeText =
          "${DateFormat('dd MMM').format(_fromDate!)} - ${DateFormat('dd MMM yyyy').format(_toDate!)}";
    } else if (_fromDate != null) {
      rangeText = "From ${DateFormat('dd MMM yyyy').format(_fromDate!)}";
    } else if (_toDate != null) {
      rangeText = "Up to ${DateFormat('dd MMM yyyy').format(_toDate!)}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filtered Attendance Summary",
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (rangeText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      rangeText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF002060).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "$percent% Present",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF002060),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHeaderMetric(
                  "Total Logs",
                  "$totalRecords Records",
                  const Color(0xFF002060),
                ),
              ),
              Expanded(
                child: _buildHeaderMetric(
                  "Present",
                  "$presentRecords Days",
                  const Color(0xFF16A34A),
                ),
              ),
              Expanded(
                child: _buildHeaderMetric(
                  "Completed",
                  "$completedRecords Days",
                  const Color(0xFFEA580C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Empty state when no records match filter or no records at all
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF002060).withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFilterApplied
                    ? Icons.filter_alt_off_rounded
                    : Icons.event_busy_rounded,
                size: 52,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isFilterApplied
                  ? "No records in selected date range"
                  : "No attendance records found",
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isFilterApplied
                  ? "Try selecting a different date range or reset the filter."
                  : "Your daily check-in and check-out logs will appear here.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
              ),
            ),
            if (_isFilterApplied) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _resetFilter,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text("Reset Filter"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF002060),
                  side: const BorderSide(color: Color(0xFF002060)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
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
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
