import 'package:gymapp_member/core/api/api_client.dart';
import 'package:gymapp_member/core/api/api_response.dart';
import 'package:gymapp_member/features/notifications/data/notification_models.dart';

class NotificationRepository {
  NotificationRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<MemberNotification>> myNotifications() {
    return unwrap(
      () => _apiClient.dio.get('/me/notifications'),
      (data) => (data as List<dynamic>)
          .map((item) => MemberNotification.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
