import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_admin/core/api/api_exception.dart';
import 'package:gymapp_admin/core/theme/app_tokens.dart';
import 'package:gymapp_admin/features/member_portal/domain/member_portal_models.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_portal_providers.dart';
import 'package:gymapp_admin/features/members/domain/member_models.dart';
import 'package:gymapp_admin/features/members/presentation/expiry_badge.dart';

/// Days left on the membership, with the plan, dates, trainer, and a
/// renewal request. Mirrors the staff dashboard's hero card styling.
class MembershipHeroCard extends StatelessWidget {
  const MembershipHeroCard({
    required this.details,
    required this.trainerName,
    super.key,
  });

  final MembershipDetails details;
  final String? trainerName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final current = details.current;
    final daysLeft = current?.daysRemaining(DateTime.now());
    final isExpired = daysLeft == null || daysLeft < 0;
    final dateFormat = DateFormat('d MMM yyyy');
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
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingLg - 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    current?.planName ?? 'Membership',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ExpiryBadge(bucket: details.expiryBucket),
              ],
            ),
            SizedBox(height: tokens.spacingXs),
            Text(
              switch (daysLeft) {
                null => 'No active plan',
                < 0 => 'Expired',
                0 => 'Ends today',
                1 => '1 day left',
                _ => '$daysLeft days left',
              },
              style: textTheme.displaySmall?.copyWith(
                color: isExpired ? scheme.error : scheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            if (current != null) ...[
              SizedBox(height: tokens.spacingXs),
              Text(
                '${isExpired ? 'Ended' : 'Ends'} '
                '${dateFormat.format(current.endDate)}',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spacingMd),
              child: Divider(height: 1, color: scheme.outline),
            ),
            Row(
              children: [
                Expanded(
                  child: _Meta(
                    label: 'Started',
                    value: current == null
                        ? '—'
                        : dateFormat.format(current.startDate),
                  ),
                ),
                Expanded(
                  child: _Meta(label: 'Trainer', value: trainerName ?? '—'),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingMd),
            _RenewalButton(
              emphasized:
                  details.expiryBucket != ExpiryBucket.green || isExpired,
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label, required this.value});

  final String label;
  final String value;

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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleSmall,
        ),
      ],
    );
  }
}

/// Sends a renewal request to the gym's admins/receptionists. Filled when
/// the membership is expiring or expired, tonal otherwise.
class _RenewalButton extends ConsumerStatefulWidget {
  const _RenewalButton({required this.emphasized});

  final bool emphasized;

  @override
  ConsumerState<_RenewalButton> createState() => _RenewalButtonState();
}

class _RenewalButtonState extends ConsumerState<_RenewalButton> {
  bool _isSending = false;

  Future<void> _send() async {
    setState(() => _isSending = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(memberPortalRepositoryProvider).requestRenewal();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Renewal request sent. Gym staff will contact you.'),
        ),
      );
    } on ApiException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _isSending
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Text('Request renewal');
    final onPressed = _isSending ? null : _send;

    return SizedBox(
      width: double.infinity,
      child: widget.emphasized
          ? FilledButton(onPressed: onPressed, child: child)
          : OutlinedButton(onPressed: onPressed, child: child),
    );
  }
}
