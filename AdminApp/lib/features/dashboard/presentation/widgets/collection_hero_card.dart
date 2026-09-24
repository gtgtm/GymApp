import 'package:flutter/material.dart';

import 'package:gymapp_admin/core/theme/app_tokens.dart';
import 'package:gymapp_admin/features/dashboard/domain/dashboard_models.dart';
import 'package:gymapp_admin/features/dashboard/presentation/widgets/dashboard_format.dart';

/// The headline money card: today's collection up top, month-to-date
/// revenue and today's new members below a hairline divider.
class CollectionHeroCard extends StatelessWidget {
  const CollectionHeroCard({required this.summary, super.key});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final radius = BorderRadius.circular(tokens.radiusXl);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              scheme.primary.withValues(alpha: 0.22),
              scheme.surfaceContainerHighest,
            ),
            scheme.surface,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingLg - 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Collected today',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: tokens.spacingXs),
            Text(
              formatRupees(summary.todaysRevenue),
              style: textTheme.displaySmall?.copyWith(
                color: scheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: tokens.spacingXs),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: formatRupees(summary.pendingPayments),
                    style: TextStyle(
                      color: tokens.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' still pending'),
                ],
              ),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spacingMd),
              child: Divider(height: 1, color: scheme.outline),
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _HeroMetric(
                      label: 'This month',
                      value: formatRupees(summary.monthlyRevenue),
                    ),
                  ),
                  VerticalDivider(width: 1, color: scheme.outline),
                  SizedBox(width: tokens.spacingMd),
                  Expanded(
                    child: _HeroMetric(
                      label: 'New members today',
                      value: '${summary.todaysNewMembers}',
                      accent: scheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value, this.accent});

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            color: accent ?? scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
