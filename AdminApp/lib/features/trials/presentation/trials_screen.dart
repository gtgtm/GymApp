import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
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
            return const Center(child: Text('No trials yet.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(trialListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: trials.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final trial = trials[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(trial.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(trial.mobile, style: Theme.of(context).textTheme.bodySmall),
                              Text(
                                '${dateFormat.format(DateTime.parse(trial.trialStart))} → ${dateFormat.format(DateTime.parse(trial.trialEnd))}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        DropdownButton<String>(
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
                      ],
                    ),
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
