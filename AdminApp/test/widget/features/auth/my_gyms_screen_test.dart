import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gymapp_admin/core/theme/app_theme.dart';
import 'package:gymapp_admin/features/auth/domain/gym_membership.dart';
import 'package:gymapp_admin/features/auth/presentation/my_gyms_providers.dart';
import 'package:gymapp_admin/features/auth/presentation/my_gyms_screen.dart';

GymMembership _membership(int id, String gym, String role) => GymMembership(
  id: id,
  gymId: id,
  gymName: gym,
  roleName: role,
  roleLabel: role,
  memberId: null,
);

void main() {
  // Regression: with the app theme's full-width buttons, the Enter/Accept
  // buttons inside each card's Row threw "BoxConstraints forces an
  // infinite width" and the picker rendered blank for multi-gym logins.
  testWidgets('lists every gym with an Enter button and pending invites', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myGymsProvider.overrideWith(
            (ref) async => [
              _membership(1, 'Demo Fitness Club', 'member'),
              _membership(12, 'Iron Paradise', 'trainer'),
            ],
          ),
          pendingGymsProvider.overrideWith(
            (ref) async => [_membership(20, 'Pulse Gym', 'member')],
          ),
        ],
        child: MaterialApp(theme: AppTheme.dark(), home: const MyGymsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Demo Fitness Club'), findsOneWidget);
    expect(find.text('Iron Paradise'), findsOneWidget);
    expect(find.text('Enter'), findsNWidgets(2));
    expect(find.text('Accept'), findsOneWidget);
  });
}
