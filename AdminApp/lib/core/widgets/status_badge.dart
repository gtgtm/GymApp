import 'package:flutter/material.dart';

import 'package:gymapp_admin/core/theme/app_tokens.dart';

enum StatusTone { success, warning, danger, info, neutral }

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.label, required this.tone, super.key});

  final String label;
  final StatusTone tone;

  Color _toneColor(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return switch (tone) {
      StatusTone.success => tokens.success,
      StatusTone.warning => tokens.warning,
      StatusTone.danger => tokens.danger,
      StatusTone.info => tokens.info,
      StatusTone.neutral => scheme.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _toneColor(context);
    final radius = context.tokens.radiusSm;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
