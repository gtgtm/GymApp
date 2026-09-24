import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_admin/core/theme/app_tokens.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/features/dashboard/presentation/widgets/dashboard_sections.dart';
import 'package:gymapp_admin/features/member_portal/domain/member_portal_models.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_portal_providers.dart';
import 'package:gymapp_admin/features/progress/presentation/weight_trend_chart.dart';

/// Body measurements the trainer recorded: weight trend + history.
class MemberProgressScreen extends ConsumerWidget {
  const MemberProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myProgressProvider);
        await ref.read(myProgressProvider.future);
      },
      child: AsyncValueView(
        value: ref.watch(myProgressProvider),
        onRetry: () => ref.invalidate(myProgressProvider),
        builder: (context, progress) => _ProgressBody(progress: progress),
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({required this.progress});

  final PortalProgress progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final weights = [
      for (final m in progress.measurements)
        if (m.weightKg != null) m.weightKg!,
    ];
    final change = weights.length < 2 ? null : weights.last - weights.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Container(
          padding: EdgeInsets.all(tokens.spacingMd),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(tokens.radiusXl),
            border: Border.all(color: scheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weight',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    weights.isEmpty
                        ? '—'
                        : '${weights.last.toStringAsFixed(1)} kg',
                    style: textTheme.headlineMedium,
                  ),
                  if (change != null) ...[
                    const SizedBox(width: 10),
                    Text(
                      '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} kg',
                      style: textTheme.titleSmall?.copyWith(
                        color: change <= 0 ? tokens.success : tokens.warning,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: tokens.spacingMd),
              if (weights.isEmpty)
                const DashboardEmptyCard(
                  icon: Icons.show_chart,
                  message: 'No measurements yet. Your trainer records these.',
                )
              else
                WeightTrendChart(weights: weights),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const DashboardSectionHeader(title: 'History'),
        if (progress.measurements.isEmpty)
          const DashboardEmptyCard(
            icon: Icons.straighten,
            message: 'No measurements recorded.',
          )
        else
          for (final m in progress.measurements.reversed)
            _MeasurementTile(measurement: m),
      ],
    );
  }
}

class _MeasurementTile extends StatelessWidget {
  const _MeasurementTile({required this.measurement});

  final PortalMeasurement measurement;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    String? figure(String label, double? value, String unit) =>
        value == null ? null : '$label ${value.toStringAsFixed(1)}$unit';
    final stats = [
      figure('Weight', measurement.weightKg, 'kg'),
      figure('BMI', measurement.bmi, ''),
      figure('Body fat', measurement.bodyFatPercent, '%'),
      figure('Chest', measurement.chestCm, 'cm'),
      figure('Waist', measurement.waistCm, 'cm'),
      figure('Arms', measurement.armsCm, 'cm'),
    ].nonNulls;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.tokens.radiusLg),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('d MMM yyyy').format(measurement.recordedDate),
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            stats.join('  ·  '),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
