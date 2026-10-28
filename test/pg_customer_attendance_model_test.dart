import 'package:flutter_test/flutter_test.dart';
import 'package:vlr/data/models/rooom/pg_customer_attendance_model.dart';

void main() {
  test('attendance state reflects punch-in then punch-out response times', () {
    final initial = PgCustomerAttendanceData.fromJson({
      'stats': {
        'today_punch_in': '2026-10-24 10:22:13',
      },
    });

    expect(initial.stats?.isPunchedIn, isTrue);
    expect(initial.stats?.isCompleted, isFalse);

    final punchedOut = initial.copyWith(
      stats: initial.stats!.copyWith(
        todayPunchIn: '2026-10-24 10:22:13',
        todayPunchOut: '2026-10-24 10:37:28',
      ),
    );

    expect(punchedOut.stats?.isPunchedIn, isFalse);
    expect(punchedOut.stats?.isCompleted, isTrue);
    expect(punchedOut.stats?.todayPunchOut, '2026-10-24 10:37:28');
  });
}
