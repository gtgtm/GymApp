import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/features/workouts/presentation/create_workout_plan_sheet.dart';
import 'package:gymapp_admin/features/workouts/presentation/workout_providers.dart';

class WorkoutTab extends ConsumerWidget {
  const WorkoutTab({required this.memberId, super.key});

  final int memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(workoutPlanListProvider(memberId));

    return Stack(
      children: [
        AsyncValueView(
          value: plansAsync,
          onRetry: () => ref.invalidate(workoutPlanListProvider(memberId)),
          builder: (context, plans) {
            if (plans.isEmpty) {
              return const Center(child: Text('No workout plans yet.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                final byDay = <int, List<String>>{};
                for (final exercise in plan.exercises) {
                  (byDay[exercise.dayNumber] ??= []).add(
                    '${exercise.exerciseName}${exercise.sets != null ? ' – ${exercise.sets} sets' : ''}${exercise.reps != null ? ' × ${exercise.reps}' : ''}',
                  );
                }
                final sortedDays = byDay.keys.toList()..sort();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              plan.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Chip(
                              label: Text(plan.status),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        for (final day in sortedDays) ...[
                          Text(
                            'Day $day',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          for (final line in byDay[day]!)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, top: 2),
                              child: Text('• $line'),
                            ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            onPressed: () => showCreateWorkoutPlanSheet(context, memberId),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
