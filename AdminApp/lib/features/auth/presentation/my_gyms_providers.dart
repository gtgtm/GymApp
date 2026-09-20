import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/features/auth/domain/gym_membership.dart';
import 'package:gymapp_admin/features/auth/presentation/auth_controller.dart';

part 'my_gyms_providers.g.dart';

@riverpod
Future<List<GymMembership>> myGyms(Ref ref) {
  return ref.watch(authRepositoryProvider).myGyms();
}

@riverpod
Future<List<GymMembership>> pendingGyms(Ref ref) {
  return ref.watch(authRepositoryProvider).pendingGyms();
}
