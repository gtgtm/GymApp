import 'package:flutter/material.dart';

import 'package:gymapp_admin/core/theme/app_tokens.dart';

class PulseStat {
  const PulseStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
}

/// A row of equal-width compact counters (Active / Check-ins / Renewals),
/// each with a tinted icon badge in its own semantic colour.
class PulseStatsRow extends StatelessWidget {
  const PulseStatsRow({required this.stats, super.key});

  final List<PulseStat> stats;

  @override
  Widget build(BuildContext context) {
    final gap = context.tokens.spacingSm + 2;

    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(child: _PulseTile(stat: stats[i])),
        ],
      ],
    );
  }
}

class _PulseTile extends StatelessWidget {
  const _PulseTile({required this.stat});

  final PulseStat stat;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final radius = BorderRadius.circular(tokens.radiusLg);

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: stat.onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: scheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(stat.value, style: textTheme.headlineSmall),
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: stat.color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(tokens.radiusSm + 2),
                    ),
                    child: Icon(stat.icon, size: 18, color: stat.color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
