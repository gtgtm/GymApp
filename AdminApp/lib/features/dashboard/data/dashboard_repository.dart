import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/dashboard/domain/dashboard_models.dart';

class DashboardRepository {
  DashboardRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<DashboardData> fetch() {
    return unwrap(
      () => _apiClient.dio.get('/dashboard'),
      (data) => DashboardData.fromJson(data as Map<String, dynamic>),
    );
  }
}
