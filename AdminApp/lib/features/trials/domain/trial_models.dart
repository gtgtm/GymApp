const trialStatuses = ['active', 'expired', 'converted'];

class TrialTrainerRef {
  const TrialTrainerRef({required this.id, required this.name});

  factory TrialTrainerRef.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return TrialTrainerRef(id: json['id'] as int, name: user?['name'] as String? ?? '');
  }

  final int id;
  final String name;
}

class Trial {
  const Trial({
    required this.id,
    required this.name,
    required this.mobile,
    required this.trialStart,
    required this.trialEnd,
    required this.status,
    this.trainer,
  });

  factory Trial.fromJson(Map<String, dynamic> json) {
    return Trial(
      id: json['id'] as int,
      name: json['name'] as String,
      mobile: json['mobile'] as String,
      trialStart: json['trial_start'] as String,
      trialEnd: json['trial_end'] as String,
      status: json['status'] as String,
      trainer: json['trainer'] == null
          ? null
          : TrialTrainerRef.fromJson(json['trainer'] as Map<String, dynamic>),
    );
  }

  final int id;
  final String name;
  final String mobile;
  final String trialStart;
  final String trialEnd;
  final String status;
  final TrialTrainerRef? trainer;
}

class TrialInput {
  const TrialInput({
    required this.name,
    required this.mobile,
    required this.trialStart,
    required this.trialEnd,
    this.trainerId,
  });

  final String name;
  final String mobile;
  final String trialStart;
  final String trialEnd;
  final int? trainerId;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'trial_start': trialStart,
      'trial_end': trialEnd,
      if (trainerId != null) 'trainer_id': trainerId,
    };
  }
}
