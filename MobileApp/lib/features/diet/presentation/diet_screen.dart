import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_member/core/widgets/async_value_view.dart';
import 'package:gymapp_member/features/diet/domain/diet_models.dart';
import 'package:gymapp_member/features/diet/presentation/diet_providers.dart';

class DietScreen extends ConsumerWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(myDietPlansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Diet Plan')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myDietPlansProvider),
        child: AsyncValueView(
          value: plansAsync,
          onRetry: () => ref.invalidate(myDietPlansProvider),
          builder: (context, plans) {
            if (plans.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No diet plan assigned yet.')),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [for (final plan in plans) _DietPlanCard(plan: plan)],
            );
          },
        ),
      ),
    );
  }
}

class _DietPlanCard extends StatelessWidget {
  const _DietPlanCard({required this.plan});

  final DietPlan plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            if (plan.trainerName != null)
              Text('Assigned by ${plan.trainerName}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            _NutritionSummaryRow(summary: plan.dailySummary),
            const SizedBox(height: 12),
            for (final meal in plan.meals) _MealRow(meal: meal),
          ],
        ),
      ),
    );
  }
}

class _NutritionSummaryRow extends StatelessWidget {
  const _NutritionSummaryRow({required this.summary});

  final DailyNutritionSummary summary;

  @override
  Widget build(BuildContext context) {
    Widget stat(String label, String value) {
      return Expanded(
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          stat('kcal', summary.calories.toStringAsFixed(0)),
          stat('Protein', '${summary.proteinG.toStringAsFixed(0)}g'),
          stat('Carbs', '${summary.carbsG.toStringAsFixed(0)}g'),
          stat('Fat', '${summary.fatG.toStringAsFixed(0)}g'),
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.meal});

  final DietMeal meal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealSlotLabels[meal.mealSlot] ?? meal.mealSlot,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  [meal.foodItem, if (meal.quantity != null) '(${meal.quantity})'].join(' '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (meal.calories != null) Text('${meal.calories!.toStringAsFixed(0)} kcal'),
        ],
      ),
    );
  }
}
