import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/widgets/app_list_card.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/core/widgets/empty_state.dart';
import 'package:gymapp_admin/core/widgets/status_badge.dart';
import 'package:gymapp_admin/features/plans/presentation/create_plan_sheet.dart';
import 'package:gymapp_admin/features/plans/presentation/plan_providers.dart';

class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({this.openCreateOnLoad = false, super.key});

  final bool openCreateOnLoad;

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openCreateOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showCreatePlanSheet(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(planListProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreatePlanSheet(context),
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView(
        value: plansAsync,
        onRetry: () => ref.invalidate(planListProvider),
        builder: (context, plans) {
          if (plans.isEmpty) {
            return const EmptyState(
              icon: Icons.assignment_outlined,
              message: 'No membership plans yet.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(planListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return AppListCard(
                  title: Text(plan.name),
                  subtitle: Text(
                    '${plan.durationDays} days · ₹${plan.totalAmount}',
                  ),
                  trailing: StatusBadge(
                    label: plan.status,
                    tone: plan.status == 'active'
                        ? StatusTone.success
                        : StatusTone.neutral,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
