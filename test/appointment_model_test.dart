import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlr/hospital/features/appointments/data/model/appointment_model.dart';
import 'package:vlr/hospital/features/appointments/data/repositories/appointment_repo.dart';
import 'package:vlr/hospital/features/doctor/data/repositories/doctor_repo.dart';
import 'package:vlr/hospital/features/doctor/logics/doctor_controller.dart';
import 'package:vlr/services/constants.dart';

void main() {
  test('reads doctor image and profile from appointments API payload', () {
    final appointment = AppointmentModel.fromJson({
      'id': 42,
      'doctor': {
        'id': 7,
        'name': 'Dr. Asha Sharma',
        'photo': '/uploads/doctors/asha.jpg',
        'qualification': 'MBBS, MD',
        'specialist': {'name': 'Cardiology'},
        'work_experience': '12 years',
        'phone': '9876543210',
      },
      'hospital': {'domain_name': 'usha'},
    });

    expect(appointment.imageUrl, '/uploads/doctors/asha.jpg');
    expect(appointment.doctorName, 'Dr. Asha Sharma');
    expect(appointment.designation, 'MBBS, MD');
    expect(appointment.doctor?['specialist'], {'name': 'Cardiology'});
    expect(appointment.doctor?['work_experience'], '12 years');
    expect(appointment.doctor?['phone'], '9876543210');
    expect(appointment.doctorId, 7);
    expect(appointment.hospitalDomain, 'usha');
  });

  test('keeps hospital domain to distinguish doctors with matching IDs', () {
    final firstHospitalAppointment = AppointmentModel.fromJson({
      'id': 100,
      'doctor_id': 7,
      'hospital': {'domain': 'usha'},
    });
    final secondHospitalAppointment = AppointmentModel.fromJson({
      'id': 101,
      'doctor_id': 7,
      'hospital': {'domain': 'city-care'},
    });

    expect(
        firstHospitalAppointment.doctorId, secondHospitalAppointment.doctorId);
    expect(firstHospitalAppointment.hospitalDomain, 'usha');
    expect(secondHospitalAppointment.hospitalDomain, 'city-care');
  });

  test('cached doctor lookup matches both ID and hospital domain', () {
    final controller = DoctorController(doctorRepo: DoctorRepo());
    controller.rawDoctors.addAll([
      {
        'id': 7,
        'name': 'Dr Vishu Sharma',
        'hospital': {'domain_name': 'usha'},
      },
      {
        'id': 7,
        'name': 'Dr Ajju Sharma',
        'hospital': {'domain': 'city-care'},
      },
    ]);

    final ushaDoctor = controller.findDoctorForHospital(
      id: 7,
      hospitalDomain: 'usha',
    );
    final cityCareDoctor = controller.findDoctorForHospital(
      id: 7,
      hospitalDomain: 'city-care',
    );

    expect(ushaDoctor?.name, 'Dr Vishu Sharma');
    expect(cityCareDoctor?.name, 'Dr Ajju Sharma');
  });

  test('doctor detail request sends id and domain_name in GET JSON body',
      () async {
    SharedPreferences.setMockInitialValues({});
    http.Request? capturedRequest;
    final repo = DoctorRepo(
      httpClient: MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'status': true,
            'data': {'id': 66, 'name': 'Dr Vishu Sharma'},
          }),
          200,
        );
      }),
    );

    final response = await repo.fetchDoctorById(
      66,
      hospitalDomain: 'usha',
    );

    expect(response['status'], isTrue);
    expect(capturedRequest?.method, 'GET');
    expect(capturedRequest?.url.path, endsWith('/v1/hospital/doctors/66'));
    expect(
      jsonDecode(capturedRequest!.body),
      {'id': 66, 'domain_name': 'usha'},
    );
  });

  test('appointment detail request sends domain in GET JSON body', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.token: 'Bearer test-token',
    });
    http.Request? capturedRequest;
    final repo = AppointmentRepo(
      httpClient: MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'status': true,
            'data': {'id': 66},
          }),
          200,
        );
      }),
    );

    final response = await repo.getMyAppointmentDetail(
      66,
      hospitalDomain: 'akhospital',
    );

    expect(response['status'], isTrue);
    expect(capturedRequest?.method, 'GET');
    expect(
      capturedRequest?.url.path,
      endsWith('/v1/hospital/my-appointments/66'),
    );
    expect(capturedRequest?.headers['Authorization'], 'Bearer test-token');
    expect(
      jsonDecode(capturedRequest!.body),
      {'domain': 'akhospital'},
    );
  });
}
