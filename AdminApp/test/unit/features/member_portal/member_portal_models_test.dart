import 'package:flutter_test/flutter_test.dart';

import 'package:gymapp_admin/core/permissions/nav_permissions.dart';
import 'package:gymapp_admin/features/member_portal/domain/member_portal_models.dart';
import 'package:gymapp_admin/features/members/domain/member_models.dart';

// Payload shapes below are trimmed copies of live /me/* responses.
void main() {
  group('MembershipDetails', () {
    test('fills the current plan name from the matching history row', () {
      final details = MembershipDetails.fromJson({
        'current': {
          'id': 7,
          'start_date': '2026-09-13T00:00:00.000000Z',
          'end_date': '2026-10-13T00:00:00.000000Z',
          'status': 'active',
        },
        'history': [
          {
            'id': 7,
            'start_date': '2026-09-13T00:00:00.000000Z',
            'end_date': '2026-10-13T00:00:00.000000Z',
            'status': 'active',
            'plan': {'name': 'Monthly'},
          },
        ],
        'expiry_bucket': 'green',
      });

      expect(details.current?.planName, 'Monthly');
      expect(details.current?.endDate, DateTime(2026, 10, 13));
      expect(details.expiryBucket, ExpiryBucket.green);
    });

    test('daysRemaining counts calendar days from today', () {
      final period = MembershipPeriod.fromJson({
        'id': 1,
        'start_date': '2026-09-01',
        'end_date': '2026-09-30',
        'status': 'active',
      });

      expect(period.daysRemaining(DateTime(2026, 9, 24, 22)), 6);
      expect(period.daysRemaining(DateTime(2026, 10, 2)), -2);
    });

    test('handles a member with no membership', () {
      final details = MembershipDetails.fromJson({
        'current': null,
        'history': <dynamic>[],
        'expiry_bucket': 'red',
      });

      expect(details.current, isNull);
      expect(details.expiryBucket, ExpiryBucket.red);
    });
  });

  test('PortalProgress parses photos by photo_path and sorts oldest first', () {
    final progress = PortalProgress.fromJson({
      'measurements': [
        {'recorded_date': '2026-09-10', 'weight_kg': '71.50'},
        {'recorded_date': '2026-08-10', 'weight_kg': '74.00', 'bmi': null},
      ],
      'photos': [
        {
          'photo_path': 'demo/progress-photos/member-1-1.jpg',
          'type': 'progress',
          'taken_on': '2026-09-16T00:00:00.000000Z',
        },
      ],
    });

    expect(progress.measurements.map((m) => m.weightKg), [74.0, 71.5]);
    expect(progress.photoCount, 1);
  });

  test('PortalWorkoutPlan groups exercises by day with the trainer name', () {
    final plan = PortalWorkoutPlan.fromJson({
      'id': 1,
      'name': 'Beginner Strength Split',
      'status': 'active',
      'trainer': {
        'user': {'name': 'Rohan'},
      },
      'exercises': [
        {'day_number': 2, 'exercise_name': 'Squat', 'sets': 3, 'reps': '8'},
        {
          'day_number': 1,
          'exercise_name': 'Bench',
          'sets': 3,
          'reps': '10',
          'weight_kg': '40.00',
        },
        {'day_number': 1, 'exercise_name': 'Row'},
      ],
    });

    expect(plan.trainerName, 'Rohan');
    expect(plan.days.map((d) => d.$1), [1, 2]);
    expect(plan.days.first.$2.map((e) => e.exerciseName), ['Bench', 'Row']);
    expect(plan.days.first.$2.first.prescription, '3 sets × 10 @ 40kg');
  });

  test('PortalDietPlan reads string macros and tolerates missing summary', () {
    final plan = PortalDietPlan.fromJson({
      'id': 1,
      'name': 'Cutting',
      'status': 'active',
      'meals': [
        {'meal_slot': 'breakfast', 'food_item': 'Oats', 'calories': '350.00'},
      ],
    });

    expect(plan.meals.single.calories, 350);
    expect(plan.meals.single.slotLabel, 'Breakfast');
    expect(plan.dailyTotals.calories, 0);
  });

  group('app roles', () {
    test('members and staff can use the app; super_admin cannot', () {
      expect(appRoleNames, containsAll(['admin', 'trainer', 'member']));
      expect(appRoleNames, isNot(contains('super_admin')));
    });

    test('isMemberRole only matches the member role', () {
      expect(isMemberRole('member'), isTrue);
      expect(isMemberRole('trainer'), isFalse);
      expect(isMemberRole(null), isFalse);
    });

    test('a member has no staff nav', () {
      for (final key in NavKey.values) {
        expect(canAccessNav('member', key), isFalse);
      }
    });
  });
}
