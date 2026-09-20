/// One gym this login has access to, with the role that applies AT THAT
/// GYM specifically — the same person can be a trainer at one gym and an
/// admin at another (see Backend's user_gym_memberships table).
class GymMembership {
  const GymMembership({
    required this.id,
    required this.gymId,
    required this.gymName,
    required this.roleName,
    required this.roleLabel,
    required this.memberId,
  });

  factory GymMembership.fromJson(Map<String, dynamic> json) {
    return GymMembership(
      id: json['id'] as int,
      gymId: json['gym_id'] as int,
      gymName: json['gym_name'] as String? ?? '',
      roleName: json['role'] as String? ?? '',
      roleLabel: json['role_label'] as String? ?? '',
      memberId: json['member_id'] as int?,
    );
  }

  /// The membership row's own id — pass this to
  /// AuthRepository.acceptMembership, NOT gymId (a gym can have many
  /// memberships; this identifies the specific one).
  final int id;
  final int gymId;
  final String gymName;
  final String roleName;
  final String roleLabel;
  final int? memberId;
}
