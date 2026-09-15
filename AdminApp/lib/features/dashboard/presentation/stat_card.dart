import 'package:flutter/material.dart';

enum StatTone { normal, success, warning, danger }

class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.tone = StatTone.normal,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final StatTone tone;

  Color _toneColor(ColorScheme scheme) {
    return switch (tone) {
      StatTone.success => Colors.green,
      StatTone.warning => Colors.amber,
      StatTone.danger => scheme.error,
      StatTone.normal => scheme.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final toneColor = _toneColor(scheme);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: toneColor.withValues(alpha: 0.12),
                  child: Icon(icon, size: 16, color: toneColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
