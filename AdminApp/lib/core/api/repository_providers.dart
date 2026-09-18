import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/api_providers.dart';
import 'package:gymapp_admin/features/attendance/data/attendance_repository.dart';
import 'package:gymapp_admin/features/dashboard/data/dashboard_repository.dart';
import 'package:gymapp_admin/features/diet/data/diet_repository.dart';
import 'package:gymapp_admin/features/enquiries/data/enquiry_repository.dart';
import 'package:gymapp_admin/features/equipment/data/equipment_repository.dart';
import 'package:gymapp_admin/features/expenses/data/expense_repository.dart';
import 'package:gymapp_admin/features/members/data/member_repository.dart';
import 'package:gymapp_admin/features/payments/data/payment_repository.dart';
import 'package:gymapp_admin/features/plans/data/plan_repository.dart';
import 'package:gymapp_admin/features/platform/data/platform_repository.dart';
import 'package:gymapp_admin/features/progress/data/progress_repository.dart';
import 'package:gymapp_admin/features/trainers/data/trainer_repository.dart';
import 'package:gymapp_admin/features/trials/data/trial_repository.dart';
import 'package:gymapp_admin/features/workouts/data/workout_repository.dart';

part 'repository_providers.g.dart';

@riverpod
DashboardRepository dashboardRepository(Ref ref) {
  return DashboardRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
MemberRepository memberRepository(Ref ref) {
  return MemberRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
AttendanceRepository attendanceRepository(Ref ref) {
  return AttendanceRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
PaymentRepository paymentRepository(Ref ref) {
  return PaymentRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
TrainerRepository trainerRepository(Ref ref) {
  return TrainerRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
PlanRepository planRepository(Ref ref) {
  return PlanRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
EnquiryRepository enquiryRepository(Ref ref) {
  return EnquiryRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
TrialRepository trialRepository(Ref ref) {
  return TrialRepository(apiClient: ref.watch(apiClientProvider));
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
ExpenseRepository expenseRepository(Ref ref) {
  return ExpenseRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
EquipmentRepository equipmentRepository(Ref ref) {
  return EquipmentRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
PlatformRepository platformRepository(Ref ref) {
  return PlatformRepository(apiClient: ref.watch(apiClientProvider));
}
