import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gymapp_admin/core/api/acting_gym.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/core/widgets/empty_state.dart';
import 'package:gymapp_admin/features/auth/domain/gym_membership.dart';
import 'package:gymapp_admin/features/auth/presentation/auth_controller.dart';
import 'package:gymapp_admin/features/auth/presentation/my_gyms_providers.dart';
import 'package:gymapp_admin/features/platform/presentation/acting_gym_controller.dart';

/// Picker for a regular (non-super_admin) multi-gym login: which of their
/// OWN memberships to act as. Distinct from GymsScreen, which is the
/// super_admin's cross-tenant gym directory — this only ever shows gyms
/// this specific login actually belongs to.
class MyGymsScreen extends ConsumerWidget {
  const MyGymsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myGymsAsync = ref.watch(myGymsProvider);
    final pendingGymsAsync = ref.watch(pendingGymsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Gyms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: AsyncValueView(
        value: myGymsAsync,
        onRetry: () => ref.invalidate(myGymsProvider),
        builder: (context, memberships) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myGymsProvider);
              ref.invalidate(pendingGymsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (memberships.isEmpty)
                  const EmptyState(
                    icon: Icons.storefront_outlined,
                    message: 'You are not a member of any gym yet.',
                  )
                else
                  for (final membership in memberships) ...[
                    _MembershipCard(membership: membership),
                    const SizedBox(height: 12),
                  ],
                pendingGymsAsync.maybeWhen(
                  data: (pending) => pending.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pending invitations',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              for (final membership in pending) ...[
                                _PendingMembershipCard(membership: membership),
                                const SizedBox(height: 12),
                              ],
                            ],
                          ),
                        ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MembershipCard extends ConsumerWidget {
  const _MembershipCard({required this.membership});

  final GymMembership membership;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    membership.gymName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    membership.roleLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () {
                ref
                    .read(actingGymControllerProvider.notifier)
                    .enter(
                      ActingGym(id: membership.gymId, name: membership.gymName),
                    );
                context.go('/dashboard');
              },
              child: const Text('Enter'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingMembershipCard extends ConsumerWidget {
  const _PendingMembershipCard({required this.membership});

  final GymMembership membership;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    membership.gymName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Invited as ${membership.roleLabel}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await ref
                      .read(authRepositoryProvider)
                      .acceptMembership(membership.id);
                  ref.invalidate(myGymsProvider);
                  ref.invalidate(pendingGymsProvider);
                } on Exception catch (error) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(error.toString())),
                  );
                }
              },
              child: const Text('Accept'),
            ),
          ],
        ),
      ),
    );
  }
}
