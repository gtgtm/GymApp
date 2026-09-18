import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gymapp_admin/core/api/acting_gym.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/core/widgets/empty_state.dart';
import 'package:gymapp_admin/core/widgets/status_badge.dart';
import 'package:gymapp_admin/features/auth/presentation/auth_controller.dart';
import 'package:gymapp_admin/features/platform/domain/platform_models.dart';
import 'package:gymapp_admin/features/platform/presentation/acting_gym_controller.dart';
import 'package:gymapp_admin/features/platform/presentation/platform_providers.dart';

class GymsScreen extends ConsumerWidget {
  const GymsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymsAsync = ref.watch(gymListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gyms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: AsyncValueView(
        value: gymsAsync,
        onRetry: () => ref.invalidate(gymListProvider),
        builder: (context, gyms) {
          if (gyms.isEmpty) {
            return const EmptyState(
              icon: Icons.storefront_outlined,
              message: 'No gyms yet.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(gymListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: gyms.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _GymCard(gym: gyms[index]),
            ),
          );
        },
      ),
    );
  }
}

class _GymCard extends ConsumerWidget {
  const _GymCard({required this.gym});

  final GymSummary gym;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = gym.subscription;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    gym.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                StatusBadge(
                  label: gym.status,
                  tone: gym.status == 'active'
                      ? StatusTone.success
                      : StatusTone.danger,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${gym.membersCount} members'),
            if (subscription != null) ...[
              const SizedBox(height: 4),
              Text(
                '${subscription.plan[0].toUpperCase()}${subscription.plan.substring(1)} plan · '
                '${subscription.paymentStatus}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Enter as Admin'),
                onPressed: () {
                  ref
                      .read(actingGymControllerProvider.notifier)
                      .enter(ActingGym(id: gym.id, name: gym.name));
                  context.go('/dashboard');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
