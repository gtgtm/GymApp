class StaffUser {
  const StaffUser({
    required this.id,
    required this.name,
    required this.email,
    required this.gymName,
    required this.roleName,
    required this.roleLabel,
  });

  factory StaffUser.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as Map<String, dynamic>?;
    return StaffUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      gymName: (json['gym'] as Map<String, dynamic>?)?['name'] as String? ?? '',
      roleName: role?['name'] as String? ?? '',
      roleLabel: role?['label'] as String? ?? '',
    );
  }

  final int id;
  final String name;
  final String email;
  final String gymName;
  final String roleName;
  final String roleLabel;

  bool get isSuperAdmin => roleName == 'super_admin';
}
