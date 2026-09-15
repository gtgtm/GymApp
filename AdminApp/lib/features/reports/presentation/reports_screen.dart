import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/features/reports/presentation/report_providers.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late DateTime _from = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _to = DateTime.now();

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
      } else {
        _to = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('yyyy-MM-dd');
    final displayFormat = DateFormat.yMMMd();
    final summaryAsync = ref.watch(financialSummaryProvider(format.format(_from), format.format(_to)));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _pickDate(isFrom: true),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'From'),
                  child: Text(displayFormat.format(_from)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => _pickDate(isFrom: false),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'To'),
                  child: Text(displayFormat.format(_to)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AsyncValueView(
          value: summaryAsync,
          onRetry: () => ref.invalidate(financialSummaryProvider),
          builder: (context, summary) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: _StatTile(label: 'Revenue', value: summary.revenue, tone: StatTone.success)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatTile(label: 'Expenses', value: summary.expenses, tone: StatTone.danger)),
                  ],
                ),
                const SizedBox(height: 12),
                _StatTile(
                  label: 'Profit',
                  value: summary.profit,
                  tone: summary.profit >= 0 ? StatTone.success : StatTone.danger,
                ),
                const SizedBox(height: 20),
                Text('Payment Method Breakdown', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (summary.paymentMethodBreakdown.isEmpty)
                  const Text('No payments in this period.')
                else
                  Card(
                    child: Column(
                      children: [
                        for (final entry in summary.paymentMethodBreakdown.entries)
                          ListTile(
                            title: Text(entry.key.replaceAll('_', ' ')),
                            trailing: Text('₹${entry.value.toStringAsFixed(2)}'),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

enum StatTone { success, danger }

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.tone});

  final String label;
  final double value;
  final StatTone tone;

  @override
  Widget build(BuildContext context) {
    final color = tone == StatTone.success ? Colors.green : Theme.of(context).colorScheme.error;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              '₹${value.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
