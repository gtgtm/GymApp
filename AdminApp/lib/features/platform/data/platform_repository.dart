import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/platform/domain/platform_models.dart';

class PlatformRepository {
  PlatformRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<GymSummary>> gyms() {
    return unwrap(
      () => _apiClient.dio.get('/platform/gyms'),
      (data) => (data as List<dynamic>)
          .map((json) => GymSummary.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<GymDetail> gym(int id) {
    return unwrap(
      () => _apiClient.dio.get('/platform/gyms/$id'),
      (data) => GymDetail.fromJson(data as Map<String, dynamic>),
    );
  }
}
