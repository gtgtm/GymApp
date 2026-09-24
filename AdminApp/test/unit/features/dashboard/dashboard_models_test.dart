import 'package:flutter_test/flutter_test.dart';

import 'package:gymapp_admin/features/dashboard/domain/dashboard_models.dart';
import 'package:gymapp_admin/features/dashboard/presentation/widgets/dashboard_format.dart';

Map<String, dynamic> _membership(int id, String endDate) => {
  'id': id,
  'member_id': id * 10,
  'end_date': endDate,
  'member': {'id': id * 10, 'full_name': 'Member $id'},
};

void main() {
  group('RenewalDue', () {
    test('parses the calendar date from a UTC-midnight timestamp', () {
      final renewal = RenewalDue.fromJson(
        _membership(1, '2026-10-13T00:00:00.000000Z'),
      );

      expect(renewal.endDate, DateTime(2026, 10, 13));
      expect(renewal.memberName, 'Member 1');
      expect(renewal.memberId, 10);
    });

    test('daysRemaining ignores the time of day', () {
      final renewal = RenewalDue.fromJson(_membership(1, '2026-09-27'));

      expect(renewal.daysRemaining(DateTime(2026, 9, 24, 23, 59)), 3);
      expect(renewal.daysRemaining(DateTime(2026, 9, 27, 8)), 0);
      expect(renewal.daysRemaining(DateTime(2026, 9, 29)), -2);
    });
  });

  group('DashboardData', () {
    test('flattens every expiry bucket into one list sorted by end date', () {
      final data = DashboardData.fromJson({
        'summary': <String, dynamic>{},
        'expiring': {
          'green': [_membership(1, '2026-12-01')],
          'red': [_membership(2, '2026-09-01')],
          'orange': [_membership(3, '2026-09-26')],
        },
      });

      expect(data.renewals.map((r) => r.membershipId), [2, 3, 1]);
    });

    test('tolerates a missing expiring key', () {
      final data = DashboardData.fromJson({'summary': <String, dynamic>{}});

      expect(data.renewals, isEmpty);
    });
  });

  group('dashboard formatting', () {
    test('formatRupees uses Indian grouping without paise', () {
      expect(formatRupees(14998), '₹14,998');
      expect(formatRupees(1234567), '₹12,34,567');
      expect(formatRupees(0), '₹0');
    });

    test('initialsOf takes up to two initials', () {
      expect(initialsOf('shashank kumar'), 'SK');
      expect(initialsOf('Aarav'), 'A');
      expect(initialsOf('  '), '?');
    });

    test('dueLabel describes today, future and overdue', () {
      expect(dueLabel(0), 'Due today');
      expect(dueLabel(1), 'Due tomorrow');
      expect(dueLabel(3), 'Due in 3 days');
      expect(dueLabel(-1), 'Overdue by 1 day');
      expect(dueLabel(-4), 'Overdue by 4 days');
    });
  });
}
