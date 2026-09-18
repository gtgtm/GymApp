import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/widgets/app_list_card.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/core/widgets/empty_state.dart';
import 'package:gymapp_admin/core/widgets/status_badge.dart';
import 'package:gymapp_admin/features/equipment/presentation/create_equipment_sheet.dart';
import 'package:gymapp_admin/features/equipment/presentation/equipment_providers.dart';

class EquipmentScreen extends ConsumerStatefulWidget {
  const EquipmentScreen({this.openCreateOnLoad = false, super.key});

  final bool openCreateOnLoad;

  @override
  ConsumerState<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends ConsumerState<EquipmentScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openCreateOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showCreateEquipmentSheet(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final equipmentAsync = ref.watch(equipmentListProvider);
    final maintenanceDueAsync = ref.watch(maintenanceDueListProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateEquipmentSheet(context),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(equipmentListProvider);
          ref.invalidate(maintenanceDueListProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            maintenanceDueAsync.when(
              data: (due) {
                if (due.isEmpty) return const SizedBox.shrink();
                final scheme = Theme.of(context).colorScheme;
                return Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: scheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: scheme.error.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: scheme.error),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${due.length} item(s) need maintenance soon.',
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            AsyncValueView(
              value: equipmentAsync,
              onRetry: () => ref.invalidate(equipmentListProvider),
              builder: (context, equipment) {
                if (equipment.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: EmptyState(
                      icon: Icons.build_outlined,
                      message: 'No equipment recorded yet.',
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final item in equipment)
                      AppListCard(
                        title: Text(item.name),
                        subtitle: Text(item.category ?? 'Uncategorized'),
                        trailing: StatusBadge(
                          label: (item.condition ?? 'good').replaceAll(
                            '_',
                            ' ',
                          ),
                          tone: switch (item.condition) {
                            'needs_repair' => StatusTone.danger,
                            'fair' => StatusTone.warning,
                            _ => StatusTone.success,
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
