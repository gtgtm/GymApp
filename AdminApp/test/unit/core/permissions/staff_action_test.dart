import 'package:flutter_test/flutter_test.dart';

import 'package:gymapp_admin/core/permissions/nav_permissions.dart';

void main() {
  group('canPerform', () {
    test('admin and receptionist can add and renew members', () {
      for (final role in ['admin', 'receptionist']) {
        expect(canPerform(role, StaffAction.createMember), isTrue);
        expect(canPerform(role, StaffAction.renewMembership), isTrue);
      }
    });

    test('trainer can view members but not add or renew them', () {
      expect(canAccessNav('trainer', NavKey.members), isTrue);
      expect(canPerform('trainer', StaffAction.createMember), isFalse);
      expect(canPerform('trainer', StaffAction.renewMembership), isFalse);
    });

    test('no acting role can do nothing', () {
      expect(canPerform(null, StaffAction.createMember), isFalse);
    });
  });
}
