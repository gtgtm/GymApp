import 'package:flutter_test/flutter_test.dart';
import 'package:gymapp_admin/features/auth/domain/gym_membership.dart';
import 'package:gymapp_admin/features/auth/domain/staff_user.dart';

void main() {
  group('GymMembership.fromJson', () {
    test('parses all fields from the login/me response shape', () {
      final membership = GymMembership.fromJson({
        'id': 15,
        'gym_id': 12,
        'gym_name': 'Iron Paradise',
        'role': 'trainer',
        'role_label': 'Trainer',
        'member_id': null,
      });

      expect(membership.id, 15);
      expect(membership.gymId, 12);
      expect(membership.gymName, 'Iron Paradise');
      expect(membership.roleName, 'trainer');
      expect(membership.roleLabel, 'Trainer');
      expect(membership.memberId, isNull);
    });

    test('defaults missing gym_name/role fields to empty strings', () {
      final membership = GymMembership.fromJson({'id': 1, 'gym_id': 1});

      expect(membership.gymName, '');
      expect(membership.roleName, '');
      expect(membership.roleLabel, '');
    });
  });

  group('StaffUser', () {
    StaffUser userWith(List<GymMembership> memberships, {String role = ''}) {
      return StaffUser(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        roleName: role,
        memberships: memberships,
      );
    }

    const gymA = GymMembership(
      id: 1,
      gymId: 1,
      gymName: 'Gym A',
      roleName: 'admin',
      roleLabel: 'Admin',
      memberId: null,
    );
    const gymB = GymMembership(
      id: 2,
      gymId: 2,
      gymName: 'Gym B',
      roleName: 'trainer',
      roleLabel: 'Trainer',
      memberId: null,
    );

    test('isSuperAdmin is true only for the super_admin role', () {
      expect(userWith([], role: 'super_admin').isSuperAdmin, isTrue);
      expect(userWith([gymA], role: 'admin').isSuperAdmin, isFalse);
    });

    test('requiresGymSelection is false with 0 or 1 memberships', () {
      expect(userWith([]).requiresGymSelection, isFalse);
      expect(userWith([gymA]).requiresGymSelection, isFalse);
    });

    test('requiresGymSelection is true with 2+ memberships', () {
      expect(userWith([gymA, gymB]).requiresGymSelection, isTrue);
    });

    test('soleMembership returns the only membership, or null otherwise', () {
      expect(userWith([gymA]).soleMembership, gymA);
      expect(userWith([]).soleMembership, isNull);
      expect(userWith([gymA, gymB]).soleMembership, isNull);
    });

    test('membershipFor finds a membership by gym id', () {
      final user = userWith([gymA, gymB]);

      expect(user.membershipFor(2), gymB);
      expect(user.membershipFor(999), isNull);
    });
  });
}
