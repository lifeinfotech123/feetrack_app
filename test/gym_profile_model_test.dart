import 'package:flutter_test/flutter_test.dart';
import 'package:vlr/data/models/gym_attendance_model.dart';
import 'package:vlr/data/models/category_model/staff_model.dart';
import 'package:vlr/data/models/user_model.dart';

void main() {
  test('maps authenticated profile response user data for Gym Profile', () {
    final Map<String, dynamic> response = {
      'status': true,
      'message': 'User profile retrieved successfully.',
      'data': {
        'user': {
          'id': 3,
          'name': 'Arjun Kumar',
          'first_name': 'Arjun',
          'last_name': 'Kumar',
          'email': 'arjun12@gmail.com',
          'phone': '7054343213',
          'country_code': '+91',
          'gender': 'Male',
          'date_of_birth': null,
          'blood_group': null,
          'avatar': null,
          'address': null,
          'city': null,
          'state': null,
          'pincode': null,
          'country': 'India',
          'status': 'active',
          'preferred_category': null,
          'email_verified_at': null,
          'phone_verified_at': null,
          'created_at': '2026-10-11T07:42:21.000000Z',
        },
      },
    };

    final user = UserModel.fromJson(response['data']!['user']!);

    expect(user.id, '3');
    expect(user.name, 'Arjun Kumar');
    expect(user.firstName, 'Arjun');
    expect(user.lastName, 'Kumar');
    expect(user.email, 'arjun12@gmail.com');
    expect(user.mobile, '7054343213');
    expect(user.countryCode, '+91');
    expect(user.gender, 'Male');
    expect(user.dateOfBirth, isNull);
    expect(user.country, 'India');
    expect(user.status, 'active');
    expect(user.emailVerifiedAt, isFalse);
    expect(user.mobileVerifiedAt, isFalse);
    expect(user.createdAt, DateTime.parse('2026-10-11T07:42:21.000000Z'));
  });

  test('parses bool-like gym API values from strings and numbers', () {
    final user = UserModel.fromJson({
      'id': '3',
      'email_verified_at': '0',
      'phone_verified_at': '1',
      'country_code': '+91',
    });

    expect(user.emailVerifiedAt, isFalse);
    expect(user.mobileVerifiedAt, isTrue);

    final attendance = GymAttendanceStatusData.fromJson({
      'can_punch_in': '1',
      'can_punch_out': '0',
      'is_completed': 'true',
      'is_late': 'false',
      'membership': {
        'id': 'gym-membership-123',
        'status': 'active',
      },
    });

    expect(attendance.canPunchIn, isTrue);
    expect(attendance.canPunchOut, isFalse);
    expect(attendance.currentSession, isNull);
    expect(attendance.todaySessions, isEmpty);
    expect(attendance.membership?.id, 'gym-membership-123');
  });

  test('parses gym attendance history response', () {
    final history = GymAttendanceHistoryData.fromJson({
      'summary': {
        'month': '2026-10',
        'month_label': 'October 2026',
        'total_days_attended': 1,
        'total_workout_minutes': 1,
        'total_workout_hours_formatted': '0h 1m',
        'avg_session_minutes': 1,
        'current_streak_days': 1,
      },
      'pagination': {
        'current_page': 1,
        'per_page': 20,
        'total': 1,
        'last_page': 1,
      },
      'logs': [
        {
          'id': 2,
          'date': '2026-10-16',
          'formatted_date': 'Fri, 16 Oct 2026',
          'punch_in_at': '2026-10-16 13:14:53',
          'punch_in_time': '01:14 PM',
          'punch_out_at': '2026-10-16 13:17:06',
          'punch_out_time': '01:17 PM',
          'duration_minutes': 1,
          'duration_formatted': '1 mins',
          'is_completed': true,
          'is_late': false,
          'late_minutes': 0,
          'note': 'Chest and Triceps day',
          'gym': {
            'id': '23ebdb04-6502-4afd-b2fe-20075b994513',
            'title': 'Diwali offer',
            'city': 'Lucknow',
          },
          'shift': null,
        },
      ],
    });

    expect(history.summary?.monthLabel, 'October 2026');
    expect(history.summary?.totalWorkoutMinutes, 1);
    expect(history.pagination?.total, 1);
    expect(history.logs, hasLength(1));
    expect(history.logs.single.isCompleted, isTrue);
    expect(history.logs.single.punchOutTime, '01:17 PM');
    expect(history.logs.single.gym?.city, 'Lucknow');
  });

  test('parses trainer fields from the gym trainers API response', () {
    final response = {
      'status': true,
      'data': [
        {
          'id': '50',
          'name': 'Shambhu',
          'specialization': 'train body',
          'experience_years': 7,
          'experience_label': '7+ Years Experience',
          'description': 'good',
          'photo':
              'https://vgym.orderknow.com/storage/trainers/trainer-photo.jpg',
          'gym': {
            'id': 'ba528f82-08d2-456b-b62d-71a195cd3f48',
            'title': 'zoomgym',
          },
        },
      ],
    };
    final trainers = response['data'] as List;
    final trainer = StaffModel.fromJson(
      Map<String, dynamic>.from(trainers.single as Map),
    );

    expect(trainer.id, 50);
    expect(trainer.name, 'Shambhu');
    expect(trainer.specialization, 'train body');
    expect(trainer.experienceYears, '7');
    expect(
      trainer.photoUrl,
      'https://vgym.orderknow.com/storage/trainers/trainer-photo.jpg',
    );
  });
}
