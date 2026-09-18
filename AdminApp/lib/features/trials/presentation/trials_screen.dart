import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/core/widgets/app_list_card.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/core/widgets/empty_state.dart';
import 'package:gymapp_admin/features/trials/domain/trial_models.dart';
import 'package:gymapp_admin/features/trials/presentation/create_trial_sheet.dart';
import 'package:gymapp_admin/features/trials/presentation/trial_providers.dart';

class TrialsScreen extends ConsumerStatefulWidget {
  const TrialsScreen({this.openCreateOnLoad = false, super.key});

  final bool openCreateOnLoad;

  @override
  ConsumerState<TrialsScreen> createState() => _TrialsScreenState();
}

class _TrialsScreenState extends ConsumerState<TrialsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openCreateOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showCreateTrialSheet(context);
      });
    }
  }

  Future<void> _updateStatus(Trial trial, String status) async {
    try {
      await ref.read(trialRepositoryProvider).updateStatus(trial.id, status);
      ref.invalidate(trialListProvider);
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trialsAsync = ref.watch(trialListProvider);
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateTrialSheet(context),
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView(
        value: trialsAsync,
        onRetry: () => ref.invalidate(trialListProvider),
        builder: (context, trials) {
          if (trials.isEmpty) {
            return const EmptyState(
              icon: Icons.hourglass_empty,
              message: 'No trials yet.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(trialListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trials.length,
              itemBuilder: (context, index) {
                final trial = trials[index];
                return AppListCard(
                  title: Text(trial.name),
                  subtitle: Text(
                    '${trial.mobile}\n${dateFormat.format(DateTime.parse(trial.trialStart))} → ${dateFormat.format(DateTime.parse(trial.trialEnd))}',
                  ),
                  trailing: DropdownButton<String>(
                    value: trial.status,
                    underline: const SizedBox.shrink(),
                    items: [
                      for (final status in trialStatuses)
                        DropdownMenuItem(value: status, child: Text(status)),
                    ],
                    onChanged: (value) {
                      if (value != null) _updateStatus(trial, value);
                    },
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
