import 'package:flutter/material.dart';

import 'package:gymapp_admin/core/theme/app_tokens.dart';

enum StatTone { normal, success, warning, danger }

class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.tone = StatTone.normal,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final StatTone tone;
  final VoidCallback? onTap;

  Color _toneColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;
    return switch (tone) {
      StatTone.success => tokens.success,
      StatTone.warning => tokens.warning,
      StatTone.danger => scheme.error,
      StatTone.normal => scheme.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final toneColor = _toneColor(context);

    final content = Padding(
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
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              CircleAvatar(
                radius: 14,
                backgroundColor: toneColor.withValues(alpha: 0.14),
                child: Icon(icon, size: 16, color: toneColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return Card(child: content);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
