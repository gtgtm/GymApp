import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/workouts/domain/workout_models.dart';

part 'workout_providers.g.dart';

@riverpod
Future<List<WorkoutPlan>> workoutPlanList(Ref ref, int memberId) {
  return ref.watch(workoutRepositoryProvider).list(memberId);
}
