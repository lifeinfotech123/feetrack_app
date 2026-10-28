bool parseGymBool(dynamic value, {bool defaultValue = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes' || normalized == 'y' || normalized == 'on') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no' || normalized == 'n' || normalized == 'off' || normalized.isEmpty) {
      return false;
    }
  }
  return defaultValue;
}

class GymAttendanceStatusResponse {
  final bool? status;
  final String? message;
  final GymAttendanceStatusData? data;

  GymAttendanceStatusResponse({this.status, this.message, this.data});

  factory GymAttendanceStatusResponse.fromJson(Map<String, dynamic> json) {
    return GymAttendanceStatusResponse(
      status: parseGymBool(json['status']),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? GymAttendanceStatusData.fromJson(
              Map<String, dynamic>.from(json['data']))
          : null,
    );
  }
}

class GymAttendanceStatusData {
  final String? status;
  final String? statusLabel;
  final bool canPunchIn;
  final bool canPunchOut;
  final String? todayDate;
  final String? todayFormatted;
  final GymAttendanceSessionItem? currentSession;
  final List<GymAttendanceSessionItem> todaySessions;
  final int totalTodayMinutes;
  final GymAttendanceCustomer? customer;
  final GymAttendanceGym? gym;
  final dynamic shift;
  final GymAttendanceMembership? membership;

  GymAttendanceStatusData({
    this.status,
    this.statusLabel,
    this.canPunchIn = false,
    this.canPunchOut = false,
    this.todayDate,
    this.todayFormatted,
    this.currentSession,
    this.todaySessions = const [],
    this.totalTodayMinutes = 0,
    this.customer,
    this.gym,
    this.shift,
    this.membership,
  });

