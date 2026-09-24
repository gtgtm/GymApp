import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gymapp_admin/core/router/staff_bottom_bar.dart';

Future<void> _pumpBar(WidgetTester tester, String role) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        bottomNavigationBar: StaffBottomBar(
          location: '/dashboard',
          roleName: role,
        ),
      ),
    ),
  );
}

List<String> _labelsInOrder(WidgetTester tester) {
  const labels = ['Home', 'Members', 'Check-in', 'Billing', 'More'];
  final found = labels.where((label) => find.text(label).evaluate().isNotEmpty);
  return found.toList()..sort(
    (a, b) => tester
        .getCenter(find.text(a))
        .dx
        .compareTo(tester.getCenter(find.text(b)).dx),
  );
}

void main() {
  testWidgets('trainer gets Home | Check-in | Members with no More tab', (
    tester,
  ) async {
    await _pumpBar(tester, 'trainer');

    expect(_labelsInOrder(tester), ['Home', 'Check-in', 'Members']);
  });

  testWidgets('admin gets Billing and More with Check-in centred', (
    tester,
  ) async {
    await _pumpBar(tester, 'admin');

    expect(_labelsInOrder(tester), [
      'Home',
      'Members',
      'Check-in',
      'Billing',
      'More',
    ]);
  });

  testWidgets('receptionist keeps More for enquiries and trials', (
    tester,
  ) async {
    await _pumpBar(tester, 'receptionist');

    expect(_labelsInOrder(tester), contains('More'));
    expect(_labelsInOrder(tester)[2], 'Check-in');
  });
}
