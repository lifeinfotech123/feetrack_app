import 'package:vlr/data/models/rooom/pg_customer_dashboard_model.dart';

class PgCustomerAttendanceResponse {
  final bool status;
  final String? message;
  final PgCustomerAttendanceData? data;

  PgCustomerAttendanceResponse({
    this.status = false,
    this.message,
    this.data,
  });

  factory PgCustomerAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return PgCustomerAttendanceResponse(
      status: json['status'] == true || json['status'] == 'true',
      message: json['message']?.toString(),
      data: json['data'] is Map
          ? PgCustomerAttendanceData.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }
}

class PgCustomerAttendanceData {
  final int month;
  final int year;
  final PgAttendanceStats? stats;
  final List<PgAttendanceLogItem> attendanceLogs;

  PgCustomerAttendanceData({
    this.month = 0,
    this.year = 0,
    this.stats,
    this.attendanceLogs = const [],
  });

  factory PgCustomerAttendanceData.fromJson(Map<String, dynamic> json) {
    return PgCustomerAttendanceData(
      month: json['month'] is int
          ? json['month']
          : int.tryParse(json['month']?.toString() ?? "") ?? 0,
      year: json['year'] is int
          ? json['year']
          : int.tryParse(json['year']?.toString() ?? "") ?? 0,
      stats: json['stats'] is Map
          ? PgAttendanceStats.fromJson(Map<String, dynamic>.from(json['stats']))
          : null,
      attendanceLogs: (json['attendance_logs'] is List)
          ? (json['attendance_logs'] as List)
              .whereType<Map>()
              .map((e) => PgAttendanceLogItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }
}

class PgAttendanceStats {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final dynamic attendancePercent;
  final String? todayStatus;
  final String? todayPunchIn;
  final String? todayPunchOut;

  PgAttendanceStats({
    this.totalDays = 0,
    this.presentDays = 0,
    this.absentDays = 0,
    this.attendancePercent = 0,
    this.todayStatus,
    this.todayPunchIn,
    this.todayPunchOut,
  });

  factory PgAttendanceStats.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) =>
        val != null ? (int.tryParse(val.toString()) ?? 0) : 0;

    return PgAttendanceStats(
      totalDays: parseInt(json['total_days']),
      presentDays: parseInt(json['present_days']),
      absentDays: parseInt(json['absent_days']),
      attendancePercent: json['attendance_percent'] ?? 0,
      todayStatus: json['today_status']?.toString(),
      todayPunchIn: json['today_punch_in']?.toString(),
      todayPunchOut: json['today_punch_out']?.toString(),
    );
  }

  bool get isPunchedIn =>
      todayPunchIn != null && todayPunchIn!.isNotEmpty && (todayPunchOut == null || todayPunchOut!.isEmpty);

  bool get isCompleted =>
      todayPunchIn != null &&
      todayPunchIn!.isNotEmpty &&
      todayPunchOut != null &&
      todayPunchOut!.isNotEmpty;
}

class PgAttendanceLogItem {
  final int? id;
  final String? date;
  final String? formattedDate;
  final String? punchInAt;
  final String? punchOutAt;
  final int? durationMinutes;
  final String? durationDisplay;
  final String? status;
  final String? note;
  final PgPropertyShortInfo? property;

  PgAttendanceLogItem({
    this.id,
    this.date,
    this.formattedDate,
    this.punchInAt,
    this.punchOutAt,
    this.durationMinutes,
    this.durationDisplay,
    this.status,
    this.note,
    this.property,
  });

  factory PgAttendanceLogItem.fromJson(Map<String, dynamic> json) {
    return PgAttendanceLogItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ""),
      date: json['date']?.toString(),
      formattedDate: json['formatted_date']?.toString(),
      punchInAt: json['punch_in_at']?.toString(),
      punchOutAt: json['punch_out_at']?.toString(),
      durationMinutes: json['duration_minutes'] is int
          ? json['duration_minutes']
          : int.tryParse(json['duration_minutes']?.toString() ?? ""),
      durationDisplay: json['duration_display']?.toString(),
      status: json['status']?.toString() ?? "Present",
      note: json['note']?.toString(),
      property: json['property'] is Map
          ? PgPropertyShortInfo.fromJson(Map<String, dynamic>.from(json['property']))
          : null,
    );
  }
}
