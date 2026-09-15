import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/features/diet/domain/diet_models.dart';
import 'package:gymapp_admin/features/diet/presentation/create_diet_plan_sheet.dart';
import 'package:gymapp_admin/features/diet/presentation/diet_providers.dart';

class DietTab extends ConsumerWidget {
  const DietTab({required this.memberId, super.key});

  final int memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(dietPlanListProvider(memberId));

    return Stack(
      children: [
        AsyncValueView(
          value: plansAsync,
          onRetry: () => ref.invalidate(dietPlanListProvider(memberId)),
          builder: (context, plans) {
            if (plans.isEmpty) {
              return const Center(child: Text('No diet plans yet.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                final bySlot = <String, List<DietMeal>>{};
                for (final meal in plan.meals) {
                  (bySlot[meal.mealSlot] ??= []).add(meal);
                }

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
                            Text(plan.name, style: Theme.of(context).textTheme.titleMedium),
                            Chip(label: Text(plan.status), visualDensity: VisualDensity.compact),
                          ],
                        ),
                        const Divider(height: 20),
                        for (final slot in mealSlots)
                          if (bySlot[slot] != null) ...[
                            Text(mealSlotLabel(slot), style: const TextStyle(fontWeight: FontWeight.w600)),
                            for (final meal in bySlot[slot]!)
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 2),
                                child: Text(
                                  '• ${meal.foodItem}${meal.quantity != null ? ' (${meal.quantity})' : ''}',
                                ),
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
            onPressed: () => showCreateDietPlanSheet(context, memberId),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
