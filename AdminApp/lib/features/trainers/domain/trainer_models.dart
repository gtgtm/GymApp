class TrainerUserRef {
  const TrainerUserRef({required this.id, required this.name, this.phone});

  factory TrainerUserRef.fromJson(Map<String, dynamic> json) {
    return TrainerUserRef(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
    );
  }

  final int id;
  final String name;
  final String? phone;
}

class Trainer {
  const Trainer({
    required this.id,
    required this.user,
    required this.specialization,
    required this.status,
    this.assignedMembersCount,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: json['id'] as int,
      user: TrainerUserRef.fromJson(json['user'] as Map<String, dynamic>),
      specialization: json['specialization'] as String?,
      status: json['status'] as String,
      assignedMembersCount: json['assigned_members_count'] as int?,
    );
  }

  final int id;
  final TrainerUserRef user;
  final String? specialization;
  final String status;
  final int? assignedMembersCount;
}

class TrainerInput {
  const TrainerInput({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.specialization,
  });

  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? specialization;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (specialization != null && specialization!.isNotEmpty)
        'specialization': specialization,
    };
  }
}
