import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_member/core/api/repository_providers.dart';
import 'package:gymapp_member/features/workout/domain/workout_models.dart';

part 'workout_providers.g.dart';

@riverpod
Future<List<WorkoutPlan>> myWorkoutPlans(Ref ref) {
  return ref.watch(workoutRepositoryProvider).myWorkoutPlans();
}
