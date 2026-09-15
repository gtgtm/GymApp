import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/features/auth/presentation/auth_controller.dart';
import 'package:gymapp_admin/features/dashboard/domain/dashboard_models.dart';
import 'package:gymapp_admin/features/dashboard/presentation/dashboard_providers.dart';
import 'package:gymapp_admin/features/dashboard/presentation/quick_actions.dart';
import 'package:gymapp_admin/features/dashboard/presentation/stat_card.dart';
import 'package:gymapp_admin/features/subscriptions/presentation/subscription_status_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(dashboardDataProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: AsyncValueView(
          value: dashboardAsync,
          onRetry: () => ref.invalidate(dashboardDataProvider),
          builder: (context, data) => switch (user?.roleName) {
            'trainer' => _TrainerDashboard(summary: data.summary),
            'receptionist' => _ReceptionistDashboard(summary: data.summary),
            _ => _AdminDashboard(summary: data.summary),
          },
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: children,
    );
  }
}

String _currency(double value) => '₹${value.toStringAsFixed(0)}';

class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QuickActions(),
        const SizedBox(height: 20),
        _StatGrid(
          children: [
            StatCard(label: 'Total Members', value: '${summary.totalMembers}', icon: Icons.people_outline),
            StatCard(
              label: 'Active Members',
              value: '${summary.activeMembers}',
              icon: Icons.verified_user_outlined,
              tone: StatTone.success,
            ),
            StatCard(
              label: 'Expired',
              value: '${summary.expiredMemberships}',
              icon: Icons.event_busy_outlined,
              tone: StatTone.danger,
            ),
            StatCard(
              label: 'Expiring Soon',
              value: '${summary.expiringSoon}',
              icon: Icons.hourglass_bottom_outlined,
              tone: StatTone.warning,
            ),
            StatCard(
              label: "Today's Attendance",
              value: '${summary.todaysAttendance}',
              icon: Icons.event_available_outlined,
            ),
            StatCard(
              label: "Today's New Members",
              value: '${summary.todaysNewMembers}',
              icon: Icons.person_add_alt_outlined,
            ),
            StatCard(
              label: "Today's Revenue",
              value: _currency(summary.todaysRevenue),
              icon: Icons.currency_rupee,
              tone: StatTone.success,
            ),
            StatCard(
              label: 'Monthly Revenue',
              value: _currency(summary.monthlyRevenue),
              icon: Icons.trending_up,
              tone: StatTone.success,
            ),
            StatCard(
              label: 'Pending Payments',
              value: _currency(summary.pendingPayments),
              icon: Icons.account_balance_wallet_outlined,
              tone: StatTone.warning,
            ),
            StatCard(
              label: 'Net Profit (Month)',
              value: _currency(summary.monthlyNetProfit),
              icon: Icons.show_chart,
              tone: summary.monthlyNetProfit >= 0 ? StatTone.success : StatTone.danger,
            ),
            StatCard(
              label: 'New Enquiries',
              value: '${summary.newEnquiries}',
              icon: Icons.person_search_outlined,
            ),
            StatCard(
              label: 'Active Trainers',
              value: '${summary.activeTrainers}',
              icon: Icons.fitness_center_outlined,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const SubscriptionStatusCard(),
      ],
    );
  }
}

class _ReceptionistDashboard extends StatelessWidget {
  const _ReceptionistDashboard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QuickActions(exclude: ['/plans?new=1', '/expenses?new=1']),
        const SizedBox(height: 20),
        _StatGrid(
          children: [
            StatCard(label: 'Total Members', value: '${summary.totalMembers}', icon: Icons.people_outline),
            StatCard(
              label: 'Active Members',
              value: '${summary.activeMembers}',
              icon: Icons.verified_user_outlined,
              tone: StatTone.success,
            ),
            StatCard(
              label: 'Expiring Soon',
              value: '${summary.expiringSoon}',
              icon: Icons.hourglass_bottom_outlined,
              tone: StatTone.warning,
            ),
            StatCard(
              label: "Today's Attendance",
              value: '${summary.todaysAttendance}',
              icon: Icons.event_available_outlined,
            ),
            StatCard(
              label: "Today's New Members",
              value: '${summary.todaysNewMembers}',
              icon: Icons.person_add_alt_outlined,
            ),
            StatCard(
              label: 'Expired',
              value: '${summary.expiredMemberships}',
              icon: Icons.event_busy_outlined,
              tone: StatTone.danger,
            ),
            StatCard(
              label: 'New Enquiries',
              value: '${summary.newEnquiries}',
              icon: Icons.person_search_outlined,
            ),
          ],
        ),
      ],
    );
  }
}

class _TrainerDashboard extends ConsumerWidget {
  const _TrainerDashboard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome, ${user?.name ?? ''}', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          user?.roleLabel ?? 'Trainer',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 20),
        const QuickActions(
          exclude: ['/payments?new=1', '/plans?new=1', '/enquiries?new=1', '/expenses?new=1'],
        ),
        const SizedBox(height: 20),
        _StatGrid(
          children: [
            StatCard(
              label: "Today's Attendance",
              value: '${summary.todaysAttendance}',
              icon: Icons.event_available_outlined,
            ),
            StatCard(
              label: 'Active Trainers',
              value: '${summary.activeTrainers}',
              icon: Icons.fitness_center_outlined,
            ),
          ],
        ),
      ],
    );
  }
}
