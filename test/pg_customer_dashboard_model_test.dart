import 'package:flutter_test/flutter_test.dart';
import 'package:vlr/data/models/rooom/pg_customer_dashboard_model.dart';
import 'package:vlr/services/constants.dart';

void main() {
  test('PG room booking uses the v1 bookings endpoint', () {
    expect(AppConstants.pgBookings, 'v1/pg/bookings');
  });

  test('parses dashboard values returned by the customer API', () {
    final dashboard = PgCustomerDashboardData.fromJson({
      'customer': {
        'name': 'Asha Patel',
        'email': 'asha@example.com',
        'phone': '9876543210',
      },
      'header': {
        'unread_notifications_count': 2,
      },
      'metrics': {
        'scheduled_visits': 3,
        'total_bookings': 5,
        'active_subscriptions': 1,
        'total_spent': 12500,
      },
    });

    expect(dashboard.customer?.name, 'Asha Patel');
    expect(dashboard.header?.unreadNotificationsCount, 2);
    expect(dashboard.metrics?.scheduledVisits, 3);
    expect(dashboard.metrics?.totalBookings, 5);
    expect(dashboard.metrics?.activeSubscriptions, 1);
    expect(dashboard.metrics?.totalSpent, 12500);
  });

  test('does not invent customer metrics or profile status when omitted', () {
    final dashboard = PgCustomerDashboardData.fromJson({
      'customer': {},
      'header': {},
      'metrics': {},
    });
    final profile = PgCustomerProfileModel.fromJson({});

    expect(dashboard.header?.unreadNotificationsCount, isNull);
    expect(dashboard.metrics?.scheduledVisits, isNull);
    expect(dashboard.metrics?.totalBookings, isNull);
    expect(dashboard.metrics?.activeSubscriptions, isNull);
    expect(dashboard.metrics?.totalSpent, isNull);
    expect(profile.status, isNull);
    expect(profile.country, isNull);
  });
}
