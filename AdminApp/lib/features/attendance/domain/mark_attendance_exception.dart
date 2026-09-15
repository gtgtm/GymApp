import 'package:gymapp_admin/features/attendance/domain/attendance_models.dart';

/// Thrown when marking attendance fails because the membership has expired.
/// Carries the extra context the backend returns alongside the error message
/// (see AttendanceController::store/scanQr `error.errors` payload).
class MembershipExpiredException implements Exception {
  const MembershipExpiredException({
    required this.message,
    required this.membershipEndDate,
    this.member,
  });

  final String message;
  final String? membershipEndDate;
  final AttendanceMemberRef? member;

  @override
  String toString() => message;
}
