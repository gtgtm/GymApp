import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/widgets/async_value_view.dart';
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
                return Card(
                  color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('${due.length} item(s) need maintenance soon.'),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            AsyncValueView(
              value: equipmentAsync,
              onRetry: () => ref.invalidate(equipmentListProvider),
              builder: (context, equipment) {
                if (equipment.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No equipment recorded yet.')),
                  );
                }
                return Column(
                  children: [
                    for (final item in equipment)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text(item.category ?? 'Uncategorized'),
                          trailing: Chip(
                            label: Text((item.condition ?? 'good').replaceAll('_', ' ')),
                            visualDensity: VisualDensity.compact,
                          ),
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
