import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_member/core/api/api_providers.dart';
import 'package:gymapp_member/features/attendance/data/attendance_repository.dart';
import 'package:gymapp_member/features/diet/data/diet_repository.dart';
import 'package:gymapp_member/features/membership/data/membership_repository.dart';
import 'package:gymapp_member/features/notifications/data/notification_repository.dart';
import 'package:gymapp_member/features/payments/data/payment_repository.dart';
import 'package:gymapp_member/features/progress/data/progress_repository.dart';
import 'package:gymapp_member/features/workout/data/workout_repository.dart';

part 'repository_providers.g.dart';

@riverpod
MembershipRepository membershipRepository(Ref ref) {
  return MembershipRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
PaymentRepository paymentRepository(Ref ref) {
  return PaymentRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
AttendanceRepository attendanceRepository(Ref ref) {
  return AttendanceRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
WorkoutRepository workoutRepository(Ref ref) {
  return WorkoutRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
DietRepository dietRepository(Ref ref) {
  return DietRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
ProgressRepository progressRepository(Ref ref) {
  return ProgressRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepository(apiClient: ref.watch(apiClientProvider));
}
