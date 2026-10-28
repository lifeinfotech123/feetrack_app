import 'package:flutter_test/flutter_test.dart';
import 'package:vlr/hospital/features/online_consultation/data/live_consultation_model.dart';

void main() {
  test('parses live consultation and nested Zoom meeting response', () {
    final consultation = LiveConsultation.fromJson({
      'id': 87,
      'appointment_no': 'APT-0087',
      'appointment_date': '2026-10-23',
      'slot': '06:15 PM - 06:30 PM',
      'time_status': {'status_text': 'Upcoming'},
      'video_meeting': {
        'meeting_id': '1943283685',
        'password': '784944',
        'join_url': 'https://zoom.us/j/1943283685?pwd=784944',
        'can_join': true,
      },
      'doctor': {
        'name': 'Vishu Sharma',
        'full_name': 'Dr. Vishu Sharma',
        'specialization': 'Cardiologist',
        'photo': 'https://example.com/doctor.jpg',
      },
      'patient': {'name': null},
    });

    expect(consultation.id, 87);
    expect(consultation.appointmentNo, 'APT-0087');
    expect(consultation.formattedAppointmentDate, '23-10-2026');
    expect(consultation.timeStatus, 'Upcoming');
    expect(consultation.canJoin, isTrue);
    expect(consultation.joinUrl, 'https://zoom.us/j/1943283685?pwd=784944');
    expect(consultation.meetingId, '1943283685');
    expect(consultation.meetingPassword, '784944');
    expect(consultation.doctorName, 'Dr. Vishu Sharma');
    expect(consultation.doctorSpecialization, 'Cardiologist');
    expect(consultation.patientName, 'Patient');
  });

  test('parses false join permission and flat legacy Zoom keys', () {
    final consultation = LiveConsultation.fromJson({
      'id': '88',
      'zoom_meeting_id': '123456',
      'zoom_password': 'pass',
      'zoom_join_url': 'https://zoom.us/j/123456',
      'video_meeting': {'can_join': false},
    });

    expect(consultation.id, 88);
    expect(consultation.canJoin, isFalse);
    expect(consultation.meetingId, '123456');
    expect(consultation.meetingPassword, 'pass');
    expect(consultation.joinUrl, 'https://zoom.us/j/123456');
  });

  test('rejects consultation payload without an ID', () {
    expect(
      () => LiveConsultation.fromJson({}),
      throwsFormatException,
    );
  });
}
