import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/attendance/domain/attendance_models.dart';

part 'attendance_providers.g.dart';

@riverpod
Future<List<AttendanceEntry>> todaysAttendance(Ref ref) {
  return ref.watch(attendanceRepositoryProvider).today();
}
