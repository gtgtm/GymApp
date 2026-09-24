import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/theme/app_tokens.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/core/widgets/empty_state.dart';
import 'package:gymapp_admin/features/member_portal/domain/member_portal_models.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_portal_providers.dart';

/// Pull-to-refresh list with an empty state, shared by the plan screens.
class _PlanList<T> extends StatelessWidget {
  const _PlanList({
    required this.value,
    required this.onRefresh,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.itemBuilder,
  });

  final AsyncValue<List<T>> value;
  final Future<void> Function() onRefresh;
  final IconData emptyIcon;
  final String emptyMessage;
  final Widget Function(T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: AsyncValueView(
        value: value,
        onRetry: onRefresh,
        builder: (context, items) => items.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  EmptyState(icon: emptyIcon, message: emptyMessage),
                ],
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [for (final item in items) itemBuilder(item)],
              ),
      ),
    );
  }
}

class MemberWorkoutScreen extends ConsumerWidget {
  const MemberWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PlanList<PortalWorkoutPlan>(
      value: ref.watch(myWorkoutPlansProvider),
      onRefresh: () async {
        ref.invalidate(myWorkoutPlansProvider);
        await ref.read(myWorkoutPlansProvider.future);
      },
      emptyIcon: Icons.fitness_center_outlined,
      emptyMessage: 'No workout plan yet. Your trainer will assign one.',
      itemBuilder: (plan) => _WorkoutPlanCard(plan: plan),
    );
  }
}

class MemberDietScreen extends ConsumerWidget {
  const MemberDietScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PlanList<PortalDietPlan>(
      value: ref.watch(myDietPlansProvider),
      onRefresh: () async {
        ref.invalidate(myDietPlansProvider);
        await ref.read(myDietPlansProvider.future);
      },
      emptyIcon: Icons.restaurant_outlined,
      emptyMessage: 'No diet plan yet. Your trainer will assign one.',
      itemBuilder: (plan) => _DietPlanCard(plan: plan),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.trainerName,
    required this.children,
  });

  final String name;
  final String? trainerName;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.tokens;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusXl),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(name, style: textTheme.titleLarge),
          if (trainerName != null)
            Text(
              'By $trainerName',
              style: textTheme.bodySmall?.copyWith(color: scheme.secondary),
            ),
          SizedBox(height: tokens.spacingMd),
          ...children,
        ],
      ),
    );
  }
}

class _WorkoutPlanCard extends StatelessWidget {
  const _WorkoutPlanCard({required this.plan});

  final PortalWorkoutPlan plan;

  @override
  Widget build(BuildContext context) {
    return _PlanCard(
      name: plan.name,
      trainerName: plan.trainerName,
      children: [
        for (final (day, exercises) in plan.days)
          _DayBlock(day: day, exercises: exercises),
      ],
    );
  }
}

class _DayBlock extends StatelessWidget {
  const _DayBlock({required this.day, required this.exercises});

  final int day;
  final List<PortalExercise> exercises;

  @override
  Widget build(BuildContext context) {
    final label = exercises.first.dayLabel;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GroupHeading(leading: 'DAY $day', title: label),
          for (final exercise in exercises)
            _Row(
              title: exercise.exerciseName,
              subtitle: exercise.muscleGroup,
              trailing: exercise.prescription,
            ),
        ],
      ),
    );
  }
}

class _DietPlanCard extends StatelessWidget {
  const _DietPlanCard({required this.plan});

  final PortalDietPlan plan;

  @override
  Widget build(BuildContext context) {
    final bySlot = <String, List<PortalMeal>>{};
    for (final meal in plan.meals) {
      bySlot.putIfAbsent(meal.slotLabel, () => []).add(meal);
    }

    return _PlanCard(
      name: plan.name,
      trainerName: plan.trainerName,
      children: [
        _MacroStrip(totals: plan.dailyTotals),
        const SizedBox(height: 14),
        for (final entry in bySlot.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GroupHeading(leading: entry.key.toUpperCase()),
                for (final meal in entry.value)
                  _Row(
                    title: meal.foodItem,
                    subtitle: meal.quantity,
                    trailing: meal.calories == null
                        ? ''
                        : '${meal.calories!.toStringAsFixed(0)} kcal',
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Daily calories + macros as four compact figures.
class _MacroStrip extends StatelessWidget {
  const _MacroStrip({required this.totals});

  final NutritionTotals totals;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final figures = [
      ('kcal', totals.calories, scheme.primary),
      ('protein', totals.proteinG, tokens.success),
      ('carbs', totals.carbsG, tokens.info),
      ('fat', totals.fatG, tokens.warning),
    ];

    return Row(
      children: [
        for (final (label, value, color) in figures)
          Expanded(
            child: Column(
              children: [
                Text(
                  value.toStringAsFixed(0) + (label == 'kcal' ? '' : 'g'),
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: color),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _GroupHeading extends StatelessWidget {
  const _GroupHeading({required this.leading, this.title});

  final String leading;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: leading,
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            if (title != null) TextSpan(text: '  $title'),
          ],
        ),
        style: textTheme.labelLarge,
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.title, required this.trailing, this.subtitle});

  final String title;
  final String? subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(context.tokens.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleSmall),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing.isNotEmpty)
            Text(
              trailing,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
