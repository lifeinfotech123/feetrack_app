class LiveConsultation {
  final int id;
  final String appointmentNo;
  final String appointmentDate;
  final String slot;
  final String status;
  final String paymentStatus;
  final String timeStatus;
  final bool canJoin;
  final String? joinUrl;
  final String? meetingId;
  final String? meetingPassword;
  final String? message;
  final Map<String, dynamic> doctor;
  final Map<String, dynamic> patient;
  final Map<String, dynamic> hospital;

  const LiveConsultation({
    required this.id,
    required this.appointmentNo,
    required this.appointmentDate,
    required this.slot,
    required this.status,
    required this.paymentStatus,
    required this.timeStatus,
    required this.canJoin,
    required this.joinUrl,
    required this.meetingId,
    required this.meetingPassword,
    required this.message,
    required this.doctor,
    required this.patient,
    required this.hospital,
  });

  factory LiveConsultation.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse(json['id']?.toString() ?? '');
    if (id == null) {
      throw const FormatException('Consultation response is missing its id.');
    }

    final rawMeeting = json['video_meeting'];
    final meeting =
        rawMeeting is Map ? Map<String, dynamic>.from(rawMeeting) : const {};
    final rawTimeStatus = json['time_status'];
    final timeStatus = rawTimeStatus is Map
        ? Map<String, dynamic>.from(rawTimeStatus)
        : const <String, dynamic>{};

    Map<String, dynamic> readMap(String key) {
      final value = json[key];
      return value is Map ? Map<String, dynamic>.from(value) : {};
    }

    return LiveConsultation(
      id: id,
      appointmentNo: json['appointment_no']?.toString() ?? '',
      appointmentDate: json['appointment_date']?.toString() ?? '',
      slot: json['slot']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      timeStatus: timeStatus['status_text']?.toString() ?? '',
      canJoin: meeting['can_join'] == true ||
          meeting['can_join']?.toString().toLowerCase() == 'true' ||
          meeting['can_join']?.toString() == '1',
      joinUrl: (meeting['join_url'] ?? json['zoom_join_url'])?.toString(),
      meetingId:
          (meeting['meeting_id'] ?? json['zoom_meeting_id'])?.toString(),
      meetingPassword:
          (meeting['password'] ?? json['zoom_password'])?.toString(),
      message: json['message']?.toString(),
      doctor: readMap('doctor'),
      patient: readMap('patient'),
      hospital: readMap('hospital'),
    );
  }

  String get doctorName =>
      doctor['full_name']?.toString() ??
      doctor['name']?.toString() ??
      'Doctor';

  String get doctorSpecialization =>
      doctor['specialization']?.toString() ?? '';

  String get doctorPhoto =>
      (doctor['photo_url'] ?? doctor['photo'])?.toString() ?? '';

  String get patientName => patient['name']?.toString() ?? 'Patient';

  String get formattedAppointmentDate {
    final parsedDate = DateTime.tryParse(appointmentDate);
    if (parsedDate == null) return appointmentDate;

    final day = parsedDate.day.toString().padLeft(2, '0');
    final month = parsedDate.month.toString().padLeft(2, '0');
    return '$day-$month-${parsedDate.year}';
  }
}
