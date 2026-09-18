import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/subscriptions/domain/subscription_models.dart';

class SubscriptionRepository {
  SubscriptionRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Subscription?> mine() {
    return unwrap(
      () => _apiClient.dio.get('/subscriptions/mine'),
      (data) => data == null
          ? null
          : Subscription.fromJson(data as Map<String, dynamic>),
    );
  }
}
