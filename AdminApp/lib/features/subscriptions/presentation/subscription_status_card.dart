import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_admin/features/subscriptions/presentation/subscription_providers.dart';

class SubscriptionStatusCard extends ConsumerWidget {
  const SubscriptionStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(mySubscriptionProvider);

    return subscriptionAsync.when(
      data: (subscription) {
        if (subscription == null) return const SizedBox.shrink();
        final daysLeft = DateTime.parse(subscription.expiryDate)
            .difference(DateTime.now())
            .inDays;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  subscription.plan[0].toUpperCase() +
                      subscription.plan.substring(1),
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Member limit: ${subscription.memberLimit}'),
                Text(
                  'Expires: ${DateFormat.yMMMd().format(DateTime.parse(subscription.expiryDate))}',
                ),
                if (daysLeft <= 14)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      daysLeft < 0
                          ? 'Subscription expired'
                          : 'Expires in $daysLeft days',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
