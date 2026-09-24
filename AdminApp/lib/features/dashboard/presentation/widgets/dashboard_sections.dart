import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gymapp_admin/core/theme/app_tokens.dart';
import 'package:gymapp_admin/features/attendance/domain/attendance_models.dart';
import 'package:gymapp_admin/features/attendance/presentation/attendance_providers.dart';
import 'package:gymapp_admin/features/dashboard/domain/dashboard_models.dart';
import 'package:gymapp_admin/features/dashboard/presentation/widgets/dashboard_format.dart';

const _upcomingWindowDays = 15;
const _upcomingPreviewCount = 3;
const _checkInPreviewCount = 8;

class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader({
    required this.title,
    this.count,
    this.onSeeAll,
    super.key,
  });

  final String title;
  final int? count;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(title, style: textTheme.titleMedium),
          if (count != null) ...[
            const SizedBox(width: 8),
            Text(
              '$count',
              style: textTheme.titleMedium?.copyWith(color: scheme.secondary),
            ),
          ],
          const Spacer(),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: scheme.secondary,
              ),
              child: const Text('See all'),
            ),
        ],
      ),
    );
  }
}

/// Muted placeholder card used when a section has nothing to show.
class DashboardEmptyCard extends StatelessWidget {
  const DashboardEmptyCard({
    required this.icon,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tokens.success.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: tokens.success),
          ),
          SizedBox(width: tokens.spacingMd),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Payment due today" + "Upcoming payments": memberships ending today,
/// then the next few ending within [_upcomingWindowDays].
class RenewalSections extends StatelessWidget {
  const RenewalSections({required this.renewals, super.key});

  final List<RenewalDue> renewals;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dueToday = renewals
        .where((renewal) => renewal.daysRemaining(today) == 0)
        .toList();
    final upcoming = renewals.where((renewal) {
      final days = renewal.daysRemaining(today);
      return days > 0 && days <= _upcomingWindowDays;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DashboardSectionHeader(title: 'Payment due today'),
        if (dueToday.isEmpty)
          const DashboardEmptyCard(
            icon: Icons.task_alt,
            message: 'No payments due today',
          )
        else
          for (final renewal in dueToday)
            _RenewalTile(renewal: renewal, today: today),
        const SizedBox(height: 20),
        DashboardSectionHeader(
          title: 'Upcoming payments',
          onSeeAll: upcoming.isEmpty
              ? null
              : () => context.go('/members?filter=expiring_soon'),
        ),
        if (upcoming.isEmpty)
          const DashboardEmptyCard(
            icon: Icons.event_available_outlined,
            message: 'Nothing due in the next two weeks',
          )
        else
          for (final renewal in upcoming.take(_upcomingPreviewCount))
            _RenewalTile(renewal: renewal, today: today),
      ],
    );
  }
}

class _RenewalTile extends StatelessWidget {
  const _RenewalTile({required this.renewal, required this.today});

  final RenewalDue renewal;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final days = renewal.daysRemaining(today);
    final dueColor = days <= 0 ? scheme.error : tokens.warning;
    final radius = BorderRadius.circular(tokens.radiusLg);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: () => context.push('/members/${renewal.memberId}'),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: scheme.outline),
            ),
            child: Row(
              children: [
                _InitialsAvatar(name: renewal.memberName),
                SizedBox(width: tokens.spacingSm + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        renewal.memberName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dueLabel(days),
                        style: textTheme.bodySmall?.copyWith(
                          color: dueColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => context.go('/payments?new=1'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    // The theme's FilledButton is full-width (infinite
                    // minimum width), which a Row can't lay out.
                    minimumSize: const Size(0, 40),
                  ),
                  child: const Text('Collect'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name, this.size = 44});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(context.tokens.radiusMd),
        border: Border.all(color: scheme.outline),
      ),
      child: Text(
        initialsOf(name),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// "In today": who has checked in so far, as a horizontal strip.
class TodayCheckIns extends ConsumerWidget {
  const TodayCheckIns({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(todaysAttendanceProvider).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardSectionHeader(
          title: 'In today',
          count: entries.length,
          onSeeAll: () => context.go('/attendance'),
        ),
        if (entries.isEmpty)
          const DashboardEmptyCard(
            icon: Icons.how_to_reg_outlined,
            message: 'No check-ins today',
          )
        else
          SizedBox(
            height: 96,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: entries.length.clamp(0, _checkInPreviewCount),
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) =>
                  _CheckInChip(entry: entries[index]),
            ),
          ),
      ],
    );
  }
}

class _CheckInChip extends StatelessWidget {
  const _CheckInChip({required this.entry});

  final AttendanceEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final name = entry.member?.fullName ?? 'Member';
    // check_in_time is "HH:mm:ss"; show "HH:mm".
    final time = entry.checkInTime == null || entry.checkInTime!.length < 5
        ? ''
        : entry.checkInTime!.substring(0, 5);

    return Container(
      width: 88,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.tokens.radiusLg),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        children: [
          _InitialsAvatar(name: name, size: 36),
          const SizedBox(height: 6),
          Text(
            name.split(' ').first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium,
          ),
          Text(
            time,
            style: textTheme.labelSmall?.copyWith(color: scheme.secondary),
          ),
        ],
      ),
    );
  }
}
