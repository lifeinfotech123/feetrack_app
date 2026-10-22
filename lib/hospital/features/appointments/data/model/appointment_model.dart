class AppointmentModel {
  final int? id;
  final int? appUserId;
  final int? patientId;
  final String? appointmentNo;
  final String? doctorName;
  final int? doctorId;
  final Map<String, dynamic>? doctor;
  final Map<String, dynamic>? patient;
  final String? designation;
  final String? date;
  final String? time;
  final String? slot;
  final String? slotStartTime;
  final String? slotEndTime;
  final String? shift;
  final String? status;
  final String? imageUrl;
  final dynamic fees;
  final String? paymentMode;
  final String? paymentStatus;
  final String? appointmentPriority;
  final String? liveConsultation;
  final String? zoomJoinUrl;
  final String? zoomMeetingId;
  final String? zoomPassword;
  final String? message;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? createdAt;
  final Map<String, dynamic>? hospital;

  AppointmentModel({
    this.id,
    this.appUserId,
    this.patientId,
    this.appointmentNo,
    this.doctorName,
    this.doctorId,
    this.doctor,
    this.patient,
    this.designation,
    this.date,
    this.time,
    this.slot,
    this.slotStartTime,
    this.slotEndTime,
    this.shift,
    this.status,
    this.imageUrl,
    this.fees,
    this.paymentMode,
    this.paymentStatus,
    this.appointmentPriority,
    this.liveConsultation,
    this.zoomJoinUrl,
    this.zoomMeetingId,
    this.zoomPassword,
    this.message,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.createdAt,
    this.hospital,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final docMap = json['doctor'] is Map ? Map<String, dynamic>.from(json['doctor']) : null;
    final patMap = json['patient'] is Map ? Map<String, dynamic>.from(json['patient']) : null;
    final hospMap = json['hospital'] is Map ? Map<String, dynamic>.from(json['hospital']) : null;

    final docName = json['doctor_name']?.toString() ??
        docMap?['name']?.toString() ??
        json['doctor']?.toString();

    final qualification = docMap?['qualification']?.toString();
    final desig = json['designation']?.toString() ??
        qualification ??
        json['speciality']?.toString() ??
        (json['shift'] != null ? '${json['shift']} Shift' : 'Consultation');

    return AppointmentModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      appUserId: json['app_user_id'] != null ? int.tryParse(json['app_user_id'].toString()) : null,
      patientId: json['patient_id'] != null ? int.tryParse(json['patient_id'].toString()) : null,
      appointmentNo: json['appointment_no']?.toString() ??
          json['booking_id']?.toString() ??
          json['appointment_id']?.toString(),
      doctorName: docName,
      doctorId: json['doctor_id'] != null
          ? int.tryParse(json['doctor_id'].toString())
          : (docMap?['id'] != null ? int.tryParse(docMap!['id'].toString()) : null),
      doctor: docMap,
      patient: patMap,
      designation: desig,
      date: json['appointment_date']?.toString() ?? json['date']?.toString(),
      time: json['slot']?.toString() ?? json['time']?.toString(),
      slot: json['slot']?.toString(),
      slotStartTime: json['slot_start_time']?.toString(),
      slotEndTime: json['slot_end_time']?.toString(),
      shift: json['shift']?.toString(),
      status: json['status']?.toString() ?? 'Booked',
      imageUrl: json['image_url']?.toString() ?? json['doctor_image']?.toString(),
      fees: json['fees'],
      paymentMode: json['payment_mode']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      appointmentPriority: json['appointment_priority']?.toString(),
      liveConsultation: json['live_consultation']?.toString(),
      zoomJoinUrl: json['zoom_join_url']?.toString(),
      zoomMeetingId: json['zoom_meeting_id']?.toString(),
      zoomPassword: json['zoom_password']?.toString(),
      message: json['message']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      createdAt: json['created_at']?.toString(),
      hospital: hospMap,
    );
  }

  /// Formatted date in dd-MM-yyyy format
  String get formattedDate {
    if (date == null || date!.trim().isEmpty) return '';
    final cleaned = date!.trim();
    try {
      if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(cleaned)) {
        return cleaned;
      }
      final dt = DateTime.tryParse(cleaned);
      if (dt != null) {
        final d = dt.day.toString().padLeft(2, '0');
        final m = dt.month.toString().padLeft(2, '0');
        final y = dt.year.toString().padLeft(4, '0');
        return '$d-$m-$y';
      }
      final parts = cleaned.split(RegExp(r'[-/]'));
      if (parts.length >= 3) {
        if (parts[0].length == 4) {
          final y = parts[0];
          final m = parts[1].padLeft(2, '0');
          final d = parts[2].split(' ').first.padLeft(2, '0');
          return '$d-$m-$y';
        } else if (parts[2].length >= 4) {
          final d = parts[0].padLeft(2, '0');
          final m = parts[1].padLeft(2, '0');
          final y = parts[2].split(' ').first.substring(0, 4);
          return '$d-$m-$y';
        }
      }
    } catch (_) {}
    return cleaned;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'app_user_id': appUserId,
        'patient_id': patientId,
        'appointment_no': appointmentNo,
        'doctor_name': doctorName,
        'doctor_id': doctorId,
        'doctor': doctor,
        'patient': patient,
        'designation': designation,
        'appointment_date': date,
        'time': time,
        'slot': slot,
        'slot_start_time': slotStartTime,
        'slot_end_time': slotEndTime,
        'shift': shift,
        'status': status,
        'image_url': imageUrl,
        'fees': fees,
        'payment_mode': paymentMode,
        'payment_status': paymentStatus,
        'appointment_priority': appointmentPriority,
        'live_consultation': liveConsultation,
        'zoom_join_url': zoomJoinUrl,
        'zoom_meeting_id': zoomMeetingId,
        'zoom_password': zoomPassword,
        'message': message,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
        'created_at': createdAt,
        'hospital': hospital,
      };
}

