class MemberUser {
  const MemberUser({
    required this.id,
    required this.name,
    required this.email,
    required this.gymName,
    required this.roleName,
  });

  factory MemberUser.fromJson(Map<String, dynamic> json) {
    return MemberUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      gymName: (json['gym'] as Map<String, dynamic>?)?['name'] as String? ?? '',
      roleName: (json['role'] as Map<String, dynamic>?)?['name'] as String? ?? '',
    );
  }

  final int id;
  final String name;
  final String email;
  final String gymName;
  final String roleName;
}
