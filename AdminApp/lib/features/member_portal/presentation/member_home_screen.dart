import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_admin/core/theme/app_tokens.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/features/auth/presentation/acting_gym_controller.dart';
import 'package:gymapp_admin/features/auth/presentation/auth_controller.dart';
import 'package:gymapp_admin/features/dashboard/presentation/quick_actions.dart';
import 'package:gymapp_admin/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:gymapp_admin/features/dashboard/presentation/widgets/dashboard_sections.dart';
import 'package:gymapp_admin/features/dashboard/presentation/widgets/pulse_stats_row.dart';
import 'package:gymapp_admin/features/member_portal/domain/member_portal_models.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_portal_providers.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_shell.dart';
import 'package:gymapp_admin/features/member_portal/presentation/widgets/membership_hero_card.dart';

const _visitWindowDays = 30;
const _recentVisitCount = 5;

class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final actingGym = ref.watch(actingGymControllerProvider);
    final membershipAsync = ref.watch(myMembershipProvider);
    final topInset = MediaQuery.paddingOf(context).top;

    Future<void> refresh() async {
      ref
        ..invalidate(myMembershipProvider)
        ..invalidate(myProfileProvider)
        ..invalidate(myAttendanceProvider)
        ..invalidate(myWorkoutPlansProvider)
        ..invalidate(myProgressProvider);
      await ref.read(myMembershipProvider.future);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 12),
          child: _MemberHeader(
            gymName: actingGym?.name ?? '',
            userName: user?.name ?? '',
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
              child: AsyncValueView(
                value: membershipAsync,
                onRetry: () => ref.invalidate(myMembershipProvider),
                builder: (context, details) => _HomeBody(details: details),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MemberHeader extends StatelessWidget {
  const _MemberHeader({required this.gymName, required this.userName});

  final String gymName;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final firstName = userName.split(' ').first;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DateFormat('EEE · d MMMM').format(DateTime.now())}'
                '${gymName.isEmpty ? '' : ' · $gymName'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Hi, $firstName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        HeaderButton(
          tooltip: 'Notifications',
          onTap: () => context.go(MemberRoutes.notifications),
          child: Icon(
            Icons.notifications_none_rounded,
            color: scheme.onSurface,
            size: 22,
          ),
        ),
        SizedBox(width: context.tokens.spacingSm),
        HeaderButton(
          tooltip: 'Profile',
          filled: true,
          onTap: () => context.go(MemberRoutes.profile),
          child: Text(
            userName.isEmpty ? '?' : userName[0].toUpperCase(),
            style: textTheme.titleMedium?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.details});

  final MembershipDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final profile = ref.watch(myProfileProvider).value;
    final attendance = ref.watch(myAttendanceProvider).value ?? const [];
    final plans = ref.watch(myWorkoutPlansProvider).value ?? const [];
    final progress = ref.watch(myProgressProvider).value;

    final since = DateTime.now().subtract(
      const Duration(days: _visitWindowDays),
    );
    final recentVisits = attendance.where((r) => r.date.isAfter(since)).length;
    final workoutDays = plans.isEmpty ? 0 : plans.first.days.length;
    final latestWeight = progress == null || progress.measurements.isEmpty
        ? null
        : progress.measurements.last.weightKg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MembershipHeroCard(details: details, trainerName: profile?.trainerName),
        const SizedBox(height: 14),
        PulseStatsRow(
          stats: [
            PulseStat(
              label: 'Visits · 30d',
              value: '$recentVisits',
              icon: Icons.event_available_outlined,
              color: tokens.success,
              onTap: () => context.go(MemberRoutes.qr),
            ),
            PulseStat(
              label: 'Workout days',
              value: '$workoutDays',
              icon: Icons.fitness_center_outlined,
              color: tokens.info,
              onTap: () => context.go(MemberRoutes.workout),
            ),
            PulseStat(
              label: 'Weight',
              value: latestWeight == null
                  ? '—'
                  : '${latestWeight.toStringAsFixed(1)}kg',
              icon: Icons.monitor_weight_outlined,
              color: tokens.warning,
              onTap: () => context.go(MemberRoutes.progress),
            ),
          ],
        ),
        const SizedBox(height: 14),
        QuickActionsCard(
          items: [
            QuickActionItem(
              label: 'My QR',
              icon: Icons.qr_code_2_rounded,
              onTap: () => context.go(MemberRoutes.qr),
            ),
            QuickActionItem(
              label: 'Workout',
              icon: Icons.fitness_center_outlined,
              onTap: () => context.go(MemberRoutes.workout),
            ),
            QuickActionItem(
              label: 'Diet',
              icon: Icons.restaurant_outlined,
              onTap: () => context.go(MemberRoutes.diet),
            ),
            QuickActionItem(
              label: 'Progress',
              icon: Icons.show_chart,
              onTap: () => context.go(MemberRoutes.progress),
            ),
          ],
        ),
        const SizedBox(height: 22),
        DashboardSectionHeader(
          title: 'Recent visits',
          onSeeAll: attendance.isEmpty
              ? null
              : () => context.go(MemberRoutes.qr),
        ),
        if (attendance.isEmpty)
          const DashboardEmptyCard(
            icon: Icons.how_to_reg_outlined,
            message: 'No check-ins yet. Show your QR code at the front desk.',
          )
        else
          for (final record in attendance.take(_recentVisitCount))
            _VisitTile(record: record),
      ],
    );
  }
}

class _VisitTile extends StatelessWidget {
  const _VisitTile({required this.record});

  final MemberAttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final time = record.checkInTime == null || record.checkInTime!.length < 5
        ? ''
        : record.checkInTime!.substring(0, 5);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: tokens.success, size: 20),
          SizedBox(width: tokens.spacingSm + 4),
          Expanded(
            child: Text(
              DateFormat('EEE, d MMM').format(record.date),
              style: textTheme.titleSmall,
            ),
          ),
          Text(
            time,
            style: textTheme.bodySmall?.copyWith(color: scheme.secondary),
          ),
        ],
      ),
    );
  }
}
