import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_member/core/widgets/app_list_card.dart';
import 'package:gymapp_member/core/widgets/async_value_view.dart';
import 'package:gymapp_member/core/widgets/empty_state.dart';
import 'package:gymapp_member/features/notifications/presentation/notifications_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(myNotificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myNotificationsProvider),
        child: AsyncValueView(
          value: notificationsAsync,
          onRetry: () => ref.invalidate(myNotificationsProvider),
          builder: (context, notifications) {
            if (notifications.isEmpty) {
              return const EmptyState(
                icon: Icons.notifications_none,
                message: 'No notifications yet.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final scheme = Theme.of(context).colorScheme;
                return AppListCard(
                  leading: Icon(
                    notification.isUnread
                        ? Icons.circle
                        : Icons.circle_outlined,
                    size: 12,
                    color: notification.isUnread
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isUnread
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (notification.body != null) Text(notification.body!),
                      Text(
                        DateFormat.yMMMd().add_jm().format(
                          notification.createdAt,
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
