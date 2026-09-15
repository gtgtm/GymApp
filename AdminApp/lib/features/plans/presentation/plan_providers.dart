import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/plans/domain/plan_models.dart';

part 'plan_providers.g.dart';

@riverpod
Future<List<MembershipPlan>> planList(Ref ref) {
  return ref.watch(planRepositoryProvider).list();
}
