enum ExpiryBucket { green, yellow, orange, red }

ExpiryBucket expiryBucketFromString(String value) {
  return switch (value) {
    'green' => ExpiryBucket.green,
    'yellow' => ExpiryBucket.yellow,
    'orange' => ExpiryBucket.orange,
    _ => ExpiryBucket.red,
  };
}

class MembershipInfo {
  const MembershipInfo({
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory MembershipInfo.fromJson(Map<String, dynamic> json) {
    return MembershipInfo(
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String,
    );
  }

  final DateTime startDate;
  final DateTime endDate;
  final String status;

  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
}

class MembershipDetails {
  const MembershipDetails({
    required this.current,
    required this.expiryBucket,
  });

  factory MembershipDetails.fromJson(Map<String, dynamic> json) {
    return MembershipDetails(
      current: json['current'] != null
          ? MembershipInfo.fromJson(json['current'] as Map<String, dynamic>)
          : null,
      expiryBucket: expiryBucketFromString(json['expiry_bucket'] as String? ?? 'red'),
    );
  }

  final MembershipInfo? current;
  final ExpiryBucket expiryBucket;
}

class MemberProfile {
  const MemberProfile({
    required this.id,
    required this.memberCode,
    required this.fullName,
    required this.mobile,
    required this.status,
    required this.expiryBucket,
    this.trainerName,
    this.currentMembershipEnd,
  });

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    final currentMembership = json['current_membership'] as Map<String, dynamic>?;

    return MemberProfile(
      id: json['id'] as int,
      memberCode: json['member_code'] as String,
      fullName: json['full_name'] as String,
      mobile: json['mobile'] as String,
      status: json['status'] as String,
      expiryBucket: expiryBucketFromString(json['expiry_bucket'] as String? ?? 'red'),
      trainerName: (json['trainer'] as Map<String, dynamic>?)?['name'] as String?,
      currentMembershipEnd: currentMembership != null
          ? DateTime.tryParse(currentMembership['end_date'] as String)
          : null,
    );
  }

  final int id;
  final String memberCode;
  final String fullName;
  final String mobile;
  final String status;
  final ExpiryBucket expiryBucket;
  final String? trainerName;
  final DateTime? currentMembershipEnd;
}
