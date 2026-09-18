import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_member/core/widgets/app_list_card.dart';
import 'package:gymapp_member/core/widgets/async_value_view.dart';
import 'package:gymapp_member/core/widgets/empty_state.dart';
import 'package:gymapp_member/features/progress/domain/progress_models.dart';
import 'package:gymapp_member/features/progress/presentation/progress_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(myProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myProgressProvider),
        child: AsyncValueView(
          value: progressAsync,
          onRetry: () => ref.invalidate(myProgressProvider),
          builder: (context, progress) {
            if (progress.measurements.isEmpty) {
              return const EmptyState(
                icon: Icons.show_chart,
                message: 'No progress measurements recorded yet.',
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weight Trend (kg)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: _WeightChart(
                            measurements: progress.measurements,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('History', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final measurement in progress.measurements.reversed)
                  _MeasurementTile(measurement: measurement),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.measurements});

  final List<BodyMeasurement> measurements;

  @override
  Widget build(BuildContext context) {
    final points = measurements
        .asMap()
        .entries
        .where((entry) => entry.value.weightKg != null)
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.weightKg!))
        .toList();

    if (points.isEmpty) {
      return const EmptyState(
        icon: Icons.show_chart,
        message: 'No weight data yet.',
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final labelStyle = TextStyle(color: scheme.onSurfaceVariant, fontSize: 10);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: scheme.outline, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) =>
                  Text(value.toStringAsFixed(0), style: labelStyle),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= measurements.length)
                  return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat.Md().format(measurements[index].recordedDate),
                    style: labelStyle,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: points,
            isCurved: true,
            color: scheme.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: scheme.primary,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: scheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementTile extends StatelessWidget {
  const _MeasurementTile({required this.measurement});

  final BodyMeasurement measurement;

  @override
  Widget build(BuildContext context) {
    final stats = <String>[
      if (measurement.weightKg != null) '${measurement.weightKg} kg',
      if (measurement.bmi != null) 'BMI ${measurement.bmi}',
      if (measurement.bodyFatPercent != null)
        '${measurement.bodyFatPercent}% fat',
    ];

    return AppListCard(
      title: Text(DateFormat.yMMMd().format(measurement.recordedDate)),
      subtitle: Text(stats.join(' · ')),
    );
  }
}
