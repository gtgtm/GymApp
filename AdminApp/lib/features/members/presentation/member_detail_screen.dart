import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_admin/core/permissions/nav_permissions.dart';
import 'package:gymapp_admin/core/widgets/app_list_card.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/core/widgets/empty_state.dart';
import 'package:gymapp_admin/features/auth/presentation/acting_gym_controller.dart';
import 'package:gymapp_admin/features/diet/presentation/diet_tab.dart';
import 'package:gymapp_admin/features/members/domain/member_models.dart';
import 'package:gymapp_admin/features/members/presentation/expiry_badge.dart';
import 'package:gymapp_admin/features/members/presentation/member_providers.dart';
import 'package:gymapp_admin/features/members/presentation/renew_membership_sheet.dart';
import 'package:gymapp_admin/features/progress/presentation/progress_tab.dart';
import 'package:gymapp_admin/features/workouts/presentation/workout_tab.dart';

class MemberDetailScreen extends ConsumerWidget {
  const MemberDetailScreen({required this.memberId, super.key});

  final int memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberDetailProvider(memberId));

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: AsyncValueView(
            value: memberAsync,
            builder: (context, member) => Text(member.fullName),
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Membership'),
              Tab(text: 'Payments'),
              Tab(text: 'Workout'),
              Tab(text: 'Diet'),
              Tab(text: 'Progress'),
            ],
          ),
        ),
        body: AsyncValueView(
          value: memberAsync,
          onRetry: () => ref.invalidate(memberDetailProvider(memberId)),
          builder: (context, member) => TabBarView(
            children: [
              _OverviewTab(member: member),
              _MembershipTab(member: member),
              _PaymentsTab(memberId: memberId),
              WorkoutTab(memberId: memberId),
              DietTab(memberId: memberId),
              ProgressTab(memberId: memberId),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoRow(label: 'Member Code', value: member.memberCode),
        _InfoRow(label: 'Mobile', value: member.mobile),
        _InfoRow(label: 'Email', value: member.email ?? '—'),
        _InfoRow(label: 'Date of Birth', value: member.dateOfBirth ?? '—'),
        _InfoRow(label: 'Gender', value: member.gender ?? '—'),
        _InfoRow(label: 'Address', value: member.address ?? '—'),
        _InfoRow(
          label: 'Emergency Contact',
          value: member.emergencyContactName ?? '—',
        ),
        _InfoRow(
          label: 'Emergency Phone',
          value: member.emergencyContactPhone ?? '—',
        ),
        _InfoRow(label: 'Joining Date', value: member.joiningDate),
        _InfoRow(label: 'Trainer', value: member.trainer?.name ?? '—'),
        _InfoRow(label: 'Height (cm)', value: member.heightCm ?? '—'),
        _InfoRow(label: 'Weight (kg)', value: member.weightKg ?? '—'),
        _InfoRow(label: 'Blood Group', value: member.bloodGroup ?? '—'),
        _InfoRow(label: 'Notes', value: member.notes ?? '—'),
      ],
    );
  }
}

class _MembershipTab extends ConsumerWidget {
  const _MembershipTab({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canRenew = canPerform(
      ref.watch(actingRoleNameProvider),
      StaffAction.renewMembership,
    );
    final membership = member.currentMembership;
    final dateFormat = DateFormat.yMMMd();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Membership',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ExpiryBadge(bucket: member.expiryBucket),
          ],
        ),
        const SizedBox(height: 12),
        if (membership == null)
          const Text('No active membership.')
        else ...[
          _InfoRow(
            label: 'Start Date',
            value: DateFormat('yyyy-MM-dd')
                .parse(membership.startDate)
                .let(dateFormat.format),
          ),
          _InfoRow(
            label: 'End Date',
            value: DateFormat('yyyy-MM-dd')
                .parse(membership.endDate)
                .let(dateFormat.format),
          ),
          _InfoRow(label: 'Status', value: membership.status),
        ],
        if (canRenew) ...[
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => showRenewMembershipSheet(context, member.id),
            icon: const Icon(Icons.autorenew),
            label: const Text('Renew Membership'),
          ),
        ],
      ],
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab({required this.memberId});

  final int memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(memberPaymentsProvider(memberId));
    final dateFormat = DateFormat.yMMMd();

    return AsyncValueView(
      value: paymentsAsync,
      onRetry: () => ref.invalidate(memberPaymentsProvider(memberId)),
      builder: (context, payments) {
        if (payments.isEmpty) {
          return const EmptyState(
            icon: Icons.payments_outlined,
            message: 'No payments recorded yet.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
            return AppListCard(
              title: Text('₹${payment.amount}'),
              subtitle: Text('${payment.receiptNumber} · ${payment.method}'),
              trailing: Text(
                dateFormat.format(DateTime.parse(payment.paidAt)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          },
        );
      },
    );
  }
}
