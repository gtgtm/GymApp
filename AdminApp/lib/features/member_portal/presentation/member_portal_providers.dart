import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/api_providers.dart';
import 'package:gymapp_admin/features/member_portal/data/member_portal_repository.dart';
import 'package:gymapp_admin/features/member_portal/domain/member_portal_models.dart';

part 'member_portal_providers.g.dart';

@riverpod
MemberPortalRepository memberPortalRepository(Ref ref) {
  return MemberPortalRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
Future<MemberProfile> myProfile(Ref ref) {
  return ref.watch(memberPortalRepositoryProvider).profile();
}

@riverpod
Future<MembershipDetails> myMembership(Ref ref) {
  return ref.watch(memberPortalRepositoryProvider).membership();
}

@riverpod
Future<MemberQrCode> myQrCode(Ref ref) {
  return ref.watch(memberPortalRepositoryProvider).qrCode();
}

@riverpod
Future<List<MemberAttendanceRecord>> myAttendance(Ref ref) {
  return ref.watch(memberPortalRepositoryProvider).attendance();
}

@riverpod
Future<List<MemberPaymentRecord>> myPayments(Ref ref) {
  return ref.watch(memberPortalRepositoryProvider).payments();
}

@riverpod
Future<List<MemberNotification>> myNotifications(Ref ref) {
  return ref.watch(memberPortalRepositoryProvider).notifications();
}

@riverpod
Future<List<PortalWorkoutPlan>> myWorkoutPlans(Ref ref) {
  return ref.watch(memberPortalRepositoryProvider).workoutPlans();
}

@riverpod
Future<List<PortalDietPlan>> myDietPlans(Ref ref) {
  return ref.watch(memberPortalRepositoryProvider).dietPlans();
}

@riverpod
Future<PortalProgress> myProgress(Ref ref) {
  return ref.watch(memberPortalRepositoryProvider).progress();
}
