import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gymapp_member/main.dart';

void main() {
  // flutter_secure_storage talks to the platform over a MethodChannel that
  // has no real implementation in the widget-test harness. Without this
  // mock, the read() call in AuthController.build() awaits forever and
  // pumpAndSettle times out.
  const secureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      secureStorageChannel,
      (call) async => call.method == 'read' ? null : <String, String>{},
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      secureStorageChannel,
      null,
    );
  });

  testWidgets('App boots to the login screen when logged out', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GymAppMember()));
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
  });
}
