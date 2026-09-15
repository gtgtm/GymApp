import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/api_providers.dart';
import 'package:gymapp_admin/features/subscriptions/data/subscription_repository.dart';
import 'package:gymapp_admin/features/subscriptions/domain/subscription_models.dart';

part 'subscription_providers.g.dart';

@riverpod
SubscriptionRepository subscriptionRepository(Ref ref) {
  return SubscriptionRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
Future<Subscription?> mySubscription(Ref ref) {
  return ref.watch(subscriptionRepositoryProvider).mine();
}