  factory GymAttendanceStatusData.fromJson(Map<String, dynamic> json) {
    var rawSessions = json['today_sessions'];
    List<GymAttendanceSessionItem> sessionsList = [];
    if (rawSessions is List) {
      sessionsList = rawSessions
          .map((e) => GymAttendanceSessionItem.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return GymAttendanceStatusData(
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString() ??
          json['status']?.toString() ??
          "Not Marked",
      canPunchIn: parseGymBool(json['can_punch_in']),
      canPunchOut: parseGymBool(json['can_punch_out']),
      todayDate: json['today_date']?.toString(),
      todayFormatted: json['today_formatted']?.toString(),
      currentSession: json['current_session'] is Map
          ? GymAttendanceSessionItem.fromJson(
              Map<String, dynamic>.from(json['current_session'] as Map))
          : null,
      todaySessions: sessionsList,
      totalTodayMinutes: json['total_today_minutes'] is num
          ? (json['total_today_minutes'] as num).toInt()
          : int.tryParse(json['total_today_minutes']?.toString() ?? '0') ?? 0,
      customer: json['customer'] is Map
          ? GymAttendanceCustomer.fromJson(
              Map<String, dynamic>.from(json['customer'] as Map))
          : null,
      gym: json['gym'] is Map
          ? GymAttendanceGym.fromJson(
              Map<String, dynamic>.from(json['gym'] as Map))
          : null,
      shift: json['shift'],
      membership: json['membership'] is Map
          ? GymAttendanceMembership.fromJson(
              Map<String, dynamic>.from(json['membership'] as Map))
          : null,
    );
  }
}

class GymAttendanceSessionItem {
  final dynamic id;
  final String? date;
  final String? punchInAt;
  final String? punchInTime;
  final String? punchOutAt;
  final String? punchOutTime;
  final int? durationMinutes;
  final String? durationFormatted;
  final bool isCompleted;
  final bool isLate;
  final int lateMinutes;

  GymAttendanceSessionItem({
    this.id,
    this.date,
    this.punchInAt,
    this.punchInTime,
    this.punchOutAt,
    this.punchOutTime,
    this.durationMinutes,
    this.durationFormatted,
    this.isCompleted = false,
    this.isLate = false,
    this.lateMinutes = 0,
  });

  factory GymAttendanceSessionItem.fromJson(Map<String, dynamic> json) {
    return GymAttendanceSessionItem(
      id: json['id'],
      date: json['date']?.toString(),
      punchInAt: json['punch_in_at']?.toString(),
      punchInTime: json['punch_in_time']?.toString(),
      punchOutAt: json['punch_out_at']?.toString(),
      punchOutTime: json['punch_out_time']?.toString(),
      durationMinutes: json['duration_minutes'] is num
          ? (json['duration_minutes'] as num).toInt()
          : int.tryParse(json['duration_minutes']?.toString() ?? ''),
      durationFormatted: json['duration_formatted']?.toString(),
      isCompleted: parseGymBool(json['is_completed']),
      isLate: parseGymBool(json['is_late']),
      lateMinutes: json['late_minutes'] is num
          ? (json['late_minutes'] as num).toInt()
          : int.tryParse(json['late_minutes']?.toString() ?? '0') ?? 0,
    );
  }
}

class GymAttendanceCustomer {
  final String? id;
  final String? name;
  final String? phone;
  final String? email;

  GymAttendanceCustomer({this.id, this.name, this.phone, this.email});

  factory GymAttendanceCustomer.fromJson(Map<String, dynamic> json) {
    return GymAttendanceCustomer(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

class GymAttendanceGym {
  final String? id;
  final String? title;
  final String? address;
  final String? city;
  final String? phone;
  final dynamic lat;
  final dynamic lng;

  GymAttendanceGym({
    this.id,
    this.title,
    this.address,
    this.city,
    this.phone,
    this.lat,
    this.lng,
  });

  factory GymAttendanceGym.fromJson(Map<String, dynamic> json) {
    return GymAttendanceGym(
      id: json['id']?.toString(),
      title: json['title']?.toString() ?? json['name']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      phone: json['phone']?.toString(),
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}

class GymAttendanceMembership {
  final String? id;
  final String? status;
  final String? expiresAt;

  GymAttendanceMembership({this.id, this.status, this.expiresAt});

  factory GymAttendanceMembership.fromJson(Map<String, dynamic> json) {
    return GymAttendanceMembership(
      id: json['id']?.toString(),
      status: json['status']?.toString(),
      expiresAt: json['expires_at']?.toString(),
    );
  }
}

class GymAttendancePunchResponse {
  final bool? status;
  final String? message;
  final GymAttendancePunchData? data;

  GymAttendancePunchResponse({this.status, this.message, this.data});

  factory GymAttendancePunchResponse.fromJson(Map<String, dynamic> json) {
    return GymAttendancePunchResponse(
      status: parseGymBool(json['status']),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? GymAttendancePunchData.fromJson(
              Map<String, dynamic>.from(json['data']))
          : null,
    );
  }
}

class GymAttendancePunchData {
  final bool? success;
  final int? code;
  final String? message;
  final dynamic attendanceId;
  final String? punchInAt;
  final String? punchInTime;
  final String? punchOutAt;
  final String? punchOutTime;
  final int? durationMinutes;
  final String? durationFormatted;
  final bool isReopened;
  final GymAttendanceGym? gym;

  GymAttendancePunchData({
    this.success,
    this.code,
    this.message,
    this.attendanceId,
    this.punchInAt,
    this.punchInTime,
    this.punchOutAt,
    this.punchOutTime,
    this.durationMinutes,
    this.durationFormatted,
    this.isReopened = false,
    this.gym,
  });

  factory GymAttendancePunchData.fromJson(Map<String, dynamic> json) {
    return GymAttendancePunchData(
      success: parseGymBool(json['success']),
      code: json['code'] is num
          ? (json['code'] as num).toInt()
          : int.tryParse(json['code']?.toString() ?? ''),
      message: json['message']?.toString(),
      attendanceId: json['attendance_id'] ?? json['id'],
      punchInAt: json['punch_in_at']?.toString(),
      punchInTime: json['punch_in_time']?.toString(),
      punchOutAt: json['punch_out_at']?.toString(),
      punchOutTime: json['punch_out_time']?.toString(),
      durationMinutes: json['duration_minutes'] is num
          ? (json['duration_minutes'] as num).toInt()
          : int.tryParse(json['duration_minutes']?.toString() ?? ''),
      durationFormatted: json['duration_formatted']?.toString(),
      isReopened: parseGymBool(json['is_reopened']),
      gym: json['gym'] is Map
          ? GymAttendanceGym.fromJson(
              Map<String, dynamic>.from(json['gym'] as Map))
          : null,
    );
  }
}

class GymAttendanceHistoryResponse {
  final bool? status;
  final String? message;
  final GymAttendanceHistoryData? data;

  GymAttendanceHistoryResponse({this.status, this.message, this.data});

  factory GymAttendanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    return GymAttendanceHistoryResponse(
      status: parseGymBool(json['status']),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? GymAttendanceHistoryData.fromJson(
              Map<String, dynamic>.from(json['data']))
          : null,
    );
  }
}

class GymAttendanceHistoryData {
  final GymAttendanceHistorySummary? summary;
  final GymAttendancePagination? pagination;
  final List<GymAttendanceLogItem> logs;

  GymAttendanceHistoryData({
    this.summary,
    this.pagination,
    this.logs = const [],
  });

  factory GymAttendanceHistoryData.fromJson(Map<String, dynamic> json) {
    var rawLogs = json['logs'];
    List<GymAttendanceLogItem> list = [];
    if (rawLogs is List) {
      list = rawLogs
          .map((e) => GymAttendanceLogItem.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return GymAttendanceHistoryData(
      summary: json['summary'] is Map
          ? GymAttendanceHistorySummary.fromJson(
              Map<String, dynamic>.from(json['summary'] as Map))
          : null,
      pagination: json['pagination'] is Map
          ? GymAttendancePagination.fromJson(
              Map<String, dynamic>.from(json['pagination'] as Map))
          : null,
      logs: list,
    );
  }
}

class GymAttendanceHistorySummary {
  final String? month;
  final String? monthLabel;
  final int totalDaysAttended;
  final int totalWorkoutMinutes;
  final String? totalWorkoutHoursFormatted;
  final int avgSessionMinutes;
  final int currentStreakDays;

  GymAttendanceHistorySummary({
    this.month,
    this.monthLabel,
    this.totalDaysAttended = 0,
    this.totalWorkoutMinutes = 0,
    this.totalWorkoutHoursFormatted,
    this.avgSessionMinutes = 0,
    this.currentStreakDays = 0,
  });

  factory GymAttendanceHistorySummary.fromJson(Map<String, dynamic> json) {
    return GymAttendanceHistorySummary(
      month: json['month']?.toString(),
      monthLabel: json['month_label']?.toString(),
      totalDaysAttended: json['total_days_attended'] is num
          ? (json['total_days_attended'] as num).toInt()
          : int.tryParse(json['total_days_attended']?.toString() ?? '0') ?? 0,
      totalWorkoutMinutes: json['total_workout_minutes'] is num
          ? (json['total_workout_minutes'] as num).toInt()
          : int.tryParse(json['total_workout_minutes']?.toString() ?? '0') ?? 0,
      totalWorkoutHoursFormatted:
          json['total_workout_hours_formatted']?.toString(),
      avgSessionMinutes: json['avg_session_minutes'] is num
          ? (json['avg_session_minutes'] as num).toInt()
          : int.tryParse(json['avg_session_minutes']?.toString() ?? '0') ?? 0,
      currentStreakDays: json['current_streak_days'] is num
          ? (json['current_streak_days'] as num).toInt()
          : int.tryParse(json['current_streak_days']?.toString() ?? '0') ?? 0,
    );
  }
}

class GymAttendancePagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  GymAttendancePagination({
    this.currentPage = 1,
    this.perPage = 20,
    this.total = 0,
    this.lastPage = 1,
  });

  factory GymAttendancePagination.fromJson(Map<String, dynamic> json) {
    return GymAttendancePagination(
      currentPage: json['current_page'] is num
          ? (json['current_page'] as num).toInt()
          : int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      perPage: json['per_page'] is num
          ? (json['per_page'] as num).toInt()
          : int.tryParse(json['per_page']?.toString() ?? '20') ?? 20,
      total: json['total'] is num
          ? (json['total'] as num).toInt()
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      lastPage: json['last_page'] is num
          ? (json['last_page'] as num).toInt()
          : int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
    );
  }
}

class GymAttendanceLogItem {
  final dynamic id;
  final String? date;
  final String? formattedDate;
  final String? punchInAt;
  final String? punchInTime;
  final String? punchOutAt;
  final String? punchOutTime;
  final int? durationMinutes;
  final String? durationFormatted;
  final bool isCompleted;
  final bool isLate;
  final int lateMinutes;
  final String? note;
  final GymAttendanceGym? gym;
  final dynamic shift;

  GymAttendanceLogItem({
    this.id,
    this.date,
    this.formattedDate,
    this.punchInAt,
    this.punchInTime,
    this.punchOutAt,
    this.punchOutTime,
    this.durationMinutes,
    this.durationFormatted,
    this.isCompleted = false,
    this.isLate = false,
    this.lateMinutes = 0,
    this.note,
    this.gym,
    this.shift,
  });

  factory GymAttendanceLogItem.fromJson(Map<String, dynamic> json) {
    return GymAttendanceLogItem(
      id: json['id'],
      date: json['date']?.toString(),
      formattedDate: json['formatted_date']?.toString(),
      punchInAt: json['punch_in_at']?.toString(),
      punchInTime: json['punch_in_time']?.toString(),
      punchOutAt: json['punch_out_at']?.toString(),
      punchOutTime: json['punch_out_time']?.toString(),
      durationMinutes: json['duration_minutes'] is num
          ? (json['duration_minutes'] as num).toInt()
          : int.tryParse(json['duration_minutes']?.toString() ?? ''),
      durationFormatted: json['duration_formatted']?.toString(),
      isCompleted: parseGymBool(json['is_completed']),
      isLate: parseGymBool(json['is_late']),
      lateMinutes: json['late_minutes'] is num
          ? (json['late_minutes'] as num).toInt()
          : int.tryParse(json['late_minutes']?.toString() ?? '0') ?? 0,
      note: json['note']?.toString(),
      gym: json['gym'] is Map
          ? GymAttendanceGym.fromJson(
              Map<String, dynamic>.from(json['gym'] as Map))
          : null,
      shift: json['shift'],
    );
  }
}
