import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_member/core/widgets/async_value_view.dart';
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
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No progress measurements recorded yet.')),
                  ),
                ],
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
                        Text('Weight Trend (kg)', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: _WeightChart(measurements: progress.measurements),
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
      return const Center(child: Text('No weight data yet.'));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= measurements.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat.Md().format(measurements[index].recordedDate),
                    style: const TextStyle(fontSize: 10),
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
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
      if (measurement.bodyFatPercent != null) '${measurement.bodyFatPercent}% fat',
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(DateFormat.yMMMd().format(measurement.recordedDate)),
        subtitle: Text(stats.join(' · ')),
      ),
    );
  }
}
