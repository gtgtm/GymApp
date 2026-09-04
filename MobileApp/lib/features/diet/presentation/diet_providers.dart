import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_member/core/api/repository_providers.dart';
import 'package:gymapp_member/features/diet/domain/diet_models.dart';

part 'diet_providers.g.dart';

@riverpod
Future<List<DietPlan>> myDietPlans(Ref ref) {
  return ref.watch(dietRepositoryProvider).myDietPlans();
}
