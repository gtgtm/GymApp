import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/diet/domain/diet_models.dart';

part 'diet_providers.g.dart';

@riverpod
Future<List<DietPlan>> dietPlanList(Ref ref, int memberId) {
  return ref.watch(dietRepositoryProvider).list(memberId);
}
