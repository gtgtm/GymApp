import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/diet/domain/diet_models.dart';

class DietRepository {
  DietRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<DietPlan>> list(int memberId) {
    return unwrap(
      () => _apiClient.dio.get('/diet-plans', queryParameters: {'member_id': memberId}),
      (data) =>
          (data as List<dynamic>).map((json) => DietPlan.fromJson(json as Map<String, dynamic>)).toList(),
    );
  }

  Future<DietPlan> create(DietPlanInput input) {
    return unwrap(
      () => _apiClient.dio.post('/diet-plans', data: input.toJson()),
      (data) => DietPlan.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> delete(int id) {
    return unwrap(() => _apiClient.dio.delete('/diet-plans/$id'), (_) => null);
  }
}
