import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gymapp_admin/core/permissions/nav_permissions.dart';
import 'package:gymapp_admin/core/theme/app_tokens.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/core/widgets/stat_card.dart';
import 'package:gymapp_admin/features/attendance/presentation/attendance_providers.dart';
import 'package:gymapp_admin/features/auth/presentation/acting_gym_controller.dart';
import 'package:gymapp_admin/features/auth/presentation/auth_controller.dart';
import 'package:gymapp_admin/features/dashboard/domain/dashboard_models.dart';
import 'package:gymapp_admin/features/dashboard/presentation/dashboard_providers.dart';
import 'package:gymapp_admin/features/dashboard/presentation/quick_actions.dart';
import 'package:gymapp_admin/features/dashboard/presentation/widgets/collection_hero_card.dart';
import 'package:gymapp_admin/features/dashboard/presentation/widgets/dashboard_format.dart';
import 'package:gymapp_admin/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:gymapp_admin/features/dashboard/presentation/widgets/dashboard_sections.dart';
import 'package:gymapp_admin/features/dashboard/presentation/widgets/pulse_stats_row.dart';
import 'package:gymapp_admin/features/subscriptions/presentation/subscription_status_card.dart';

const _sectionGap = 22.0;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final actingGym = ref.watch(actingGymControllerProvider);
    final roleName = ref.watch(actingRoleNameProvider);
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final gymName = actingGym?.name ?? user?.soleMembership?.gymName ?? '';
    final topInset = MediaQuery.paddingOf(context).top;

    Future<void> refresh() async {
      ref
        ..invalidate(dashboardDataProvider)
        ..invalidate(todaysAttendanceProvider);
      await ref.read(dashboardDataProvider.future);
    }

    // The header stays pinned; only the content below it scrolls.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 12),
          child: DashboardHeader(gymName: gymName, userName: user?.name ?? ''),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
              child: AsyncValueView(
                value: dashboardAsync,
                onRetry: () => ref.invalidate(dashboardDataProvider),
                builder: (context, data) =>
                    _DashboardBody(data: data, roleName: roleName),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data, required this.roleName});

  final DashboardData data;
  final String? roleName;

  @override
  Widget build(BuildContext context) {
    final summary = data.summary;
    final canSeePayments = canAccessNav(roleName, NavKey.payments);
    final isAdmin = roleName == 'admin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canSeePayments) ...[
          CollectionHeroCard(summary: summary),
          const SizedBox(height: 14),
        ],
        _PulseRow(summary: summary),
        const SizedBox(height: 14),
        QuickActions(roleName: roleName),
        const SizedBox(height: _sectionGap),
        if (canSeePayments) ...[
          RenewalSections(renewals: data.renewals),
          const SizedBox(height: _sectionGap),
        ],
        const TodayCheckIns(),
        if (isAdmin) ...[
          const SizedBox(height: _sectionGap),
          _BusinessSnapshot(summary: summary),
          const SizedBox(height: _sectionGap),
          const SubscriptionStatusCard(),
        ],
      ],
    );
  }
}

class _PulseRow extends StatelessWidget {
  const _PulseRow({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return PulseStatsRow(
      stats: [
        PulseStat(
          label: 'Active',
          value: '${summary.activeMembers}',
          icon: Icons.groups_outlined,
          color: tokens.info,
          onTap: () => context.go('/members'),
        ),
        PulseStat(
          label: 'Check-ins',
          value: '${summary.todaysAttendance}',
          icon: Icons.event_available_outlined,
          color: tokens.success,
          onTap: () => context.go('/attendance'),
        ),
        PulseStat(
          label: 'Renewals',
          value: '${summary.expiringSoon}',
          icon: Icons.autorenew,
          color: tokens.warning,
          onTap: () => context.go('/members?filter=expiring_soon'),
        ),
      ],
    );
  }
}

/// Owner-only month view: the numbers that matter for running the
/// business rather than the front desk.
class _BusinessSnapshot extends StatelessWidget {
  const _BusinessSnapshot({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DashboardSectionHeader(title: 'This month'),
        GridView.count(
          // Without an explicit padding a GridView inherits the status-bar
          // inset (the dashboard has no AppBar to absorb it).
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            StatCard(
              label: 'Net profit',
              value: formatRupees(summary.monthlyNetProfit),
              icon: Icons.show_chart,
              tone: summary.monthlyNetProfit >= 0
                  ? StatTone.success
                  : StatTone.danger,
            ),
            StatCard(
              label: 'Expenses',
              value: formatRupees(summary.monthlyExpenses),
              icon: Icons.receipt_long_outlined,
              tone: StatTone.warning,
              onTap: () => context.go('/expenses'),
            ),
            StatCard(
              label: 'Expired',
              value: '${summary.expiredMemberships}',
              icon: Icons.event_busy_outlined,
              tone: StatTone.danger,
              onTap: () => context.go('/members?filter=expired'),
            ),
            StatCard(
              label: 'New enquiries',
              value: '${summary.newEnquiries}',
              icon: Icons.person_search_outlined,
              onTap: () => context.go('/enquiries'),
            ),
          ],
        ),
      ],
    );
  }
}
