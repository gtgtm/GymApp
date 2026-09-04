import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_member/core/api/repository_providers.dart';
import 'package:gymapp_member/core/widgets/async_value_view.dart';
import 'package:gymapp_member/core/widgets/expiry_badge.dart';
import 'package:gymapp_member/features/auth/presentation/auth_controller.dart';
import 'package:gymapp_member/features/membership/domain/membership_models.dart';
import 'package:gymapp_member/features/membership/presentation/membership_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(memberProfileProvider);
    final user = ref.watch(authControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.gymName ?? 'GymApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(memberProfileProvider);
          ref.invalidate(membershipDetailsProvider);
        },
        child: AsyncValueView(
          value: profileAsync,
          onRetry: () => ref.invalidate(memberProfileProvider),
          builder: (context, profile) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MembershipCard(profile: profile),
              const SizedBox(height: 16),
              _QuickActionsGrid(),
              const SizedBox(height: 16),
              _ExpiryNotice(profile: profile),
            ],
          ),
        ),
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    final endDate = profile.currentMembershipEnd;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  profile.fullName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                ExpiryBadge(bucket: profile.expiryBucket),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              profile.memberCode,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const Divider(height: 32),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  endDate != null
                      ? 'Membership valid until ${dateFormat.format(endDate)}'
                      : 'No active membership',
                ),
              ],
            ),
            if (profile.trainerName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Trainer: ${profile.trainerName}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  static const _actions = [
    ('/attendance', Icons.qr_code, 'My QR Code'),
    ('/progress', Icons.show_chart, 'Progress'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        for (final action in _actions)
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push(action.$1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(action.$2, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(action.$3, style: const TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ExpiryNotice extends ConsumerWidget {
  const _ExpiryNotice({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucket = profile.expiryBucket;
    if (bucket == ExpiryBucket.green) return const SizedBox.shrink();

    final message = switch (bucket) {
      ExpiryBucket.red => 'Your membership has expired. Renew now to continue using the gym.',
      _ => 'Your membership is expiring soon. Renew now to avoid interruption.',
    };

    return Card(
      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () async {
                final repository = ref.read(membershipRepositoryProvider);
                try {
                  await repository.requestRenewal();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Renewal request sent to gym staff.')),
                    );
                  }
                } on Exception catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                  }
                }
              },
              child: const Text('Request Renewal'),
            ),
          ],
        ),
      ),
    );
  }
}
