import 'package:gymapp_admin/features/auth/domain/gym_membership.dart';

/// A logged-in staff identity. One login can now hold ACTIVE memberships at
/// several gyms, each with its own role (see GymMembership) — so, unlike
/// before, there is no single fixed roleName/gymName on this class. Callers
/// that need "the role/gym for the screen currently being shown" must
/// combine this with whichever gym is currently acting (see
/// ActingGymController) via [membershipFor] or [soleMembership].
class StaffUser {
  const StaffUser({
    required this.id,
    required this.name,
    required this.email,
    required this.roleName,
    required this.memberships,
  });

  factory StaffUser.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as Map<String, dynamic>?;
    final membershipsJson = json['memberships'] as List<dynamic>? ?? const [];

    return StaffUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      // Only used to detect (and reject) a platform-owner super_admin
      // login — per-gym roles come from `memberships` instead.
      roleName: role?['name'] as String? ?? '',
      memberships: membershipsJson
          .map((json) => GymMembership.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final String name;
  final String email;
  final String roleName;
  final List<GymMembership> memberships;

  bool get isSuperAdmin => roleName == 'super_admin';

  bool get requiresGymSelection => memberships.length > 1;

  /// The only membership this user has, or null if they have zero or more
  /// than one (in which case a gym must be explicitly chosen — see
  /// ActingGymController / the gyms picker screen).
  GymMembership? get soleMembership =>
      memberships.length == 1 ? memberships.first : null;

  GymMembership? membershipFor(int gymId) {
    for (final membership in memberships) {
      if (membership.gymId == gymId) return membership;
    }
    return null;
  }
}
