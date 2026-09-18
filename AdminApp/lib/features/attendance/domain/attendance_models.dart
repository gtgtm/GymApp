class AttendanceMemberRef {
  const AttendanceMemberRef({
    required this.id,
    required this.fullName,
    required this.memberCode,
  });

  factory AttendanceMemberRef.fromJson(Map<String, dynamic> json) {
    return AttendanceMemberRef(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      memberCode: json['member_code'] as String,
    );
  }

  final int id;
  final String fullName;
  final String memberCode;
}

class AttendanceEntry {
  const AttendanceEntry({
    required this.id,
    required this.member,
    required this.checkInTime,
    required this.status,
  });

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceEntry(
      id: json['id'] as int,
      member: json['member'] == null
          ? null
          : AttendanceMemberRef.fromJson(
              json['member'] as Map<String, dynamic>,
            ),
      checkInTime: json['check_in_time'] as String?,
      status: json['status'] as String,
    );
  }

  final int id;
  final AttendanceMemberRef? member;
  final String? checkInTime;
  final String status;
}

class MarkAttendanceResult {
  const MarkAttendanceResult({required this.membershipEndDate, this.member});

  factory MarkAttendanceResult.fromJson(Map<String, dynamic> json) {
    return MarkAttendanceResult(
      membershipEndDate: json['membership_end_date'] as String?,
      member: json['member'] == null
          ? null
          : AttendanceMemberRef.fromJson(
              json['member'] as Map<String, dynamic>,
            ),
    );
  }

  final String? membershipEndDate;
  final AttendanceMemberRef? member;
}
