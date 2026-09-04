import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_member/core/api/repository_providers.dart';
import 'package:gymapp_member/features/attendance/data/attendance_models.dart';

part 'attendance_providers.g.dart';

@riverpod
Future<List<AttendanceRecord>> myAttendanceHistory(Ref ref) {
  return ref.watch(attendanceRepositoryProvider).myAttendance();
}
