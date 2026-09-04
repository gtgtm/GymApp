import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_member/core/widgets/async_value_view.dart';
import 'package:gymapp_member/features/workout/domain/workout_models.dart';
import 'package:gymapp_member/features/workout/presentation/workout_providers.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(myWorkoutPlansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Plan')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myWorkoutPlansProvider),
        child: AsyncValueView(
          value: plansAsync,
          onRetry: () => ref.invalidate(myWorkoutPlansProvider),
          builder: (context, plans) {
            if (plans.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No workout plan assigned yet.')),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [for (final plan in plans) _WorkoutPlanCard(plan: plan)],
            );
          },
        ),
      ),
    );
  }
}

class _WorkoutPlanCard extends StatelessWidget {
  const _WorkoutPlanCard({required this.plan});

  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context) {
    final exercisesByDay = plan.exercisesByDay;
    final sortedDays = exercisesByDay.keys.toList()..sort();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            if (plan.trainerName != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Assigned by ${plan.trainerName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 12),
            for (final day in sortedDays) _DaySection(day: day, exercises: exercisesByDay[day]!),
          ],
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({required this.day, required this.exercises});

  final int day;
  final List<WorkoutExercise> exercises;

  @override
  Widget build(BuildContext context) {
    final label = exercises.first.dayLabel;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label != null ? 'Day $day — $label' : 'Day $day',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          for (final exercise in exercises)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercise.exerciseName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        if (exercise.muscleGroup != null)
                          Text(exercise.muscleGroup!, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text(
                    [
                      if (exercise.sets != null) '${exercise.sets} sets',
                      if (exercise.reps != null) '× ${exercise.reps}',
                      if (exercise.weightKg != null) '@ ${exercise.weightKg}kg',
                    ].join(' '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