class CreateAppointmentPayload {
  final String hospital;
  final String? hospitalDomain;
  final String? domain;
  final int doctorId;
  final String doctorName;
  final String appointmentDate;
  final String slot;
  final String shift;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String gender;
  final String paymentMode;
  final String serviceName;
  final String liveConsultation;
  final String message;
  final String alternateAddress;

  CreateAppointmentPayload({
    required this.hospital,
    this.hospitalDomain,
    this.domain,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentDate,
    required this.slot,
    required this.shift,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.gender = 'Male',
    this.paymentMode = 'Online',
    this.serviceName = 'OPD General Consultation',
    this.liveConsultation = 'No',
    this.message = 'Routine health checkup',
    this.alternateAddress = '',
  });

  Map<String, dynamic> toJson() => {
        'hospital': hospital,
        'hospital_domain': hospitalDomain ?? hospital,
        'domain': domain ?? hospitalDomain ?? hospital,
        'doctor_id': doctorId,
        'doctor_name': doctorName,
        'appointment_date': appointmentDate,
        'slot': slot,
        'shift': shift,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
        'gender': gender,
        'payment_mode': paymentMode,
        'service_name': serviceName,
        'live_consultation': liveConsultation,
        'message': message,
        'alternate_address': alternateAddress,
      };
}

class AppointmentBookingResponse {
  final bool status;
  final String? message;
  final Map<String, dynamic>? data;

  AppointmentBookingResponse({
    this.status = false,
    this.message,
    this.data,
  });

  factory AppointmentBookingResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentBookingResponse(
      status: json['status'] == true || json['status'] == 'true' || json['success'] == true,
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null,
    );
  }
}

class PaymentGatewayModel {
  final String id;
  final String name;
  final String slug;
  final bool active;
  final Map<String, dynamic>? credentials;

  PaymentGatewayModel({
    required this.id,
    required this.name,
    required this.slug,
    this.active = false,
    this.credentials,
  });

  factory PaymentGatewayModel.fromJson(Map<String, dynamic> json) {
    return PaymentGatewayModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      active: json['active'] == true || json['active'] == 1 || json['active'] == 'true',
      credentials: json['credentials'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['credentials'])
          : null,
    );
  }

  String? get keyId => credentials?['key_id']?.toString();
}

class VerifyPaymentResponse {
  final bool success;
  final String message;
  final dynamic data;

  VerifyPaymentResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory VerifyPaymentResponse.fromJson(Map<String, dynamic> json) {
    return VerifyPaymentResponse(
      success: json['status'] == true || json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'],
    );
  }
}
