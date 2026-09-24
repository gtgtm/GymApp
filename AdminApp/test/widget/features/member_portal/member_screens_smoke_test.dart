import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gymapp_admin/core/theme/app_theme.dart';
import 'package:gymapp_admin/features/auth/domain/gym_membership.dart';
import 'package:gymapp_admin/features/auth/domain/staff_user.dart';
import 'package:gymapp_admin/features/auth/presentation/auth_controller.dart';
import 'package:gymapp_admin/features/member_portal/domain/member_portal_models.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_home_screen.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_notifications_screen.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_plan_screens.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_portal_providers.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_profile_screen.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_progress_screen.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_qr_screen.dart';

/// Renders every member screen at phone size with realistic data, so a
/// layout exception (overflow, unbounded width) fails the test instead of
/// shipping. Data mirrors the live demo member's /me/* payloads.

const _member = StaffUser(
  id: 4,
  name: 'Vikas Kumar',
  email: 'member@demofitness.test',
  roleName: 'member',
  memberships: [
    GymMembership(
      id: 1,
      gymId: 1,
      gymName: 'Demo Fitness Club',
      roleName: 'member',
      roleLabel: 'Member',
      memberId: 1,
    ),
  ],
);

class _FakeAuth extends AuthController {
  @override
  Future<StaffUser?> build() async => _member;
}

final _today = DateTime.now();
String _day(int offset) =>
    _today.add(Duration(days: offset)).toIso8601String().substring(0, 10);

final _membership = MembershipDetails.fromJson({
  'current': {
    'id': 1,
    'start_date': _day(-20),
    'end_date': _day(4),
    'status': 'active',
  },
  'history': [
    {
      'id': 1,
      'start_date': _day(-20),
      'end_date': _day(4),
      'status': 'active',
      'plan': {'name': 'Monthly'},
    },
  ],
  'expiry_bucket': 'orange',
});

final _profile = MemberProfile.fromJson({
  'id': 1,
  'member_code': 'MEM-DEMO1',
  'full_name': 'Vikas Kumar',
  'mobile': '9800000001',
  'status': 'active',
  'expiry_bucket': 'orange',
  'joining_date': '2026-07-20',
  'trainer': {'id': 1, 'name': 'Rohan Mehta'},
});

final _attendance = [
  for (var i = 0; i < 3; i++)
    MemberAttendanceRecord.fromJson({
      'date': _day(-i),
      'status': 'present',
      'check_in_time': '07:1$i:00',
    }),
];

final _workout = PortalWorkoutPlan.fromJson({
  'id': 1,
  'name': 'Beginner Strength Split',
  'status': 'active',
  'trainer': {
    'user': {'name': 'Rohan Mehta'},
  },
  'exercises': [
    {
      'day_number': 1,
      'day_label': 'Push',
      'exercise_name': 'Barbell Bench Press',
      'muscle_group': 'Chest',
      'sets': 4,
      'reps': '8-10',
      'weight_kg': '40.00',
    },
    {'day_number': 2, 'day_label': 'Pull', 'exercise_name': 'Deadlift'},
  ],
});

final _diet = PortalDietPlan.fromJson({
  'id': 1,
  'name': 'Standard Cutting Plan',
  'status': 'active',
  'meals': [
    {
      'meal_slot': 'breakfast',
      'food_item': 'Oats with whey and banana',
      'quantity': '1 bowl',
      'calories': '420.00',
    },
  ],
  'daily_summary': {
    'calories': 1850,
    'protein_g': 140,
    'carbs_g': 180,
    'fat_g': 55,
  },
});

final _progress = PortalProgress.fromJson({
  'measurements': [
    for (var i = 0; i < 4; i++)
      {
        'recorded_date': _day(-30 * (4 - i)),
        'weight_kg': '${76 - i}.50',
        'bmi': '24.10',
      },
  ],
  'photos': <dynamic>[],
});

final _overrides = [
  authControllerProvider.overrideWith(_FakeAuth.new),
  myMembershipProvider.overrideWith((ref) async => _membership),
  myProfileProvider.overrideWith((ref) async => _profile),
  myAttendanceProvider.overrideWith((ref) async => _attendance),
  myWorkoutPlansProvider.overrideWith((ref) async => [_workout]),
  myDietPlansProvider.overrideWith((ref) async => [_diet]),
  myProgressProvider.overrideWith((ref) async => _progress),
  myQrCodeProvider.overrideWith(
    (ref) async =>
        const MemberQrCode(qrToken: 'DEMO-QR-1', memberCode: 'MEM-DEMO1'),
  ),
  myPaymentsProvider.overrideWith(
    (ref) async => [
      MemberPaymentRecord(
        receiptNumber: 'RCPT-DEMO-0001',
        amount: 1700,
        method: 'bank_transfer',
        paidAt: _today,
      ),
    ],
  ),
  myNotificationsProvider.overrideWith(
    (ref) async => [
      MemberNotification(
        id: 1,
        title: 'Your membership expires in 4 days',
        body: 'Renew to keep your access.',
        createdAt: _today,
      ),
    ],
  ),
];

Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrides,
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(body: screen),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home shows days left, plan and recent visits', (tester) async {
    await _pump(tester, const MemberHomeScreen());

    expect(find.text('4 days left'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Hi, Vikas'), findsOneWidget);
    expect(find.text('Request renewal'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('QR screen shows the member code', (tester) async {
    await _pump(tester, const MemberQrScreen());

    expect(find.text('MEM-DEMO1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('workout groups exercises by day', (tester) async {
    await _pump(tester, const MemberWorkoutScreen());

    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(find.text('4 sets × 8-10 @ 40kg'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('diet shows daily totals and meals', (tester) async {
    await _pump(tester, const MemberDietScreen());

    expect(find.text('1850'), findsOneWidget);
    expect(find.text('Oats with whey and banana'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('progress, profile and notifications render', (tester) async {
    await _pump(tester, const MemberProgressScreen());
    expect(find.text('73.5 kg'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pump(tester, const MemberProfileScreen());
    expect(find.text('RCPT-DEMO-0001'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pump(tester, const MemberNotificationsScreen());
    expect(find.text('Your membership expires in 4 days'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
