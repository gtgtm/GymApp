import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/widgets/app_list_card.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/core/widgets/empty_state.dart';
import 'package:gymapp_admin/features/trainers/presentation/create_trainer_sheet.dart';
import 'package:gymapp_admin/features/trainers/presentation/trainer_providers.dart';

class TrainersScreen extends ConsumerStatefulWidget {
  const TrainersScreen({this.openCreateOnLoad = false, super.key});

  final bool openCreateOnLoad;

  @override
  ConsumerState<TrainersScreen> createState() => _TrainersScreenState();
}

class _TrainersScreenState extends ConsumerState<TrainersScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openCreateOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showCreateTrainerSheet(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainersAsync = ref.watch(trainerListProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateTrainerSheet(context),
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView(
        value: trainersAsync,
        onRetry: () => ref.invalidate(trainerListProvider),
        builder: (context, trainers) {
          if (trainers.isEmpty) {
            return const EmptyState(
              icon: Icons.fitness_center_outlined,
              message: 'No trainers yet.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(trainerListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trainers.length,
              itemBuilder: (context, index) {
                final trainer = trainers[index];
                return AppListCard(
                  title: Text(trainer.user.name),
                  subtitle: Text(trainer.specialization ?? 'General Trainer'),
                  trailing: Text(
                    '${trainer.assignedMembersCount ?? 0} members',
                    style: Theme.of(context).textTheme.bodySmall,
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
